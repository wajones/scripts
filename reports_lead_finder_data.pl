#!/usr/bin/env perl

use warnings;
use strict;

use DBIx::Connector;

my $dsn = 'DBI:mysql:database=reportss;host=192.168.49.111';
my $user = 'nate';
my $pass = 'horsie$barbie10';

my $conn = DBIx::Connector->new( $dsn, $user, $pass );
$conn->run( fixup => sub {
    $_->do( 'truncate table lead_finder_data' ) } );
$conn->run( fixup => sub {
    $_->do( 'insert into lead_finder_data select z.county as county, 
             lm.zip as zip, lm.state as state, lm.lead_type_id as lead_type_id, 
             count(lm.lead_id) as leads from leads.lead_master lm 
             left join leads.lead_types lt on lm.lead_type_id = lt.id 
             inner join leads.zip_codes z on lm.zip = z.zip 
             where lm.received > date_sub(now(),interval 30 day) 
             group by z.zip, lm.lead_type_id ' ) } );

exit;

