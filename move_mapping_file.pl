#!/home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -wi
use strict ;

my $in_dir = shift ;
my $out_dir = shift ;
my @files = <$in_dir/*.map> ; 

#print $in_dir."\n" ;
#print $out_dir."\n" ;
foreach (@files) {
  #print $_."\n" ;
  /.*\/(.*?)\..*\.map/ ;
  my $block = $1 ;
  print "cp $_ $out_dir/$block/control/ \n " ; 
}
