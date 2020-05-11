#!/home/utils/perl-5.8.8/bin/perl

BEGIN {
#    $tot = "/home/nvtools/service/gp100_tm";
    $tot = "/home/scratch.gv100_master_libs/gv100_tm";
    $ENV{NVDEV} = $tot;
}



use strict;         # no symbolic references
use warnings FATAL => qw(all);

use Getopt::Long;

use vars qw($opt_ps $opt_rev $opt_blocks $opt_view $opt_macro_list_file $opt_h);
GetOptions (  "ps=s", "rev=s", "blocks=s", "view=s", "macro_list_file=s", "h");

# -----------------------------------------
# help 
# -----------------------------------------

usage(0) if ($opt_h);
usage(0) if (!defined($opt_blocks) && !defined($opt_macro_list_file));

sub usage {
    my($ret) = shift;

    print "$0 - update the generate_sdc parameter  
    -ps                 <project setup yaml>            project setup file. optional.  default is <TOT>/<project>/project_setup.yaml
    -rev                <layoutrev>                     layout rev to touch. optional. default is current revison
    -blocks             <block1:block2>                 block from command line
    -view               <view>                          view feflat or flat
    -macro_list_file    <file>                        macro list file, file format: block_name
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
my $view = "$opt_view";
my ($file);
if ($opt_ps) {
    $file = $opt_ps;
} else {
    $file = "$chip_root/timing/$chip/project_setup.yaml";
}    

my %block_hash;

if (defined($opt_macro_list_file)) {
    open FILEID,$opt_macro_list_file or die "cannot open file $opt_macro_list_file";
    print "opening file $opt_macro_list_file\n";

    while(<FILEID>){
        my $line = $_;
        chomp($line);

        next if ($line =~ /^#/);
        next if ($line !~ /^\w+/);
        my $block = $line;
        print "updating ipo: $block to generate sdc.\n";
        $block_hash{$block} = 1;
    }

    close FILEID;
}

if (defined($opt_blocks)) {
    my @blocks = split(/:/,$opt_blocks);
    foreach my $block (@blocks) {
        print "updating ipo: $block to generate sdc.\n";
        $block_hash{$block} = 1;
    }
}



# -----------------------------------------
# Main 
# -----------------------------------------
system("p4 edit $file");

my $ps = new ProjectSetup(-yamlFile => $file, -debug => 0, -project => $chip, -updater => 1);

my $rev;
if (defined($opt_rev)) {
    $rev = $opt_rev;
} elsif ($ps->HasProject(-project => $chip, -param => "latest_revision")) {
    $rev = $ps->GetProject(-project => $chip, -param => "latest_revision");
} else {
    die "Error: you must specify -rev in project $chip\n";
}

my $updated = 0;
my $msg = "\"Update macro generate_sdc parameter";

foreach my $block (sort keys %block_hash) {
    my $gen_sdc = $block_hash{$block};
    if ( !$ps->IsBlock(-project => $chip, -rev => $rev, -view => $view, -block => $block) ) {
        die "Error: -block $block is not a valid block\n";
    }
    
    my $exist_gen_sdc = "";
    if ($ps->HasBlock(-project => $chip, -rev => $rev, -view => $view, -block => $block, -param => "generate_sdc") ) {
        $exist_gen_sdc = $ps->GetBlock(-project => $chip, -rev => $rev, -view => $view, -block => $block, -param => "generate_sdc");
    }
    
    if ($exist_gen_sdc) {
        print "Info: in project $chip layout rev $rev, type $view, already update generate_sdc for $block.\n";
        next;
    }
    
    print "Info: in project $chip layout rev $rev, update generate_sdc parameter of $block.\n";
    $msg .= " $block generate_sdc ";
    
    $ps->SetBlock(-project => $chip, -rev => $rev, -view => $view, -block => $block, -param => "generate_sdc", -value => "true" );

    $updated++;

}

$msg .= "\"";

if ($updated > 0) {
    $ps->Verify();
    $ps->Save();
    # -----------------------------------------
    open (OUT, ">$chip_root/timing/update_block_generate_sdc");
    print OUT "p4_submit -m $msg $file\n";
    printf ("Info: Type \"source $chip_root/timing/update_block_generate_sdc\" in this shell to check in the changes\n");
    close OUT;
    
    system("chmod 777 $chip_root/timing/update_block_generate_sdc");

} else {
    print "Info: in project $chip layout rev $rev, No update done. revert $file\n";
    system("p4 revert $file");
}


