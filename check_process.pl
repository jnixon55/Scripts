#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use File::Basename;
use DateTime;

#Global Variables
my %RETCODES = ('OK' => 0, 'WARNING' => 1, 'CRITICAL' => 2, 'UNKNOWN' => 3);
my ( $stuff, $file, $line, $pid, $ctime, $cdate, $etime, $stime, $comm, $lrdate, $PSCMD, $TOUCH, $service,
     $start, $startbuf1, $startbuf2, $dt, $hr, $min, $dur, $periodbegin, $periodend, $period, $pbtime, $petime,
     $debug, $count ) = "";
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
                    "p=s"       => \$service,
                    "s=s"       => \$start,
                    "d=s"       => \$dur,
                    "t=s"       => \$period,
                    "debug!"    => \$debug);
    unless (($service) and ($start) and ($dur) and ($period))
    {
                    &help;
    }
}

check_args();
$file = "/tmp/$prog.$service";
($periodbegin, $periodend) = split(/-/,$period);
$PSCMD = "ps -e -o pid,stime,etime,comm | grep $service | grep -v grep";
$ctime = `date +%R`;
$cdate = `date +%F`;
($hr, $min) = split(/:/,$start);
$dt = DateTime->new(
    year   => 1,
    month  => 1,
    day    => 1,
    hour => "$hr",
    minute => "$min"
);
$dt->subtract(minutes => 5);
($stuff,$startbuf1) = split(/T/,$dt);
$dt->add(minutes => 10);
($stuff,$startbuf2) = split(/T/,$dt);
if ($debug){print "### Start buffer 1: $startbuf1 - Start buffer 2: $startbuf2 ###\n"};
if ($debug){print "### Service: $service, Start time: $start, Duration: $dur, Period: $period, Current Time: $ctime, Period Begin: $periodbegin, Period End: $periodend ###\n"};

open (PS, "$PSCMD |") or die "\nCould not open ps cmd: $!";
while (<PS>) {
        chomp;
        ($pid, $stime, $etime, $comm) = split;
        if ($debug){print "PID- $pid,\tSTIME- $stime,\tETIME- $etime,\tProcess- $comm\n"};
}

if ($ctime lt $periodbegin) {
    if ($debug){print "### The Current Time is BEFORE the Check Time Period Begin. Start time: $start, Duration: $dur, Period Begin: $periodbegin, Current Time: $ctime ###\n"};
    print "OK: The Current Time is BEFORE the Check Time Period Begin. Start time: $start, Duration: $dur, Period Begin: $periodbegin, Current Time: $ctime\n"; exit $RETCODES{"OK"};
}
elsif ( $ctime ge $periodbegin && $ctime le $periodend  ) {
    if ($debug){print "### The Current Time is IN the Check Time Period. Start time: $start, Duration: $dur, Period: $period, Current Time: $ctime ###\n"};
    if (! defined $pid) {
        if (-e $file) {
            #code for Process no longer running but touch file exists
            #Get the info from the file so we can see when it started.
            if ($debug){print "### In the Not defined pid and the touch file exists section ###\n"};
            open (FH, "$file") or die "\nCould not open file $file: $!";
            while (<FH>) {
                chomp;
                if ($debug){print "### Before split command $_ ###\n"};
                ($pid,$stime,$etime,$comm,$lrdate) = split(/\t/, $_);
            }
            close(FH);
            if ($debug){print "### In the Info Read from the touch file exists section ###\n"};
            if ($debug){print "### Last Run Date: $lrdate PID: $pid Start Time: $stime Duration: $etime Process: $comm current date: $cdate ###\n"};
            if ($cdate = $lrdate) {
                print "OK: Process IS NOT Running, but it Did Start on Time earlier today! Last Run Date: $lrdate, Start time: $stime, Duration: $etime, Period: $period, Current Time: $ctime\n"; exit $RETCODES{"OK"};
            }
            else {
                print "Critical: Process IS NOT Running, and it Did NOT run earlier today! Last Run Date: $lrdate, Start time: $stime, Duration: $etime, Period: $period, Current Time: $ctime\n"; exit $RETCODES{"CRITICAL"};
            }
        }
        else {
            #code for Process no longer running but touch file does NOT exists
            if ($debug){print "### In the Not defined pid and the touch file does NOT exists section ###\n"};
            print "Critical: Process HAS NOT Started running! Start time: $start, Duration: $dur, Period: $period, Current Time: $ctime\n"; exit $RETCODES{"CRITICAL"};
        }
    }
    else {
        if ($debug){print "### In the Defined pid section ###\n"};
        if ($debug){print "### Process is running $pid ###\n"};
        # Cleanup of the etime returned from the PSCMD
        $count = ($etime =~ tr/://);
        if ($debug){print "### Count of ':': $count ###\n"};
        if ($count lt 2) {
            $etime = "00:".$etime;
        }
        if ($debug){print "### ETime Check: $etime ###\n"};

        open (FH, ">$file") or die "\nCould not open file $file: $!";
        print FH "$pid\t$stime\t$etime\t$comm\t$cdate";
        close FH;
        if ($stime ge $startbuf1 && $stime le $startbuf2) {
            if ($debug){print "### Proccess $comm started on time ###\n"};
            if ($etime ge $dur) {
                print "Warning: Process is running but exceeds duration!! Start time: $start, Duration: $dur, Period: $period, Current Time: $ctime\n"; exit $RETCODES{"WARNING"};
            }
            else {
                print "OK: Process is running but does not exceed duration. Start time: $start, Duration: $dur, Period: $period, Current Time: $ctime\n"; exit $RETCODES{"OK"};
            }
        }
        else {
            print "Warning: Process is running but $comm did not start on time. Start time: $start, Duration: $dur, Period: $period, Current Time: $ctime\n"; exit $RETCODES{"WARNING"};
        }
    }
}
else  {
    if ($debug){print "### The Current Time is AFTER the Check Time Period End. Start time: $start, Duration: $dur, Period End: $periodend, Current Time: $ctime ###\n"};
    print "OK: The Current Time is AFTER the Check Time Period End. Start time: $start, Duration: $dur, Period End: $periodend, Current Time: $ctime\n"; exit $RETCODES{"OK"};
}
