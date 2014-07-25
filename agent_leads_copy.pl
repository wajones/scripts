#!/usr/bin/perl

use DBI;
$|++;

my $table = "website_alusercache";
my $new_table = "website_alusercache_new";
my $columns; #= "receipt_type_id,people_id_credited,people_id_debited,transaction_id,lead_id,amount,notes,timestamp"; 
my $dbh = DBI->connect("dbi:mysql:database=alshare;host=prodeast-aldbinstance.cavohb8ptjyr.us-east-1.rds.amazonaws.com;port=3306", "allistlover", 'Phuyei!s1r');

my $col_sth = $dbh->prepare( "select * from $table where 1=0;" );
$col_sth->execute;
my @cols = @{ $sth->{NAME} };
my $columns = join ',', @cols;
$columns =~ s/,$//g;
my $id = $dbh->selectrow_hashref("select max(id) as max, min(id) as min from $table");
my $number = 10000;
my $continue = 1;

$id->{start} = $id->{min};
$id->{stop}  = $id->{start} + $number;

my $sth = $dbh->prepare( "insert into $new_table ( $columns ) select $columns from $table where id between ? and ?" );
#my $sth = $dbh->prepare( "insert into $new_table select * from $table where id between ? and ?" );
while ( $continue )
  {
	my $rc = $sth->execute( $id->{start}, $id->{stop} );
	print "Completed through ID $id->{stop}\n";
	$continue = ( $id->{stop} == $id->{max} ) ? 0 : 1;
	$id->{start} = $id->{stop} + 1;
	$id->{stop}  = $id->{start} + $number;
	$id->{stop}  = ( $id->{stop} > $id->{max} ) ? $id->{max} : $id->{stop};
	sleep 1;
  }

exit;
