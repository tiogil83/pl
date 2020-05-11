#!/home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -wi
use strict ;

my $par = shift ;
my $infile = "/home/scratch.gp104_NV_gpd_t0/gp104/gp104/layout/revP6.0/netlists/sdc_tcm_flat/clock_nets/$par.shift_max.clock_nets" ;
my $reffile = "/home/scratch.sqiu_gpu/gp104/layout/revP6.0/cmds/custom/padlet/pin_spec/$par.ports_connect_2_pad_list" ;
my $outfile = $infile ;
$outfile =~ s/.*\/(.*)$/\/home\/junw\/$1/ ;
print $outfile ;
open IN , "$infile" ;
open OUT, "> $outfile" ;
open OUT_B, "> $outfile.removed" ;
open REF, "$reffile" ;

my %ref_nets ;

while(<REF>) {
  chomp ;
  my $ref_net = $_ ;
  $ref_nets{$ref_net} = 1 ; 
}

while(<IN>) {
  chomp ;
  if (exists $ref_nets{$_}) {
    print OUT_B "$_\n" ;
  }else{
    print OUT "$_\n" ;
  }
}


close IN ;
close OUT ;
close OUT_B ;
close REF ;
