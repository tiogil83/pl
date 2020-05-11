#! /home/gnu/bin/perl -w
use strict ;

open IN, "changelink" ;
open OUT, "> unqi_changelink" ;

my %change ;
while(<IN>){
  /^change_link (\S+) (\S+)$/ ;
  $change{$1} = $_ ;
}

foreach my $key(keys %change){
  print OUT $change{$key} ;
}

close IN ;
close OUT ;
