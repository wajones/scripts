#!/usr/bin/env perl

use lib "/usr/local/ActivePerl-5.12/site/lib/";
use lib "/u/apps/leads2/current";
use Leads::Lead;
use Data::Dumper;

my $lead = Leads::Lead->new( { db=>'leads', new_id => 'N' } );
$lead->{lead_type_id} = 2;
$lead->{a} = 1;
my $state = 'OH';
my $zip   = '43215';
$lead->getPurchasingAgentsByState( $state, $zip );

