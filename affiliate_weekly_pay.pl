#!/usr/bin/env perl

use warnings;
use strict;

use lib "/u/apps/leads2/current";
use lib "/u/apps/leads2/current/admin";

use Leads::DB;

$|++;

my $db = Leads::DB->new( 'prod-leads' );

my ( $current_day, $current_month, $current_year, $day_of_week ) =
  ( localtime( time() ) )[ 3, 4, 5, 6 ];

my $start_date = '2011-12-01';
#  $db->sqlSelect( "date(date_sub(now(), interval $day_of_week+7 day))",
#                  "sequence_table" );
my $end_date = '2011-12-31'; #$db->sqlSelect( "date(date_add('$start_date', interval 7 day))",
                             #  "sequence_table" );
$start_date .= " 00:00:00";
$end_date   .= " 23:59:59";

my $affiliates_to_pay =
  $db->sqlSelectAll( "id, pay_method",
                     "affiliates",
                     "status='Active'" );

#print "\"Affiliate ID\",\"Period Earnings\"\n";

open FILE1, ">../data/affiliate_payments.csv" || die "Can't create file 1";
open FILE2, ">../data/affiliate_payment_notification.csv" || die "Can't create file 2";
open FILE3, ">../data/affiliate_payment_summary.csv" || die "Can't create file 3";

print FILE1 "\"Affiliate ID\",\"Total leads received\",\"Duplicate Leads\",\"Returned Leads\",\"Bad Leads\",\"Leads Beginning\",\"Leads Ending\",\"Payment Method\",\"Payment\"\n";
print FILE2 "\"Affiliate ID\",\"Tentative Payout Amount\",\"Email Address\"\n";
print FILE3 "\"Affiliate ID\",\"Payment\"\n";

foreach my $affiliate ( sort { $a->[0] <=> $b->[0] } @$affiliates_to_pay )
  {
    my $affiliate_id   = $affiliate->[ 0 ];
    my $payment_method = $affiliate->[ 1 ];

next unless ($affiliate_id);

    my $affiliate_email = $db->sqlSelect( "e.email", "affiliates a, email e", "a.people_id = e.people_id and a.id=$affiliate_id" );
    my $total_lead_count = $db->sqlCount(
        "lead_master",
        "affiliate_id = '$affiliate_id'
                                     and received > '$start_date'
                                     and received < '$end_date'" );
    $total_lead_count ||= 0;
    my $duplicate_lead_count = $db->sqlCount(
        "lead_master",
        "affiliate_id = '$affiliate_id'
                                     and received > '$start_date'
                                     and received < '$end_date'
                                     and status like '%Duplicate%'" );
    $duplicate_lead_count ||= 0;
    my $returned_lead_count = $db->sqlCount(
        "lead_master",
        "affiliate_id = '$affiliate_id'
                                     and received > '$start_date'
                                     and received < '$end_date'
                                     and status like '%returned%'" );
    $returned_lead_count ||= 0;
    my $bad_lead_count = $db->sqlCount(
        "lead_master",
        "affiliate_id = '$affiliate_id'
                                     and received > '$start_date'
                                     and received < '$end_date'
                                     and ( status like 'Rejected%' or status like '%Bad%' )"
                                      );
    $bad_lead_count ||= 0;
    my $period_earnings = $db->sqlSelect(
        "sum(lead_cost)",
        "lead_master",
        "affiliate_id = '$affiliate_id'
                                     and received > '$start_date'
                                     and received < '$end_date'" );
    next unless ( $period_earnings );
    $period_earnings = sprintf( "%.2f", $period_earnings );

    print FILE1 "$affiliate_id,$total_lead_count,$duplicate_lead_count,$returned_lead_count,$bad_lead_count,\"$start_date\",\"$end_date\",\"$payment_method\",\"$period_earnings\"\n";
    print FILE2 "$affiliate_id,\"$period_earnings\",\"$affiliate_email\"\n";
    print FILE3 "\"$affiliate_id\",\"$period_earnings\"\n";
  }

