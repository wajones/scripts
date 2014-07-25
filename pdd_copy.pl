#!/usr/bin/perl

use DBI;
$|++;

my $table = "ping_distribution_directives";
my $new_table = "reporting.ping_distribution_directives";
my $columns = "receipt_type_id,people_id_credited,people_id_debited,transaction_id,lead_id,amount,notes,timestamp"; 
my $dbh = DBI->connect("dbi:mysql:database=leads;host=192.168.49.11;port=3306", "bjones", "Blue Bison");

my $id = $dbh->selectrow_hashref("select max(ping_id) as max, min(ping_id) as min from $table");
my $number = 10000;
my $continue = 1;
$id->{min} = 34017001;
$id->{start} = $id->{min};
$id->{stop}  = $id->{start} + $number;

#my $sth = $dbh->prepare( "insert into $new_table ( $columns ) select $columns from $table where id between ? and ?" );
my $sth = $dbh->prepare( "insert into $new_table select * from $table where ping_id between ? and ?" );
while ( $continue )
  {
	my $rc = $sth->execute( $id->{start}, $id->{stop} );
	print "Completed through ID $id->{stop}\n";
	$continue = ( $id->{stop} == $id->{max} ) ? 0 : 1;
	$id->{start} = $id->{stop} + 1;
	$id->{stop}  = $id->{start} + $number;
	$id->{stop}  = ( $id->{stop} > $id->{max} ) ? $id->{max} : $id->{stop};
  }

exit;
