#!/usr/bin/env perl 

use warnings;
use strict;
use Data::Dumper;

use lib "/u/apps/leads2/current";
use lib "/u/apps/leads2/current/admin";

use Util::API::GetLead;

my ( $return, $success );

my $lead = Util::API::GetLead->new( { lead_id => $ARGV[0] } );
my $lead_data = $lead->getLeadWithTokenFromID;
if ( $lead_data !~ /lead/ )
  {
    $lead_data = "<lead>Not Found</lead>\n";
  }

my $form_values = { key => 'e0a60f4e3d93d50e763d3df52f7b114fdd4025cd',
                    xml => $lead_data, };
my $url = "https://portal.insuranceagents.com/api/leads";
my $ua = LWP::UserAgent->new;
$return = $ua->post( $url, $form_values );
$success = ( $return->is_success ) ? 1 : 0;
 print Dumper($return);

