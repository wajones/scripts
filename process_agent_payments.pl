#!/usr/bin/env perl

use warnings;
use strict;

use lib "/u/apps/leads2/current";
use lib "/u/apps/leads2/current/admin";

use Leads::DB;

my $dbh = Leads::DB->new( 'prod-accounting' );

open my $fh, '<', $ARGV[0];

while ( <$fh> )
  {
    chomp;
    my ( $agent_id, $amount, $date, $note_data ) = split ',', $_;
    $date =~ s/"//g;
    $note_data =~ s/"//g;
    my $note = "$note_data Invoice Payment";
    $dbh->sqlDo( "call agentPaymentReceived ( $agent_id, $amount, '$note', '$date', \@result )" );
    my $rc = $dbh->sqlSelect( '@result' );

    if ( $rc )
      {
        my $dbh1 = Leads::DB->new( 'prod-leads' );
        my $people_id = $dbh1->sqlSelect( 'people_id', 'agents', "id=$agent_id" );
        if ( defined $people_id && $people_id>0 )
          {
            my $payment = sprintf( "%.2f", $amount );
            $dbh1->sqlInsert( "notes", { people_id => $people_id,
                              poster_id => 0,
                              note_message => "Payment of \$$payment credited on $date",
                    } );
          }
      }

    ( $rc ) ? print "$note_data payment for $agent_id in the amount of $amount SUCCESSFUL\n" :
      print "$note_data payment for $agent_id FAILED\n";
  }

