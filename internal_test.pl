#!/usr/bin/env perl

use lib "/u/apps/leads2/current";
use Leads::Lead;
use Data::Dumper;

my $lead = Leads::Lead->new( {new_id => 'N'} );
my $sale_list = $lead->{dbh}->sqlSelectColArrayref( "people_id", "lead_sales", "lead_id = 9330627" );

print Dumper( $sale_list );

my $exclude_people = ( scalar @$sale_list ) ? join ',', @$sale_list : 0;
print "$exclude_people\n";

