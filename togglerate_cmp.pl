#! /home/gnu/bin/perl -w
use strict ;

open NOSCAN, "/home/junw/cr1_noscan_netpower" ;
open FEFLAT, "/home/junw/cr1_feflat_netpower" ;

open NOSCANPOUT, "> /home/junw/cr1_noscan_powercmp" ;
open FEFLATPOUT, "> /home/junw/cr1_feflat_powercmp" ;
open POUT, "> /home/junw/cr1_powersame" ;
open TOUT, "> /home/junw/cr1_trsame" ;
open NOSCANTOUT, "> /home/junw/cr1_noscan_trcmp" ;
open FEFLATTOUT, "> /home/junw/cr1_feflat_trcmp" ;

my %tr_noscan ;
my %pr_noscan ;
my %tr_feflat ;
my %pr_feflat ;

while(<NOSCAN>){
  if(/^#+/){
    next ;
  }else{
    /(\S+)\s+0\.85\s+\S+\s+\S+\s+(\S+)\s+(\S+)\s+/ ;
    my $net = $1 ;
    $tr_noscan{$net} = $2 ;
    $pr_noscan{$net} = $3 ;
  }
}

while(<FEFLAT>){
  if(/^#+/){
    next ;
  }else{
    /(\S+)\s+0\.85\s+\S+\s+\S+\s+(\S+)\s+(\S+)\s+/ ;
    my $net = $1 ;
    $tr_feflat{$net} = $2 ;
    $pr_feflat{$net} = $3 ;
    if(exists $tr_noscan{$net}){
      if($tr_feflat{$net} == $tr_noscan{$net}){
        print TOUT "$net\n" ;
      }elsif($tr_feflat{$net} > $tr_noscan{$net}){
        print FEFLATTOUT "$net $tr_feflat{$net}\n"
      }elsif($tr_feflat{$net} < $tr_noscan{$net}){ 
        print NOSCANTOUT "$net $tr_noscan{$net}\n" ;
      }
      if($pr_feflat{$net} == $pr_noscan{$net}){
        print POUT "$net\n" ;
      }elsif($pr_feflat{$net} > $pr_noscan{$net}){
        print FEFLATPOUT "$net $pr_feflat{$net}\n"
      }elsif($pr_feflat{$net} < $pr_noscan{$net}){ 
        print NOSCANPOUT "$net $pr_noscan{$net}\n" ;
      }
    }
  }
}

my $sum_tr_noscan ;
my $sum_pr_noscan ;
my $sum_tr_feflat ;
my $sum_pr_feflat ;

foreach (keys %tr_noscan){
  $sum_tr_noscan += $tr_noscan{$_} ; 
  $sum_pr_noscan += $pr_noscan{$_} ;
}

print "$sum_tr_noscan $sum_pr_noscan\n" ;

foreach (keys %tr_feflat){
  $sum_tr_feflat += $tr_feflat{$_} ; 
  $sum_pr_feflat += $pr_feflat{$_} ;
}
print "$sum_tr_feflat $sum_pr_feflat\n" ;

close  NOSCAN ;
close  FEFLAT ;
close  NOSCANPOUT ;
close  FEFLATPOUT ;
close  POUT ;
close  TOUT ;
close  NOSCANTOUT ;
close  FEFLATTOUT ;
