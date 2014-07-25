#!/usr/bin/env perl

use warnings;
use strict;

use lib "/u/apps/leads2/current";
use lib "/u/apps/leads2/current/admin";

use Leads::DB;
use Leads::Utils;
use XML::Simple;
use Data::Dumper;

open my $fh, '<', "/Users/bjones/Downloads/efinancialdata.csv";
if ( !$fh ) { die "Failed to open file: $!"; }

my $ping_data;
while ( <$fh> )
  {
	next if ( /Source/ );
	chomp;
	my ( $date, $age, $zip, $email, $rest ) = split /,/, $_, 5;
	$date =~ s/^ //g;
	$date =~ s/"//g;
	$date =~ m|(\d{2})/(\d{2})/(\d{4}) (\d{1,2}):(\d{2}):(\d{2}) (.M)|;
	my ( $month, $day, $year, $hour, $min, $sec, $ext ) = ( $1, $2, $3, $4, $5, $6, $7 );
	$hour += 12 if ( $ext eq 'PM' );
	$hour = "0" . $hour if length( $hour ) == 1;
	my $sql_date = "$year-$month-$day $hour:$min:$sec";
	$email =~ s/"//g;
	push @$ping_data, { date => $sql_date, age => $age, zip => $zip, email => $email };
  }

my $db = Leads::DB->new( 'prod-slave' );

foreach ( @$ping_data )
  {
	my $potential_match = $db->sqlCount( "tmp_pings.pings_to_match",
										 "zip = '$_->{zip}' 
										  and (abs(age - $_->{age})) <= 1 
										  and abs(unix_timestamp('$_->{date}') - unix_timestamp(ts)) <= 60" );
	print "$_->{email} is a potential match\n" if ( $potential_match > 0 );
  }

