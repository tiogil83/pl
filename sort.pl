#!/home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -wi
use strict ;

my $inputfile = shift ;
open IN, "$inputfile" ;

while(<IN>) {
  m/(^GP.PAD0.*?),/ ;
  my $block = $1 ;
  unless (-e "$block.trans.csv") {
    open OUT, "> $block.trans.csv" ;
    print OUT "Partition,Pin name,Reqd,Slack,Corner,Net name,Net length,Ref name,Driver Ref,Comment,\n" ;
    print OUT "$_" ;
    close OUT ;
  } else {
    open OUT, ">> $block.trans.csv" ;
    print OUT "$_" ;
    close OUT ;
  }
}

close IN ;
