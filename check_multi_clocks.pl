#! /home/utils/perl-5.8.8/bin/perl -wi

use strict ;

use Getopt::Long ;
use Data::Dumper ;

my $in ;
my $help ;

GetOptions (
  "h" => \$help ,
  "in=s" => \$in ,
) ;

my $USAGE = "This script is used summarizing the multiple clocks report\n" ;
$USAGE .= "$0 -h         print this message\n" ;
$USAGE .= "$0 -in        the CheckTiming report file\n" ;

###################
## Options
###################

if($help || $in eq ""){
  die "$USAGE" ;
}

my $chk_flg   = 0 ;
my $num       = 0 ;
my %multi_grp = () ;

###################
## Main loop 
###################

open IN ,"gunzip -dc $in|" or die "Can't open file $in\n" ;
while (<IN>) {
    chomp ;
    my $line = $_ ; 
    if ($line =~ /^Information: Checking \'multiple_clocks\'/) {
        $chk_flg = 1 ;
    } elsif ($chk_flg == 1 && $line =~ /^Clock Pins Number of Multiple_clocks:/) {
            $line =~ /^Clock Pins Number of Multiple_clocks:(\d+)/ ; 
            $num = $1 ;
            $chk_flg = 0 ;
            last ; 
    } elsif ($chk_flg == 1 && $line !~ /^---/) {
        $line =~ /^(.*):\s+\S+\s+:/ ;
        my $group = $1 ;
        if (exists $multi_grp{$group}) {
            $multi_grp{$group} = $multi_grp{$group} + 1 ;
        } else {
            $multi_grp{$group} = 1 ;
        }
    } else {
        next ;
    }
}
close IN ;

###################
## Dump out reports 
###################

my @grps     = (sort keys %multi_grp) ;
my $max_leng = get_max_array_length (@grps) ; 

print "Clock Pins Number of Multiple_clocks:$num\n" ;
foreach my $grp (sort {$multi_grp{$b} <=> $multi_grp{$a}} keys %multi_grp) {
    printf ("%s : %s\n", $grp, $multi_grp{$grp}) ;
}

###################
## subs 
###################


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

