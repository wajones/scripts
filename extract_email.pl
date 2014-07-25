#!/usr/bin/env perl

use warnings;
use strict;

use lib "/u/apps/leads2/current";
use lib "/u/apps/leads2/current/admin";

use Leads::DB;
use Leads::Utils;
use XML::Simple;
use Data::Dumper;

my $db = Leads::DB->new( 'prod-slave' );
my $count = 0;
my $disp_count;

my $ping_list = $db->sqlSelectAllHashrefArray( "ping_id, xml, ping_received",
											"tmp_pings.ping_raw" );

foreach my $ping ( @$ping_list )
  {
	next unless ( $ping->{xml} =~ /lead_life/ );
	$ping->{xml} = unscrubXMLData( $ping->{xml} );
	my $ping_data = XML::Simple->new()->XMLin( $ping->{xml} );
	
	my $email = $ping_data->{email} || '';
	my $dob   = $ping_data->{applicant}{dob} || $ping_data->{dob} || '0000-00-00';
	my $zip   = $ping_data->{zip} || '00000';
	
	$db->sqlInsert( "tmp_pings.ping_email_list",
					{ ping_id => $ping->{ping_id},
					  email   => $email,
					  dob     => $dob,
					  zip     => $zip,
					  ts      => $ping->{ping_received}, } );

	
	$count++;
	$disp_count = sprintf( "%05d", $count );
	( $count % 20 ) ? print "$disp_count" : print "$disp_count\n";
  }