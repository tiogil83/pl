#! /home/gnu/bin/perl -w

use strict ;
#use Getopt::Long ;
#
#my $opt_help ;
#my $opt_block ;
#my $opt_iponum ;
#my $opt_layoutrev ;
#
#GetOptions (
#  "h" => \$opt_help ,
#  "n" => \$opt_iponum ,
#  "b" => \$opt_block ,
#  "l" => \$opt_layoutrev ,
#);
#
#my $USAGE = "This script is to kick off the anno run for macros.
#Arguments:
#\t-h : This help.
#\t-b : REQUIRED. The block (macro) being run.
#\t-n : REQUIRED. The block (macro) ipo number.
#\t-l : REQUIRED. The block (macro) layout revision.
#" ;
#
#if(!$opt_block || !$opt_iponum || $opt_help){
#  die($USAGE) ;
#}

#my $block = $opt_block ;
#my $iponum = $opt_iponum ;
#my $layoutrev = $opt_layoutrev ;
my $block = shift ;
my $iponum = shift ;
my $layoutrev = shift ; 

my @corners = qw /macro_anno_hv_ss_cold_max_std_max macro_anno_hv_ss_cold_max_std_max/ ;
foreach my $corner(@corners){
  `/home/utils/make-3.82/bin/make PT_FALSE_PATH_IO=1 ANNO_REV_$block=$iponum DONT_USE_NONYAML=1 USE_YAML=1 USE_LAYOUT_REV=$layoutrev USE_32G_OPTERON=1 USE_PROJ_RAM_LIB=1 USE_SDC_FILE=1 IPO_DIR=/home/t148_layout/tot/layout/$layoutrev/netlists $block.$corner & ` ;
  #print "/home/utils/make-3.82/bin/make PT_FALSE_PATH_IO=1 ANNO_REV_$block=$iponum DONT_USE_NONYAML=1 USE_YAML=1 USE_LAYOUT_REV=$layoutrev USE_32G_OPTERON=1 USE_PROJ_RAM_LIB=1 USE_SDC_FILE=1 IPO_DIR=/home/t148_layout/tot/layout/$layoutrev/netlists $block.$corner & " ;
}
