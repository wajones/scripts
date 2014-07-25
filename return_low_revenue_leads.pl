#!/usr/bin/env perl

use warnings;
use strict;

use lib "/u/apps/leads2/current";
use lib "/u/apps/leads2/current/admin";

use Leads::DB;

my $db = Leads::DB->new( 'prod-accounting' );

my $leads = $db->sqlSelectAllHashrefArray( "lm.lead_id, lm.affiliate_id, lm.lead_cost, lm.lead_revenue",
                            "leads.lead_master lm 
                                left outer join leads.ping_lead_lu plu 
                                on lm.lead_id=plu.lead_id",
                            "plu.lead_id is NULL 
                              and lm.lead_cost>0 
                              and lm.lead_revenue>0 
                              and lm.lead_revenue<=2
                              and lm.received>'2011-08-20 00:00:00'" );

my ( $count, $cost, $revenue ) = ( {}, {}, {} );
open my $fh, '>>', "/Users/bjones/Development/data/low_revenue_leads.csv";
open my $fh1, '>>', "/Users/bjones/Development/data/low_revenue_leads_summary.csv";

print $fh1 "\"Affiliate ID\",\"Number of Leads\",\"Total Lead Cost\",\"Total Lead Revenue\"\n";
print $fh "\"Lead ID\",\"Affiliate ID\",\"Lead Cost\",\"Lead Revenue\"\n";

foreach my $lead ( @$leads )
  {
    my $lead_id = $lead->{lead_id};
    my $affiliate_id = $lead->{affiliate_id};
    $count->{$affiliate_id}++;
    $cost->{$affiliate_id} += $lead->{lead_cost};
    $revenue->{$affiliate_id} += $lead->{lead_revenue};
    print $fh "$lead_id,$affiliate_id,$lead->{lead_cost},$lead->{lead_revenue}\n";

    $db->sqlDo( "call leadReturn( $lead_id, $affiliate_id, 'Lead Return -- Revenue limit', \@result )" );
    $db->sqlUpdate( "leads.lead_master",
                    {  lead_cost => 0,
                       status    => "Lead returned by agent",
                    },
                    "lead_id = '$lead_id'" );
    print "Lead ID $lead_id returned for affiliate ID $affiliate_id\n";
  }

foreach my $affiliate ( sort { $a <=> $b } keys %$count )
  {
    print $fh1 "$affiliate,$count->{$affiliate},$cost->{$affiliate},$revenue->{$affiliate}\n";
  }

close $fh;
close $fh1;

