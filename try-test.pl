#!/usr/bin/env perl

use strict;
use warnings;
use Try::Tiny;

my $error = 'NONE';
my $continue = 1;
my $test_value = $ARGV[0];
chomp($test_value);

try {
	die "FOO" unless ( $test_value == 1 );
} catch {
	$error = $_;
	try {
		die "BAR" unless ( $test_value == 2 );
	} catch {
		$error = $_;
		$continue = 0;
	};
} finally {
	if ( $continue )
	  {
		print $test_value . "\n";
		print $continue . "\n";
		print $error . "\n";
	  }
	else
	  {
                print $test_value . "\n";
                print $continue . "\n";
		print $error . "\n";
		print "FAILED\n";
	  }
};
