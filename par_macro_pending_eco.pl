#!/home/utils/perl-5.8.8/bin/perl -wi

#BEGIN {
#  require "/home/nv/bin/asic_pd/lib/TimingEnv.pm";
#}

BEGIN {
    $tot = "/home/nvtools/service/gp100_tm";
    $ENV{NVDEV} = $tot;
}

use vars qw ($opt_help $opt_top $opt_yaml $opt_rev $opt_chiplet $opt_par $opt_macro) ;

use strict;
use Carp;
use NVEnv;
use CadConfig;
use Getopt::Long;
use YAML::Syck;
use ProjectSetup;
use PartitionUtils;
use Data::Dumper;

GetOptions (
  "h"       => \$opt_help ,
  "top=s"   => \$opt_top ,
  "yaml=s"  => \$opt_yaml ,
  "rev=s"   => \$opt_rev ,
  "chiplet" => \$opt_chiplet ,
  "par"     => \$opt_par ,
  "macro"   => \$opt_macro ,
) ;
 
my $USAGE =  "to get the pending ecos. \n" ;
$USAGE .= "-h : to print the help message. \n" ;
$USAGE .= "-top : to specify the top. \n" ;
$USAGE .= "-yaml :  to specify the yaml file. \n" ;
$USAGE .= "-rev : to specify the layout revision. \n" ;
$USAGE .= "-chiplet : to print out the chiplet ecos. \n" ;
$USAGE .= "-par : to print out the partition ecos. \n" ;
$USAGE .= "-macro : to print out the macro ecos. \n" ;

if ($opt_help || !$opt_chiplet || !$opt_par || !$opt_macro) {
  die($USAGE) ;
}

my $tot = `depth`;
my $config = CadConfig::factory();
my $proj = $config->CHIP_NAME;

my $top ; 
unless (defined $opt_top) {
  $top = "nv_top" ;
}else{
  $top = $opt_top ;
}

my $yaml_file ;
unless (defined $opt_yaml) {
  $yaml_file = "${tot}/timing/${proj}/project_setup.yaml" ;
}else{
  $yaml_file = $opt_yaml ;
}
print "Start to loading the yaml file : $yaml_file \n" ;

my $loadyaml = LoadFile($yaml_file) ;

my $rev ; 
unless (defined $opt_rev) {
  $rev = ${$loadyaml}{projects}{$proj}{latest_revision} ; 
}else{
  $rev = $opt_rev ;
}

my $yaml     = ProjectSetup->new(-yamlFile=>$yaml_file );
my @inst = $yaml->GetHierarchy(-block=> "NV_gmg_t0",-rev=>"$rev",-project=>"$proj");
foreach my $ins (@inst) {
  my $ischiplet = $yaml->HasBlock(-block=> $ins,-rev=>$rev,-project=>$proj,-param=>"is_chiplet") ;
  my $ispartition = $yaml->HasBlock(-block=> $ins,-rev=>$rev,-project=>$proj,-param=>"is_partition") ;
  my $ismacro = $yaml->HasBlock(-block=> $ins,-rev=>$rev,-project=>$proj,-param=>"is_macro") ;
} 


####Subs###
####yaml_data is gen the all necessage data from projest_setup.yaml.
#sub yaml_data {
####Variable### 
#  my $topdata = {};
#  my $yamlfile = shift;
#  my $proj     = shift;
####New object### 
#  my $yaml = LoadFile($yamlfile) ;
#  unless ($opt_rev) {
#    $opt_rev                 = ${$yaml}{projects}{$proj}{latest_revision} ;
#    print "## Undefined revision. Use latest revision: $opt_rev \n";
#  }
#  my @inst = $yaml->GetHierarchy(-block=> "nv_top",-rev=>$rev,-project=>$proj);
#  if(defined $opt_top){
#     @inst = split(/\s+/, $opt_top);
#     print "got top module @inst from command line \n";
#  } 
#}
