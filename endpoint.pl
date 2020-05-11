#! /home/gnu/bin/perl -w
use strict ;

unlink 'num' ;

my $input_file = $ARGV[0] ;
open IN ,"gunzip -dc $input_file|" ;
open OUT, ">> num" ;


my $start_flag ;
my $endpoint ;
my $slack ;
#my $blpg_num = 0 ;
#my $clock_num = 0 ;
my $macro_num = 0;
my $other_num = 0 ;

while(<IN>){
  chomp ;
  if(/Startpoint: /){
    $start_flag = 1 ;
    $slack = 0 ;
    next ;
  }
  if($start_flag && /Endpoint: (\S+)$/){
    $endpoint = $1 ;
    next ;
  }
  if($start_flag && /slack \(VIOLATED\)/){
    $slack = 1 ;
    $start_flag = 0 ;
    next ;
  }
#  if($slack){
#    if($endpoint =~ /U_blpg_master/){
#      $blpg_num ++ ;
#      $slack = 0 ;
#    }elsif($endpoint =~ /cb_group_et0tx1a/){
#      $clock_num ++ ;
#      $slack = 0 ;
#    }else{
#      $other_num ++ ;
#      print OUT "$endpoint\n" ;
#      $slack = 0 ;
#    }
#  }
  if($slack){
    if($endpoint =~ /U_blpg_master|cb_group_et0tx1a|NV_ISM_MINI_1CLK_GPU_et0tx1a/){
      $macro_num ++ ;
      $slack = 0 ;
    }else{
      $other_num ++ ;
      print OUT "$endpoint\n" ;
      $slack = 0 ;
    }
  }
}

print OUT "-" x 50 ;
print OUT "\n" ;
#print OUT "violations in blpg macros:\t\t$blpg_num\n" ;
#print OUT "violations in clock macros:\t\t$clock_num\n" ;
print OUT "violations in macros:\t\t\t$macro_num\n" ;
print OUT "violations NOT in macros:\t\t$other_num\n" ;
print OUT "-" x 50 ;
print OUT "\n" ;

close IN ;
close OUT ;
