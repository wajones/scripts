#!/usr/bin/env perl

use strict;
use warnings;

use lib "/u/apps/leads2/current";
use lib "/u/apps/leads2/current/admin";

use LWP::UserAgent;
use Leads::DB;
use XML::Simple;

$|++;

my ( $fh_in, $fh_out, $agent_count, $agent_value );

if ( -e $ARGV[ 0 ] )
  {
    open $fh_in, '<', $ARGV[ 0 ] || die "Can't open file $ARGV[0]";
  }
else
  {
    print "Usage:\n\tpp_return.pl <file_name>\n\n";
    exit;
  }

open $fh_out, '>>', './pp_returns.csv';
die "Can't open output file\n" unless ( defined $fh_out );

my @lines = <$fh_in>;

my $db = Leads::DB->new( 'prod-slave' );
my $ua  = LWP::UserAgent->new;
my $url = 'https://leads.insuranceagents.com/return_lead';

foreach my $line ( @lines )
  {
    chomp($line);
    my @fields = split ',', $line;
    my $agent_email = $fields[2];
    $agent_email =~ s/"//g;
    next if ( $agent_email !~ /\@/ );
    my $lead_id = $fields[5];
    $lead_id =~ s/"//g;

    my ( $agent_id, $people_id ) = $db->sqlSelect( "a.id, a.people_id",
                                   "agents a left join people p on a.people_id=p.id
                                    left join email e on p.id=e.people_id",
                                   "e.email = '$agent_email'" );
    if ( $agent_id && $agent_id > 0 && $people_id && $people_id > 0 )
      {
        my $values;
        $values->{a}     = $agent_id;
        $values->{l}     = $lead_id;

        my $response = $ua->post( $url, $values );
        my $content = $response->content;
        $content =~ s/[\n\r]//g;
        my $data = XML::Simple->new()->XMLin( $content );
        my $status = ( $data->{status} eq 'Accepted' ) ? 'Completed' : 'Not Completed';
        print $fh_out "$line,$data->{amount},\"$status\"\n";
        print "$lead_id to $agent_id for $data->{amount} completed\n";
        if ( $status eq 'Completed' )
          {
            $agent_count->{$agent_id}++;
            $agent_value->{$agent_id} += $data->{amount};
          }
      }
  }

open my $summary, '>>', './pp_summary_csv';
foreach my $agent( keys %$agent_count )
  {
    print "$agent_count->{$agent},$agent_value->{$agent}\n";
    print $summary "$agent_count->{$agent},$agent_value->{$agent}\n" if ( defined $summary );
  }

close $fh_in;
close $fh_out;

