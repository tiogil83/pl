#! /home/utils/perl-5.14/5.14.1-threads-64/bin/perl

use strict ;

my $input = "ga100/rep/NV_gaa_s0.test_timing.custom_check.sum" ;
open IN, "$input" or die "Can't open file $input\n" ;
open OUT, "> xxx.txt" ;
my $wiki_header = "<div class=\"preformatted panel conf-macro output-block\" style=\"border-width: 1px;\" data-hasbody=\"true\" data-macro-name=\"noformat\">
<div class=\"preformattedContent panelContent\">
<pre>
" ;

while (<IN>) {
    my $line = $_ ;
    if ($line =~ /^Working/) {
        $line =~ s/\s*:\s*\n// ;
        $line = "<h1>" . $line . "<\/h1>\n" ;
        $line = $line . $wiki_header ;
        print OUT "$line" ;
    }elsif ($line =~ /^NV_gaa_s0/) {
        $line =~ s/\s*:\s*\n// ;
        $line = "<\/pre>\n<\/div>\n<\/div>\n<h1>" . $line . "<\/h1>\n";
        $line = $line . $wiki_header ;
        print OUT "$line" ;
    }else{
        print OUT "$line" ;
    } 
}

print OUT "<\/pre>\n<\/div>\n<\/div>\n" ;
