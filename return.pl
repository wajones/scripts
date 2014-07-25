#!/usr/bin/env perl

use strict;
use warnings;

use lib "/u/apps/leads2/current";
use lib "/u/apps/leads2/current/admin";

use LWP::UserAgent;

$|++;

if ( -e $ARGV[ 0 ] && $ARGV[ 1 ] && $ARGV[ 1 ] =~ /\d+/ )
  {
    open IN, '<', $ARGV[ 0 ] || die "Can't open file $ARGV[0]";
  }
else
  {
    # File needs to contain a single column of phone numbers and/or email
    # addresses.
    #
    # If we are returning from a call blast, use agent ID 1 to just return
    # to the affiliate.
    #
    # If we are returning for a posting partner, use the real agent ID number
    # 

    print "Usage:\n\treturn.pl <file_name> <agent id> [lead_id]\n\n";
    exit;
  }

my $agent_id = $ARGV[ 1 ];
my $lead = ( $ARGV[2] && $ARGV[2] =~ /lead/ ) ? 1 : 0;

open OUT, '>>', "returns_$agent_id.txt" || die "Can't open output file";

my $ua  = LWP::UserAgent->new;
my $url = 'https://leads.insuranceagents.com/return_lead';

while ( <IN> )
  {
    chomp;

    $_ =~ s/^\s+//g;
    $_ =~ s/\s+$//g;

    my $email = ( $_ =~ /\@/ ) ? 1 : 0;
    if ( !$email ) { $_ =~ s/\D//g; }

    my $values;
    $values->{a}     = $agent_id;
    $values->{phone} = $_ if ( !$email && !$lead );
    $values->{email} = $_ if ( $email );
    $values->{l}     = $_ if ( $lead );

    my $response = $ua->post( $url, $values );
    my $content = $response->content;
    $content =~ s/[\n\r]//g;
    print OUT "$_,$content\n";
    print "$_ completed\n";
#    sleep 2;
  }

close OUT;
close IN;

