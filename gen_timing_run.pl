#! /home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -w
use strict ;

open IN, "gp100_timing_run" ;

while(<IN>){
  if(/^\s+(.*)$/){
    chomp ;
    print "timing_run -type \${type} -block \${top} $1 -datecode \${datecode} -use_96g_opteron 1 -pt_exit 0 -disable_nvLogView 1 -use_clock_constraint_include 1\n" ;
  }
}
