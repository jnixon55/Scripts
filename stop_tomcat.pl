#!/usr/bin/perl
# New Cycleon Environment

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

#Commenting this out since Cycleon no longer has access to these folders
#my @OWNDIRS = ("$TOMCAT/webapps/unicorn/WEB-INF/pages", "$TOMCAT/webapps/unicorn/styles", "$TOMCAT/webapps/unicorn/decorators");

print "Stopping tomcat ";
system($STOPCMD);
sleep(10);

my $stopped = 0;
my $trycnt = 0;
while (not $stopped) {
  $stopped = 1;
  my $pid = `ps auxf | grep java | grep tomcat | grep -v grep`;
  if (defined($pid) && $pid ne "" ) {
    chomp $pid;
    print "\npid after chomp: $pid\n";
    my @pid = split(/ +/, $pid);
    my $id = @pid[1];
    kill(15, $id);
    $stopped = 0;
  }
  if (not $stopped) {
    if ($trycnt > 10) {
      die "\nWe tried to stop tomcat 10 times. It is still running. Giving up...\n";
    }
    sleep(10);
    $trycnt++;
  }
}

print "\n";
print "\nStopping tomcat is complete...\n";
