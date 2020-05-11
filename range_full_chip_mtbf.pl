#!/home/utils/perl-5.8.8/bin/perl
our @args = @ARGV;
    while (@args) {
    $_ = shift(@args );
    if(/^-rep$/) {
    $rep= shift(@args);
    } elsif (/^-out$/) {
    $out=shift(@args);
    } elsif (/^-outlier$/) {
    $outlier = shift(@args);
    } else {
    die "ERROR: \"$_\" is not an option.\n";
    }
    };
#system("sort -k3,3 -k8,8g -t \" \" $rep > /home/ohu/new/yanfangw/tmp");
#open (REP,"</home/ohu/tmp");
open (REP,"<$rep");
open (OUT,">$out");
my %index_hash;
print OUT "from from_ref to to_ref depth bits corner MTBF\n ";
my $full_chip_mtbf = 0;
my $M = 0;
my $outlier_number =0;
my $M_remove_outlier = 0;
while (my $line_rf = <REP>) {
chomp($line_rf);
my @spc_split = split (/\s+/,$line_rf);
$from = $spc_split[0];
$from_cell = $spc_split[1];
$to = $spc_split[2];
$to_cell = $spc_split[3];
$depth = $spc_split[4];
$bits = $spc_split[5];
$corner = $spc_split[6];
$mtbf= $spc_split[7];
#@a= split (/\//,$to);
#@a=(split /\//,$_);
#pop @a;
#print join "/",@a ,"\n";
if (exists $index_hash{$spc_split[2]} || $mtbf < 100 ){
next;
}else {
print OUT "$from $from_cell $to $to_cell $depth $bits $corner $mtbf\n";
$index_hash{$spc_split[2]} =1;
$M+=1/$mtbf;
if ($mtbf>=$outlier) {
$M_remove_outlier+=1/$mtbf;
} else {
$outlier_number+=1;
}
}
}
$full_chip_mtbf=1/$M;
$full_chip_mtbf_remove_outlier=1/$M_remove_outlier;
print OUT "##full_chip_mtbf=$full_chip_mtbf\n";
print OUT "##outlirt MTBF = $outlier\n";
print OUT "##outlier number = $outlier_number\n";
print OUT "##after fix outlier, full chip MTBF = $full_chip_mtbf_remove_outlier\n";
close (REP);
close (OUT);


