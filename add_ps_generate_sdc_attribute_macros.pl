#! /home/utils/perl-5.8.8/bin/perl 

use lib "/home/nvtools/latest/nvtools/perlib";


BEGIN {require "/home/nvtools/latest/nvtools/perlib/TimingEnv.pm";}

##TODO : macro list hardcoded ; pls. change
print "###Output will be in test.scenario file, copy it to gp102/project_setup.yaml\n";

#use NVEnv;
use CadConfig;
use Getopt::Long ;
use NVTools::NVBuildUtil;
use ProjectSetup;
use strict;
use warnings FATAL => qw(all);

# read in the chip config - all sorts of goodies in there
my($config) = CadConfig::factory();


# Open project setup YAML.
my $chip = $config->{CHIP_NAME};
my $nvbu = new NVTools::NVBuildUtil;
my $depth = $nvbu->Depth();
my $rev = $ARGV[0];
my $view = $ARGV[1];
my $opt_skipverify;
print "$depth/timing/$chip/project_setup.yaml\n";
my $ps = new ProjectSetup(-yamlFile => "$depth/timing/$chip/project_setup.yaml", -project => $chip, -skipverify => $opt_skipverify);

## Add emc_pad_macro_pipe_config_if in list ##
my @macros_noscan=();

## Add emc_pad_macro_pipe_config_if in list ##
my @macros_feflat=(
"");

if ($view eq "noscan") {
    foreach my $macro (@macros_noscan) {
        print "$macro $view\n";
        my $macro_jtag = $macro."_jtag";
        if($ps->HasBlock(-project => "gp102", -view => $view, -rev => $rev, -param => "is_macro", -block => $macro)) {
            $ps->SetBlock(-project => "gp102", -view => $view, -rev => $rev, -block => $macro, -param => 'generate_sdc', -value => 'true');
        } 
    }
} else { 
    foreach my $macro (@macros_feflat) {
        print "$macro $view\n";
        if ($ps->HasBlock(-project => "gp102", -view => $view, -rev => $rev, -param => "is_macro", -block => $macro)) {
             $ps->SetBlock(-project => "gp102", -view => $view, -rev => $rev, -block => $macro, -param => 'generate_sdc', -value => 'true');
         }
     }

}

$ps->SaveAs('test.scenario');
