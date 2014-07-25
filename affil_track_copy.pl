#!/usr/bin/env perl

use DBI;
$|++;

my $dbh =
  DBI->connect( "dbi:mysql:database=leads;host=192.168.49.111;port=3306",
                "bjones", "Blue Bison" );

my $id = $dbh->selectrow_hashref(
    "select max(lead_id) as max, min(lead_id) as min from lead_master where lead_id<20000000"
);
my $number   = 10000;
my $continue = 1;

$id->{start} = $id->{min};
$id->{stop}  = $id->{start} + $number;

my $sth = $dbh->prepare(
    "insert into lead_master_new select * from lead_master where lead_id between ? and ?"
);

while ( $continue )
  {
    my $rc = $sth->execute( $id->{start}, $id->{stop} );
    print "Completed through Lead ID $id->{stop}\n";
    $continue = ( $id->{stop} == $id->{max} ) ? 0 : 1;
    $id->{start} = $id->{stop} + 1;
    $id->{stop}  = $id->{start} + $number;
    $id->{stop}  = ( $id->{stop} > $id->{max} ) ? $id->{max} : $id->{stop};
    sleep 1;
  }

exit;
