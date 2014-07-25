#!/usr/bin/env perl

###############################################################################
#
# Perl script to repeatedly poll SHOW FULL PROCESSLIST to view running SQL
# statements.
#
# Author  : Partha Dutta
# Version : 1.0
# Date    : July 22, 2006
#
###############################################################################

use warnings;

use DBI;
use Time::HiRes qw(usleep ualarm gettimeofday tv_interval);
use Getopt::Long;

# Declare all possible command line options
my $help = 0;
my $host = "";
my $port = 3306;
my $user = "";
my $password = "";
my $count = 1000;
my $interval = 500;

Getopt::Long::GetOptions(
    "help|\?"        => \$help,
    "h|host=s"       => \$host,
    "P|port=i"       => \$port,
    "u|user=s"       => \$user,
    "password:s"     => \$password,
    "c|count=i"      => \$count,
    "i|sleep=i"      => \$interval
) or printhelp();

printhelp() if ($help);

my %o = ();         # All final options kept here

$o{'host'} = $host if ($host ne "");
$o{'port'} = $port if ($port ne "");
$o{'user'} = $user if ($user ne "");
$o{'password'} = $password if ($password ne "");
$o{'count'} = $count if ($count ne "");
$o{'sleep'} = $interval if ($interval ne "");

# Set defaults if values are still missing
$o{'host'} ||= "localhost";
$o{'port'} ne "" || ($o{'port'} = 3306);
$o{'user'} ||= "root";
$o{'count'} ne "" || ($o{'count'} = 1000);
$o{'sleep'} ne "" || ($o{'sleep'} = 500);

printhelp() if (!defined $o{'password'} || $o{'password'} eq "");

# Connect to the database.
# This needs to be changed based on the target to connect to.
$db_handle = DBI->connect("dbi:mysql:host=$o{'host'};port=$o{'port'}", $o{'user'}, $o{'password'}) or
    die("Could not connect: $DBI::errstr\n");

# Find out our current connection id.
@conn_id = $db_handle->selectrow_array("SELECT CONNECTION_ID()") or
    die("Failed to get connid: $DBI::errstr\n");


$sth = $db_handle->prepare("SHOW FULL PROCESSLIST") or
    die("Could not prepare stmt: $DBI::errstr\n");

while ( 1 ) {
#for ($n = 0; $n < $o{'count'}; $n++) {    
	usleep($o{'sleep'}*1000);
    $sth->execute() or die("Failed to exec: $DBI::errstr\n");
    while (@data = $sth->fetchrow_array()) {
        $mysql_id = $data[0];
        next if ($mysql_id == $conn_id[0]);
        $mysql_user = $data[1];
        $mysql_host = $data[2];
        $mysql_db = $data[3];
        $mysql_command = $data[4];
        $mysql_time = $data[5];
        $mysql_state = $data[6];
        $mysql_info = $data[7];

        next if ($mysql_command eq "Connect" || $mysql_command eq "Sleep" ||
                 $mysql_command eq "Binlog Dump");

        ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
            localtime;
        $wday = $isdst = $yday = 0;

        ($seconds , $milliseconds) =
            gettimeofday;
        $seconds = 0;

        printf("%d-%s-%d %02d:%02d:%02d.%06s|%d|%s|%s|%s|%s|%d|%s|%s\n",
            $year+1900, ($mon > 9 ? $mon : "0" . $mon),
            ($mday > 9 ? $mday : "0" . $mday),
            ($hour > 9 ? $hour : "0" . $hour),
            ($min > 9 ? $min : "0" . $min),
            ($sec > 9 ? $sec : "0" . $sec),
            $milliseconds,
            $mysql_id, $mysql_user, $mysql_host, $mysql_db,
            $mysql_command, $mysql_time, $mysql_state,
            $mysql_info);
    }
    $sth->finish();
}
$db_handle->disconnect();


sub printhelp {
    print "Usage : perl proclist.pl [options]\n";
    print "  -h, --host=hostname             Connect to host (localhost)\n";
    print "  -P, --port=#                    Port number to use for connection (3306)\n";
    print "  -u, --user=name                 User for login (root)\n";
    print "  --password=name                 Password for user\n";
    print "  -c, --count=#                   # of iterations (1000)\n";
    print "  -i, --sleep=#                   Delay in ms between iterations (500)\n";
    exit 0;
}