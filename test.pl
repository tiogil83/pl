#!/home/utils/perl-5.8.8/bin/perl

BEGIN {
    $tot = "/home/nvtools/service/ga100_tm";
    $ENV{NVDEV} = $tot;
}



use strict;         # no symbolic references
use warnings FATAL => qw(all);

use Getopt::Long;
use Data::Dumper ;

use vars qw($opt_ps $opt_rev $opt_blocks $opt_ipo_list_file $opt_post $opt_h);
GetOptions (  "ps=s", "rev=s", "blocks=s","ipo_list_file=s", "post", "h");

# -----------------------------------------
# help 
# -----------------------------------------

usage(0) if ($opt_h);
#usage(0) if (!defined($opt_blocks) && !defined($opt_ipo_list_file));

sub usage {
    my($ret) = shift;

    print "$0 - update block ipo number
    -ps             <project setup yaml>            project setup file. optional.  default is <TOT>/<project>/project_setup.yaml
    -rev            <layoutrev>                     layout rev to touch. optional. default is current revison
    -blocks         <block1.ipoxxx:block2.ipoxxx>   block & ipo from command line
    -ipo_list_file  <file>                          ipo list file, file format: block_name ipo_number
    -post           enable post check for gv/def/spef files. default is disabled 
    -h              helper
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
my $view = "layout";
my ($file);
if ($opt_ps) {
    $file = $opt_ps;
} else {
    $file = "$chip_root/timing/$chip/project_setup.yaml";
}    

my %block_hash;

if (defined($opt_ipo_list_file)) {
    open FILEID,$opt_ipo_list_file or die "cannot open file $opt_ipo_list_file";
    print "opening file $opt_ipo_list_file\n";

    while(<FILEID>){
        my $line = $_;
        chomp($line);

        next if ($line =~ /^#/);
        next if ($line !~ /^\w+/);
        my @block_with_ipo = split(/\s+/,$line);
        print "updating ipo: $block_with_ipo[0] -> $block_with_ipo[1]\n";
        $block_hash{$block_with_ipo[0]} = $block_with_ipo[1];
    }

    close FILEID;
}

if (defined($opt_blocks)) {
    my @block_with_ipo = split(/:/,$opt_blocks);
    foreach my $block_ipo (@block_with_ipo) {
        my @block_pair = split(/\./,$block_ipo);
        $block_pair[1] =~ s/ipo//g;
        print "updating ipo: $block_pair[0] -> $block_pair[1]\n";
        $block_hash{$block_pair[0]} = $block_pair[1];
    }
}



# -----------------------------------------
# Main 
# -----------------------------------------

my $ps = new ProjectSetup(-yamlFile => $file, -debug => 0, -project => $chip, -updater => 1);

my $rev;
if (defined($opt_rev)) {
    $rev = $opt_rev;
} elsif ($ps->HasProject(-project => $chip, -param => "latest_revision")) {
    $rev = $ps->GetProject(-project => $chip, -param => "latest_revision");
} else {
    die "Error: you must specify -rev in project $chip\n";
}

# -----------------------------------------
# Post Check  
# ----------------------------------------- 

my $phase ;
my $ps_phases ;
my %corners ;  
my $ps_corners ;
my %para_temp ;

if ($ps->HasProject(-project => $chip, -param => "current_project_phase")) {
    $phase = $ps->GetProject(-project => $chip, -param => "current_project_phase") ;
} else {
    die "Need to specify a Phase Name.\n" ;
}

#$ps_phases = $ps->GetProject(-project => $chip, -param => "phases") ;
my @ps_corners = $ps->GetPhaseCorners(-project => $chip, -phase => $phase) ;
#%corners = %{${$ps_phases}{$phase}{corners}} ;


print (Dumper @ps_corners) ;
#foreach (sort keys %{$ps_corners}) {
#    print "$_\n" ;
#}
#foreach my $corner (sort keys %corners) {
#    #print "$corner\n" ;
#    print (Dumper ${$ps_corners}{$corner}) ;
#    if (exists ${$ps_corners}{$corner}{parasitics_temp}) {
#        print "${$ps_corners}{$corner}{parasitics_temp}\n" ;
#    } 
#}

