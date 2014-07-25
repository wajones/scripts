#!/usr/bin/env perl

use warnings;
use strict;
use Statistics::Descriptive;

use lib "/u/apps/leads2/current";

use Leads::DB;

my $db = Leads::DB->new();

my $data = $db->sqlSelectAllHashrefArray( "initialize, new_lead, parse, process, send",
                                       "ping_timing",
                                       "1=1",
                                       "order by id desc limit 2500" );

my @init = map { $_->{initialize} != 10000 ? $_->{initialize} : () } @$data;
my @newlead = map { $_->{new_lead} != 10000 ? $_->{new_lead} : () } @$data;
my @parse = map{ $_->{parse} != 10000 ? $_->{parse} : () } @$data;
my @process = map{ $_->{process} != 10000 ? $_->{process} : () } @$data;
my @send = map{ $_->{send} != 10000 ? $_->{send} : () } @$data;
my @total = map{ (    $_->{initialize} != 10000 
                   && $_->{new_lead} != 10000 
                   && $_->{parse} != 10000 
                   && $_->{process} != 10000 
                   && $_->{send} != 10000 ) ?   $_->{initialize} 
                                              + $_->{new_lead} 
                                              + $_->{parse} 
                                              + $_->{process} 
                                              + $_->{send} : () } @$data;

my $stat = Statistics::Descriptive::Full->new();

# Values for initialize
$stat->add_data( @init );
my $init_mean = $stat->mean;
my $init_median = $stat->median;
my $init_stddev = $stat->standard_deviation;
my ( $init_99, $init_99_index ) = $stat->percentile( 99 );
my ( $init_999, $init_999_index ) = $stat->percentile( 99.9 );
my $init_max = $stat->max;

print "Initialize Data:\n";
print '=' x 50 . "\n";
print "Mean:                  $init_mean\n";
print "Median:                $init_median\n";
print "Standard Deviation:    $init_stddev\n";
print "99\% Percentile at:     $init_99\n";
print "99.9\% Percentile at:   $init_999\n";
print "Max:                   $init_max\n";
print '-' x 50 . "\n\n";

$stat->clear();

$stat->add_data( @newlead );
my $newlead_mean = $stat->mean;
my $newlead_median = $stat->median;
my $newlead_stddev = $stat->standard_deviation;
my ( $newlead_99, $newlead_99_index ) = $stat->percentile( 99 );
my ( $newlead_999, $newlead_999_index ) = $stat->percentile( 99.9 );
my $newlead_max = $stat->max;

print "Lead Object Creation:\n";
print '=' x 50 . "\n";
print "Mean:                  $newlead_mean\n";
print "Median:                $newlead_median\n";
print "Standard Deviation:    $newlead_stddev\n";
print "99\% Percentile at:     $newlead_99\n";
print "99.9\% Percentile at:   $newlead_999\n";
print "Max:                   $newlead_max\n";
print '-' x 50 . "\n\n";

$stat->clear();

$stat->add_data( @parse );
my $parse_mean = $stat->mean;
my $parse_median = $stat->median;
my $parse_stddev = $stat->standard_deviation;
my ( $parse_99, $parse_99_index ) = $stat->percentile( 99 );
my ( $parse_999, $parse_999_index ) = $stat->percentile( 99.9 );
my $parse_max = $stat->max;

print "Parse Data:\n";
print '=' x 50 . "\n";
print "Mean:                  $parse_mean\n";
print "Median:                $parse_median\n";
print "Standard Deviation:    $parse_stddev\n";
print "99\% Percentile at:     $parse_99\n";
print "99.9\% Percentile at:   $parse_999\n";
print "Max:                   $parse_max\n";
print '-' x 50 . "\n\n";

$stat->clear();

$stat->add_data( @process );
my $process_mean = $stat->mean;
my $process_median = $stat->median;
my $process_stddev = $stat->standard_deviation;
my ( $process_99, $process_99_index ) = $stat->percentile( 99 );
my ( $process_999, $process_999_index ) = $stat->percentile( 99.9 );
my $process_max = $stat->max;

print "Process Data:\n";
print '=' x 50 . "\n";
print "Mean:                  $process_mean\n";
print "Median:                $process_median\n";
print "Standard Deviation:    $process_stddev\n";
print "99\% Percentile at:     $process_99\n";
print "99.9\% Percentile at:   $process_999\n";
print "Max:                   $process_max\n";
print '-' x 50 . "\n\n";

$stat->clear();

$stat->add_data( @send );
my $send_mean = $stat->mean;
my $send_median = $stat->median;
my $send_stddev = $stat->standard_deviation;
my ( $send_99, $send_99_index ) = $stat->percentile( 99 );
my ( $send_999, $send_999_index ) = $stat->percentile( 99.9 );
my $send_max = $stat->max;

print "Send Data:\n";
print '=' x 50 . "\n";
print "Mean:                  $send_mean\n";
print "Median:                $send_median\n";
print "Standard Deviation:    $send_stddev\n";
print "99\% Percentile at:     $send_99\n";
print "99.9\% Percentile at:   $send_999\n";
print "Max:                   $send_max\n";
print '-' x 50 . "\n\n";

$stat->clear();

$stat->add_data( @total );
my $total_mean = $stat->mean;
my $total_median = $stat->median;
my $total_stddev = $stat->standard_deviation;
my ( $total_99, $total_99_index ) = $stat->percentile( 99 );
my ( $total_999, $total_999_index ) = $stat->percentile( 99.9 );
my $total_max = $stat->max;

print "Total Processing Time:\n";
print '=' x 50 . "\n";
print "Mean:                  $total_mean\n";
print "Median:                $total_median\n";
print "Standard Deviation:    $total_stddev\n";
print "99\% Percentile at:     $total_99\n";
print "99.9\% Percentile at:   $total_999\n";
print "Max:                   $total_max\n";
print '-' x 50 . "\n\n";

