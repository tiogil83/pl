#!/home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -wi
use strict ;
use warnings FATAL => qw(all);

use Getopt::Long;

use vars qw($opt_i $opt_o $opt_h);
GetOptions ("i=s", "o=s", "h");

# -----------------------------------------
# help
# -----------------------------------------

usage(0) if ($opt_h);

sub usage {
    my($ret) = shift;

    print "$0 - get the exception files by timing paths reports 
    -i      <input file>        input timing report files, dumped by \"rt -from <> -to <> -except all\"
    -o      <output file>       output file 
    -h      helper
    \n";
    exit $ret;
}

# -----------------------------------------
# arguments 
# -----------------------------------------
my $in_file ;
my $out_file ;

if (!defined($opt_i)) {
    die (usage) ;
} else {
    $in_file = $opt_i ; 
}

if (!defined($opt_o)) {
    $out_file = $in_file.".except_output.txt" ;
} else {
    $out_file = $opt_o ;
}

open IN, "$in_file" or die "Can't read file $opt_i\n" ;
open OUT, "> $out_file" or die "Can't write to file $opt_o\n" ; 

# ------------------------------------------
# main loop
# ------------------------------------------

my $start_fl    = 0 ;
my $start_pin   = "" ;
my $end_pin     = "" ;
my %except_file = () ;
my %temp_except = () ;
my %temp        = () ;
my %non_temp    = () ;

while (<IN>) {
    chomp ;
    my $line = $_ ;
    if ($start_fl == 0 && $line =~ /^  Startpoint: /) {
        $start_pin = $line ;
        $start_pin =~ s/^  Startpoint: (\S+)/$1/ ;
        $start_fl  = 1 ; 
        #print "Start $start_pin $start_fl\n" ;
        next ;
    } elsif ($start_fl == 1 && $line =~ /^  Endpoint: /) {
        $end_pin = $line ;
        $end_pin =~ s/^  Endpoint: (\S+)/$1/ ;
        #print "End $end_pin $start_fl\n" ;
        next ;
    } elsif ($start_fl == 1 && $line =~ /.*location = .*/) {
        $line =~ /^.*location = (\S+):(\d+) .*/ ;
        my $except   = $1 ;
        my $line_num = $2 ;
        if ($except =~ /exceptions\.temporary\./) {
            $temp_except{$except}{$start_pin}{$end_pin} = $line_num ; 
            $temp{$start_pin}{$end_pin} = 1 ;
        } else {
            $except_file{$except}{$start_pin}{$end_pin} = $line_num ; 
        }
        #print "Line: $line\n$except $start_pin $end_pin\n" ;
        next ;
    } elsif ($start_fl == 1 && $line =~ /^1$/) {
        $start_fl = 0 ;
        next ;
    } else {
        next ;
    }
}


# -------------------------------------
# to get the non-temporary exceptions
# -------------------------------------

foreach my $file (sort keys %except_file) {
    foreach my $start (sort keys %{$except_file{$file}}) {
        foreach my $end (sort keys %{$except_file{$file}{$start}}) {
            if (exists $temp{$start}{$end}) {
            } else {
                $non_temp{$file}{$start}{$end} = $except_file{$file}{$start}{$end} ;
            }
        }
    }
}

# -------------------------------------
# dump outputs
# -------------------------------------

foreach my $file (sort keys %non_temp) {
    print OUT "File : $file\n" ;
    foreach my $start (sort keys %{$non_temp{$file}}) {
        foreach my $end (sort keys %{$non_temp{$file}{$start}}) {
            print OUT "Line $non_temp{$file}{$start}{$end} : $start $end\n" ;
        }
    }
}

foreach my $file (sort keys %temp_except) {
    print OUT "Temporary Exception File : $file\n" ;
    foreach my $start (sort keys %{$temp_except{$file}}) {
        foreach my $end (sort keys %{$temp_except{$file}{$start}}) {
            print OUT "Line $temp_except{$file}{$start}{$end} : $start $end\n" ;
        }
    }
}

close IN ;
close OUT ;
