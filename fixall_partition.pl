#! /home/utils/perl-5.8.8/bin/perl -wi

use strict ;

use Getopt::Long ;

my $opt_par ; 
my $opt_ipo ;
my $opt_rev ;
my $opt_conf ;

GetOptions (
  "par=s" => \$opt_par ,
  "ipo=s" => \$opt_ipo ,
  "rev=s" => \$opt_rev ,
  "conf=s" => \$opt_conf ,
);

my $par = $opt_par ;
my $ipo = $opt_ipo ;
my $rev = $opt_rev ;
my $conf = $opt_conf ;
my $date = `date "+%y%b%d_%H"` ;
chomp $date ;

my $Usage = "$0 -par <partition> -ipo <ipo number> -rev <layout revision> -conf <configure file>\n" ;

if(!$opt_par | !$opt_ipo | !$opt_rev | !$opt_conf){
  die($Usage) ;
}

my $options = "MENDER_EXIT=0 ANNO_REV_$par=$ipo MENDER_USER_FIXALL_CFG=$conf MENDER_DATECODE=.$date USE_LAYOUT_REV=$rev USE_PROJ_RAM_LIB=1 USE_MASTER=1 MENDER_PAR_QUEUE='-q o_cpu_32G' PAR_VIOL_DIR=/home/scratch.t148_partition/t148/t148/timing/t148/rep\\\\\\ /home/scratch.t148_partition_2/t148/t148/timing/t148/rep\\\\\\ /home/scratch.t148_partition_3/t148/t148/timing/t148/rep " ;

chomp $options ;

system "/home/utils/make-3.82/bin/make ${par}.mender.fixall.netfix $options & " ;

#/home/utils/make-3.82/bin/make  MENDER_TOUCH_MACROS=1 PAR_VIOL_DIR=/home/scratch.t148_partition/t148/t148/timing/t148/rep\\\ /home/scratch.t148_partition_2/t148/t148/timing/t148/rep\\\ /home/scratch.t148_partition_3/t148/t148/timing/t148/rep MENDER_EXIT=0 ANNO_REV_TDD=2055 MENDER_USER_FIXALL_CFG=/home/scratch.junw_t148/T148/t148/timing/t148/mender/DIS/user_fixall_cfg.DIS_tran.medic MENDER_DATECODE=.Aug31.1 USE_LAYOUT_REV=revP2.0 USE_PROJ_RAM_LIB=1 USE_MASTER=1 MENDER_PAR_QUEUE=-q\ o_cpu_32G TDD.mender.fixall.netfix



