#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;
use LWP::UserAgent;

my $xml_file = $ARGV[ 0 ] || "xml_dumps";
my $file;
my $started = 0;
my $ua      = LWP::UserAgent->new;
my $VAR1;

$|++;

open FILE, "<$xml_file" or die "Can't open file: $!";

while ( <FILE> )
  {
    chomp;
    if ( /XML Post/ )
      {
        s/XML Post: //g;
        $started = 1;
      }

    if ( $started )
      {
        $file .= $_;
        if ( /\}\;/ )
          {
            $started = 0;
            my $password = undef;
            my $user     = undef;
            my $id       = '';
            my $campaign = 'iw';
my $xml='<\?xml version=\"1.0\" encoding=\"UTF-8\"\?>\
<lead_health>\
	\
	<distribution sold=\"2\">\
\
	\
	\
		<directive agent=\"566                      MPLY5506\" type=\"exclude\"/>\
		\
		<directive agent=\"999999999                XXXX0000\" company=\"Liberty Mutual\" type=\"exclude\"/>\
	\
	</distribution>\
		\
	<addr>107 Tomahawk Drive</addr>\
\
	<city>Summerville</city>\
	\
	<dui>false</dui>\
	<email>testing701@hometownquotes.com</email>\
	<expectant>false</expectant>\
	<fname>Albert</fname>\
	<has_cond>false</has_cond>\
	<hospital>false</hospital>\
	<how_long_ins>6 Months - 1 Year</how_long_ins>\
	<insco>Allstate</insco>\
	<insured>true</insured>\
	<lname>Thomason</lname>\
	\
	<medication>false</medication>\
	<occupation>Government</occupation>\
	<phone>8438757701</phone>\
	<phone2>8438757701</phone2>\
	<physician>false</physician>\
	<plan>Individual Family</plan>\
	<state>SC</state>\
	<zip>29483</zip>\
	\
				<applicant>\
					<dob>1970-07-30</dob>\
					<gender>M</gender>\
					<height>\
						<feet>6</feet>\
						<inches>0</inches>\
					</height>\
					<relation>Primary</relation>\
					<smoker>false</smoker>\
					<weight>142</weight>\
				</applicant>\
			\
				<applicant>\
					<dob>1969-06-29</dob>\
					<gender>F</gender>\
					<height>\
						<feet>5</feet>\
						<inches>4</inches>\
					</height>\
					<relation>Spouse</relation>\
					<smoker>false</smoker>\
					<weight>120</weight>\
				</applicant>\
			\
</lead_health>';
            #my $tmp = eval $file; print $file . "\n";
            #print Dumper($tmp); exit;
            #my $password = $VAR1->{pw}  || undef;
            #my $user     = $VAR1->{a}   || undef;
            #my $id       = $VAR1->{id}  || undef;
            #my $campaign = $VAR1->{c}   || undef;
            ###my $xml      = $VAR1->{xml} || undef;
            my $orig_xml = $xml;
            my $key      = '78d83a543a79fb6ab668739f46bf1805';
            $xml =~ s|<fname>.+?</fname>|<fname></fname>|g;
            $xml =~ s|<lname>.+?</lname>|<lname></lname>|g;
            $xml =~ s|<addr>.+?</addr>|<addr></addr>|g;
            $xml =~ s|<city>.+?</city>|<city></city>|g;
            $xml =~ s|<state>.+?</state>|<state></state>|g;
            $xml =~ s|<phone>.+?</phone>|<phone></phone>|g;
            $xml =~ s|<email>.+?</email>|<email></email>|g;

            print $xml; exit;

            my $form_values = { a        => $user,
                                pw       => $password,
                                id       => $id,
                                campaign => $campaign,
                                key      => $key,
                                xml      => $xml, };

            my $return =
              $ua->post( "https://pingtest1.insuranceagents.com/ping",
                         $form_values );

            #print Dumper($return);
            print $return->content;
            exit;
            if ( $return->is_success )
              {
                my $string = $return->content;
                print $string . "\n";
                $string =~ m|<lead>(.*)</lead>|;
                my $ping_id = $1;

                $form_values = { a        => $user,
                                 pw       => $password,
                                 id       => $id,
                                 campaign => $campaign,
                                 key      => $key,
                                 action   => 'sell',
                                 ping_id  => $ping_id,
                                 xml      => $orig_xml, };

                $return = $ua->post( "https://pingtest1.insuranceagents.com/pingtest",
                                     $form_values );

                if ( $return->is_success )
                  {
                    $string = $return->content;
                    print $string . "\n";
                  }
                else
                  {
                    print localtime( time )
                      . "\tERROR:    "
                      . $return->status_line . "\n";
                  }
              }
            else
              {
                print localtime( time )
                  . "\tERROR:    "
                  . $return->status_line . "\n";
              }

            $file = "";
          }
      }
  }

close FILE;

