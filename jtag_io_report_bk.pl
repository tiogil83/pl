#!/home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -wi
use strict ;

use Getopt::Long ;
use Text::Table ;

my $opt_help ;
my $opt_dir ;
my $opt_mail ;

GetOptions (
  "h" => \$opt_help ,
  "dir=s" => \$opt_dir ,
  "mail" => \$opt_mail ,
) ;

my $USAGE = "This script is used for timing summary.\n" ;
$USAGE .= "$0 -h\tprint this message\n" ;
$USAGE .= "$0 -dir\treport dir\n" ;
$USAGE .= "$0 -mail\tsend out mails\n" ;

if ($opt_help || !$opt_dir) {
  die "$USAGE" ;
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
while (<IN_INDEX>) {
  if (/BURNIN_CONTROLS_stdjtag\/Jreg_lat_reg_26_|TEST_MASTER_CTRL_stdjtag\/Jreg_lat_reg_14_|jtag_to_1500\/instr_hold_reg_._|coresight/) {
    next ;
  } else {
    m/(.*?),.*max,(.*?),(.*?),(.*)/ ;
    my $pad_pin = $3 ;
    my $reg_pin = $4 ;
    if ($pad_pin =~ /jtag_tms_pad/) {
      print OUT_INDEX "$index_num,$pad_pin,$reg_pin,\n" ;
    } elsif ($pad_pin =~ /jtag_tdi_pad/){
      print OUT_INDEX "$index_num,$pad_pin,$reg_pin,\n" ;
    } else {
      print OUT_INDEX "$index_num,$reg_pin,$pad_pin,\n" ;
    }
    $slack_index = $slack_index."$index_num," ;
    $index_num = $index_num + 1 ;
  }
}
print OUT_SLACK "$slack_index\n" ;

close IN_INDEX ;

foreach (@max_sum) {
  my $slack_slack = "" ;
  print "Working on the setup file : $_\n" ;
  open IN, "$_" or die "Can't open file $_ .\n" ;
  my $corner ;
  while (<IN>) {
    if (/BURNIN_CONTROLS_stdjtag\/Jreg_lat_reg_26_|TEST_MASTER_CTRL_stdjtag\/Jreg_lat_reg_14_|jtag_to_1500\/instr_hold_reg_._|coresight/) {
      next ;
    } else {
      m/(.*?),.*max,(.*?),(.*?),(.*)/ ;
      my $slack = $1 ;
      $corner = $2 ;
      #print "$slack $corner $pad_pin $reg_pin\n" ;
      $slack_slack = $slack_slack."$slack," ; 
    }
  }
  print OUT_SLACK "$corner,$slack_slack\n" ;
  close IN ;
}
foreach (@min_sum) {
  my $slack_slack = "" ;
  print "Working on the hold file : $_\n" ;
  open IN, "$_" or die "Can't open file $_ .\n" ;
  my $corner ;
  while (<IN>) {
    if (/BURNIN_CONTROLS_stdjtag\/Jreg_lat_reg_26_|jtag_to_1500\/instr_hold_reg_._|coresight/) {
      next ;
    } else {
      m/(.*?),.*min,(.*?),(.*?),(.*)/ ;
      my $slack = $1 ;
      $corner = $2 ;
      #print "$slack $corner $pad_pin $reg_pin\n" ;
      $slack_slack = $slack_slack."$slack," ;
    }
  }
  print OUT_SLACK "$corner,$slack_slack\n" ;
  close IN ;
}

if ($opt_mail) {
  system "echo jtag_io_file | mutt junw -s jtag_io_file -a $out_slack_file -a $out_index_file" ;
}

close OUT_SLACK ;
close OUT_INDEX ;
