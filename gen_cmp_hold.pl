#!/home/utils/perl-5.14/5.14.1-threads-64/bin/perl -wi
use strict ;

my @pars = qw "GPAS0FE GPAF0LTS1 GPAS0PD GPAG0GP" ;
foreach my $par(@pars){
  
  open COMM_IN, "cp.txt.${par}" ;
  open DIFF_IN, "diff.txt.${par}" ;
  open COMM_OUT, "> common.${par}.csv" ;
  open DIFF_OUT, "> diff.${par}.csv" ;
  open PERCENT_OUT, "> percent.${par}.csv" ;
  
  my %common_num ;
  my %diff_num ;
  my %total_num ;
  my %percent ;
  
  my @corners = qw "ffg_m40c_1p21v_min_si ssg_0c_0p6v_min_si ssg_0c_0p5v_min_si ssg_105c_0p5v_min_si" ;
  
  while(<COMM_IN>){
    /(\S+) (\S+) common viol: (\d+) .*$/ ;
    my $corner1 = $1 ;
    my $corner2 = $2 ;
    $common_num{$corner1}{$corner2} = $3 ; 
  }
  
  while(<DIFF_IN>){
    /(\S+) (\S+) diff viol: (\d+) (\d+)$/ ;
    my $corner1 = $1 ;
    my $corner2 = $2 ;
    $diff_num{$corner1}{$corner2} = $3 ; 
    $total_num{$corner1}{$corner2} = $4 ; 
    eval ($percent{$corner1}{$corner2} = $diff_num{$corner1}{$corner2} / $total_num{$corner1}{$corner2} *100) ; 
  }
  
  print COMM_OUT "common viols," ;
  print DIFF_OUT "diff viols," ;
  print PERCENT_OUT "diff percentage," ;
  
  foreach my $corner1(@corners){
    print COMM_OUT "$corner1," ;
    print DIFF_OUT "$corner1," ;
    print PERCENT_OUT "$corner1," ;
  }
  print COMM_OUT "\n" ;
  print DIFF_OUT "\n" ;
  print PERCENT_OUT "\n" ;
  
  
  foreach my $corner2(@corners){
      print COMM_OUT "$corner2," ;
      print DIFF_OUT "$corner2," ;
      print PERCENT_OUT "$corner2," ;
    foreach my $corner1(@corners){
      print COMM_OUT "$common_num{$corner1}{$corner2}," ;
      print DIFF_OUT "$diff_num{$corner1}{$corner2}," ;
      printf PERCENT_OUT "%.2f%%,","$percent{$corner1}{$corner2}" ;
      }
      print COMM_OUT "\n" ;
      print DIFF_OUT "\n" ;
      print PERCENT_OUT "\n" ;
  }
  
  
  close COMM_IN ;
  close DIFF_IN ;
  close COMM_OUT ;
  close DIFF_OUT ;
  close PERCENT_OUT ;
}
