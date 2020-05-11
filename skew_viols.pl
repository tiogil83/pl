#! /home/gnu/bin/perl -w
use strict ;

my $input_file = $ARGV[0] ;
open IN ,"gunzip -dc $input_file|" ;

if(-e "timing_report_skew"){
  unlink "timing_report_skew" ;
}

open OUT, "> timing_report_skew" ;

my $start_flag ;
my $data_path ;
my $data_delay ;
my $clock_delay ;
my $skew ;
my $gt200 = 0 ;
my $gt100 = 0 ;
my $lt100 = 0 ;
my $lt200 = 0 ;
my $mid100 = 0 ;

while(<IN>){
  chomp ;
  if(/Startpoint:/){
    $start_flag = 1 ;
    $data_path = 1 ;
    next ;
  }
  if(/clock uncertainty/){
    $start_flag = 0 ;
    $data_path = 0 ;
    next ;
  }
  if($start_flag){
    if($data_path && /clock network delay \(propagated\)\s+(\d\.\d+)/ ){
      $data_delay = $1 ;
      next ;
    }
    if(/data arrival time/){
      $data_path = 0 ;
      next ;
    }
    if(($data_path == 0) && /clock network delay \(propagated\)\s+(\d\.\d+)/ ){
      $clock_delay = $1 ;
      $skew = $clock_delay - $data_delay ;
      if($skew > 0.2){
        $gt200++ ; 
      }elsif(($skew < 0.2) && ($skew > 0.1)){
        $gt100++ ;
      }elsif(($skew < 0.1) && ($skew > -0.1)){
        $mid100++ ;
      }elsif(($skew < -0.1) && ($skew > -0.2)){
        $lt100++ ;
      }else{
        $lt200++ ;
      }

      next ;
    }
    next ;
  }
}

my $col1 = "skew" ;
my $col2 = "viol num" ;

printf OUT "+" x 38 ;
printf OUT "\n" ;
printf OUT "|%-25s|%-10s|\n", $col1, $col2  ;
printf OUT "+" x 38 ;
printf OUT "\n" ;
printf OUT "|%-25s|%-10d|\n", "skew > 200ps", $gt200 ;
printf OUT "|%-25s|%-10d|\n", "100ps < skew < 200ps", $gt100 ;
printf OUT "|%-25s|%-10d|\n", "-100ps < skew < 100ps", $mid100 ;
printf OUT "|%-25s|%-10d|\n", "-200ps < skew < -100ps", $lt100 ;
printf OUT "|%-25s|%-10d|\n", "skew < -200ps", $lt200 ;
printf OUT "+" x 38 ;
printf OUT "\n" ;

close IN ;
close OUT ;
