#! /home/utils/perl-5.8.8/bin/perl -wi

use strict ;

my ($subject, @files) = @ARGV ;

print "$subject\n" ;
foreach (@files) {
  print "$_\n" ;
}

my $files_list = "" ;

if ($#files == 0) {
    $files_list = $files[0] ; 
}else{
    $files_list = join (" -a ", @files) ; 
}

print "echo $subject | mutt junw -a $files_list\n" ; 
