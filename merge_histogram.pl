#!/home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -wi
use strict ;

open IN1, "aaa" ;
open IN2, "bbb" ;
open OUT, "merge_hist.txt" ;

my $par = "" ;
my $corner = "" ;
my %in1 = () ;
my %in2 = () ;

while (<IN1>) {
    chomp ;
    my $line = $_ ;
    if ($line =~ /\| GAA/) {
        $line =~ /\| (GAA\S+)\s+ffg_0c_1p16v\s+(.*)/ ;
        $par = $1 ;
        $corner = "ffg_0c_1p16v" ; 
    } elsif ($line =~ /^\| \"\s+ssg_0c_0p55v/) {
        $corner = "ssg_0c_0p55v" ;
    } elsif ($line =~ /2018Oct23_18_43_IPO1_revP3p0_ra/) { 
        $line =~ /^\|.*?\|(.*)/ ;
        $in1{$par}{$corner}{"2018Oct23_18_43_IPO1_revP3p0_ra"} = $1 ;
    } else {
        next ;
    }
}

while (<IN2>) {
    chomp ;
    my $line = $_ ;
    if ($line =~ /\| GAA/) {
        $line =~ /\| (GAA\S+)\s+ffg_105c_1p16v\s+2018Dec16_23_LPR_revP3p0_ra\s+\|(.*)/ ;
        $par = $1 ;
        $corner = "ffg_105c_1p16v" ;
        $in2{$par}{$corner}{"2018Dec16_23_LPR_revP3p0_ra"} = $2 ;
    } elsif ($line =~ /^\| \"\s+ssg_0c_0p55v\s+2018Dec16_23_LPR_revP3p0_ra\s+\|(.*)/) {
        $corner = "ssg_0c_0p55v" ;
        $in2{$par}{$corner}{"2018Dec16_23_LPR_revP3p0_ra"} = $1 ;
    } else {
        next ;
    }
}

print "
========================================================================================================================================================================================
| end_par    corner         datecode                    |                                                                                    |        |          |         |           |
|                                                       |                                        hold                                        |  worst |      tns |   count |     worst |
|                                                       | 0.000 -0.005 -0.010 -0.015 -0.020 -0.025 -0.030 -0.035 -0.040 -0.045 -0.050 -0.055 |   hold |     hold | end_pin | id(slack) |
========================================================================================================================================================================================
" ;

foreach my $partition (sort keys %in1) {
    foreach my $corners (sort keys %{$in1{$partition}}) {
        foreach my $dc (sort keys %{$in1{$partition}{$corners}}) {
            if ($corners =~ /ffg/) {
                printf ( "| %-10s %-14s %-32s | %s\n", $partition, $corners, $dc, $in1{$partition}{$corners}{$dc})  ;
                printf ( "| \"%-9s %-14s %-32s | %s\n", " ", "ffg_105c_1p16v", "2018Dec16_23_LPR_revP3p0_ra", $in2{$partition}{"ffg_105c_1p16v"}{"2018Dec16_23_LPR_revP3p0_ra"}) ;
            } elsif ($corners =~ /ssg/) {
                printf ( "| \"%-9s %-14s %-32s | %s\n", " ", $corners, $dc, $in1{$partition}{$corners}{$dc})  ;
                printf ( "| \"%-9s \"%-13s %-32s | %s\n", " ", " ", "2018Dec16_23_LPR_revP3p0_ra", $in2{$partition}{"ssg_0c_0p55v"}{"2018Dec16_23_LPR_revP3p0_ra"}) ;
                print "+------------------------------------------------------------+-------------------------------------------------------------------------------------+--------+----------+---------+-----------+\n" ;
            }
        }
    }
}

close IN1 ;
close IN2 ;
close OUT ;
