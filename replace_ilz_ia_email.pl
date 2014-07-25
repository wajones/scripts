#!/usr/bin/env perl
#

use lib "/u/apps/leads2/current";
use lib "/u/apps/leads2/current/admin";

use Leads::DB;

my $db = Leads::DB->new( 'prod-leads' );

my $emails_to_change = $db->sqlSelectAll( "id, email", "email", "email like '%insuranceleadz.com'" );

foreach my $_email ( @$emails_to_change )
  {
    my $email = $_email->[1];
    my $id = $_email->[0];
    $email =~ s/insuranceleadz\.com/insuranceagents\.com/g;
    $email =~ s/\s+//g;

    print "$id\t$email\t";
    my $rc = $db->sqlUpdate( "email", { email => $email, }, "id = $id" );
    print ( $rc == 1 ) ? "Done\n" : "Failed\n";
  }
