#!/home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -wi
use strict ;

use Getopt::Long ;
use Text::Table ;

my $opt_help ;
my $opt_dir ;
my $opt_mail ;
my $period ;
my $in_max ;
my $in_min ;
my $out_max ;
my $out_min ;

GetOptions (
  "h" => \$opt_help ,
  "dir=s" => \$opt_dir ,
  "mail" => \$opt_mail ,
  "period" => \$period,
  "in_max" => \$in_max,
  "in_min" => \$in_min,
  "out_max" => \$out_max,
  "out_min" => \$out_min,
) ;

my $USAGE = "This script is used for timing summary.\n" ;
$USAGE .= "$0 -h\tprint this message\n" ;
$USAGE .= "$0 -dir\treport dir\n" ;
$USAGE .= "$0 -mail\tsend out mails\n" ;

if ($opt_help || !$opt_dir) {
  die "$USAGE" ;
}

if (!$period) {
    $period = 10 ;
} 

if (!$in_max) {
    $in_max = 4 ;
}

if (!$in_min) {
    $in_min = 0 ;
}

if (!$out_max) {
    $out_max = 0 ;
}

if (!$out_min) {
    $out_min = 1 ;
}


my $dir = $opt_dir ;
my $datecode = $dir ;
$datecode =~ s/\/$// ;
$datecode =~ s/.*\/(\S+)/$1/ ;
my @max_sum = <$dir/*max*.sum.rpt> ;
my @min_sum = <$dir/*min*.sum.rpt> ;

my $out_slack_file = "$dir/${datecode}_slack.csv" ;
my $out_index_file = "$dir/${datecode}_index.csv" ;

open OUT_SLACK, "> $out_slack_file" or die "Can't write to file $out_slack_file" ;
open OUT_INDEX, "> $out_index_file" or die "Can't write to file $out_index_file" ;
print OUT_INDEX "index,startpoint,endpoint,\n" ;

open IN_INDEX, "$max_sum[0]" or die "Can't open file file $max_sum[0].\n" ;

my $index_num = 1 ;
my $slack_index = "," ;
my %index ;
my $pre_pad_cell = "" ;

while (<IN_INDEX>) {
  if (/BURNIN_CONTROLS_stdjtag\/Jreg_lat_reg_26_|TEST_MASTER_CTRL_stdjtag\/Jreg_lat_reg_14_|jtag_to_1500\/instr_hold_reg_._|coresight/) {
    next ;
  } else {
    m/(.*?),.*max,(.*?),(.*?),(.*)/ ;
    my $pad_pin = $3 ;
    my $reg_pin = $4 ;
    my $pad_cell = $pad_pin ;
    $pad_cell =~ s/(.*)\/.*/$1/ ;
    if ($pad_pin =~ /jtag_tms_pad/) {
      print OUT_INDEX "$index_num,$pad_pin,$reg_pin,\n" ;
      $index{$pad_pin}{$index_num} = $reg_pin ;
    } elsif ($pad_pin =~ /jtag_tdi_pad/){
      print OUT_INDEX "$index_num,$pad_pin,$reg_pin,\n" ;
      $index{$pad_pin}{$index_num} = $reg_pin ;
    } elsif ($pad_pin =~ /jtag_tdo_pad/) {
      print OUT_INDEX "$index_num,$reg_pin,$pad_pin,\n" ;
      $index{$pad_pin}{$index_num} = $reg_pin ;
    } else {
      print "Please Double Check the path!\n$_\n"
    }
    if ($pre_pad_cell eq "") {
        $pre_pad_cell = $pad_cell ;
        $slack_index = $slack_index."$index_num," ;
    } elsif ($pre_pad_cell eq $pad_cell) {
        $slack_index = $slack_index."$index_num," ;
        $pre_pad_cell = $pad_cell ;
    } else {
        $slack_index = $slack_index."Skew," ;
        $slack_index = $slack_index."$index_num," ;
        $pre_pad_cell = $pad_cell ;
    }
    $index_num = $index_num + 1 ;
  }
}
$slack_index = $slack_index."Skew," ;
print OUT_SLACK ",inbound path(ZI-->flop),,,,,,,,,,,outbound path(flop-->tdo),,,,,,\n" ;
print OUT_SLACK ",TMS Slack,,,,,TDI Slack,,,,,,TDO Slack,,,,,,\n" ;
print OUT_SLACK "$slack_index\n" ;
close OUT_SLACK ;
close IN_INDEX ;
close OUT_INDEX ;

my @tms_skews = () ;
my @tdi_skews = () ;
my @tdo_skews = () ;

print_slack_file (@max_sum, $out_slack_file) ;
print_slack_file (@min_sum, $out_slack_file) ;

my $tms_max_skew = get_max_skew (@tms_skews) ;
my $tdi_max_skew = get_max_skew (@tdi_skews) ;
my $tdo_max_skew = get_max_skew (@tdo_skews) ;

open OUT_SLACK, ">> $out_slack_file" or die "Can't write to file $out_slack_file" ;
my $period_pr = "period," ;
foreach (-1..$index_num) {
    $period_pr = $period_pr.$period."," ;
}

