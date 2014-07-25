#!/usr/bin/env perl

use strict;
use warnings;

use lib "/u/apps/leads2/current";

use Leads::Lead;
use Data::Dumper;

my $_lead = Leads::Lead->new( { new_id => 'N', } );
my $db    = $_lead->{dbh};
my $accounting = Leads::DB->new( "accounting" );

my $leads_to_process = $db->sqlSelectAll( "lead_id", "lead_master",
					  "lead_revenue=0 and (status not like 'Duplicate of%' or status not like '%targus%')
					   and lead_cost>0 and received between '2010-10-01 00:00:00' and now()" );
foreach my $lead ( @$leads_to_process )
  {
    my $sale_count = $db->sqlCount( "lead_sales", "lead_id = '$lead->[0]'" );
    if ( $sale_count == 0 )
      {
        print "Want to return lead $lead->[0]\n";
      }
  }

