#!/usr/bin/env perl

use strict;
use warnings;
use lib "/u/apps/leads2/current";
use Leads::DB;
use Data::Dumper;

my $report_time = $ARGV[ 0 ] || do { print STDERR "No data given\n"; exit; };

my $db = Leads::DB->new( 'prod-slave' );

$db->sqlDo(
    "create temporary table tmp_active_agents 
	 select a.id as agent_id, 
	        a.people_id, 
	        ifnull(a.invoiceable, 0) as invoiceable, 
	        a.balance, 
	        a.promo_balance, 
	        a.promo_balance_available
	 from agents a 
	 where a.status='Active'"
          );

print "First temp table created\n";

$db->sqlDo(
    "create temporary table tmp_inactive_agents 
     select a.id as agent_id, 
            a.people_id, 
            ifnull(a.invoiceable, 0) as invoiceable, 
            a.balance, 
            a.promo_balance, 
            a.promo_balance_available 
	 from agents a 
	 where (a.balance!=0 or a.promo_balance!=0 or a.promo_balance_available!=0) and 
	       a.id not in (select agent_id from tmp_active_agents)"
          );

print "Second temp table created\n";

my $active_agent_info =
  $db->sqlSelectAllHashrefArray(
    "agent_id, people_id, invoiceable, balance, promo_balance, promo_balance_available",
    "tmp_active_agents" );

print "Active agent info pulled\n";

my $inactive_agent_info =
  $db->sqlSelectAllHashrefArray(
    "agent_id, people_id, invoiceable, balance, promo_balance, promo_balance_available",
    "tmp_inactive_agents" );

print "Inactive agent info pulled\n\n";

my $count = 0;

foreach my $agent ( @$active_agent_info, @$inactive_agent_info )
  {
    my $balance = $db->sqlSelect(
        "balance",
        "accounting.agent_cash_transactions",
        "agent_id='$agent->{agent_id}' and
                     date=(select max(date) from accounting.agent_cash_transactions
                           where agent_id='$agent->{agent_id}' and
                                 date<'$report_time')" );
    $balance ||= "No balance";

    my ( $promo_balance, $promo_balance_available ) = $db->sqlSelect(
        "balance, balance_available",
        "accounting.agent_promo_transactions",
        "agent_id='$agent->{agent_id}' and
                     date=(select max(date) from accounting.agent_promo_transactions
                           where agent_id='$agent->{agent_id}' and
                                 date<'$report_time')" );
    $promo_balance           ||= 0;
    $promo_balance_available ||= 0;

    my $last_sale = $db->sqlSelect(
        "timestamp",
        "accounting.receipts",
        "people_id_debited='$agent->{people_id}' and
                     timestamp=(select max(timestamp) from accounting.receipts
                          where receipt_type_id in (11,12,28) and
                                people_id_debited='$agent->{people_id}'
                              and timestamp<'$report_time')" );
    $last_sale ||= "Prior to 2011/05/01";

    my $last_fund = $db->sqlSelect(
        "timestamp",
        "accounting.receipts",
        "people_id_credited='$agent->{people_id}' and
                     receipt_type_id in (1,3) and
                     timestamp=(select max(timestamp) from accounting.receipts
                          where receipt_type_id in (1,3) and
                                people_id_credited='$agent->{people_id}'
                              and timestamp<'$report_time')" );
    $last_fund ||= "Prior to 2010-05-01";

    my ( $first_name, $last_name ) =
      $db->sqlSelect( "first_name, last_name",
                      "people",
                      "id = '$agent->{people_id}'" );
    $first_name ||= "Unknown";
    $last_name  ||= "Unknown";

    if ( $last_sale =~ /Prior/ || $last_fund =~ /Prior/ )
      {
        my $new_agent = $db->sqlSelect( "datediff(now(), created_stamp) < 30",
                                        "agents",
                                        "people_id = '$agent->{people_id}'" );
        if ( $new_agent )
          {
            $last_sale = "New Agent";
            $last_fund = "New Agent";
          }
      }

    $agent->{balance}                 = $balance;
    $agent->{promo_balance}           = $promo_balance;
    $agent->{promo_balance_available} = $promo_balance_available;
    $agent->{last_sale}               = $last_sale;
    $agent->{last_fund}               = $last_fund;
    $agent->{last_name}               = $last_name;
    $agent->{first_name}              = $first_name;

    $agent->{hold_status} = $db->sqlSelect( "preference_setting", "preferences",
                 "preference_type='hold' and people_id='$agent->{people_id}'" );
    $agent->{rebill_status} = $db->sqlSelect( "active", "agent_rebill",
                                              "agent_id='$agent->{agent_id}'" );
    $agent->{rebill_status} ||= 0;
    $agent->{rebill_status} = ( $agent->{rebill_status} ) ? 'on' : 'off';

    $agent->{invoiceable}             ||= 0;
    $agent->{balance}                 ||= 0;
    $agent->{promo_balance}           ||= 0;
    $agent->{promo_balance_available} ||= 0;
    $agent->{last_sale}               ||= '0000-00-00 00:00:00';
    $agent->{last_funded}             ||= '0000-00-00 00:00:00';
    $agent->{hold_status}             ||= 'off';

    $agent->{phone} = $db->sqlSelect( "concat(country_code, area_code, number)",
                                      "phone",
                                      "people_id='$agent->{people_id}' limit 1"
                                    );
    $agent->{phone} ||= 'XXXXXXXXXXX';

    $count++;
    my $display_count = sprintf( "%06d", $count );
    print "$display_count ";
    ( $count % 10 ) ? print "" : print "\n";
  }

my $report_date = substr( $report_time, 0, 10 );
open ACTIVE, ">/Users/bjones/active_agent_info_$report_date.csv"
  || die "Can't open file for active agents";
open INACTIVE, ">/Users/bjones/inactive_agent_info_$report_date.csv"
  || die "Can't open file for inactive agents";

my @header =
  qw(agent_id people_id first_name last_name invoiceable balance promo_balance
  promo_balance_available last_sale last_funded hold_status rebill_status phone);
my $header = join ',', @header;
print ACTIVE $header,   "\n";
print INACTIVE $header, "\n";

foreach ( sort { $a->{agent_id} <=> $b->{agent_id} } @$active_agent_info )
  {
    print ACTIVE
      "$_->{agent_id},$_->{people_id},\"$_->{first_name}\",\"$_->{last_name}\",";
    print ACTIVE "$_->{invoiceable},$_->{balance},$_->{promo_balance},";
    print ACTIVE
      "$_->{promo_balance_available},\"$_->{last_sale}\",\"$_->{last_fund}\",";
    print ACTIVE "$_->{hold_status},$_->{rebill_status},$_->{phone}\n";
  }

foreach ( sort { $a->{agent_id} <=> $b->{agent_id} } @$inactive_agent_info )
  {
    print INACTIVE
      "$_->{agent_id},$_->{people_id},\"$_->{first_name}\",\"$_->{last_name}\",";
    print INACTIVE "$_->{invoiceable},$_->{balance},$_->{promo_balance},";
    print INACTIVE
      "$_->{promo_balance_available},\"$_->{last_sale}\",\"$_->{last_fund}\",";
    print INACTIVE "$_->{hold_status},$_->{rebill_status},$_->{phone}\n";
  }

close ACTIVE;
close INACTIVE;
