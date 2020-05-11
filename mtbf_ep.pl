#! /home/gnu/bin/perl -w
use strict ;

my $input1 = $ARGV[0] ;
my $input2 = $ARGV[1] ;

open IN1, "$input1" ;
open IN2, "$input2" ;

my %mtbf ;

while(<IN2>) {
  #NV_GMG_SYS0_CLK_ncxbarpll,s0_0/gmgs0fe/u_GMG_S0_1500_wrapper/dftModules_gmgs0fe/dftModulesWrapper_GMGS0FE_inst/DFD_CTL_PMM_gmlit4_inst/DFD_CTL_jtag_inst/DFD_CTL_reg/Q_reg_0_/E,LHCND2,s0_0/gmgs0pw/clks/gmgs0pw/ncxbarpll/xbar2clk_out_pdiv_ctrl_ncxbarpll_f/pllmodule/UJ_I_syncvco_stop_all_clks/d,SSYNC3DO_C_PPP,3,jtag_reg_clk,27,xbarpll_o,3344.48160535117,tt_0.99v_105c,svt,152.285370946915,4,0.0274113667704447,1
  m/,(.*?),(.*?),(.*?),/ ;
  my $sp = $1 ;
  my $ep = $3 ;
  $mtbf{$sp}{$ep} = 1 ;
}

while(<IN1>) {
  #s0_0/gmgs0pw/clks/gmgs0pw/ncsyspll/sys2clk_out_onesrcmux_ldiv_ncsyspll_f/swcontrol/divsel0/start_updateswctrl_reg/CP,p_SDFCNQD1,s0_0/gmgs0pw/clks/gmgs0pw/ncsyspll/sys2clk_out_onesrcmux_ldiv_ncsyspll_f/pllmodule/UJ_I_syncvco_busy_inv/d,p_SSYNC3DO_C_PPP,3,1,ssg_0.85v_0c,30721.0593957914,years
  m/,(.*?),(.*?),(.*?),/ ;
  my $sp = $1 ;
  my $ep = $3 ;
  if (exists $mtbf{$sp}{$ep}) {
    print "exist $sp TO $ep\n" ;
    next ;
  }else{
    print "$sp TO $ep\n" ;
  }
}
