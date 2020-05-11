#! /home/utils/perl-5.8.8/bin/perl -wi

use strict ;

open IN, "a" ;
while(<IN>){
  chomp ;
  if(/^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s*$/){
    print "! $1\n! $2\n! $3\n! $4\n! $5\n|-\n" ;
    next ;
  }else{
    print "!\n!\n!\n!\n!\n|-\n" ;
    next ; 
  }
}

