#!/usr/bin/perl

use DBI;
$|++;

my $dbh = DBI->connect( "dbi:mysql:database=leads;host=localhost;port=3306", "bjones", "Blue Bison" );
my $ids = $dbh->selectall_arrayref( "select ping_id from ping_affiliate_offers where lead_type_id = 0" );

my $sth1 = $dbh->prepare( "select lead_type_id from ping_raw where ping_raw.ping_id = ?" );
my $sth2 = $dbh->prepare( "update ping_affiliate_offers set lead_type_id = ? where ping_id = ?" );

foreach my $ping_id ( @$ids )
  {
	$sth1->execute( $ping_id );
	my $lead_type_id = $sth1->fetchrow;
	my $rc = $sth2->execute( $lead_type_id, $ping_id );
    if ( $rc )
      {
		$count++;
		print ( $count % 100 ) ? "" : ( $count % 1000 ) ? "$count\n" : "$count ";
	  }
	else
	  {
		print "An error occurred.  Ping ID:  $ping_id\tlead type ID:  $lead_type_id\n";
		exit;
	  }
  }

exit;