#!/home/utils/perl-5.14/5.14.1-nothreads-64/bin/perl -wi
use strict ;

my $proj = "gp10b" ;

use Getopt::Long ;
use Text::Table ;

my $opt_help ;
my $opt_iponum ;
my $opt_block ;

GetOptions (
  "h" => \$opt_help ,
  "n=s" => \$opt_iponum ,
  "b=s" => \$opt_block ,
) ;

my $USAGE = "This script is used for timing summary.\n" ;
$USAGE .= "$0 -h\tprint this message\n" ;
$USAGE .= "$0 -b\tpartition name\n" ;
$USAGE .= "$0 -n\tpartition ipo number\n" ;

my $datecode = `date "+%y%b%d_%H"` ;
chomp $datecode ;

if( $opt_help || !$opt_iponum || !$opt_block ){
  die($USAGE) ;
}

my $dir1 = "/home/scratch.${proj}_partition/$proj/$proj/timing/$proj/rep" ;
my $dir2 = "/home/scratch.${proj}_partition_2/$proj/$proj/timing/$proj/rep" ;
my $dir3 = "/home/scratch.${proj}_partition_3/$proj/$proj/timing/$proj/rep" ;


my @func_setup_viols = <$dir1/*$opt_block.*$opt_iponum*std_max*pba.viol.gz> ;
my @func_hold_viols = <$dir2/*$opt_block.*$opt_iponum*std_min*pba.viol.gz> ;
my @shift_hold_viols = <$dir3/*$opt_block.*$opt_iponum*shift_fmax_discrete_min*pba.viol.gz> ;

if(-e "$opt_block\.$opt_iponum\.$datecode\.timingSummary"){
  unlink "$opt_block\.$opt_iponum\.$datecode\.timingSummary" ;
}else{
}

open OUT, "> $opt_block\.$opt_iponum\.$datecode\.timingSummary" ;

print OUT "Timing Summary for $opt_block\.ipo$opt_iponum\n\n" ;
print OUT "Functional Setup Status\n\n" ;
my @table_title_setup = ("corner", "|", "setup wns", "|", "setup num", "|") ;

my $table_setup = Text::Table->new(@table_title_setup);
my @table_line_setup ;
push @table_line_setup, ("-"x6, "|", "-"x9, "|", "-"x9, "|") ;
$table_setup->add(@table_line_setup);

foreach my $vios(@func_setup_viols){
  $vios =~ m/\S+\.\.anno\S+pt\.(\S+)\.std_max\S+\.viol\.gz/;
  my $corner = $1 ; 
  open IN ,"gunzip -dc $vios|" ;
  my $setupwns = 0 ;
  my $setupcount = 0;
  while(<IN>){
    if(/slack \(VIOLATED\S+\s+(\S+)$/){
      if($1 < 0){
        $setupcount++ ;
        if($1 < $setupwns){
          $setupwns = $1 ;
          next ;
        }else{
          next ;  
        }
      }
      else{
        next ;
      }
    }else{
      next ;
    }
  }
  chomp $setupwns ;
  chomp $setupcount ;
  @table_line_setup = ($corner,"|",$setupwns,"|",$setupcount,"|") ; 
  $table_setup->add(@table_line_setup);
  close IN ;
}

@table_line_setup = $table_setup->table ;

foreach (@table_line_setup){
  print OUT ;
}

print OUT "\n\nHold Status\n" ;
print OUT "\n" ;

my @hold_viols = (@func_hold_viols,@shift_hold_viols) ;

my @table_title_hold = ("corner", "|", "mode", "|", "hold wns", "|", "hold num", "|") ;

my $table_hold = Text::Table->new(@table_title_hold) ;

my @table_line_hold ; 
push @table_line_hold, ("-"x6, "|", "-"x4, "|", "-"x8, "|", "-"x8, "|") ;
$table_hold->add(@table_line_hold) ;

foreach my $vios(@hold_viols){
  $vios =~ m/\S+\.\.anno\S+pt\.(\S+)\.flat\S+\.viol\.gz/ ;
  my $corner = $1 ;
  $corner =~ /(\S+)\.(\S+)/ ;
  $corner = $1 ;
  my $mode = $2 ;
  open IN ,"gunzip -dc $vios|" ;
  my $wns = 0 ;
  my $count = 0;
  while(<IN>){
    if(/slack \(VIOLATED\S+\s+(\S+)$/){
      if($1 < 0){
        $count++ ;
        if($1 < $wns){
          $wns = $1 ;
          next ;
        }else{
          next ;  
        }
      }
      else{
        next ;
      }
    }else{
      next ;
    }
  }
  @table_line_hold = ($corner, "|", $mode, "|", $wns, "|", $count, "|") ;
  $table_hold->add(@table_line_hold) ;
  close IN ;
}

@table_line_hold = $table_hold->table ;

foreach (@table_line_hold){
  print OUT ;
}


print OUT "\n\nClock Trans\/Max Cap Status\n" ;
print OUT "\n" ;

my @viols = (@func_setup_viols, @hold_viols) ;

my @table_clk_tran_title = ("corner", "|", "mode", "|", "trans wns", "|", "trans num", "|", "cap wns", "|", "cap num", "|") ;

my $table_clk_tran = Text::Table->new(@table_clk_tran_title) ; 

my @table_clk_tran_line ;
push @table_clk_tran_line, ("-"x6, "|", "-"x4, "|", "-"x9, "|", "-"x9, "|", "-"x7, "|", "-"x7, "|") ;
$table_clk_tran->add(@table_clk_tran_line) ;

foreach my $vios(@viols){
  $vios =~ m/\S+\.\.anno\S+pt\.(\S+)\.flat\S+\.viol\.gz/ ;
  my $corner = $1 ;
  $corner =~ /(\S+)\.(\S+)/ ;
  $corner = $1 ;
  my $mode = $2 ;
  my $clk_trans_flg = 0 ;
  my $clk_trans_cnt = 0 ;
  my $clk_trans_wns = 0 ;
  my $clk_cap_flg = 0 ;
  my $clk_cap_cnt = 0 ;
  my $clk_cap_wns = 0 ;
  open IN ,"gunzip -dc $vios|" ;
  while(<IN>){
    if(/\s+clock_max_transition$/){
      $clk_trans_flg = 1 ;
      print "x" ;
      next ;
    }elsif($clk_trans_flg & /^1$/){
      $clk_trans_flg = 0 ;
      print "y" ;
      next ;
    }else{
      next ;
      print "z" ;
    }
    if($clk_trans_flg & (/^\s+\S+\s+\S+\s+\S+\s+(\S+)\s+\(VIOL/)){
      print "a" ;
      $clk_trans_cnt ++ ;
      if($clk_trans_wns > $1){
        $clk_trans_wns = $1 ;
      }
      next ;
    }else{
      next ;
    }
    if(/^\s+clock_max_capacitance/){
      $clk_cap_flg = 1 ;
      next ;
    }elsif($clk_cap_flg & /^1$/){
      $clk_cap_flg = 0 ;
      next ;
    }else{
      next ;
    }
    if($clk_cap_flg & (/^\s+\S+\s+\S+\s+\S+\s+(\S+)\s+\(VIOL/)){
      $clk_cap_cnt ++ ;
      if($clk_cap_wns > $1){
        $clk_cap_wns = $1 ;
      }
      next ;
    }else{
      next ;
    }
  }
  @table_clk_tran_line = ($corner,"|",$mode,"|",$clk_trans_wns,"|",$clk_trans_cnt,"|",$clk_cap_wns,"|",$clk_cap_cnt,"|") ;
  $table_clk_tran->add(@table_clk_tran_line) ;
}

@table_clk_tran_line = $table_clk_tran->table ;

foreach (@table_clk_tran_line){
  print OUT ;
}

print OUT "\n\nData Trans\/Max Cap Status\n" ;
print OUT "\n" ;

my @table_data_tran_title = ("corner", "|", "mode", "|", "trans wns", "|", "trans num", "|", "cap wns", "|", "cap num", "|") ;

my $table_data_tran = Text::Table->new(@table_data_tran_title) ; 

my @table_data_tran_line ;
push @table_data_tran_line, ("-"x6, "|", "-"x4, "|", "-"x9, "|", "-"x9, "|", "-"x7, "|", "-"x7, "|") ;
$table_data_tran->add(@table_data_tran_line) ;

foreach my $vios(@viols){
  $vios =~ m/\S+\.\.anno\S+pt\.(\S+)\.flat\S+\.viol\.gz/ ;
  my $corner = $1 ;
  $corner =~ /(\S+)\.(\S+)/ ;
  $corner = $1 ;
  my $mode = $2 ;
  my $data_trans_flg = 0 ;
  my $data_trans_cnt = 0 ;
  my $data_trans_wns = 0 ;
  my $data_cap_flg = 0 ;
  my $data_cap_cnt = 0 ;
  my $data_cap_wns = 0 ;
  open IN ,"gunzip -dc $vios|" ;
  while(<IN>){
    if(/\s+data_max_transition$/){
      $data_trans_flg = 1 ;
      next ;
    }elsif($data_trans_flg & /^1$/){
      $data_trans_flg = 0 ;
      next ;
    }else{
      next ;
    }
    if($data_trans_flg & (/^\s+\S+\s+\S+\s+\S+\s+(\S+)\s+\(VIOL\S+/)){
      $data_trans_cnt ++ ;
      if($data_trans_wns > $1){
        $data_trans_wns = $1 ;
      }
      next ;
    }else{
      next ;
    }
    if(/^\s+data_max_capacitance/){
      $data_cap_flg = 1 ;
      next ;
    }elsif($data_cap_flg & /^1$/){
      $data_cap_flg = 0 ;
      next ;
    }else{
      next ;
    }
    if($data_cap_flg & (/^\s+\S+\s+\S+\s+\S+\s+(\S+)\s+\(VIOL\S+/)){
      $data_cap_cnt ++ ;
      if($data_cap_wns > $1){
        $data_cap_wns = $1 ;
      }
      next ;
    }else{
      next ;
    }
  }
  @table_data_tran_line = ($corner,"|",$mode,"|",$data_trans_wns,"|",$data_trans_cnt,"|",$data_cap_wns,"|",$data_cap_cnt,"|") ;
  $table_data_tran->add(@table_data_tran_line) ;
}

@table_data_tran_line = $table_data_tran->table ;

foreach (@table_data_tran_line){
  print OUT ;
}
close OUT ;
