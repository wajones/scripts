#!/usr/bin/env perl

use strict;
use warnings;

use DBI;

my $dbh = DBI->connect("dbi:mysql:database=YOUR_DB_NAME;host=localhost;port=3306", "YOUR DB_USERNAME", "YOUR DB_PASSWORD" ) or die "Can't connect to database";
my $file = $ARGV[0];

open my $fh, '<', $file or die "Can't open file $file";

while (<$fh>)
  {
    chomp;
    $dbh->do( "insert into TABLE_NAME values ( $_ )" );
    print $_ . "\n";
  }

close $fh;

