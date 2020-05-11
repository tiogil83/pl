#! /home/utils/perl-5.8.8/bin/perl -wi

use strict ;
use Getopt::Long ;

my $help ;
my $ref_file ;
my $in_file ;
my $out_file ;

GetOptions (
  "h" => \$help ,
  "ref=s" => \$ref_file,
  "in=s" => \$in_file,
  "out=s" => \$out_file,
) ;

my $USAGE = "This script is used for filter out throug_pin paths.\n" ;
$USAGE .= "$0 -h\tprint this message\n" ;
$USAGE .= "$0 -ref\treference file\n" ;
$USAGE .= "$0 -in\tinput file\n" ;
$USAGE .= "$0 -out\toutput file\n" ;

if($help || !$in_file || !$out_file){
  die "$USAGE" ;
}

open REF, "$ref_file" or die "can't open the input file $ref_file\n" ;
open IN, "$in_file" or die "can't open the input file $in_file\n" ;
#open OUT, "> $out_file" or die "can't write to the output file $out_file\n" ;;

if(-e "/home/junw/temp"){
  unlink "/home/junw/temp" ; 
}

open TEMP, "> /home/junw/temp" ;

#10:89     10    max  -1.113 ssg_0c_0p6v_max_mv_si.std_max **async_default** (jtag_reg_tck => jtag_reg_tck) sys0_0/u_txa_backbone/car/u_NV_FUSE_wrapper/u_NV_fuse/u_gen/u_fls_wrapper/u_fls_jtag/TOP_FS_stdjtag/Jreg_lat_reg_0_/D gpu0_0/fgsx0_0/GVC0STPC0/GVC0TPC0/tpc0/sm0_0/gvcsm0sdlqa_1/u_GVC_SMV_1500_wrapper/dftModules_gvcsm0sdlqa_0/dftModulesWrapper_inst/MISCDFTModulesWrapper_inst/MBIST_TOP_inst/central_bist_ctrl_inst/test_sel_inst/MBIST_TOP_stdjtag/Jreg_lat_reg_181_/CDN
my %epins = () ;

while (<REF>) {
  chomp ;
  if (/^\d+:\d+\s+/) {
    /^\d+:\d+\s+\d+\s+\S+\s+\S+\s+\S+\s+\S+\s+\(.*\)\s+(\S+)\s+(\S+)/ ;
    my $start_pin = $1 ;
    my $end_pin = $2 ;
    $epins{$end_pin} = 1 ;
  }
}

while(<IN>){
  chomp ;
  if (/^\d+:\d+\s+/) {
    /^\d+:\d+\s+\d+\s+\S+\s+\S+\s+\S+\s+\S+\s+\(.*\)\s+(\S+)\s+(\S+)/ ;
    my $start_pin = $1 ;
    my $end_pin = $2 ;
    if (exists $epins{$end_pin}) {
       print "$start_pin $end_pin\n" ;
    } else {
       print TEMP "$end_pin\n" ;
    }
  }
}

`mv /home/junw/temp $out_file` ; 

close REF ;
close IN ;
#close OUT ;
close TEMP ;
