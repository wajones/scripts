#!/usr/bin/env perl

my $response = $ARGV[0];

if($response =~ /successful/i ) {
    if ($response =~ /\$(.*)/) {
      my $inside = $1;
      print ">> $inside\n";
    }
    else { print "> 0\n";
    }
  } else {
     print "$response\n";
  }

