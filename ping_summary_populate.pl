#!/usr/bin/env perl

use warnings;
use strict;

use lib "/u/apps/leads2/current";
use Leads::DB;
use Leads::Util;
use XML::Simple;

my $db = Leads::DB->new( 'prod-slave' );
my ( $min_id, $max_id ) = $db->sqlSelectAll( "min(id), max(id)",
                                             "archive.ping_raw" );
my $start = $min_id;
my $end = $min_id + 10000;

my $data = $db->sqlSelectAllHashrefArray ( "ping_id, affiliate_id, xml, ping_received",
                                           "archive.ping_raw",
                                           "id >= $start and id < $end" );
foreach my $datum ( @$data )
  {
    my $ping = XML::Simple->new->XMLin( unscrubXMLData( $datum->{xml} ) );
