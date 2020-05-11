#! /home/utils/perl-5.8.8/bin/perl -wi

use strict ;
use Getopt::Long ;

my $help ;
my $in_file ;
my $out_file ;

GetOptions (
  "h" => \$help ,
  "in=s" => \$in_file,
  "out=s" => \$out_file,
) ;

my $USAGE = "This script is used for filter .\n" ;
$USAGE .= "$0 -h\tprint this message\n" ;
$USAGE .= "$0 -in\tinput file\n" ;
$USAGE .= "$0 -out\toutput file\n" ;

if($help || !$in_file || !$out_file){
  die "$USAGE" ;
}

open IN, "$in_file" or die "can't open the input file $in_file\n" ;
#open OUT, "> $out_file" or die "can't write to the output file $out_file\n" ;;

if(-e "/home/junw/temp"){
  unlink "/home/junw/temp" ; 
}

open TEMP, "> /home/junw/temp" ;

while(<IN>){
  chomp ;
  /^\s+(\S+)(\(in\))?\s+(\S+)\s+\S+\s+(\S+)\s+\(VIOL.*\)\s+(\S+)$/g ;
  my $input_pin = $1 ;
  my $req = $3 ;
  my $viol = $4 ;
  my $output_pin = $5 ;
  print TEMP "$output_pin $req $viol\n" ;
}

`mv /home/junw/temp $out_file` ; 

close IN ;
#close OUT ;
close TEMP ;
