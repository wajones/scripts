#!/usr/bin/env perl

use lib "/usr/local/ActivePerl-5.12/site/lib/";
use lib "/u/apps/leads2/current";
use Leads::Lead;
use Data::Dumper;

my $xml = $ARGV[0];
my $lead = Leads::Lead->new( { db=>'leads', a=>1, xml=>$xml } );
$lead->parse;
$lead->generateLeadHash;
$lead->verifyRecord;
$lead->checkPhonyData;
$lead->applyConsistencyChecks;
$lead->summarizeBadData;
$lead->insertLead;
#print Dumper($lead);
