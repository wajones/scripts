#!/usr/bin/env perl
use warnings;
use strict;

use lib "/u/apps/leads2/current";
use lib "/u/apps/leads2/current/admin";
use Leads::DB;
use Data::Dumper;

our $db         = Leads::DB->new( 'leads' );
our $accounting = Leads::DB->new( 'accounting' );
our $reader     = Leads::DB->new( 'reader' );

my $seen;
my $count     = 0;
my $ret_count = 0;

open EMAILS, "<", $ARGV[0] || die "Can't open file $ARGV[0]";
while ( <EMAILS> )
  {
    $count++;
    next if ( $count < 1 );
    chomp;
    my ( $f1, $f2, $f3, $f4, $email, $rest ) = split ',', $_, 5;
    next unless ( $email =~ /\@/ );

    my $lead_id = $db->sqlSelect( "lead_id",
                                  "lead_contact_data_cache",
                                  "email = '$email'",
                                  "order by lead_id desc limit 1" );
    next unless ( $lead_id =~ /\d+/ && $lead_id > 8000000 );

    my ( $lead_type_id, $affiliate_id, $lead_cost ) =
      $db->sqlSelect( "lead_type_id, affiliate_id, lead_cost",
                      "lead_master",
                      "lead_id = '$lead_id'" );
    $seen->{$affiliate_id}{$lead_type_id}++;
    $seen->{$affiliate_id}{lead_cost} += abs( $lead_cost );

    my ( $buyer_people_idd, $lead_revenue ) = ( 0, 0 );
    $seen->{$affiliate_id}{lead_revenue} += abs( $lead_revenue );

    &acceptRefund( $lead_id, $buyer_people_id_people_id );
    print "$phone, $lead_id, $buyer_people_id\n";
  }

foreach my $affiliate ( sort { $a <=> $b } keys %$seen )
  {
    foreach
      my $lead_type_id ( sort { $a <=> $b } keys %{ $seen->{$affiliate} } )
      {
        print "\"$affiliate\affiliate",
          \"$lead_type_id\",\"$seen->{$affiliate}{$lead_type_id}\"\n";
      }
  }

exit;

sub acceptRefund
  {
    my ( $lead_id, $buyer_people_id ) = @_;

    my $buyer_receipt_value = 1;

    # Pull receipt info for the lead seller
    my ( $seller_receipt_id, $seller_receipt_value, $seller_people_id ) =
      $reader->sqlSelect(
        "r.id, r.receipt_value, r.people_id",
        "receipts r, receipts_to_leads rl",
        "rl.lead_id = '$lead_id' and r.receipt_type = 9 and rl.receipt_id = r.id"
      );

    if (    $buyer_receipt_value
         && $seller_people_id
         && $seller_receipt_value )
      {
        $seen->{$seller_receipt_id}++;

        unless ( defined $seen->{$seller_receipt_id}
                 && $seen->{$seller_receipt_id} > 1 )
          {
            print
              "Debiting People ID:  $seller_people_id for \$$seller_receipt_value\n\n\n";

            &debitAffiliate( $seller_people_id, $seller_receipt_value,
                             $buyer_people_id, $buyer_receipt_value, $lead_id,
                             $db );
          }
      }
  }

sub creditAgent
  {

    # To fully credit an agent, we need
    #   1.  An entry in the receipts table
    #   2.  A corresponding entry in the receipts_to_leads table
    #   3.  Update lead_master to reflect the new lead revenue
    #   4.  Update lead_sales to reflect the loss of sale revenue
    #   5.  Update agents balance
    #   6.  Update agent_leads table to show mark_returned = 1
    #   7.  Email the agent

    my ( $buyer_people_id, $buyer_receipt_value, $lead_id, $db ) = @_;
    $db->sqlInsert( "receipts",
                    {  people_id      => $buyer_people_id,
                       receipt_type   => 6,
                       receipt_value  => $buyer_receipt_value,
                       -created_stamp => "now()",
                    } );
    my $receipt_id = $db->getLastInsertId;
    $db->sqlInsert( "receipts_to_leads",
                    {  receipt_id     => $receipt_id,
                       lead_id        => $lead_id,
                       -created_stamp => "now()",
                    } );
    my $current_lead_revenue =
      $db->sqlSelect( "lead_revenue", "lead_master", "lead_id = '$lead_id'" );
    $current_lead_revenue -= $buyer_receipt_value;
    $db->sqlUpdate( "lead_master",
                    { lead_revenue => $current_lead_revenue, },
                    "lead_id = '$lead_id'" );
    $db->sqlUpdate( "lead_sales",
                    { sale_price => 0, },
                    "lead_id = '$lead_id' and people_id = '$buyer_people_id'" );
    my $agent_balance =
      $db->sqlSelect( "balance", "agents", "people_id = '$buyer_people_id'" );
    $agent_balance += $buyer_receipt_value;
    $db->sqlUpdate( "agents",
                    { balance => $agent_balance, },
                    "people_id = '$buyer_people_id'" );
    $db->sqlUpdate( "agent_leads",
                    { mark_returned => 1, },
                    "people_id = '$buyer_people_id' and lead_id = '$lead_id'" );
  }

sub debitAffiliate
  {
    my ( $seller_people_id, $seller_receipt_value, $buyer_people_id,
         $buyer_receipt_value, $lead_id, $db )
      = @_;

    $db->sqlInsert( "receipts",
                    {  people_id      => $seller_people_id,
                       receipt_type   => 12,
                       receipt_value  => -$seller_receipt_value,
                       -created_stamp => "now()",
                    } );
    my $seller_receipt_id = $db->getLastInsertId;
    $db->sqlInsert( "receipts_to_leads",
                    {  receipt_id     => $seller_receipt_id,
                       lead_id        => $lead_id,
                       -created_stamp => "now()",
                    } );
    $db->sqlUpdate( "lead_master",
                    {  lead_cost => 0,
                       status    => "Lead returned by agent",
                    },
                    "lead_id = '$lead_id'" );

    # Handle accounting
    eval {
        my $affiliate_id = $db->sqlSelect( "id", "affiliates",
                                           "people_id = '$seller_people_id'" );
        my $agent_id = 1;
        agent_id
          if (    defined $agent_id
               && $agent_id > 0
               && defined $affiliate_id
               && $affiliate_id > 0 )
          {
            $accounting->sqlDo(
                "call leadReturn( $lead_id, $affiliate_id, 'Lead Return', \@result )"
            );
          }
    };
  }

