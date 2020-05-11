#! /home/utils/perl-5.14/5.14.1-threads-64/bin/perl

use strict ;

open IN, "nv_top..anno40000.pt.ssg_0c_0p55v_bin_max_si.std_max.hs_ctx.TOP_FGNLXS_UNIQ__109.2019Jan02_13_revP4p0_HSM_stubSM.mpw_detailed_rep" or die "can't open rep\n";
my %dpd ;
my %no_dpd ;
my %pad ;
my $pin ;
my $dpd_pin ;
my $pad_pin ;

while (<IN>) {
    chomp ;
    my $line = $_ ;
    if ($line =~ /^\s+Pin: (\S+)/) {
        $pin = $1 ;  
        $dpd_pin = 0 ;
        $pad_pin = 0 ;
        next ;
    } elsif ($line =~ /^\s+(\S+\/DPD)\s+\(/) {
        $dpd_pin = 1 ;
        $dpd{$pin} = $1 ;
        next ;
    } elsif ($line =~ /^\s+(\S+u_padlet\/u_pads\/hbm._test_pad\/DQ_TX_\S+)\s+\(/) {
        $pad_pin = 1 ;
        $pad{$pin} = $1;
        next ;
    } elsif ($line =~ /slack \(VIOLATED/) {
        if ($dpd_pin == 1) {
            next ;
        } elsif ($pad_pin == 1) {
            next ;
        } else{
            $no_dpd{$pin} = 1 ;
            next ;
        }
    }    
} 

close IN ;

open OUT_1, "> DPD_PINS.txt";
open OUT_3, "> PAD_PINS.txt";
open OUT_2, "> NON_DPD_PINS.txt";

foreach my $pin_dpd (sort keys %dpd) {
    print OUT_1 "$pin_dpd $dpd{$pin_dpd}\n" ;
} 
foreach my $pin_dpd (sort keys %no_dpd) {
    print OUT_2 "$pin_dpd $no_dpd{$pin_dpd}\n" ;
} 
foreach my $pin_dpd (sort keys %pad) {
    print OUT_3 "$pin_dpd $pad{$pin_dpd}\n" ;
} 
