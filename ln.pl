#! /home/gnu/bin/perl -wi 

open IN, "test.txt" ;
open OUT, "> par2par.txt" ;

my @txts = qw "
junw_temp_area/2018_08_20/sd_mtm.txt
junw_temp_area/2018_08_20/xtr_ctrl.txt
junw_temp_area/2018_08_20/xtr_input.txt
junw_temp_area/2018_08_20/xtr_output.txt
junw_temp_area/2018_08_20/x24.txt
junw_temp_area/2018_08_20/x25.txt
junw_temp_area/2018_08_20/x27.txt
junw_temp_area/2018_08_20/x28.txt
junw_temp_area/2018_08_20/x29.txt
junw_temp_area/2018_08_20/x30.txt
junw_temp_area/2018_08_20/x31.txt
junw_temp_area/2018_08_20/x36.txt
junw_temp_area/2018_08_20/x43.txt
junw_temp_area/2018_08_20/x53.txt
junw_temp_area/2018_08_20/x54.txt
junw_temp_area/2018_08_20/x55.txt
junw_temp_area/2018_08_20/x56.txt
junw_temp_area/2018_08_20/comp.txt
";

foreach my $txt (@txts) {
    print "\n" ;
    print "set cells [sh cat $txt]\n" ;
    $txt =~ s/(.*)\.txt/$1_map.txt/ ;
    print "foreach cell \$cells {foreach_in_collection clk [get_attr -class pin \$cell clocks] {set clk_name [get_attr \$clk full_name]; echo dftv_to_pt_clock_map(\$cell) \$clk_name >> $txt\n" ;
    print "\n" ;
}



close IN ;
close OUT ;
