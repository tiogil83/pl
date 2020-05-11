#!/home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -wi
use strict ;

open IN1, "setup_margin.txt" ;
open IN2, "hold_vios.txt" ;

my $pin ;
my %setup_slack ;
my %hold_slack ;

while (<IN2>) {
  /(.*) (.*)/ ;
  $hold_slack{$1} = $2 ;
}

while (<IN1>) {
  /(.*) (.*)/ ;
  $pin = $1 ;
  $setup_slack{$pin} = $2 ;
  my $hold_vio = $hold_slack{$pin} ;
  my $slack_margin = -5 * $hold_vio ; 
  if ($setup_slack{$pin} < $slack_margin and $setup_slack{$pin} < 4) {
    print "$pin $setup_slack{$pin} $hold_vio\n" ;
  }
}


