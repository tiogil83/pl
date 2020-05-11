#! /home/utils/perl-5.8.8/bin/perl -wi

use strict ;

my @save_sessions = @ARGV ;

if(-e "/home/junw/rs.medic"){
  unlink "/home/junw/rs.medic" ;
}

open OUT, ">> /home/junw/rs.medic" ;

foreach my $save_session(@save_sessions){
  chomp $save_session ;
  if(-e $save_session) {
    $save_session =~ /(\S+)\/(save_session_\S+)/ ;
    my $dir = $1 ;
    my $session = $2 ;
    if ($ENV{HOSTNAME} =~ /junw\.rno\.vpx/) {
        print OUT "restore_session -pt_save_session_dir $dir -session_name $session\n" ;
    } else {
        print OUT "restore_session -pt_save_session_dir $dir -session_name $session -use_screen 1\n" ;
    }
  }else{
    print "pls check the session. \n" ;
  }
}

close OUT ;
