#!/home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -wi
use strict ;

#/home/scratch.kzhong_gk208/clock_timing/ga100/revP4.0/NV_gaa_s0/2018Dec17_23_23_CTS_revP4p0_ra.ram_access_max/clock_transition/cts_reports/*
#/home/scratch.kzhong_gk208/clock_timing/ga100/revP4.0/NV_gaa_s0/2018Dec17_23_24_CTS_revP4p0_sa_xtr.capture_stuckat_xtr_max/clock_transition/cts_reports/*
#/home/scratch.kzhong_gk208/clock_timing/ga100/revP4.0/NV_gaa_s0/2018Dec17_23_CTS_revP4p0_merge.shift_max/clock_transition/cts_reports/*


#my @test_viol_files = </home/scratch.kzhong_gk208/clock_timing/ga100/revP4.0/NV_gaa_s0/2018Dec17_23_23_CTS_revP4p0_ra.ram_access_max/clock_transition/cts_reports/*.pin.viol> ;
#push @test_viol_files, </home/scratch.kzhong_gk208/clock_timing/ga100/revP4.0/NV_gaa_s0/2018Dec17_23_24_CTS_revP4p0_sa_xtr.capture_stuckat_xtr_max/clock_transition/cts_reports/*.pin.viol> ;
#push @test_viol_files, </home/scratch.kzhong_gk208/clock_timing/ga100/revP4.0/NV_gaa_s0/2018Dec17_23_CTS_revP4p0_merge.shift_max/clock_transition/cts_reports/*.pin.viol> ;

my @test_viol_files = <./test_trans.viol> ;

#my @func_viol_files = </home/scratch.ga100_NV_gaa_s0_2/ga100/ga100/timing/ga100/rep/clocks/revP4.0/NV_gaa_s0/2018Dec19_00_41_cts_revP4p0/clock_transition/NV_gaa_s0.*.clock_cts_transition.rpt> ;
my @func_viol_files = < /home/scratch.kzhong_gk208/clock_timing/ga100/revP4.0/NV_gaa_s0/2018Dec26_19_10_1ipo02_revP4p0.std_max/clock_transition/NV_gaa_s0.*.clock_cts_transition.rpt> ;

my %test_vio = () ;
my %func_vio = () ;

foreach my $test_vio_file (@test_viol_files) {
    open IN, "$test_vio_file" ;
    while (<IN>) {
        my $line = $_ ;
        my $vio_perc = 0 ;
        my $end_pin = "" ;
        if ($line =~ /^-\d/) {
            $line =~ /^\S+\s+(\S+)\%\s+\S+\s+\S+\s+\S+\s+(\S+)/ ;
            $vio_perc = $1 ;
            $end_pin = $2 ;
        } else {
            next ;
        }
        if (exists $test_vio{$end_pin}) {
            if ($test_vio{$end_pin} < $vio_perc) {
                next ;
            } else {
                $test_vio{$end_pin} = $vio_perc ;
            }
        } else {
            $test_vio{$end_pin} = $vio_perc ;
        }
    } 
    close IN ;
}

#foreach my $key (sort keys %test_vio) {
#    print "$key $test_vio{$key}\n" ;
#}

foreach my $func_vio_file (@func_viol_files) {
    #-0.224;xclk_3x;xclk_3x;737;0.136;CKOR2CS1D6;0.057268;CKBCS1D4;0.360;gaas0xp/clks/gaas0xp/ncpex/lt43_ncpex_Pex_refClkp_xclk3x_stopped_pre_mbuf;gaas0xp/clks/gaas0xp/ncpex/Pex_refClkp_xclk3x_stopped_switch_ncpex/u_NV_CLK_switch2/clk_path/UI_clkpath_or_final/Z;17;gaas0xp/clks/gaas0xp/ncpex/ecoUI_isolate_heimdall_NV_GAA_SYS0_CLK_pex_gate_CKBD4_7/I;true;false;none;15.381538;0.087437;0.036259;0.051178
    open IN, "$func_vio_file" ;
    while (<IN>) {
        my $line = $_ ;
        my $vio_perc = 0 ;
        my $end_pin = "" ;
        if ($line =~ /^-\d/) {
            $line =~ /(\S+?);\S+?;\S+?;\S+?;(\S+?);\S+?;\S+?;\S+?;\S+?;\S+?;\S+?;\S+?;(\S+?);/ ;
            $end_pin = $3 ;
            $vio_perc = $1/$2 * 100 ;
        } else {
            next ;
        }
        if (exists $func_vio{$end_pin}) {
            if ($func_vio{$end_pin} < $vio_perc) {
                next ;
            } else {
                $func_vio{$end_pin} = $vio_perc ;
            }
        } else {
            $func_vio{$end_pin} = $vio_perc ;
        }
    }
    close IN ;
}

my %test_only  = () ;
my %test_worse = () ;

foreach my $key (sort keys %test_vio) {
    if (exists $func_vio{$key}) {
        if ($test_vio{$key} < $func_vio{$key}) {
            $test_worse{$key} = $test_vio{$key} ;
        } else {
            next ;
        }
    } else {
        $test_only{$key} = $test_vio{$key} ;
    }
}

print "Test Only : \n" ;
foreach my $key (sort keys %test_only) {
    print "$key $test_only{$key}\n" ;
}
print "Test Worse : \n" ;
foreach my $key (sort keys %test_worse) {
    print "$key $test_worse{$key}\n" ;
}
