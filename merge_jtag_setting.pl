#!/home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -wi
use strict ;

open IN1, "../layout/revP4.0/blocks/NV_gaa_s0/dft/constraints/NV_gaa_s0.xtr_fast_test_mode_jtag_settings" ;
open IN2, "../layout/revP4.0/blocks/NV_gaa_s0/dft/constraints/NV_gaa_s0.xtr_fmax_jtag_settings" ;
open OUT, "> ../layout/revP4.0/blocks/NV_gaa_s0/dft/constraints/NV_gaa_s0.xtr_merge_mode_jtag_settings" ;

my %JS1 = () ;
my %JS2 = () ;

while (<IN1>) {
    chomp ;
    my $line = $_ ;
    $line =~ /^(\S+)\s+=\s+(\d+)$/ ;
    my $pin = $1 ;
    my $val = $2 ;
    $JS1{$pin} = $val ;
}

while (<IN2>) {
    chomp ;
    my $line = $_ ;
    $line =~ /^(\S+)\s+=\s+(\d+)$/ ;
    my $pin = $1 ;
    my $val = $2 ;
    $JS2{$pin} = $val ;
}

my @JS1_PINS = sort keys %JS1 ;
my @JS2_PINS = sort keys %JS2 ;

my $js1_num = $#JS1_PINS + 1 ;
my $js2_num = $#JS2_PINS + 1 ;

my @JS_DIFF  = () ;
my $i = 1 ;

foreach my $pin (sort keys %JS1) {
    if ($JS1{$pin} eq $JS2{$pin}) {
        print OUT "$pin = $JS1{$pin}\n" ;
        $i = $i + 1 ;
    } else {
        push @JS_DIFF, $pin ;
    }
}

foreach my $pin (sort keys %JS2) {
    if (exists $JS1{$pin}) {
        next ;
    }else{
        push @JS_DIFF, $pin ;
    }
}

my $js_diff_num = $#JS_DIFF + 1 ;

print "jtag setting 1    : $js1_num pins\n" ;
print "jtag setting 2    : $js2_num pins\n" ;
print "jtag setting same : $i pins\n" ;
print "diff num          : $js_diff_num pins\n" ;

close IN1 ;
close IN2 ;
close OUT ;
