#!/home/utils/perl-5.8.8/bin/perl

BEGIN {
    $tot = "/home/nvtools/latest";
    $ENV{NVDEV} = $tot;
}



use strict;         # no symbolic references
use warnings FATAL => qw(all);

use Getopt::Long;

use vars qw($opt_i $opt_o $opt_h);
GetOptions ("i=s", "o=s", "h");

# -----------------------------------------
# help 
# -----------------------------------------

usage(0) if ($opt_h);
usage(0) if (!defined($opt_i));

sub usage {
    my($ret) = shift;

    print "$0 - find_routeRoule_clk 
    -i              <file>                          the input file, created from cdc reports in pt session. 
    -o              <file>                          the output file, \$input_file.rpt by default. 
    -h              helper
    \n";
    exit $ret;
}

# -----------------------------------------
# options
# -----------------------------------------
if (!(defined $opt_o)) {
    $opt_o = $opt_i . ".rpt" ;
}

# -----------------------------------------
# project environment
# -----------------------------------------
use NVEnv;
use NVTools::NVBuildUtil;
use SetChipPath;
use CadConfig;
use ProjectSetup;

my $config = CadConfig::factory();;
my $chip = $config->{CHIP_NAME};

my $nvbu = new NVTools::NVBuildUtil;
my $chip_root = $nvbu->Depth();
my $litter = $config->{LITTER_NAME} ;

# -----------------------------------------
# parsing routeRules pm files
# -----------------------------------------

my $routeRulesdir = "$chip_root/ip/retime/retime/1.0/vmod/include/interface_retime" ;
my %Rules = () ;  

print "Parsing routeRules.pm files : \n" ;

my @chiplets = sort keys %{$config->{partitioning}{chiplets}} ;
foreach my $chiplet (@chiplets) {
    my $routeRulesFile = "$routeRulesdir/interface_retime_${litter}_${chiplet}_routeRules.pm" ; 
    if (-e $routeRulesFile) {
        print "\t$routeRulesFile\n" ;

        my $Rule_name = "" ;
        my $Rule_pipe = "" ;
 
        open IN, "$routeRulesFile" or die "Can't open file $routeRulesFile\n" ; 
        while (<IN>) {
            chomp ;
            my $line = $_ ;
            if ($line =~ /\s+name\s+=>\s+\"(\S+)\"/) {
                $Rule_name = $1 ;
            } elsif ($line =~ /.*pipeline_steps.*=>\s+\"(\S+)\"/) {
                $Rule_pipe = $1 ;
                foreach my $pipe (split (",", $Rule_pipe)) {
                    $Rules{$chiplet}{$Rule_name}{$pipe} = 1 ;
                }   
            } 
        }
        close IN ;
    }
} 

# -----------------------------------------
# parsing cdc analysis report files
# -----------------------------------------

my $input_file  = $opt_i ;
my $output_file = $opt_o ;
my %cdc = () ;

open IN, "$input_file" or die "Can't open file $input_file\n" ; 
open OUT, "> $output_file" or die "Can't write to file $output_file\n" ;

my $start_pipe = "" ;
my $end_pipe = "" ;

