#! /home/gnu/bin/perl -w
use strict ;

unlink "./link" ;

my $fbpipo = "2950" ;
my $sysipo = "3270" ;
my $gpcipo = "2600" ;


my @fbppars = qw/KF0CR KF0LTS0 KF0LTS1 KF0LTS2 KF0LTS3 KF0PAF KF0PAL KF0ZR/ ;
#my @syspars = qw/KS0CE KS0DH KS0DI1 KS0DI2 KS0DI3 KS0DV KS0FE KS0HB KS0MSD KS0MSE0 KS0MSE1 KS0NI KS0PD KS0PW KS0XP KS0XV/ ;
my @syspars = qw/KS0CE KS0DH KS0DI1 KS0DI2 KS0DI3 KS0FE KS0HB KS0MSE0 KS0MSE1 KS0NI KS0PD KS0PW KS0XP KS0XV/ ;
my @gpcpars = qw/KG0GP KG0PR KG0SC KG0XBG KG0ZF KP0PES KP1PES KX0XBAR/ ;

open OUT, ">> link" ;

foreach my $syspar (@syspars) {
  print OUT "p4 integrate ${syspar}.ipo${sysipo}.typical_T0.SPEF.gz ${syspar}.ipo33000.typical_T0.SPEF.gz\n" ;
  print OUT "p4 integrate ${syspar}.ipo${sysipo}.typical_T105.SPEF.gz ${syspar}.ipo33000.typical_T105.SPEF.gz\n" ;
  print OUT "p4 integrate ${syspar}.ipo${sysipo}.def.gz ${syspar}.ipo33000.def.gz\n" ;
}

#foreach my $fbppar(@fbppars){
#  print OUT "ln -s ${fbppar}.ipo${fbpipo}.pairedFlopMapping ${fbppar}.pairedFlopMapping_dft.latest\n" ;
#}
#
#foreach my $syspar(@syspars){
#  print OUT "ln -s ${syspar}.ipo${sysipo}.pairedFlopMapping ${syspar}.pairedFlopMapping_dft.latest\n" ;
#}
#
#foreach my $gpcpar(@gpcpars){
#  print OUT "ln -s ${gpcpar}.ipo${gpcipo}.pairedFlopMapping ${gpcpar}.pairedFlopMapping_dft.latest\n" ;
#}
#open OUT, "> copy" ;
#
#foreach my $par(@pars){
#  print OUT "cp -v $par/$par.ipo2650-8001.reduce_leakage.gv /home/scratch.junw_gm108/gm107/gm107/layout/revP2.0/netlists/$par.ipo8050.gv\n" ;
#}

close OUT ;
