#!/home/utils/perl-5.8.8/bin/perl

BEGIN {
#    $tot = "/home/nvtools/service/gp100_tm";
    $tot = "/home/scratch.gv100_master_libs/gv100_tm";
    $ENV{NVDEV} = $tot;
}



use strict;         # no symbolic references
use warnings FATAL => qw(all);

use Getopt::Long;

use vars qw($opt_rev $opt_chiplet $opt_new $opt_old $opt_h);
GetOptions ("rev=s", "chiplet=s", "new=s", "old=s", "h");

# -----------------------------------------
# help
# -----------------------------------------

usage(0) if ($opt_h);
usage(0) if (!defined($opt_chiplet) || !defined($opt_old));

sub usage {
    my($ret) = shift;

    print "$0 -         to compare the ipos from 2 yaml files 
    -rev                <layoutrev>                     layout rev to touch. optional. default is current revison
    -chiplet            <chiplet name>                  chiplet name 
    -new                <file>                          new ipos yaml file 
    -old                <file>                          old ipos yaml file 
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

my $config = CadConfig::factory();;
my $chip = $config->{CHIP_NAME};

my $nvbu = new NVTools::NVBuildUtil;
my $chip_root = $nvbu->Depth();
#my $chip_root = `depth`;

# -----------------------------------------
# arguments
# -----------------------------------------
my ($file_new);
if ($opt_new) {
    $file_new = $opt_new ;
} else {
    $file_new = "$chip_root/timing/$chip/project_setup.yaml";
}

my $file_old = $opt_old ;

my $ps = new ProjectSetup(-yamlFile => $file_new, -debug => 0, -project => $chip);
my $ps_old = new ProjectSetup(-yamlFile => $file_old, -debug => 0, -project => $chip);

my $rev;
if (defined($opt_rev)) {
    $rev = $opt_rev;
} elsif ($ps->HasProject(-project => $chip, -param => "latest_revision")) {
    $rev = $ps->GetProject(-project => $chip, -param => "latest_revision");
} else {
    die "Error: you must specify -rev in project $chip\n";
}

if ( !$ps->IsBlock(-project => $chip, -rev => $rev, -view => 'layout', -block => $opt_chiplet) ) {
    die "Error: -block $opt_chiplet is not a valid block\n";
}

my @sub_blocks = $ps->GetBlocks(-project => $chip, -rev => $rev, -view => 'layout', -block =>$opt_chiplet) ;

foreach my $block (@sub_blocks) {
  my $ipo_new = $ps->GetBlock(-project => $chip, -rev => $rev, -view => 'layout', -block => $block, -param => 'latest_ipo') ; 
  my $ipo_old = $ps_old->GetBlock(-project => $chip, -rev => $rev, -view => 'layout', -block => $block, -param => 'latest_ipo') ; 
  #print "$_ $ipo_new $ipo_old\n" ;
  if ($ipo_new != $ipo_old) {
    printf "%-40s\t latest_ipo $ipo_new \t yaml_ipo $ipo_old\n", $block ; 
  }
}


