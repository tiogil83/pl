#! /home/gnu/bin/perl -w
use strict ;

my $eco_dir = "gm20b/eco/ipo0_lpr" ;
my $new_ipo = "50000" ;
my $layout_dir = "../layout/revG3.0/netlists" ;

my @partitions = qw "GMDF0CR1.ipo39000 
GMDG0SC.ipo40000 " ;

my %partition ;

foreach (@partitions){
  chomp ;
  m/(\S+)\.ipo(\d+)\s*/ ;
  my $par = $1 ;
  my $ipo = $2 ;
  $partition{$par}{ipo} = $ipo ;
#  print $partition{$par}{ipo} ;
} 

open OUT, "> lpr_eco.medic" ;

my @dcsh_files = glob "$eco_dir/*" ;
#print @dcsh_files ;
foreach (@dcsh_files){
  chomp ;
  s/.*\///g ;
  m/(.*)\.ipo.*/ ;
  my $par = $1 ;
  my @old_files ;
  if(exists $partition{$par}){
    $partition{$par}{dcsh} = $_ ;
    print OUT "eco_run -block $par -ipo_old $partition{$par}{ipo} -ipo_new $new_ipo -ecos $partition{$par}{dcsh} -skip_find\n" ;
    #`cd $layout_dir ; ln -s $par.ipo${partition{$par}{ipo}}.def $par.ipo${new_ipo}.def` ;
    @old_files = glob "$layout_dir/$par.ipo${partition{$par}{ipo}}.*" ;
    foreach my $old_file(@old_files){
      chomp $old_file ;
      if($old_file =~ /gv$/){
        next ;
      }else{
        $old_file =~ s/.*\///g ;
        my $new_file = $old_file ;
        $new_file =~ s/ipo$partition{$par}{ipo}\./ipo$new_ipo./g ;
       `cd $layout_dir ; ln -s $old_file $new_file ;` ;
      }
    }
  }else{
    next ;
  }
}

close OUT ;

