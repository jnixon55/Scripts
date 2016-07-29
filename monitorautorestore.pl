#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use File::Basename;
use DateTime;

my %RETCODES = ('OK' => 0, 'WARNING' => 1, 'CRITICAL' => 2, 'UNKNOWN' => 3);
my $file = "/Users/jeromenixon/Dropbox/Linux Share/scripts/time.txt";
my $line = "";
my $prog = basename($0);
my $debug = "";
my $period = "";
my $ctime = ""; 
my $periodbegin = "";
my $periodend = "";

#Help
sub help
{
 print "\nUsage : ./$prog -t Time Period [-h]\n\n";
 print "Options :\n";
 print " -t\tTime Period we want to perform the check within\n";
 print " -h, --help\tPrint this help screen\n";
 print " -debug\tWill print out the debug print information\n";
 print "\nExample : ./$prog  -t 00:00-04:00\n\n";
 exit $RETCODES{"UNKNOWN"};
}


sub check_args
{
    #help if !(defined(@ARGV));
    # Set options
     GetOptions(    "help|h"    => \&help,
                    "t=s"       => \$period,
                    "debug!"    => \$debug);
    unless ($period)
    {
                    &help;
    }
}

check_args();
$ctime = `date +%R`;
($periodbegin, $periodend) = split(/-/,$period);
if ($ctime lt $periodbegin) {
    if ($debug){print "### The Current Time is BEFORE the Check Time Period Begin. Period Begin: $periodbegin, Current Time: $ctime ###\n"};
    print "OK: The Current Time is BEFORE the Check Time Period Begin. Period Begin: $periodbegin, Current Time: $ctime\n"; exit $RETCODES{"OK"};
	}
	elsif ( $ctime ge $periodbegin && $ctime le $periodend  ) {
 	   if ($debug){print "### The Current Time is IN the Check Time Period. Period: $period, Current Time: $ctime ###\n"};
 
#This is where the the file opens time.txt
open (FH, "$file") or die "\nCould not open file $file: $!";
            while (<FH>) {
                chomp;
                	$line = $_;
            }



#print "$line\n";

if ($line =~ "start scp...") {
	print "OK: scp started\n";
	 exit $RETCODES{"OK"};
		} 
		
if ($line =~ "scp completed...") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Unicorn file exists. Restore continues.") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}		
		elsif ($line =~ "Unicorn file doesn't exist, will cause error mentioning Permissions. Restore aborted.") {
			print "WARNING: $line\n";
	 			exit $RETCODES{"WARNING"};
			}

if ($line =~ "Unicorn-3rdparty file exists. Restore continues.") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}
		elsif ($line =~ "Unicorn-3rdparty file doesn't exist, will cause error mentioning Permissions. Restore aborted") {
			print "WARNING: $line\n";
	 			exit $RETCODES{"WARNING"};
			}

if ($line =~ "Zebra file exists. Restore continues.") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}
		elsif ($line =~ "Zebra file doesn't exist, will cause error mentioning Permissions. Restore aborted.") {
			print "WARNING: $line\n";
	 			exit $RETCODES{"WARNING"};
			}	

if ($line =~ "Tomcat stopped on cycawspreapp31...") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Tomcat stopped on cycawspreapp32...") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "PostgreSQL stopped...") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "PGBouncer stopped...") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Postgres started...") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Start restore process...") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Dropping Databases") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Creating Databses") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "pg_restore unicorn begin") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "pg_restore unicorn-3rdparty begin") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "pg_restore zebra begin") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "pg_restore zebra end") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}						

if ($line =~ "PGBouncer Started") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Disabling Quartz Jobs in Unicorn Database") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Granting user permission for cycleon_ro") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}						

if ($line =~ "Tomcat started on cycawspreapp31...") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}		

if ($line =~ "Tomcat started on cycawspreapp32...") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}		

if ($line =~ "Starting Master and Slave Replication") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Stopping Postgres on cycawspredbs32") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Postgres Stopped on cycawspredbs32") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Starting Postgres Sync from cycawspredbs31 to cycawspredbs32") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Postgres Sync completed") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Editing Postgres files on DB Server") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Starting Postgres on Slave DB Server") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Postgres Started on Slave DB Server") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}

if ($line =~ "Done") {
	print "OK: $line\n";
	 exit $RETCODES{"OK"};
		}
 	}
 	else  {
 		if ($debug){print "### The Current Time is AFTER the Check Time Period End. Period End: $periodend, Current Time: $ctime ###\n"};
        print "OK: The Current Time is AFTER the Check Time Period End. Period End: $periodend, Current Time: $ctime\n"; exit $RETCODES{"OK"};
}

	