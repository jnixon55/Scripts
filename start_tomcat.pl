#!/usr/bin/perl


use strict;
use File::Copy;

#my $OWNER = "cycleonlogs";

my $WAR = "unicorn.war";

my $TMP = "/tmp";
my $TOMCAT = "/data/tomcat";
my $LOGDIR = "$TOMCAT/logs";
my $WARDIR = "$TOMCAT/webapps";
my $STOPCMD = "/etc/init.d/tomcat stop";
my $STARTCMD = "/etc/init.d/tomcat start";
my @WORKDIRS = ("$TOMCAT/work/*", "$TOMCAT/webapps/unicorn*", "$TOMCAT/temp/*");

# Commenting this out since Cycleon no longer has access to these folders
#my @OWNDIRS = ("$TOMCAT/webapps/unicorn/WEB-INF/pages", "$TOMCAT/webapps/unicorn/styles", "$TOMCAT/webapps/unicorn/decorators");

print "Starting Tomcat\n";
chdir($LOGDIR) or die "chdir to $LOGDIR failed: $!";
system($STARTCMD);
if ($? == -1) {
  die "$STARTCMD failed to execute: $!\n";
} elsif ($? & 127) {
  die "$STARTCMD died with signal %d, %s coredump\n",
  ($? & 127), ($? & 128) ? 'with' : 'without';
} elsif (($! = $? >> 8) > 0) {
  die "$STARTCMD failed: $!";
}
sleep(10);
my $started = 0;
my $pid = `ps auxf | grep java | grep tomcat | grep -v grep`;
if (defined($pid) && $pid ne "" ) {
  $started = 1;
}
if (not $started) {
  die "Tomcat has not started. Giving up...\n";
}


print "\n";
print "\nStarting tomcat is complete...\n";