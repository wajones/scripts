#!/usr/bin/env perl

use lib "/u/apps/leads2/current";
use lib "/u/apps/leads2/current/admin";

use Leads::Lead;
use Leads::DB;
use Leads::Utils;

use Data::Dumper;

my ( $sec, $min, $hour, $day, $month, $year, $wday, $yday, $isdst ) =
  localtime( time );
my $cur_date = sprintf "%d%02d%02d", $year + 1900, $month + 1, $day;

my $db = Leads::DB->new( 'bjones' );

my $six_months_ago = $db->sqlSelect( "date_sub(now(), interval 6 month)" );

my $start_time = substr( $six_months_ago, 0, 13 ) . ":00:00";
my $end_time   = substr( $six_months_ago, 0, 13 ) . ":59:59";

my $lead_ids = $db->sqlSelectAll(
    "lead_id",
    "lead_master",
    "status not like '%uplicate%' and
                                status not like '%bad%' and
                                received between '$start_time' and '$end_time'"
                                );

my $number_of_leads = scalar @$lead_ids;
my $interval        = int( 3000 / $number_of_leads );
$interval = 1;
my $vars;

foreach my $lead_id ( @$lead_ids )
  {
    my $xml = $db->sqlSelect( "xml", "lead_raw", "lead_id = $lead_id->[0]" );

    $vars->{a}   = 100055;
    $vars->{xml} = unscrubXMLData( $xml );
    $vars->{db}  = 'bjones';

    my $lead = Leads::Lead->new( $vars );
    $lead->parse;
    my $exp_date = $lead->{data}{policy_expires} || '2020-12-31';
    $exp_date =~ s/\-//g;
    if ( $exp_date < $cur_date && $lead->{data}{policy_expires} )
      {
        $lead->{data}{policy_expires} = $db->sqlSelect(
              "date_add( '$lead->{data}{policy_expires}', interval 6 month )" );
        $lead->{xml} =~
          s/policy_expires\>.+?\<\/policy_expires\>/policy_expires\>$lead->{data}{policy_expires}\<\/policy_expires\>/g;
      }

    $lead->saveRawLead;
    $lead->generateLeadHash;
    $lead->checkTargus;
    $lead->insertMasterLeadRecord;
    $lead->verifyRecord;
    $lead->checkPhonyData;
    $lead->applyConsistencyChecks;
    $lead->summarizeBadData;
    $lead->insertLead;
    $lead->recordApplicableFilters;

    unless ( $lead->{test} || $lead->{bad_data} )
      {
        $db->sqlInsert( "lead_processing_queue",
                        {  lead_id      => $lead->{lead_id},
                           lead_type_id => $lead->{lead_type_id},
                           zip_code     => $lead->{data}{zip},
                           status       => 'Processed',
                        } );
        print "Lead ID $lead->{lead_id} successful\n";
      }

    if ( $lead->{bad_data} )
      {
        print $lead->{lead_id} . "\n" . Dumper( $lead ) . "\n";
      }
    sleep $interval;
  }

