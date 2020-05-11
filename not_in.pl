#!/home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -wi
use strict ;

open IN1, "latch_list.txt" ;
open IN2, "/home/scratch.t194_master_6/t194/hw/nvmobile_t194/timing/to_review/nv_top..feflat.pt.ssg_0c_0p72v_max_mv_si.std_max.flat.none.revP4p0_2017Aug28_11_stubCpuGpu_LatchDisable.rep" ;

my %latch ;
while (<IN1>) {
  chomp ;
  $latch{$_} =  1 ;
}

while (<IN2>) {
  chomp ;
  if (exists $latch{$_}) {
    next ;
  } else {
    print "$_\n" ;
  }
}

close IN1 ;
close IN2 ;
