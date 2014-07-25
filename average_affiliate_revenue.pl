#!/usr/bin/perl

use DBI;
use Data::Dumper;
$|++;

my $dbh = DBI->connect("dbi:mysql:database=leads;host=192.168.49.11;port=3306", "bjones", "Blue Bison");

my $affiliates = $dbh->selectall_hashref( "select affiliate_id, people_id from ping_partners", "affiliate_id" );
my $affiliate_list = join ',', keys %$affiliates;
print "Affiliates: $affiliate_list\n";
$affiliate_list = 99919;
my $lead_data = $dbh->selectall_hashref( "select lm.lead_id, lm.affiliate_id, lm.lead_type_id, lm.state from lead_master lm, ping_lead_lu plu where lm.affiliate_id in ($affiliate_list) and date(lm.received) between date(date_sub(now(), interval 7 day)) and date(now()) and lm.lead_id = plu.lead_id", "lead_id" );
print "Lead data retrieved: " . scalar (keys %$lead_data) . " leads returned\n";

my $count = 0;

foreach my $lead_id ( keys %$lead_data )
  {
	my $dd_count = $dbh->selectrow_arrayref( "select count(*) from roman_distribution_directives where lead_id = $lead_id" );
	print "$lead_id\t$dd_count->[0]\n";
	my $purchase_price = $dbh->selectrow_arrayref( "select amount from accounting.receipts where lead_id = $lead_id and receipt_type_id = 15 and people_id_credited = $affiliates->{$lead_data->{$lead_id}{affiliate_id}}{people_id}" );
	$lead_data->{$lead_id}{purchase_price} = $purchase_price->[0];
	$lead_data->{$lead_id}{dd_count} = $dd_count->[0];
	print "$lead_id\n" unless ( $dd_count->[0]>=0 );
  }

print "Done with initial lead processing\n";
my $affiliate_data;

$count = 0;
foreach my $lead_id ( keys %$lead_data )
  {
	my $affiliate_id   = $lead_data->{$lead_id}{affiliate_id};
	my $state          = $lead_data->{$lead_id}{state};
	my $lead_type_id   = $lead_data->{$lead_id}{lead_type_id};
	my $dd_count       = $lead_data->{$lead_id}{dd_count};
	my $purchase_price = $lead_data->{$lead_id}{purchase_price};
	my $key            = "$affiliate_id|$state|$lead_type_id|$dd_count";
	
	$affiliate_data->{$key}{affiliate_id}    = $affiliate_id;
	$affiliate_data->{$key}{state}           = $state;
	$affiliate_data->{$key}{lead_type_id}    = $lead_type_id;
	$affiliate_data->{$key}{dd_count}        = $dd_count;
	$affiliate_data->{$key}{purchase_price} += $purchase_price;
	$affiliate_data->{$key}{lead_count}++;
  }

print "Done with secondary lead processing\n";

foreach my $key ( sort {$a cmp $b} keys %$affiliate_data )
  {
	my $ave_revenue = sprintf( "%.2f", $affiliate_data->{$key}{purchase_price} / $affiliate_data->{$key}{lead_count} );
	print "$affiliate_data->{$key}{affiliate_id},$affiliate_data->{$key}{state},$affiliate_data->{$key}{lead_type_id},$affiliate_data->{$key}{dd_count},$affiliate_data->{$key}{lead_count},$affiliate_data->{$key}{purchase_price},$ave_revenue\n";
  }

exit;
