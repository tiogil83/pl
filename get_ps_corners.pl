#!/home/utils/perl-5.8.8/bin/perl

BEGIN {
#    $tot = "/home/nvtools/service/gp100_tm";
#    $tot = "/home/scratch.gv100_master_libs/gv100_tm";
    $tot = "/home/nvtools/latest" ;
    $ENV{NVDEV} = $tot;
}



use strict;         # no symbolic references
use warnings FATAL => qw(all);

use Getopt::Long;

use vars qw($opt_ps $opt_phase $opt_mode $opt_top $opt_h);
GetOptions (  "ps=s", "phase=s", "mode=s", "top=s", "h");

# -----------------------------------------
# help 
# -----------------------------------------

usage(0) if ($opt_h);

sub usage {
    my($ret) = shift;

    print "$0 - update the generate_sdc parameter  
    -ps                 <project setup yaml>            project setup file. optional.  default is <TOT>/<project>/project_setup.yaml
    -phase              <phase name>                    phase in yaml file. default is signoff.
    -mode               <mode name>                     mode in yaml file. default is std_max.
    -top                <top name>                      top should be top|chiplet|partition|macro 
    -h                  helper
    \n";
    exit $ret;
}


# -----------------------------------------
# project environment
# -----------------------------------------
use NVEnv;
use NVTools::NVBuildUtil;
use SetChipPath;
use CadConfig;
use ProjectSetup;
use Data::Dumper;

my $config = CadConfig::factory();;
my $chip = $config->{CHIP_NAME};


my $nvbu = new NVTools::NVBuildUtil;
my $chip_root = $nvbu->Depth();

# ------------------------------
# arguments
# ------------------------------

my ($file, $phase, $mode, $top) ;

if ($opt_ps) {
    $file = $opt_ps;
} else {
    $file = "$chip_root/timing/$chip/project_setup.yaml";
}

if ($opt_top) {
    $top = $opt_top ; 
    if ($top ne 'top' && $top ne 'chiplet' && $top ne 'partition' && $top ne 'macro') {
        die  "Need to specify a Correct top. Should be [top|chiplet|partition|macro]\n" ;
    }
} else {
    $top = "chiplet" ;
}

my $ps = new ProjectSetup(-yamlFile => $file, -debug => 0, -project => $chip) ;

my $phases = $ps->GetProject(-project => $chip, -param => "phases") ;
my %ps_phases = () ;
my %ps_modes  = () ;

foreach my $ps_phase (sort keys %{$phases}) {
    $ps_phases{$ps_phase} = 1 ;
    foreach my $ps_corner (sort keys %{${$phases}{$ps_phase}{corners}}) {
        foreach my $ps_mode (sort keys %{${$phases}{$ps_phase}{corners}{$ps_corner}{constraint_modes}{tool_defaults}}) {
            $ps_modes{$ps_mode} = 1 ;
        }
    }
} 

if ($opt_phase) {
    $phase = $opt_phase ;
    if (!(exists $ps_phases{$phase})) {
        print "Need to specify a Correct Phase Name :\n" ;
        foreach (sort keys %ps_phases) {
            print "$_\n" ;
        }
        die "\n" ;
    } 
} elsif ($ps->HasProject(-project => $chip, -param => "current_project_phase")) {
    $phase = $ps->GetProject(-project => $chip, -param => "current_project_phase") ;
} else {
    die "Need to specify a Phase Name.\n" ;
} 

if ($opt_mode) {
    $mode = $opt_mode ;
    if (!(exists $ps_modes{$mode})) {
        print "Need to specify a Correct Mode Name :\n" ;
        foreach (sort keys %ps_modes) {
            print "$_\n" ;
        }
        die "\n" ;
    } 
} else {
    $mode = "std_max" ; 
}


# ------------------------------
# Main
# ------------------------------

print "PS yaml file : $file\n" ;
print "Phase name   : $phase\n" ;
print "Mode name    : $mode\n" ;

my %corners = () ;

foreach my $corner (sort keys %{${$phases}{$phase}{corners}}) {
    if (exists ${$phases}{$phase}{corners}{$corner}{constraint_modes}{tool_defaults}{$mode}{block_levels}{$top}) {
        if (${$phases}{$phase}{corners}{$corner}{constraint_modes}{tool_defaults}{$mode}{block_levels}{$top} eq 'true') {
            $corners{$corner} = 1 ;
        }
    }
}

# -------------------------------
# Dump out corners
# -------------------------------
my @phase_corners = sort keys %corners ;
my $phase_corners_num = $#phase_corners + 1 ;
print "Total $phase_corners_num $mode corners for $top in $phase.\n" ;

foreach (@phase_corners) {
    print "\t$_\n" ;
}

