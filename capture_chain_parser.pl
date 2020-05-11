#!/home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -wi
use strict ;

use Getopt::Long ;

my $opt_help ;
my $opt_input ;
my $opt_output ;

GetOptions (
  "h" => \$opt_help ,
  "i=s" => \$opt_input ,
  "o=s" => \$opt_output ,
) ;

my $USAGE = "This script is used for timing summary.\n" ;
$USAGE .= "$0 -h\tprint this message\n" ;
$USAGE .= "$0 -i\tinput chain file name\n" ;

if( $opt_help || !$opt_input ){
  die($USAGE) ;
}

my @files = glob "$opt_input" ;

foreach my $file (@files) {
    print "Working on $file\n" ;
    my $output_file = $file ;
    if ($file =~ /\.gz$/) {
        $output_file =~ s/(.*).gz/$1\.parser\.txt/ ;
        open IN, "gunzip -dc $file|" or die "Can't read file $file .\n" ;
    } else {
        if (defined $opt_output) {
            $output_file = $opt_output ;
        } else {    
            $output_file = $output_file.".parser.txt" ;
        }
        open IN, "$file" or die "Can't read file $file .\n" ;
    }
    open OUT, "> $output_file" or die "Can't write to file $output_file .\n" ;
    while (<IN>) {
        chomp ;
        my $line = $_ ;
        my $chain    = "" ;
        my $type     = "" ;
        my $clk_inst = "" ;
        my $inst     = "" ;

        if ($line =~ / MASTER /) {
            $line =~ /^ (\S+)\s+\d+\s+(\S+)\s+\S+\s+\S+\s+\d+\s+(\+|\-|\?)\s+(\S+)\s+(\S+)\s+\(.*/ ;
            $chain    = $1 ;
            $type     = $2 ;
            $clk_inst = $4 ;
            $inst     = $5 ;
        }elsif ($line !~ /^ chain|^ ------/) {
            $line =~ /^ \s+(\S+)\s+\S+\s+\S+\s+\d+\s+(\+|\-|\?)\s+(\S+)\s+(\S+)\s+\(.*/ ;    
            $chain    = "no_chain" ;
            $type     = $1 ;
            $clk_inst = $3 ;
            $inst     = $4 ;
        }else{
            print "$line\n" ;
            next ;
        }
        $clk_inst =~ s/\\//g ;
        $inst     =~ s/\\//g ;
        print OUT "$chain $type $clk_inst $inst\n" ;
    }
    close IN ;
    close OUT ;
}