while (<IN>) {
    chomp ;
    my $line = $_ ;
    if ($line =~ /^rt -from (\S+)\(.* -to (\S+)\(.*/) {
        $start_pipe = $1 ;
        $end_pipe = $2 ;
        if ($start_pipe =~ /_retime_.*_RT/) {
            $start_pipe =~ s/.*_RT.*?_(\S+?)\/.*/$1/ ; 
        } else {
            $start_pipe = "HEAD" ;
        }
        if ($end_pipe =~ /_retime_.*_RT/) { 
            $end_pipe =~ s/.*RT.*?_(\S+?)\/.*/$1/ ; 
        } else {
            $end_pipe = "TAIL" ;
        }
        print OUT "$line\n" ;
    } elsif ($line =~ /rclk : (.*) sclk : (.*) dclk : (.*) eclk : (.*)/) {
        my $rclk = $1 ;
        my $sclk = $2 ;
        my $dclk = $3 ;
        my $eclk = $4 ;
        my $sync = 0 ;
        my $type = "" ;
        foreach my $clk (split (" ", $eclk)) {
            if ($rclk =~ /$clk/) {
                $sync = 1 ;
            } 
        }
        if ($rclk eq "CASED" || $dclk eq "DANGLE" || $rclk eq "" || $dclk eq "") {
            $sync = 1 ;
        }
        if (!$sync) {
            $type = "remove" ;
            $cdc{$type}{$start_pipe} = 1 ;
            $cdc{$type}{$end_pipe}   = 1 ;
        } else {
            if ($rclk eq 'CASED') {
                if ($dclk !~ /$sclk/) {
                    $type = "wrong" ;
                    $cdc{$type}{$start_pipe} = 1 ;
                } elsif ($dclk !~ /$eclk/) {
                    $type = "wrong" ;
                    $cdc{$type}{$end_pipe} = 1 ;
                } else {
                    print OUT "Error $line\n" ; 
                }
            } elsif ($dclk eq 'DANGLE') {
                if ($rclk !~ /$sclk/) {
                    $type = "wrong" ;
                    $cdc{$type}{$start_pipe} = 1 ;
                } elsif ($rclk !~ /$eclk/) {
                    $type = "wrong" ;
                    $cdc{$type}{$end_pipe} = 1 ;
                } else {
                    print OUT "Error $line\n" ;
                }
            } elsif ($rclk !~ /$sclk/) {
                $type = "wrong" ;
                $cdc{$type}{$start_pipe} = 1 ;
            } elsif ($dclk !~ /$eclk/) {
                $type = "wrong" ;
                $cdc{$type}{$end_pipe} = 1 ;
            } else {
                $type = "waive" ;
                $cdc{waive}{$start_pipe} = 1 ;
                $cdc{waive}{$end_pipe} = 1 ;
            }
        }
        print OUT "$type $line $start_pipe $end_pipe\n" ;
    } elsif ($line =~ /Double-check/) {
        $cdc{Dcheck}{$start_pipe} = 1 ;  
        $cdc{Dcheck}{$end_pipe} = 1 ;  
        print OUT "Dcheck $line\n" ;
    } else {
        print OUT "Error $line\n" ;
    } 
}

close IN ;
close OUT ;

# -----------------------------------------
# dumping summary 
# -----------------------------------------

$output_file = $output_file . ".sum" ;
my %rule_cdc = () ;
# $Rules{$chiplet}{$Rule_name}{$pipe} =

foreach my $type (sort keys %cdc) {
    foreach my $pipe (sort keys %{$cdc{$type}}) {
        foreach my $chiplet (sort keys %Rules) {
            foreach my $rule_name (sort keys %{$Rules{$chiplet}}) {
                if (exists $Rules{$chiplet}{$rule_name}{$pipe}) {
                    $rule_cdc{$type}{$chiplet}{$rule_name}{$pipe} = 1 ;
                }
            }
        }
    }
}

open OUT, "> $output_file" or die "Can't write to file $output_file\n" ;

print OUT "Remove Rules : \n" ;
foreach my $chiplet (sort keys %{$rule_cdc{remove}}) {
    print OUT "Chiplet $chiplet :\n" ;    
    foreach my $rule_name (sort keys %{$rule_cdc{remove}{$chiplet}}) {
        print OUT "\t$rule_name\n\t\t" ;
        foreach my $pipe (sort keys %{$rule_cdc{remove}{$chiplet}{$rule_name}}) {
            print OUT "$pipe " ;
        }
        print OUT "\n" ;
    }
}

print OUT "Wrong Clk Connection Rules : \n" ;
foreach my $chiplet (sort keys %{$rule_cdc{wrong}}) {
    print OUT "Chiplet $chiplet :\n" ;
    foreach my $rule_name (sort keys %{$rule_cdc{wrong}{$chiplet}}) {
        print OUT "\t$rule_name\n\t\t" ;
        foreach my $pipe (sort keys %{$rule_cdc{wrong}{$chiplet}{$rule_name}}) {
            print OUT "$pipe " ;
        }
        print OUT "\n" ;
    }
}

print OUT "Wavie : \n" ;
foreach my $chiplet (sort keys %{$rule_cdc{waive}}) {
    print OUT "Chiplet $chiplet :\n" ;
    foreach my $rule_name (sort keys %{$rule_cdc{waive}{$chiplet}}) {
        print OUT "\t$rule_name\n\t\t" ;
        foreach my $pipe (sort keys %{$rule_cdc{waive}{$chiplet}{$rule_name}}) {
            print OUT "$pipe " ;
        }
        print OUT "\n" ;
    }
}

print OUT "Need Double Check : \n" ;
foreach my $chiplet (sort keys %{$rule_cdc{Dcheck}}) {
    print OUT "Chiplet $chiplet :\n" ;
    foreach my $rule_name (sort keys %{$rule_cdc{Dcheck}{$chiplet}}) {
        print OUT "\t$rule_name\n\t\t" ;
        foreach my $pipe (sort keys %{$rule_cdc{Dcheck}{$chiplet}{$rule_name}}) {
            print OUT "$pipe " ;
        }
        print OUT "\n" ;
    }
}


close OUT ;
