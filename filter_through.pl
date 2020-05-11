#!/home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -wi
use strict ;

my $file_in = "/home/junw/cdc" ;
my $file_out = $file_in.".out" ;

open IN, "$file_in" ;
open OUT, "> $file_out" ;

my $flag ;
my $sp ;
my $ep ;

while(<IN>) {
  my $sum = 0 ;
  if(/^  Startpoint: (.*)/) {
    $flag = 1 ;
    $sp = $1 ;
    next ;
  }
  if(/^\s+Endpoint: (.*)/) {
    $ep = $1 ;
    next ;
  }
  if(/^1$/) {
    $flag = 0 ;
    next ;
  } 
  if($flag) {
    if(/UJ_direct_reset_/) {
      $sum = 1 ;
      $flag = 0 ; 
      print OUT "$sp $ep can be waived.\n" ;
      next ;
    }else{
      next ;
    }
  }
}

