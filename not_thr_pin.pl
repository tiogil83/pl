#!/home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -wi
use strict ;

use Getopt::Long ;
use Text::Table ;

my $opt_help ;
my $opt_input ;
my $opt_output ;
my $opt_thrpin ;

GetOptions (
  "h" => \$opt_help ,
  "i=s" => \$opt_input ,
  "o=s" => \$opt_output ,
  "t=s" => \$opt_thrpin,
) ;

my $USAGE = "This script is used for timing summary.\n" ;
$USAGE .= "$0 -h\tprint this message\n" ;
$USAGE .= "$0 -i\tinput file\n" ;
$USAGE .= "$0 -o\toutput file\n" ;
$USAGE .= "$0 -t\tthrough pin\n" ;

if( $opt_help || !$opt_input || !$opt_output || !$opt_thrpin){
  die($USAGE) ;
}

if ($opt_input =~ /\.gz$/) {
  open IN ,"gunzip -dc $opt_input|" or die "Can't open file $opt_input $!" ;
} else {
  open IN, "$opt_input" or die "Can't open file $opt_input $!" ;
}
open OUT, "> $opt_output" or die "Can't write to file $opt_output $!" ; 

my $flag = 0 ;
my $found_thr = 0 ;
my %path_pair = () ;
my $start_pin = "" ;
my $end_pin = "" ;

while (<IN>) {
  if (/Startpoint: (\S+)/ and $flag == 0) {
     $flag = 1 ;
     $start_pin = $1 ; 
     print "$start_pin\n" ;
     $end_pin = "" ;
  } elsif (/Endpoint: (\S+)/ and $flag == 1) {
     $end_pin = $1 ;
     $path_pair{$end_pin} = $start_pin ; 
  } elsif (/$opt_thrpin/ and $flag == 1) {
     print OUT "through pin $opt_thrpin: $path_pair{$end_pin} $end_pin\n" ;
     print "through pin $opt_thrpin: $path_pair{$end_pin} $end_pin\n" ;
     $found_thr = 1 ;
  } elsif (/^  slack / and $flag == 1 and $found_thr == 0) {
     $flag = 0 ;
     print OUT "not through pin $opt_thrpin: $path_pair{$end_pin} $end_pin\n" ; 
     print "not through pin $opt_thrpin: $path_pair{$end_pin} $end_pin\n" ; 
     $start_pin = "" ;
     $end_pin = "" ;
  } elsif (/^  slack / and $flag == 1 and $found_thr == 1) {
     $flag = 0 ;
     $start_pin = "" ;
     $end_pin = "" ;
  } else {
     next ;
  }
}

close IN ;
close OUT ;
