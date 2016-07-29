#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use File::Basename;
use DateTime;

#Global Variables
my %RETCODES = ('OK' => 0, 'WARNING' => 1, 'CRITICAL' => 2, 'UNKNOWN' => 3);
my ( $pid, $ctime, $etime, $stime, $comm, $PSCMD, $service, $start, $dur, $periodbegin, $periodend, $period, $pbtime, $petime, $debug ) = "";
my $prog = basename($0);

# Help
sub help
{
    print "\nUsage : ./$prog -p process -s start time -d duration [-h]\n\n";
        print "Options :\n";
    print " -p\tName of the process to Grep for\n";
    print " -s\tStart time that we want to use to ensure the process started at the correct time\n";
    print " -d\tTime duration that we want to make sure the process does not run longer than\n";
    print " -t\tTime Period we want to perform the check within\n";
    print " -h, --help\tPrint this help screen\n";
    print " -debug\tWill print out the debug print information\n";
    print "\nExample : ./$prog -p nagios -s 08:00 -d 02:00:00 -t 00:00-04:00\n\n";
    exit $RETCODES{"UNKNOWN"};
}

sub check_args
{
        help if !(defined(@ARGV));

        # Set options
         GetOptions(    "help|h"    => \&help,
                                        "p=s"           => \$service,
                                        "s=s"           => \$start,
                                        "d=s"           => \$dur,
                                        "t=s"           => \$period,
                                        "debug!"        => \$debug);

        unless (($service) and ($start) and ($dur) and ($period))
        {
                        &help;
        }
}

check_args();
($periodbegin, $periodend) = split(/-/,$period);
$PSCMD = "ps -e -o pid,stime,etime,comm | grep $service | grep -v grep";
$ctime = `date +%R`;
if ($debug){print "Service: $service, Start time: $start, Duration: $dur, Period: $period, Current Time: $ctime, Period Begin: $periodbegin, Period End: $periodend\n"};

open (PS, "$PSCMD |") or die "\nCould not open ps cmd: $!";
while (<PS>) {
        chomp;
        ($pid, $stime, $etime,$comm) = split;
        if ($debug){print "PID- $pid,\tSTIME- $stime,\tETIME- $etime,\tProcess- $comm\n"};

}

if ( $ctime ge $periodbegin && $ctime le $periodend  ) {
    if ($pid eq "") {
        print "Critical: Process not running! Start time: $start, Duration: $dur, Period: $period, Current Time: $ctime\n"; exit 2;
        }
    else {
            if ($debug){print "Process is running $pid\n"};
            if ($stime eq $start) {
                    if ($debug){print "Proccess $comm started on time\n"};
                    if ($etime ge $dur) {
                            print "Warning: Process is running but exceeds duration!! Start time: $start, Duration: $dur, Period: $period, Current Time: $ctime\n"; exit 1;
                    }
                    else {
                            print "OK: Process is running but does not exceed duration. Start time: $start, Duration: $dur, Period: $period, Current Time: $ctime\n"; exit 0;
                    }
                    }
            else {
                    print "Warning: Process is running but $comm did not start on time. Start time: $start, Duration: $dur, Period: $period, Current Time: $ctime\n"; exit 1;
            }
   
    }
}
else {
    print "OK: The Current Time is NOT in the Check Time Period. Start time: $start, Duration: $dur, Period: $period, Current Time: $ctime\n"; exit 0;
}