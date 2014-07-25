#!/usr/bin/env perl

use warnings;
use strict;

use lib "/u/apps/leads2/current";

use Leads::DB;

my $db = Leads::DB->new( 'prod-leads' );

my $list = [ map { $_->[0] } @{$db->sqlSelectAll( "zip",
                                                  "zip_codes", "state='CA'" )} ];
foreach my $id ( @$list )
  {
    $db->sqlInsert( "agent_filter_zip",
                    { people_id => 435225, filter_set_id => 64950, zip_code => $id } );
    print "Done with $id\n";
  }