print OUT_SLACK "$period_pr\n" ;
print OUT_SLACK ",\n" ;
print OUT_SLACK "TMS worst slack skew : ,$tms_max_skew,\n" ;
print OUT_SLACK "TDI worst slack skew : ,$tdi_max_skew,\n" ;
print OUT_SLACK "TDO worst slack skew : ,$tdo_max_skew,\n" ;
print OUT_SLACK ",\n" ;
print OUT_SLACK "TMS input delay (setup) : ,$in_max,\n" ;
print OUT_SLACK "TMS input delay (hold) : ,$in_min,\n" ;
print OUT_SLACK "TDI input delay (setup) : ,$in_max,\n" ;
print OUT_SLACK "TDI input delay (hold) : ,$in_min,\n" ;
print OUT_SLACK "TDO output delay (setup) : ,$out_max,\n" ;
print OUT_SLACK "TDO output delay (hold) : ,$out_min,\n" ;

close OUT_SLACK ;

if ($opt_mail) {
  system "echo jtag_io_file $datecode | mutt junw -s 'jtag_io_file $datecode' -a $out_slack_file -a $out_index_file" ;
}

sub print_slack_file {
    my @sum_rpt = @_ ;
    my $fo = $sum_rpt[-1] ;
    pop @sum_rpt ; 
    open OUT, ">> $fo" or die "Can't write to file $fo" ;
    foreach (@sum_rpt) {
        my $slack_slack_tms = "" ;
        my $slack_slack_tdi = "" ;
        my $slack_slack_tdo = "" ;
        my $skew_tms = 0 ;
        my $skew_tdi = 0 ;
        my $skew_tdo = 0 ;
        my @slacks_tdi = () ;
        my @slacks_tms = () ;
        my @slacks_tdo = () ;
        if (/_max_/) {
            print "Working on the setup file : $_\n" ;
        } else {
            print "Working on the hold file :  $_\n" ;
        }
        open IN, "$_" or die "Can't open file $_ .\n" ;
        my $corner ;
        my $index_num = 1 ;
        while (<IN>) {
            if (/BURNIN_CONTROLS_stdjtag\/Jreg_lat_reg_26_|TEST_MASTER_CTRL_stdjtag\/Jreg_lat_reg_14_|jtag_to_1500\/instr_hold_reg_._|coresight/) {
                next ;
            } else {
                m/(.*?),.*(max|min),(.*?),(.*?),(.*)/ ;
                my $slack = $1 ;
                $corner = $3 ;
                my $pad_pin = $4 ;
                my $reg_pin = $5 ;
                if ($pad_pin =~ /jtag_tms_pad/) {
                    if ($index{$pad_pin}{$index_num} eq "$reg_pin") {
                        $slack_slack_tms = $slack_slack_tms."$slack," ;
                    } else {
                        print "index ordering is not matched!\n" ;
                    }
                    push @slacks_tms, $slack ; 
                } 
                if ($pad_pin =~ /jtag_tdi_pad/){
                    if ($index{$pad_pin}{$index_num} eq "$reg_pin") {
                        $slack_slack_tdi = $slack_slack_tdi."$slack," ;
                    } else {
                        print "index ordering is not matched!\n" ;
                    }
                    push @slacks_tdi, $slack ; 
                } 
                if ($pad_pin =~ /jtag_tdo_pad/) {
                    if ($index{$pad_pin}{$index_num} eq "$reg_pin") {
                        $slack_slack_tdo = $slack_slack_tdo."$slack," ;
                    } else {
                        print "index ordering is not matched!\n" ;
                    }
                    push @slacks_tdo, $slack ; 
                } 
            }
            $index_num = $index_num + 1 ;
        }
        $skew_tms = get_skew (@slacks_tms) ;
        $skew_tdi = get_skew (@slacks_tdi) ;
        $skew_tdo = get_skew (@slacks_tdo) ;
        push @tms_skews, $skew_tms ;
        push @tdi_skews, $skew_tdi ;
        push @tdo_skews, $skew_tdo ;
        print OUT "$corner,$slack_slack_tms$skew_tms,$slack_slack_tdi$skew_tdi,$slack_slack_tdo$skew_tdo,\n" ;
        close IN ;
    }
    close OUT ;
} 

sub get_skew {
    my @vals = @_ ;
    my $max_val = $vals[0] ;
    my $min_val = $vals[0] ;
    foreach my $val (@vals) {
        if ($val > $max_val) {
            $max_val = $val ;
        } elsif ($val < $min_val) {
            $min_val = $val ;
        } else {
            next ;
        }
   }
   my $skew = $max_val - $min_val ;
   $skew = substr( $skew, 0, 8);
   return $skew ;
}

sub get_max_skew {
   my $max_skew = $_[0] ;
   foreach (@_) {
      if ($_ > $max_skew) {
          $max_skew = $_ ;
      } else {
          next ;
      } 
   } 
   return $max_skew ;
}
