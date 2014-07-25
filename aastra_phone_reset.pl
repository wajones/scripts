#!/usr/bin/env perl
use strict;
use warnings;
use Text::CSV;

my $file = 'phones.csv';

my $csv = Text::CSV->new();

open (CSV, "<", $file) or die $!;

while (<CSV>) {
        if ($csv->parse($_)) {
                my @columns= $csv->fields();
                my $ip="192.168.2." . $columns[0];
                my $uname=$columns[1];
                my $pass=$columns[2];
                my $logout="wget --no-cache --http-user=$uname --http-passwd=$pass http://$ip/logout.html";
                my $reset="wget --post-data=resetOption=0 --http-user=$uname --http-passwd=$pass http://$ip/reset.html";
                my $result=system($logout);
                $result=system($logout);
                $result=system($reset);
		print "Done with $ip\n";
        }
}
close CSV;

