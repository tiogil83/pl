#! /home/utils/perl-5.8.8/bin/perl -wi

use strict ;

my $in = shift ;

open IN, "$in" ;

while(<IN>){
  chomp ;
  my $line = $_ ;
  my $par ; 
  my $net ;
  my $wide_nets_file ;
  if ($line =~ /^(\S+) :/) {
    $par = $1 ; 
    $wide_nets_file = "../layout/revP2.2/blocks/$par/control/${par}_timing.wide_nets" ;    
    `p4 sync $wide_nets_file` ;
    if (-e $wide_nets_file) {
      `p4 edit $wide_nets_file` ;
    } else {
      `touch $wide_nets_file` ;
      `p4 add $wide_nets_file` ; 
    }
    open OUT, ">> $wide_nets_file" ;
  } elsif ($line =~ /^  (\S+)/) {
    $net = $1 ;
    print OUT "$net wide_w2_s2\n" ;
  }
}

close IN ;
close OUT ;
