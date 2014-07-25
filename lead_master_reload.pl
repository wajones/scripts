#!/usr/local/ActivePerl-5.12/bin/perl

use DBI;

my $staging_dbh = DBI->connect("dbi:mysql:database=tmp_leads;host=192.168.48.21;port=3306", "bjones", "Blue Bison");
my $production_dbh = DBI->connect("dbi:mysql:database=leads;host=localhost;port=3306", "bjones", "Blue Bison");

my $lead_id = $staging_dbh->selectrow_hashref("select max(lead_id) as max, min(lead_id) as min from tmp_leads.lead_master");

my $number_of_leads = 2500;
my $lead_id->{current} = $lead_id->{max} - $number_of_leads;

while ( $lead_id->{current} >= $lead_id->{min} )
  {
	my $lead_list = $staging_dbh->selectall_arrayref( "select lead_id, received from tmp_leads.lead_master
													   where lead_id > $lead_id->{current} and lead_id <= $lead_id->{max} 
													   order by lead_id desc",
													   { Slice => {} } );
													
	my $count = 0;
	my $sth = $production_dbh->prepare( "update lead_master set received = ? where lead_id = ?" );
	
	foreach my $lead ( @$lead_list )
	  {
		my $rc = $sth->execute( $lead->{received}, $lead->{lead_id} );
		if ( $rc != 1 ) { print "ERROR on lead $lead->{lead_id} . . . EXITING\n\n"; exit; }
		$count++;
		print $lead->{lead_id};
		( $count % 10 ) ? print " " : print "\n";
	  }
	
	$max_lead_id = $current_lead_id;
	$current_lead_id = ( $max_lead_id - $number_of_leads > $min_lead_id ) ? $max_lead_id - $number_of_leads : $min_lead_id;
  }
 