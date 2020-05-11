#! /home/utils/perl-5.8.8/bin/perl -wi

use strict ;

$ENV{TIMING_NVTOOLS_ROOT} = "/home/nvtools/service/ga100_tm" ;
$ENV{ASIC_PD_LIB} = "/home/scratch.flowserver/release/asic_pd/asic_pd_lib/2018.08.main" ; 

my $log_file = shift ;
chomp $log_file ;
if ($log_file =~ /pt\..*\.log\.gz$/) {
} else {
    die "\nNot a log.gz file : $log_file\n" ;
}

my $out_file = $log_file ;
$out_file =~ s/\.log\.gz/.log_review.rep/ ;
if ($out_file =~ /^\/home\//) {
    print "OUTPUT_FILE :\n\t$out_file\n" ;
} else {
    print "OUTPUT_FILE :\n\t$ENV{PWD}/$out_file\n" ; 
}

system "/home/nvtools/service/ga100_tm/nvtools/timing/scripts/nvLogView.pl -project ga100 -debug 1 -filename $log_file > $out_file" ;

my %codes = () ;
my $code  = "" ;

open IN, "$out_file" or die "Can't open file $out_file\n" ;

while (<IN>) {
    chomp ;
    my $line = $_ ;
    if ($line =~ /^Code: (\S+)/) {
        $code = $1 ;
        $codes{$code} = 0 ;
    } elsif ($line =~ / Unwaived text: */) {
        $codes{$code} = $codes{$code} + 1 ;
    } else {
        next ;
    } 
}  

close IN ;

my @keys = sort keys %codes ;
my $max_leng = get_max_array_length (@keys) ;

foreach my $key (@keys) {
    printf ("%${max_leng}s : %d\n", $key, $codes{$key}) ;
}

sub get_max_array_length {
    my @array = @_ ;
    my $max_leng = 0 ;
    foreach (@array) {
        my $length = length $_ ;
        if ($length > $max_leng) {
            $max_leng = $length ;
        }
    }
    return $max_leng ;
}

