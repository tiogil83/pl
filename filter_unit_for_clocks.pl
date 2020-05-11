#!/usr/bin/perl

use strict ;

my $in = shift ;
my $out = "/home/junw/mtbf_num_perunit.csv" ;


open IN, "$in" ;
open OUT,  "> $out" ;

my %unit_num ;

while(<IN>){
  /(.*?),/ ;
  print $1 ;
  my $unit = $1 ;
  if(exists $unit_num{$unit}){
    $unit_num{$unit} += 1 ;
  }else{
    $unit_num{$unit} = 1 ;
  }
}

foreach (keys %unit_num){
  print OUT "$_,$unit_num{$_}\n" ;
}
