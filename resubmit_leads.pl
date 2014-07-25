#!/usr/bin/env perl

use lib "/u/apps/leads2/current";
use lib "/u/apps/leads2/current/admin";

use Leads::Lead;
use Leads::DB;
use Leads::Utils;

use Data::Dumper;

my $db = Leads::DB->new( 'bjones' );
open my $fh, '<', '/tmp/lead_ids.txt';
open my $out, '>>', '/tmp/lead_ids_done.txt';

while ( <$fh> )
  {
    chomp;
    my ( $lead_type_id, $zip ) = $db->sqlSelect( "lead_type_id, zip",
                                                 "lead_master",
                                                 "lead_id = $_" );
    $db->sqlInsert( 'lead_processing_queue',
                    { lead_id => $_,
                      lead_type_id => $lead_type_id,
                      zip_code => $zip,
                      status => 'Pending' 
                    } );
    print $out "$_\n" if ( $out );
    sleep 20;

    my ( $sec, $min, $hour, $day, $month, $year, $wday, $yday, $isdst ) =
      localtime( time );
    while ( $hour < 8 || $hour > 20 ) { sleep 600; }
  }


