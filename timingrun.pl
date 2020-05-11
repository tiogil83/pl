#! /home/gnu/bin/perl -w
use strict ;

use Getopt::Long ;

my $opt_help ;
my $opt_ipo ;
my $opt_block ;
my $opt_proj ;
my $opt_mode ;
my $opt_rev ;

GetOptions (
  "h" => \$opt_help ,
  "ipo=s" => \$opt_ipo ,
  "block=s" => \$opt_block ,
  "proj=s" => \$opt_proj ,
  "mode=s" => \$opt_mode ,
  "rev=s" => \$opt_rev ,
);



my $code = lc $opt_block ;
$code .= "\.$opt_mode" ;


my $USAGE = "This script is used for local timing run.\n" ;
$USAGE .= "-h\tprint this message\n" ;
$USAGE .= "-block\tpartition name\n" ;
$USAGE .= "-ipo\tpartition ipo number\n" ;
$USAGE .= "-proj\tproject name\n" ;
$USAGE .= "-mode\tindicate the mode\n" ;
$USAGE .= "-rev\tlayrout revision\n" ;

if( $opt_help || !$opt_ipo || !$opt_block || !$opt_proj || !$opt_mode || !$opt_rev ){
  die($USAGE) ;
}


open OUT, "> timing_run.$code.medic" ;

my @std_max ;
my @std_min ;
my @shift_max ;
my @shift_min ;

my $ipo_dir ;
my $sdc_dir ;

if($opt_help || !$opt_ipo || !$opt_block || !$opt_proj || !$opt_mode || !$opt_rev) {
  print "missing option\n" ;
  die($USAGE) ;
}

if($opt_proj eq "gm20b"){
@std_max = qw "ss_0c_0p73v_max_si_std_max ss_0c_0p85v_max_si_std_max ss_0c_1p1v_max_si_std_max ss_105c_0p73v_max_si_std_max ss_105c_0p85v_max_si_std_max ss_105c_1p1v_max_si_std_max tt_0c_0p73v_max_si_std_max" ;
@std_min = qw "ff_0c_0p85v_min_si_std_min ff_0c_0p85v_min_std_min ff_0c_1p1v_min_si_std_min ff_0c_1p1v_min_std_min ff_105c_0p85v_min_si_std_min ff_105c_0p85v_min_std_min ff_105c_1p1v_min_si_std_min ff_105c_1p1v_min_std_min ff_105c_1p35v_min_si_std_min ff_105c_1p35v_min_std_min ff_m40c_1p35v_min_si_std_min ff_m40c_1p35v_min_std_min ss_0c_0p73v_min_si_std_min ss_0c_0p73v_min_std_min ss_0c_1p1v_min_si_std_min ss_0c_1p1v_min_std_min ss_105c_0p73v_min_si_std_min ss_105c_0p73v_min_std_min ss_105c_0p85v_min_si_std_min ss_105c_0p85v_min_std_min ss_105c_1p1v_min_si_std_min ss_105c_1p1v_min_std_min ss_m40c_0p85v_min_si_std_min ss_m40c_0p85v_min_std_min" ;
@shift_max = qw "ss_0c_0p73v_max_si_shift_fmax_discrete_max ss_0c_0p85v_max_si_shift_fmax_discrete_max ss_0c_1p1v_max_si_shift_fmax_discrete_max ss_105c_0p73v_max_si_shift_fmax_discrete_max ss_105c_0p85v_max_si_shift_fmax_discrete_max ss_105c_1p1v_max_si_shift_fmax_discrete_max" ;
@shift_min = qw "ff_0c_0p85v_test_min_shift_fmax_discrete_min ff_0c_0p85v_test_min_si_shift_fmax_discrete_min ff_0c_1p1v_test_min_shift_fmax_discrete_min ff_0c_1p1v_test_min_si_shift_fmax_discrete_min ff_105c_0p85v_test_min_shift_fmax_discrete_min ff_105c_0p85v_test_min_si_shift_fmax_discrete_min ff_105c_1p1v_test_min_shift_fmax_discrete_min ff_105c_1p1v_test_min_si_shift_fmax_discrete_min ff_105c_1p35v_test_min_shift_fmax_discrete_min ff_105c_1p35v_test_min_si_shift_fmax_discrete_min ff_m40c_1p35v_test_min_shift_fmax_discrete_min ff_m40c_1p35v_test_min_si_shift_fmax_discrete_min ss_0c_0p73v_test_min_shift_fmax_discrete_min ss_0c_0p73v_test_min_si_shift_fmax_discrete_min ss_0c_1p1v_test_min_shift_fmax_discrete_min ss_0c_1p1v_test_min_si_shift_fmax_discrete_min ss_105c_0p73v_test_min_shift_fmax_discrete_min ss_105c_0p73v_test_min_si_shift_fmax_discrete_min ss_105c_0p85v_test_min_shift_fmax_discrete_min ss_105c_0p85v_test_min_si_shift_fmax_discrete_min ss_105c_1p1v_test_min_shift_fmax_discrete_min ss_105c_1p1v_test_min_si_shift_fmax_discrete_min ss_m40c_0p85v_test_min_shift_fmax_discrete_min ss_m40c_0p85v_test_min_si_shift_fmax_discrete_min " ;

$ipo_dir = "../layout/revG3.0/netlists" ;
$sdc_dir = "/home/scratch.gm20b_partition/gm20b/gm20b/layout/revG3.0/netlists/sdc_tcm" ;

}elsif ($opt_proj eq "gp10b"){
  @std_max = qw "ssg_0c_0p6v_max_si ssg_105c_0p6v_max_si ssg_105c_0p72v_max_si tt_0c_0p6v_max_si tt_105c_0p6v_max_si tt_105c_0p72v_max_si tt_105c_0p99v_max_si" ;
  $ipo_dir = "/home/scratch.gp10b_partition/gp10b/gp10b/layout/revG0.2/netlists" ;
  $sdc_dir = "/home/junw/sdc_trial" ;
}else{
  print "wrong project name\n" ;
  die($USAGE) ;
}



