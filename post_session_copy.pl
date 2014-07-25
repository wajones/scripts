#!/usr/bin/env perl

use DBI;
$|++;

my $table = "post_session";
my $new_table = "post_session_new";
my $columns = "lead_id,people_id,phase,sale_price,result,result2,external_id,creation_timestamp";
my $dbh = DBI->connect("dbi:mysql:database=leads;host=192.168.49.111;port=3306", "bjones", "Blue Bison");

my $id = $dbh->selectrow_hashref("select max(lead_id) as max, min(lead_id) as min from $table where lead_id>11910282");
my $number = 1000;
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
  sleep 1;
  }

exit;
