#! /home/utils/perl-5.8.8/bin/perl -wi

use strict ;

use Getopt::Long ;
use NVEnv;
use CadConfig;
use Data::Dumper ;

my $dc;
my $dir ;
my $help ;

GetOptions (
  "h" => \$help ,
  "dc=s" => \$dc,
  "dir=s" => \$dir,
) ;

my $USAGE = "This script is used for summarizing the capture/function path comprions.\n" ;
$USAGE .= "$0 -h         print this message\n" ;
$USAGE .= "$0 -dc        the report file datecode\n" ;
$USAGE .= "$0 -dir       the report file directories\n" ;

###################
## Options
###################

if($help || $dc eq ""){
  die "$USAGE" ;
}

my($config) = CadConfig::factory();
my $proj = $config->CHIP_NAME ;

if (!(defined $dir)) {
    $dir = "$ENV{PWD}/$proj/rep" ;
}

##################
## Report files 
##################

my @sa_reports  = () ;
my @ftm_reports = () ;

foreach my $rep_dir (split /\s+/, $dir) {
    push @sa_reports,  (glob "$dir/*_stuckat_*$dc*.log") ; 
    push @ftm_reports, (glob "$dir/*_ftm_*$dc*.log") ;
}

if ($#sa_reports == -1 && $#ftm_reports == -1) {
    print "No reports found in dir : \n\t$dir\n" ;
}

##################
## Reports summary
##################

if ($#sa_reports != -1) {
    print "SA reports :\n" ;
    capture_rep_summ (@sa_reports) ;
}

if ($#ftm_reports != -1) {
    print "FTM reports :\n" ;
    capture_rep_summ (@ftm_reports) ;
}

sub capture_rep_summ {
    my @reps = @_ ;
    foreach my $rep (@reps) {
        my %path_type = () ;
        print "$rep\n" ; 
        open IN, $rep ;
        while (<IN>) {
            chomp ;
            my $line = $_ ;
            my $type = $line ;
            if ($type =~ /^COMP_PATH/) {
                $type =~ s/(COMP_PATH\S+).*/$1/ ;
            } else {
                next ;
            }
            if (exists $path_type{$type}) {
                $path_type{$type} = $path_type{$type} + 1 ;
            } else {
                $path_type{$type} = 1 ;
            }
        } 
        close IN ;
        my @types = sort (keys %path_type) ;
        my $max_leng = get_max_array_length (@types) ;
        foreach my $type (sort {$path_type{$b} <=> $path_type{$a}} keys %path_type) {
            printf ("%${max_leng}s : %s\n", $type, $path_type{$type}) ;
        }
    }
} 

sub get_max_array_length {
    my @array = @_ ;
    my $max_leng = 0 ;
    foreach (@array) {
        my $length = length $_ ;
        if ($length > $max_leng) {
            $max_leng = $length ;
        }
    }
    return $max_leng ;
}