#if($opt_mode ne "std_max||std_min||shift_max||shift_min"){
#  print "please check the mode\n" ;
#  die($USAGE) ;
#}

if($opt_mode eq "std_max"){
  foreach my $corner(@std_max){
    my $block = $opt_block ;
    my $rev = $opt_rev ; 
    my $mode = $opt_mode ;
    my $ipo = $opt_ipo ;
    $corner =~ s/_std_max//g ;
    #print OUT "timing_run -type anno -block $block -corner $corner -mode $mode -use_layout_rev $rev -anno_rev_$block $ipo -pt_save_session 1 -skip_attr_gen 0  -use_sdc_file 1 -use_proj_ram_lib 1 -check_p4_have 0 -use_xwindow 0 -use_screen 0 -use_yaml 1 -pt_send_email 0 -tcm_sdcdir $sdc_dir -ipo_dir $ipo_dir  -use_32g_q 1 -pt_false_path_io 1 -use_screen 0 -pba_gen_reports 1 -pba_max_path_per_group 20000  -pt_send_email 0 -vio_show_derate 1 -vio_show_xtalk 1\n" ;
    print OUT "timing_run -type anno -block $block -corner $corner -mode $mode -use_layout_rev $rev -anno_rev_$block $ipo -pt_save_session 1 -skip_attr_gen 0  -use_sdc_file 1 -use_proj_ram_lib 1 -check_p4_have 0 -use_xwindow 0 -use_screen 0 -use_yaml 1 -pt_send_email 0 -tcm_sdcdir $sdc_dir -ipo_dir $ipo_dir  -use_32g_q 1 -pt_false_path_io 1 -pt_send_email 0\n" ;
  }
}elsif($opt_mode eq "std_min"){
  foreach my $corner(@std_min){
    my $block = $opt_block ;
    my $rev = $opt_rev ; 
    my $mode = $opt_mode ;
    my $ipo = $opt_ipo ;
    $corner =~ s/_std_min//g ;
    #print OUT "timing_run -type anno -block $block -corner $corner -mode $mode -use_layout_rev $rev -anno_rev_$block $ipo -pt_save_session 1 -skip_attr_gen 0  -use_sdc_file 1 -use_proj_ram_lib 1 -check_p4_have 0 -use_xwindow 0 -use_screen 0 -use_yaml 1 -pt_send_email 0 -tcm_sdcdir $sdc_dir -ipo_dir $ipo_dir  -use_32g_q 1 -pt_false_path_io 1 -use_screen 0 -pba_gen_reports 1 -pba_max_path_per_group 20000  -pt_send_email 0 -vio_show_derate 1 -vio_show_xtalk 1\n" ;
    print OUT "timing_run -type anno -block $block -corner $corner -mode $mode -use_layout_rev $rev -anno_rev_$block $ipo -pt_save_session 1 -skip_attr_gen 0  -use_sdc_file 1 -use_proj_ram_lib 1 -check_p4_have 0 -use_xwindow 0 -use_screen 0 -use_yaml 1 -pt_send_email 0 -tcm_sdcdir $sdc_dir -ipo_dir $ipo_dir  -use_32g_q 1 -pt_false_path_io 1 -pt_send_email 0\n" ;
  }
}elsif($opt_mode eq "shift_max"){
  foreach my $corner(@shift_max){
    my $block = $opt_block ;
    my $rev = $opt_rev ; 
    my $mode = "shift_fmax_discrete_max" ;
    my $ipo = $opt_ipo ;
    $corner =~ s/_shift_fmax_discrete_max//g ;
    print OUT "timing_run -type anno -block $block -corner $corner -mode $mode -use_layout_rev $rev -anno_rev_$block $ipo -pt_save_session 1 -skip_attr_gen 0  -use_sdc_file 1 -use_proj_ram_lib 1 -check_p4_have 0 -use_xwindow 0 -use_screen 0 -use_yaml 1 -pt_send_email 0 -tcm_sdcdir $sdc_dir -ipo_dir $ipo_dir  -use_32g_q 1 -pt_false_path_io 1 -use_screen 0 -pba_gen_reports 1 -pba_max_path_per_group 20000  -pt_send_email 0 -vio_show_derate 1 -vio_show_xtalk 1\n" ;
  }
}elsif($opt_mode eq "shift_min"){
  foreach my $corner(@shift_min){
    my $block = $opt_block ;
    my $rev = $opt_rev ; 
    my $mode = "shift_fmax_discrete_min" ;
    my $ipo = $opt_ipo ;
    $corner =~ s/_shift_fmax_discrete_min//g ;
    print OUT "timing_run -type anno -block $block -corner $corner -mode $mode -use_layout_rev $rev -anno_rev_$block $ipo -pt_save_session 1 -skip_attr_gen 0  -use_sdc_file 1 -use_proj_ram_lib 1 -check_p4_have 0 -use_xwindow 0 -use_screen 0 -use_yaml 1 -pt_send_email 0 -tcm_sdcdir $sdc_dir -ipo_dir $ipo_dir  -use_32g_q 1 -pt_false_path_io 1 -use_screen 0 -pba_gen_reports 1 -pba_max_path_per_group 20000  -pt_send_email 0 -vio_show_derate 1 -vio_show_xtalk 1\n" ;
  }
}else{
  print "please check the mode\n" ;
  die($USAGE) ;
}

close OUT ;
