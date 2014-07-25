#!/usr/bin/env perl
use strict;
use warnings;

use lib "/u/apps/leads2/current";
use lib "/u/apps/leads2/current/admin";

use Leads::DB;
use Leads::Lead;

use Carp;
use Data::Dumper;

my $template_dir = "/usr/local/templates";

my $lead_id = $ARGV[0];
chomp $lead_id;

my $lead = Leads::Lead->new( { db => 'prod-leads', new_id => 'N', } );
$lead->fetchLead( $lead_id );
$lead->{a} = 99919;
my ( $multiplier, $min_bid, $max_bid, $presold_weight ) = $lead->checkMultipliers;
print "Multiplier:     $multiplier\n";
print "Minimum bid:    $min_bid\n";
print "Maximum bid:    $max_bid\n";
print "Presold Weight: $presold_weight\n";

#$lead->sellLead;

#print Dumper($lead);
