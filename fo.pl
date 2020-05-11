#! /home/utils/perl-5.8.8/bin/perl -wi

use strict ;

open IN, "t194/eco/jtag/revP2_6/dpd_fanout.txt" ;
#open IN, "xxxxx" ;

while(<IN>){
  chomp ;
  my $line = $_ ;
  $line =~ /(.*) (.*) (.*)/ ;
  my $pin = $1 ;
  my $start = $2 ;
  my $end_pin = $3 ;
  my $end = $end_pin ;
  $end =~ s/(.*)\/.*/$1/ ;
  $end =~ s/(.*)Jreg_ff_reg_(.*)/$1Jreg_lat_reg_$2/;
  #print "$start $end\n" ;
  if ($start eq $end) {
    print "$_\n" ;
  } 
}

close IN ;
