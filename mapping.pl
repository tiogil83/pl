#! /home/gnu/bin/perl -wi 

my @pars = qw "
GVAPAD0DISP0.ipo50030
GVAPAD0GPIO0.ipo50040
GVAPAD0HBMA0.ipo50040
GVAPAD0HBMB0.ipo50040
GVAPAD0HBMC0.ipo50040
GVAPAD0HBMD0.ipo50040
GVAPAD0NVHS0.ipo50030
GVAPAD0PEX0.ipo50035
" ;

foreach (@pars) {
  /(.*)\.ipo(.*)/ ;  
  my $par = $1 ;
  my $ipo = $2 ;
  open OUT, "> ../layout/revP5.0/blocks/$par/netlists/$par.ipo$ipo.pairedFlopMapping" ;
  print OUT "merged map:" ;
  close OUT ;
}
