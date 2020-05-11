#! /home/utils/perl-5.8.8/bin/perl -wi

use strict ;
use Getopt::Long ;

my $help ;
my $in_file ;
my $filter_file ;
my $out_file ;

GetOptions (
  "h" => \$help ,
  "in=s" => \$in_file,
  "fil=s" => \$filter_file,
  "out=s" => \$out_file,
) ;

my $USAGE = "This script is used for filter .\n" ;
$USAGE .= "$0 -h\tprint this message\n" ;
$USAGE .= "$0 -in\tinput file\n" ;
$USAGE .= "$0 -fil\tfilter file\n" ;
$USAGE .= "$0 -out\toutput file\n" ;

if($help || !$in_file || !$filter_file || !$out_file){
  die "$USAGE" ;
}

open IN, "$in_file" or die "can't open the input file $in_file\n" ;
open FIL, "$filter_file" or die "can't open the filter file $filter_file\n" ;
open OUT, "> $out_file" or die "can't write to the output file $out_file\n" ;;

my @filter = <FIL> ;

while(<IN>){
   chomp ;
   /^\s+(.*) 0\./g ;
   my $line = $1 ;
   if($line =~ /\[/){
     $line =~ s/\[/\\[/g
   } ;
   if(grep /^$line$/, @filter){
     next ;
   }else{
     print OUT "$line\n" ;
     next ;
   }
}

close IN ;
close OUT ;
close FIL ;
