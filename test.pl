#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use File::Basename;

my %RETCODES = ('OK' => 0, 'WARNING' => 1, 'CRITICAL' => 2, 'UNKNOWN' => 3);
my ( $pid, $etime, $stime, $comm, $PSCMD, $service, $start, $dur) = "";
my $prog = basename($0);

check_args();

# Help
sub help
{
    print "Usage : $prog -p process -s start time -d duration [-h]\n\n";
	print "Options :\n";
    print " -p\tName of the process to Grep for\n";
    print " -s\tStart time that we want to use to ensure the process started at the correct time\n";
    print " -d\tTime duration that we want to make sure the process does not run longer than\n";
	print " -h, --help\tPrint this help screen\n";
    print "\nExample : $prog -p nagios -s 08:00 -d 02:00:00 \n";
    exit $RETCODES{"UNKNOWN"};
}

sub check_args 
{
	help if !(defined(@ARGV));

	# Set options
	 GetOptions( 	"help|h"    => \&help,
					"p=s"   	=> \$service,
					"s=s"		=> \$start,
					"d=s"		=> \$dur);

	unless (($service) and ($start) and ($dur))
	{
			&help;
	}
}

$PSCMD = "ps -e -o pid,stime,etime,comm | grep $service | grep -v grep";

print "Service: $service, Start time: $start, Duration: $dur\n";

open (PS, "$PSCMD |") or die "\nCould not open ps cmd: $!";
while (<PS>) {
	chomp;
	($pid, $stime, $etime,$comm) = split;
	print "PID- $pid,\tSTIME- $stime,\tETIME- $etime,\tProcess- $comm\n";

}

if ($pid eq "") {print "Critical: Process not running!\n"; exit 2;}
else {
	print "Process is running $pid\n";
	
	if ($stime eq $start) {
		print "Proccess $comm started on time\n"; 
		if ($etime ge $dur) {
			print "Warning: Process exceeds runtime!!!\n"; exit 1;
		}
		else {
			exit 0;
		}
		}
	else {
		print "Warning: Process $comm did not start on time\n"; exit 1;
	}




}
