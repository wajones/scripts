#!/usr/bin/perl

use DBI;
$|++;

my $dbh = DBI->connect( "dbi:mysql:database=ia;host=174.129.246.230;port=3306", "ia", "ia-pass-123" );
my $ids = $dbh->selectall_arrayref( "select timestamp, name, email, phone, affId, landingPage from lp_prospects where timestamp>='2010-11-08 00:00:00' and name!='test' and name!='No name entered' and name!='asdasd'" );

foreach my $ping_id ( @$ids )
  {
    my $values = join '\',\'', @$ping_id;
    print "insert into lp_prospects (timestamp,name,email,phone,affId,landingPage) values ('$values');\n";
  }

exit;
