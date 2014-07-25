#!/usr/bin/env perl

use warnings;
use strict;

use lib "/u/apps/leads/current";
use lib "/u/apps/leads/current/admin";

use MIME::Lite;
use Try::Tiny;

open my $fh, '<', 'nationwide_email_list.csv';

my $smtp_servers = [ 'smtp1.insuranceagents.com', 'smtp4.insuranceagents.com' ];
my $emails_sent = 0;

my @file = <$fh>;

my $number_of_emails = scalar @file;

my $wait_interval = int ( 3600 * 7 / $number_of_emails );

my $from = '"InsuranceAgents.com" <nationwide@insuranceagents.com>';
my $subject = 'Crank It Up! -- InsuranceAgents.com';
my $type = 'text/html';
my $image = "<img border='0' src='https://leads.insuranceagents.com/track.pl?p=__PHONE__&e=__EMAIL__' width='1' height='1'>";
my $orig_message = <<END_OF_MESSAGE;
Hi __AGENT_NAME__,<br>
<br>
My name is Lev Barinskiy, I am the President of InsuranceAgents.com. I am reaching out to you today to make you aware of the new partnership between Nationwide Insurance and InsuranceAgents.com.  We specialize in generating high quality, real-time, Internet generated referrals of consumers looking to save money on insurance in your area. <br>
<br>
InsuranceAgents.com is one of the leading and fastest growing Insurance lead generation companies, and we are proud to be part of the Nationwide’s CRANK IT UP promotion.  We’ve helped thousands of Insurance Agents just like you, grow their book of business without spending a fortune on marketing and we are excited to tell you more about how we can help your agency reach its goals.<br>
<br>
As part of the CRANK IT UP promotion, you will be able to use our services for rates lower than we have ever offered, AND be eligible for up to 75% reimbursement from your Co-Op Marketing Team.*<br>
<br>
Check out these prices: (Remember, this special pricing structure is also eligible for up to a 75% Co-Op Reimbursement!*)<br>
<br>
Shared Referrals:<br>
&nbsp;&nbsp;   Standard Auto: \$4.99 base rate plus \$1.00 for each filter<br>
&nbsp;&nbsp;   Standard Home: \$6.00<br>
&nbsp;&nbsp;   Preferred Home Leads: \$7.00<br>
&nbsp;&nbsp;   Renters Leads: \$5.00<br>
&nbsp;&nbsp;   Condo Leads: \$5.00<br>
&nbsp;&nbsp;   Standard Life Leads: \$11.00<br>
&nbsp;&nbsp;   Preferred Life Leads: \$13.00<br>
<br>
Exclusive Referrals:<br>
&nbsp;&nbsp;   Auto: \$17.00 base rate plus for each \$1.00 filter.<br>
&nbsp;&nbsp;   Standard Home Leads: \$17.00<br>
&nbsp;&nbsp;   Preferred Home Leads: \$19.99<br>
&nbsp;&nbsp;   Renters Leads: \$12.00<br>
&nbsp;&nbsp;   Condo Leads: \$12.00<br>
&nbsp;&nbsp;   Standard Life Leads: \$22.00<br>
<br>
We currently have Business Growth specialists waiting to talk with you about our program and as a company, we are looking forward to working with you and your agency in the near future. To speak with one of our specialists, please call <a href="tel:877-225-3239>877-225-3239</a>. If we do not hear from you, please be on the look out for our call so that you can be one of the first to participate in this one of a kind program in your area.<br>
<br>
*Please refer to your internal Co-op Marketing Website for more details on the promotional 75% reimbursement offer.<br>
<br>
Sincerely,<br>
<br>
Lev Barinskiy<br>
<br>
InsuranceAgents.com<br>
309 S. 4th St.<br>
Suite 412<br>
Columbus, OH 43215<br>
<a href="tel:877-225-3239>877-225-3239</a><br>
<br>
Click <a href="http://unsubscribe.ko-marketing.com/unsubscribe">here</a> to be added to our Unsubscribe List<br>
<br>
$image<br>
END_OF_MESSAGE

foreach my $line ( @file )
  {
    chomp( $line );
    my ( $name, $id, $group, $phone, $email ) = split /,/, $line;
    next unless ( $email =~ /@/ );

    my $message = $orig_message;

    my ( $fname, $lname ) = split / /, $name, 2;
    $fname = ucfirst( lc $fname );

    $message =~ s/__AGENT_NAME__/$fname/g;
    $message =~ s/__EMAIL__/$email/g;
    $phone   =~ s/\D//g;
    $message =~ s/__PHONE__/$phone/g;

    my $server = $emails_sent % 2;
    my $email_server = $smtp_servers->[ $server ];

#    print "$email_server\n$fname\n$email\n$subject\n$message\n"; exit;
    my $smtp = MIME::Lite->new(
      From    => $from,
      To      => $email,
      Subject => "$subject",
      Type    => "$type",
      Data    => "$message", );
    
    try {
      $smtp->send( "smtp", $email_server );
    }
    catch {
      try {
        $server = !$server;
        $email_server =  $smtp_servers->[ $server ];
        $smtp->send( "smtp", $email_server );
      }
      catch {
        print "Email to $email failed: $_\n";
      };
    };

    $emails_sent++;
    sleep 1;
    #sleep $wait_interval;

  }

print "Done\n";
