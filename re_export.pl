#!/usr/bin/env perl

use warnings;
use strict;

use lib "/u/apps/leads2/current";
use lib "/u/apps/leads2/current/admin";

use Leads::DB;
use Leads::Export;

my $db = Leads::DB->new();
my $export = Leads::Export->new( 'EZLynx' );

my $leads = $db->sqlSelectAll( "lead_id", "lead_sales", "people_id = 5325 and sale_time>='201-01-01 00:00:00'" );

foreach my $lead ( @$leads )
  {
    my $lead_id = $lead->[0];
    my $xml = $db->getLead( $lead_id );
    $export->create_export( $xml, 5325 );
    $export->post;
    print "$lead_id export returned $export->{return}\n";
  }
