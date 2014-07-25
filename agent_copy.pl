#!/usr/bin/env perl

use DBI;
$|++;

my $table = "lead_master";
my $new_table = "lead_master_new";
my $columns = "lead_id,lead_type_id,affiliate_id,targus_category_id,theme_id,campaign_id,transaction_id,sub_category_id,newsletter,state,zip,lead_cost,lead_revenue,hash,received,status,ip_address,type,leg_bid,sold_exclusive";
my $dbh = DBI->connect("dbi:mysql:database=leads;host=192.168.49.111;port=3306", "bjones", "Blue Bison");

my $id = $dbh->selectrow_hashref("select max(lead_id) as max, min(lead_id) as min from $table");
my $number = 10000;
my $continue = 1;

$id->{start} = $id->{min};
$id->{stop}  = $id->{start} + $number - 1;

my $sth = $dbh->prepare( "insert into $new_table ( $columns ) select $columns from $table where lead_id between ? and ?" );
#my $sth = $dbh->prepare( "insert into $new_table select * from $table where id between ? and ?" );
while ( $continue )
  {
	my $rc = $sth->execute( $id->{start}, $id->{stop} );
	print "Completed through ID $id->{stop}\n";
	$continue = ( $id->{stop} == $id->{max} ) ? 0 : 1;
	$id->{start} = $id->{stop} + 1;
	$id->{stop}  = $id->{start} + $number - 1;
	$id->{stop}  = ( $id->{stop} > $id->{max} ) ? $id->{max} : $id->{stop};
  }

exit;
