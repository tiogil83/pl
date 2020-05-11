#! /home/utils/perl-5.14/5.14.1-threads-64/bin/perl

use strict ;
use Data::Dumper ;

my $coor_file = shift @ARGV;
my $rule_file = shift @ARGV;

my $new_rule_file = $rule_file ;
$new_rule_file =~ s/_routeRules\./_routeRules_updated\./ ;

help() if ($coor_file eq "" or $rule_file eq "");

##########################
# Parsing Coordinates File 
##########################

my %rule_coor = () ;

open COOR, "$coor_file" or die "Can't open file $coor_file" ;

while (<COOR>) {
    chomp ;
    my $line = $_ ;
    my ($rule_name, $direction, $coor) = split (" ", $line) ;
    $rule_coor{$rule_name}{$direction} = $coor ;
}

close COOR ;

############################
# Parsing routeRules.pm File 
############################

open RULE, "$rule_file" or die "Can't open file $rule_file" ;
open OUT, "> $new_rule_file" or die "Can't write to file $new_rule_file" ;

my $flg = 0 ;
my $rule_name = "" ;

while (<RULE>) {
    chomp ;
    my $line = $_ ;
    if ($line =~ /^AddRouteRule / && $flg == 0) {
        $flg = 1 ;
        print OUT "$line\n" ;
    } elsif ($line =~ /^\s+name\s+.*\"(\S+)\"/ && $flg == 1) {
        $rule_name = $1 ;
        print OUT "$line\n"
    } elsif ($line =~ /^\s+source_location\s+/ && $flg == 1) {
        if (exists $rule_coor{$rule_name}{source}) {
            $line =~ s/\"\S+\"/\"$rule_coor{$rule_name}{source}\"/ ;
            print OUT "$line\n" ;
        } else {
            print OUT "$line\n" ;
        }
    } elsif ($line =~ /^\s+destination_location\s+/ && $flg == 1) {
        if (exists $rule_coor{$rule_name}{dest}) {
            $line =~ s/\"\S+\"/\"$rule_coor{$rule_name}{dest}\"/ ;
            print OUT "$line\n" ;
        } else {
            print OUT "$line\n" ;
        }
    } elsif ($line =~ /^\s+optimize_info\s+/ && $flg == 1) {
        $flg = 0 ;
        print OUT "$line\n" ;
    } else {
        print OUT "$line\n" ;
    }
}

close RULE ;
close OUT ;

sub help {
    open(PAGER, "| more");
    print PAGER <<EndOfHelp;
Purpose:   Update the source/dest location in routeRules.pm. 
           The output file is interface_retime_*_routeRules_updated.pm
Usage:     updateRuleLoc.pl <corrdinates_file> <routeRules.pm>
Example:   updateRuleLoc.pl coordinates.txt interface_retime_galit2_GAC_G0_routeRules.pm
EndOfHelp
    close(PAGER);
    die "\n";
}
