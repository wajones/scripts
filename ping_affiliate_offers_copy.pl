#!/usr/bin/env perl

use DBI;
$|++;

my $table = "ping_affiliate_offers";
my $new_table = "ping_affiliate_offers_new";
my $columns = "id,ping_id,affiliate_id,lead_type_id,offer,multiplier,sale_price,offer_made";
my $dbh = DBI->connect("dbi:mysql:database=leads;host=192.168.49.111;port=3306", "bjones", "Blue Bison");

my $id = $dbh->selectrow_hashref("select max(id) as max, min(id) as min from $table");
my $number = 10000;
my $continue = 1;

$id->{start} = $id->{min};
$id->{stop}  = $id->{start} + $number - 1;

my $sth = $dbh->prepare( "insert into $new_table ( $columns ) select $columns from $table where id between ? and ?" );
#my $sth = $dbh->prepare( "insert into $new_table select * from $table where id between ? and ?"
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
