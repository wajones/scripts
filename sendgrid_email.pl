#!/usr/bin/env perl

use warnings;
use strict;

use lib "/u/apps/leads/current";
use lib "/u/apps/leads/current/admin";

use MIME::Entity;
use Net::SMTP;
use Try::Tiny;
use DBI;

my $smtp_servers = [ 'smtp.sendgrid.net' ];
my $emails_sent  = 0;

my $from         = '"InsuranceAgents.com" <leads@insuranceagents.com>';
my $subject      = 'SUBJECT GOES HERE';
my $text_message = <<END_OF_TEXT_MESSAGE;

END_OF_TEXT_MESSAGE

my $html_message = <<END_OF_HTML_MESSAGE;

END_OF_HTML_MESSAGE

my $dbh = DBI->connect( 'DBI:mysql:email_lists', 'nate', 'makeitrain10' )
  || die "Could not connect to database:  $DBI::errstr";
my $sth = $dbh->prepare(
    'SELECT agent_full_name, fname, lanme, addr1, addr2, city, county, state, zip, phone1, phone2, email, dob, gender FROM master_list'
);
my $sth->execute;

while ( my $result = $sth->fetchrow_hashref() )
  {
    $result->{fname} =~ s/\(.*\)//g;
    $result->{lname} =~ s/\(.*\)//g;
    $result->{fname} =~ s/^\s+//g;
    $result->{lname} =~ s/^\s+//g;
    $result->{fname} =~ s/\s+$//g;
    $result->{lname} =~ s/\s+$//g;
    $result->{fname} = ucfirst( lc $result->{fname} );
    $result->{lname} = ucfirst( lc $result->{lname} );
    $result->{phone1} =~ s/\D//g if ( $result->{phone1} =~ /\d/ );
    $result->{phone2} =~ s/\D//g if ( $result->{phone2} =~ /\d/ );

    $message = $html_message;
    $message =~ s/__AGENT_FULL_NAME__/$result->{agent_full_name}/g;
    $message =~ s/__FNAME__/$result->{fname}/g;
    $message =~ s/__LNAME__/$result->{lname}/g;
    $message =~ s/__ADDR1__/$result->{addr1}/g;
    $message =~ s/__ADDR2__/$result->{addr2}/g;
    $message =~ s/__CITY__/$result->{city}/g;
    $message =~ s/__COUNTY__/$result->{county}/g;
    $message =~ s/__STATE__/$result->{state}/g;
    $message =~ s/__ZIP__/$result->{zip}/g;
    $message =~ s/__PHONE1__/$result->{phone1}/g;
    $message =~ s/__PHONE2__/$result->{phone2}/g;
    $message =~ s/__EMAIL__/$result->{email}/g;
    $message =~ s/__DOB__/$result->{dob}/g;
    $message =~ s/__GENDER__/$result->{gender}/g;
    $html_message = $message;

    $message = $text_message;
    $message =~ s/__AGENT_FULL_NAME__/$result->{agent_full_name}/g;
    $message =~ s/__FNAME__/$result->{fname}/g;
    $message =~ s/__LNAME__/$result->{lname}/g;
    $message =~ s/__ADDR1__/$result->{addr1}/g;
    $message =~ s/__ADDR2__/$result->{addr2}/g;
    $message =~ s/__CITY__/$result->{city}/g;
    $message =~ s/__COUNTY__/$result->{county}/g;
    $message =~ s/__STATE__/$result->{state}/g;
    $message =~ s/__ZIP__/$result->{zip}/g;
    $message =~ s/__PHONE1__/$result->{phone1}/g;
    $message =~ s/__PHONE2__/$result->{phone2}/g;
    $message =~ s/__EMAIL__/$result->{email}/g;
    $message =~ s/__DOB__/$result->{dob}/g;
    $message =~ s/__GENDER__/$result->{gender}/g;
    $text_message = $message;

    my $email_server = $smtp_servers->[ 0 ];

    #    print "$email_server\n$fname\n$email\n$subject\n$message\n"; exit;
    my $email = MIME::Entity->build( From     => $from,
                                     To       => $result->{email},
                                     Subject  => $subject,
                                     Type     => 'multipart/alternative',
                                     Encoding => '-SUGGEST' );

    $email->attach( Type     => 'text/plain',
                    Encoding => '-SUGGEST',
                    Data     => $text_message );
    $email->attach( Type     => 'text/html',
                    Encoding => '-SUGGEST',
                    Data     => $html_message );

    my $success = 1;

    print "Sending email to $result->{email} ";

    try
    {
        my $smtp = Net::SMTP->new( $email_server,
                                   Port    => 587,
                                   Timeout => 20,
                                   Hello   => 'insuranceagents.com' );
        $smtp->auth( 'aoconnor@insuranceagents.com', 'simple2011' );
        $smtp->mail( $from );
        $smtp->to( $result->{email} );
        $smtp->data( $email->stringify );
        $smtp->quit;
    }
    catch
    {
        print "Email to $email failed: $_\n";
        $success = 0;
        print "FAILED\n";
    };

    $dbh->do( 'INSERT INTO emails_sent ( email ) VALUES ( ? )',
              $result->{email} ) if ( $success );
    print "SUCCESS\n" if ( $success );

    $emails_sent++;

    sleep 1;
#    sleep $wait_interval;

  }

print "Done\n";
