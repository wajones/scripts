#!/usr/bin/perl

use DBI;
$|++;

my $dbh = DBI->connect("dbi:mysql:database=leads;host=192.168.49.111;port=3306", "bjones", "Blue Bison");

my $lead_id = $dbh->selectrow_hashref("select max(lead_id) as max, min(lead_id) as min from lead_master");
my $number_of_leads = 10000;
my $continue = 1;

$lead_id->{start} = $lead_id->{min};
$lead_id->{stop}  = $lead_id->{start} + $number_of_leads;

my $sth = $dbh->prepare( "insert into lead_master_new ( lead_id, lead_type_id, affiliate_id, targus_category_id, theme_id, campaign_id, transaction_id, sub_category_id, newsletter, state, zip, lead_cost, lead_revenue, hash, received, status, ip_address, type ) select lead_id, lead_type_id, affiliate_id, targus_category_id, theme_id, campaign_id, transaction_id, sub_category_id, newsletter, state, zip, lead_cost, lead_revenue, hash, received, status, ip_address, type from lead_master where lead_id between ? and ?" );

while ( $continue )
  {
	my $rc = $sth->execute( $lead_id->{start}, $lead_id->{stop} );
	print "Completed through lead $lead_id->{stop}\n";
	$continue = ( $lead_id->{stop} == $lead_id->{max} ) ? 0 : 1;
	$lead_id->{start} = $lead_id->{stop} + 1;
	$lead_id->{stop}  = $lead_id->{start} + $number_of_leads;
	$lead_id->{stop}  = ( $lead_id->{stop} > $lead_id->{max} ) ? $lead_id->{max} : $lead_id->{stop};
  }

exit;
