#! /home/utils/perl-5.8.8/bin/perl -wi
use strict ;

my @corners = qw "
    tt_105c_0p72v_opt_max_si-std_max
    ssg_0c_0p6v_bin_opt_max_si-std_max
    tt_0c_0p6v_max_si-std_max
    tt_105c_0p99v_max_si-std_max
    ffg_0c_0p6v_min_si-std_min 
    ffg_0c_0p99v_min_si-std_min 
    ffg_0c_1p21v_min_si-std_min 
    ffg_105c_0p6v_min_si-std_min 
    ffg_105c_0p99v_min_si-std_min 
    ffg_105c_1p21v_min_si-std_min 
    ssg_0c_0p6v_min_si-std_min 
    ssg_0c_0p99v_min_si-std_min 
    ssg_105c_0p6v_min_si-std_min 
    ssg_105c_0p99v_min_si-std_min 
    tt_105c_0p72v_opt_max_si-shift_fmax_discrete_max
    ssg_0c_0p6v_bin_opt_max_si-shift_fmax_discrete_max
    tt_0c_0p6v_max_si-shift_fmax_discrete_max
    tt_105c_0p99v_max_si-shift_fmax_discrete_max
    ffg_0c_0p6v_min_si-shift_fmax_discrete_min 
    ffg_0c_0p99v_min_si-shift_fmax_discrete_min 
    ffg_0c_1p21v_min_si-shift_fmax_discrete_min 
    ffg_105c_0p6v_min_si-shift_fmax_discrete_min 
    ffg_105c_0p99v_min_si-shift_fmax_discrete_min 
    ffg_105c_1p21v_min_si-shift_fmax_discrete_min 
    ssg_0c_0p6v_min_si-shift_fmax_discrete_min 
    ssg_0c_0p99v_min_si-shift_fmax_discrete_min 
    ssg_105c_0p6v_min_si-shift_fmax_discrete_min 
    ssg_105c_0p99v_min_si-shift_fmax_discrete_min 
    ffg_0c_0p6v_tran_si-cmnone 
    ffg_0c_1p21v_glitch-cmnone 
    ffg_105c_1p21v_glitch-cmnone 
    ffg_105c_1p21v_tran_si-cmnone 
    ssg_0c_0p6v_tran_si-cmnone 
    ssg_0c_0p99v_tran_si-cmnone 
    ssg_105c_0p6v_tran_si-cmnone 
    ssg_105c_0p99v_tran_si-cmnone 
" ;

my @pars = qw "GMGPAD0TEST0.ipo30030 GMGPAD0DISP0.ipo30030" ;
#my $ipo = "30030" ;

open OUT, "> /home/junw/par_run.medic" ;

foreach (@pars) {
  /(.*)\.ipo(.*)/ ;
  my $par = $1 ;
  my $ipo = $2 ;
  foreach (@corners) {
      /(.*)-(.*)/ ;
      my $corner = $1 ;
      my $mode = $2 ;
  
      print OUT "timing_run -type anno -block $par -corner $corner -mode $mode -use_layout_rev revP3.0 -pt_save_session 1 -skip_attr_gen 1 -use_sdc_file 1 -use_proj_ram_lib 1 -check_p4_have 0 -use_layout_rev revP3.0 -anno_rev_$par $ipo -use_xwindow 0 -use_screen 0 -use_yaml 1 -pt_send_email 0 -tcm_sdcdir /home/scratch.gp100_partition/gp100/gp100/layout/revP3.0/netlists/sdc_tcm -use_32g_q 1 -pt_false_path_io 1 -hyperscale_enable 0 -pba_gen_reports 1 -pba_max_path_per_group 20000 -pba_exhaustive_endpoint_limit 100 -use_custom_postupdate 1 -custom_postupdate_file /home/scratch.gp100_partition/gp100/gp100/timing/gp100/autotime_partition/gpu_autotime_custom_postupdate.tcl\n" ;
  }
}

close OUT ;

