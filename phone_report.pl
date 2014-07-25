#!/usr/bin/env perl

use warnings;
use strict;

use DBI;
use CGI;
use Data::Dumper;

my $q = new CGI;

my $date = "$ARGV[ 0 ]" || "now()";
chomp $date;

my $db =
  DBI->connect( "dbi:mysql:database=asteriskcdrdb;host=192.168.2.10;port=3306",
                "bjones", "Blue Bison" );

my $calls_to_voicemail = $db->selectall_hashref(
	"select count(*) as number_of_calls,
			left(lastdata,3) as extension
	 from cdr
	 where date(calldate)=date(now()) and
	       lastapp = 'VoiceMail'
	 group by extension", "extension");
	
my $calls_out = $db->selectall_hashref(
    "select count(*) as number_of_calls, 
            round(sum(duration)/60) as total_call_time, 
		    substring(channel, 5, 3) as extension, 
		    round(sum(duration)/count(*)/60) as ave_call_time 
	from cdr 
	where date(calldate)=date('$date') and 
	      dst!='*97' and  
	      dcontext = 'from-internal' 
	group by extension", "extension" );

my $calls_out_answered = $db->selectall_hashref(
    "select count(*) as number_of_calls, 
            round(sum(duration)/60) as total_call_time, 
	    	substring(channel, 5, 3) as extension, 
	    	round(sum(duration)/count(*)/60) as ave_call_time 
	from cdr 
	where date(calldate)=date('$date') and 
	      dst!='*97' and  
	      dcontext = 'from-internal' and
	      disposition = 'ANSWERED'
	group by extension", "extension" );
																				
my $calls_out_unanswered = $db->selectall_hashref(
    "select count(*) as number_of_calls, 
            round(sum(duration)/60) as total_call_time, 
	    	substring(channel, 5, 3) as extension, 
	    	round(sum(duration)/count(*)/60) as ave_call_time 
	from cdr 
	where date(calldate)=date('$date') and 
	      dst!='*97' and  
	      dcontext = 'from-internal' and
	      disposition != 'ANSWERED'
	group by extension", "extension" );
																														
my $hot_leads_call_in = $db->selectall_hashref(
    "select count(*) as number_of_calls, 
			round(sum(duration)/60) as total_call_time, 
			substring(dstchannel, 5, 3) as extension, 
			round(sum(duration)/count(*)/60) as ave_call_time_seconds 
	 from cdr 
	 where date(calldate)=date('$date') and 
		   dcontext = 'ext-group' and 
		   dst=603 and
		   duration > 0
	 group by extension", "extension" );

my $queue_calls_in = $db->selectall_hashref(
    "select count(*) as number_of_calls, 
        	round(sum(duration)/60) as total_call_time, 
        	substring(dstchannel, 5, 3) as extension, 
        	round(sum(duration)/count(*)/60) as ave_call_time_seconds 
     from cdr 
     where date(calldate)=date('$date') and 
           dcontext = 'ext-group' and 
           dst=604 and
           duration > 0
     group by extension", "extension" );
     
my $cs_calls_in = $db->selectall_hashref(
    "select count(*) as number_of_calls, 
	        round(sum(duration)/60) as total_call_time, 
	        substring(dstchannel, 5, 3) as extension, 
	        round(sum(duration)/count(*)/60) as ave_call_time_seconds 
	from cdr 
	where date(calldate)=date('$date') and 
	      dcontext = 'ext-group' and 
	      dst=750 and
		  duration > 0
	group by extension", "extension" );

my $did_calls_in = $db->selectall_hashref(
    "select count(*) as number_of_calls, 
	 	    round(sum(duration)/60) as total_call_time, 
	 	    dst as extension, 
	 	    round(sum(duration)/count(*)/60) as ave_call_time_seconds 
	from cdr 
	where date(calldate)=date('$date') and 
	      dcontext = 'from-did-direct' and
		  lastapp = 'Dial'
	group by extension", "extension" );

#print Dumper($calls_out); exit;
my ( $total_calls, $hot_calls, $queue_calls, $did_calls, $total_time,
     $ave_time, $count );

foreach my $extension ( sort keys %$calls_out,
                        keys %$hot_leads_call_in,
                        keys %$queue_calls_in,
                        keys %$cs_calls_in,
                        keys %$did_calls_in,
 						keys %$calls_to_voicemail )
  {
	next unless ( $extension =~ /\d{3}/ );
	next if ( defined $count->{$extension} && $count->{$extension} >= 1);

    $total_calls->{$extension}                			 ||= 0;
    $hot_calls->{$extension}                  			 ||= 0;
    $queue_calls->{$extension}                			 ||= 0;
    $did_calls->{$extension}                  			 ||= 0;
    $calls_out->{$extension}{number_of_calls} 			 ||= 0;
    $calls_to_voicemail->{$extension}{number_of_calls}   ||= 0;
	$calls_out_answered->{$extension}{number_of_calls}   ||= 0;
	$calls_out_unanswered->{$extension}{number_of_calls} ||= 0;
    $total_time->{$extension}                 			 ||= 0;
    $ave_time->{$extension}                   			 ||= "0.00";

    $total_calls->{$extension} += $calls_out->{$extension}{number_of_calls}
      if ( $calls_out->{$extension}{number_of_calls} );
    $total_calls->{$extension} +=
      $hot_leads_call_in->{$extension}{number_of_calls}
      if ( $hot_leads_call_in->{$extension}{number_of_calls} );
    $total_calls->{$extension} += $queue_calls_in->{$extension}{number_of_calls}
      if ( $queue_calls_in->{$extension}{number_of_calls} );
    $total_calls->{$extension} += $cs_calls_in->{$extension}{number_of_calls}
      if ( $cs_calls_in->{$extension}{number_of_calls} );
    $total_calls->{$extension} += $did_calls_in->{$extension}{number_of_calls}
      if ( $did_calls_in->{$extension}{number_of_calls} );

    $hot_calls->{$extension} +=
      $hot_leads_call_in->{$extension}{number_of_calls}
      if ( $hot_leads_call_in->{$extension}{number_of_calls} );
    $queue_calls->{$extension} += $queue_calls_in->{$extension}{number_of_calls}
      if ( $queue_calls_in->{$extension}{number_of_calls} );
    $queue_calls->{$extension} += $cs_calls_in->{$extension}{number_of_calls}
      if ( $cs_calls_in->{$extension}{number_of_calls} );
    $did_calls->{$extension} += $did_calls_in->{$extension}{number_of_calls}
      if ( $did_calls_in->{$extension}{number_of_calls} );

    $total_time->{$extension} += $calls_out->{$extension}{total_call_time}
      if ( $calls_out->{$extension}{total_call_time} );
    $total_time->{$extension} +=
      $hot_leads_call_in->{$extension}{total_call_time}
      if ( $hot_leads_call_in->{$extension}{total_call_time} );
    $total_time->{$extension} += $queue_calls_in->{$extension}{total_call_time}
      if ( $queue_calls_in->{$extension}{total_call_time} );
    $total_time->{$extension} += $cs_calls_in->{$extension}{total_call_time}
      if ( $cs_calls_in->{$extension}{total_call_time} );
    $total_time->{$extension} += $did_calls_in->{$extension}{total_call_time}
      if ( $did_calls_in->{$extension}{total_call_time} );

    $ave_time->{$extension} =
      ( $total_calls->{$extension} == 0 )
      ? 0
      : $total_time->{$extension} / $total_calls->{$extension};
    $ave_time->{$extension} = sprintf( "%.2f", $ave_time->{$extension} );

	$count->{$extension}++;
  }

print $q->header;
print $q->start_html;
print "<table>\n";
print "<tr>\n";
print
  	"<th>Extension</th>
	 <th>Total Calls</th>
	 <th>Hot Calls</th>
	 <th>Queue Calls</th>
	 <th>Direct dial in Calls</th>
	 <th>Calls to Voice Mail</th>
	 <th>Calls Out Total</th>
	 <th>Calls Out Answered</th>
	 <th>Calls Out Not Answered</th>
	 <th>Total Time</th>
	 <th>Average Time</th>\n";
print "</tr>\n";

foreach my $extension ( sort keys %$total_calls )
  {
	next unless ( $extension =~ /\d{3}/ );
    print "<tr>\n";
	print " <td>$extension</td>
		    <td>$total_calls->{$extension}</td>
			<td>$hot_calls->{$extension}</td>
			<td>$queue_calls->{$extension}</td>
			<td>$did_calls->{$extension}</td>
			<td>$calls_to_voicemail->{$extension}{number_of_calls}</td>
			<td>$calls_out->{$extension}{number_of_calls}</td>
			<td>$calls_out_answered->{$extension}{number_of_calls}</td>
			<td>$calls_out_unanswered->{$extension}{number_of_calls}</td>
			<td>$total_time->{$extension}</td>
			<td>$ave_time->{$extension}</td>\n";
	print "</tr>\n";
  }

print "</table>\n";
print $q->end_html;
