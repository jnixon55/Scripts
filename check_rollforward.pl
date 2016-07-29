#!/usr/bin/perl -w

use strict;
use File::Copy;

my $date = `date +"%Y-%m-%d %H:%M:%S"`;
my $DateCnv = "";
my $TAILCMD = "tail -16 /var/log/rollforward_pulsecpy.log | grep Last | awk '{print \$5}'";
my $LCT = "";
my $UTILCMD = "su - db2icpy -c 'db2 list utilities show detail'";
my $string = "";

open(TF, "$TAILCMD |") or die "\nCould not open tail cmd: $!";
while (<TF>) {
        chomp;
        $LCT = $_;
}

if ($LCT eq "") {
        open(UT, "$UTILCMD |") or die "\nCould not open db2 list utilities cmd: $!";
        while (<UT>) {
                chomp;
                $LCT = $_;
                if ($LCT =~ /Executing/) {
                        print "DB2 Rollforward is Currently Executing.\n";
                        exit 0;
                }
        }
} else {
        $string = substr($LCT,0,10).' '.substr($LCT,11,2).':'.substr($LCT,14,2).':'.substr($LCT,17,2);
        $DateCnv = `date +"$string"`;
        print "Current Date is  $date\n";
        print "Last Committed Transaction Date is       $DateCnv\n";
}
