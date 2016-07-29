#!/usr/bin/perl

# @(#) p1       Demonstrate record separator for deleting stanzas.

use warnings;
use strict;

use English qw( -no_match_vars );

my($debug);
$debug = 0;
$debug = 1;

my($sep) = " {";
$INPUT_RECORD_SEPARATOR = $sep;

my($delete) = "abc";

while ( <> ) {
  next if /$delete/;
  print;
}

exit(0);
