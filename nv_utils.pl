# nv_utils.pl  -- handy perl utilities

# fail($failstr,$killist,$keepflag,$stdout,$stderr)
#    $failstr:  printed to STDERR before exit(2)
#    $killlist: list of files to be removed before exit
#    $keepflag: if == 1, don't delete files in killlist
#    $stdout:   filehandle string to which STDOUT should be redirected
#    $stderr:   filehandle string to which STDERR should be redirected
#
#    all inputs are optional.

# print_vars("var1","var2",...)
#    print the value of the provided vars.
#    vars must be globally visible

# sub maketime($starttime,$endtime)
#    print the difference between the provided times (returned from time())
#    in HH:MM:SS



#sub NVGetOpts
#add type-checking, hex conversion

# this uses symbolic refs
sub pvars {
    foreach $varref (@_) {
        if ($varref =~ /^\s+$/) {
            print "$varref";
        } elsif (defined($$varref)) { print "\$$varref=$$varref "; } 
        else { print "\$$varref=undefined "; }
    }
    print "\n";
}

# this uses hard refs
# print_vars2(\$var1,"\t\n",\$var2,...)
sub pvars2 {
    local(@refs) = @_;
    local(@refnames);
    local($ref,$i,$matches);
    $matches = 0;
    foreach $ref (@refs) {
        die "pvars2 input not a ref: \"$ref\"\n"
            unless (ref $ref eq "SCALAR") || !(ref $ref);
    }
    # scan through all the names in main symbol table
    KEYSCAN: foreach $key (keys %main::) {
        # get the typeglob for the name
        *sym = $main::{$key};
        $symref = \$sym;
        for $i (0..$#refs) {
            if (ref $refs[$i] && $symref eq $refs[$i]) {
                $refnames[$i] = $key;
                last KEYSCAN if ($matches++ == $#refs);
            }
        }
    }
    for $i (0..$#refs) {
        if (ref $refs[$i]) {
            if (defined($refnames[$i])) {
                $ref = $refs[$i];
                if (defined $$ref) {
                    print "\$$refnames[$i]=$$ref ";
                } else {
                    print "\$$refnames[$i]=undefined ";
                }
            } else {
                die "couldn't find a name for \"$refs[$i]\"\n";
            }
        } else { print "$refs[$i]"; }
    }
    print "\n";
}


sub maketime {
    my ($starttime,$endtime);

    my ($hour,$minute,$second,$diff,$retval);
    if (@_ == 1) {
        $starttime = 0;
        $endtime = shift @_;
    } elsif (@_ == 2) {
        ($starttime,$endtime) = @_;
    } else {
        $hour = @_;
        die "bad number of maketime args $hour\n";
    }

    if (!defined($starttime)) {
        print STDERR "Warning: maketime: \$starttime not defined\n";
        $starttime = 0;
    }
    if (!defined($endtime)) {
        print STDERR "Warning: maketime: \$endtime not defined\n";
        $endtime = 0;
    }

    $diff = $endtime - $starttime;
    $hour = int($diff / 3600);
    $diff = $diff - $hour * 3600;
    $minute = int($diff / 60);
    $second = $diff - $minute * 60;
    $retval = sprintf("%02d:%02d:%02d",$hour,$minute,$second);
    $retval;
}

sub fail {
    my($failstr,$killlist,$keepflag,$stdout,$stderr) = @_;
    my($argcount) = $#_ + 1;
    die "too many args for fail(\"$failstr\",\"$killlist\",...)\n"
        unless $argcount <= 5;
    if (($argcount >= 4) && ($stdout ne "STDOUT")) {
        close(STDOUT); open(STDOUT,">&$stdout"); }
    if (($argcount >= 5) && ($stderr ne "STDERR")) {
        close(STDERR); open(STDERR,">&$stderr"); }
    if ($argcount <= 2)  { $keepflag = 0; }
    print STDERR "$failstr";
    if ($argcount >= 2) {
        if ($keepflag) {
            print STDERR "files not cleaned up at exit: $killlist\n";
        } else {
            #print "removing \"$killlist\"\n";
            system("rm -rf $killlist") if length($killlist);
        }
    }
    exit(2);
    #die "byebye\n";
}

sub bin2dec {
    unpack("N",pack("B32",substr("0" x 32 . shift,-32)));
}

sub dec2bin {
    my($dec,$bits,$ofmt) = @_;
    $ofmt = "bare" unless defined($ofmt);
    my($bin,$rest);
    $bin = join('',unpack('B*',pack('N',$dec)));
    if (defined($bits)) {
        $rest = substr($bin,0,length($bin)-$bits);
        die "ERROR: dec2bin: $dec >= 2^$bits, can't convert without losing bits\n" 
            unless $rest =~ /^0*$/;
        $bin = substr($bin,-$bits);
        #$bin = "$rest $bin";
    }
    if ($ofmt eq "bare") {
        $bin = $bin;
    } elsif ($ofmt eq "verilog") {
        $bin = "$bits\'b$bin";
    } else {
        die "ERROR: dec2bin: unknown output fmt \"$ofmt\"\n";
    }
    $bin;
}


sub ceiling {
    my($val) = @_;
    my($v2) = int($val);
    $v2++ if ($v2 < $val);
    $v2;
}

sub floor {
    my($val) = @_;
    my($v2) = int($val);
    $v2;
}

sub round {
    my($innum,$indigs) = @_;
    my($scale,$tmp1,$tmp2,$outnum);
    $indigs = 0.0 unless defined($indigs);
    $scale = (10.0 ** $indigs);
    
    # convert to int, then back to float
    $tmp1 = ($innum * $scale) + 0.5;
    $tmp2 = int($tmp1);
    $outnum = $tmp2 / $scale;
    #print "$innum ($indigs) -> $outnum\n";
    #print "   tmp1=$tmp1 tmp2=$tmp2 scale=$scale\n";
    $outnum;
}

sub strtol {
    my($str) = @_;
    my($num);
    $str =~ s/\s//g;
    if ($str =~ /^[0-9]+$/) {
        $num = $str;
    } elsif ($str =~ /^0x([0-9A-Fa-f]+)$/) {
        $num = hex $1;
    } else {
        die "ERROR: strtol: \"$str\" is not a number\n";
    }
    $num;
}

 # strip c comments out of lines.  example usage:
 # $incomment = 0;
 # while (<INFILE>) {
 #  ($line,$incomment) = ccomment($_,$incomment);
 #  print $line;
 # }
 # a good test is at ~alben/test/ccomment/testc.v , output at testo.v.pp
sub ccomment {
    my($line,$incomment,$verilog) = @_;
    $verilog = 0 unless defined($verilog);
    my($oline);
    $incomment = 0 unless defined($incomment);
    #print "PARSE: $incomment $line";
    while($line !~ /^\s*$/) {
        #print "LOOP: $incomment $line";
        if ($incomment == 1) {
            #print "CASE 1\n";
            if ($line =~ s/[^\*]*\*(.)//) {
                my $term = $1;
                if ($term eq "/") {
                    $incomment = 0;
                } else {
                    $line = $term . $line;
                }
            } else {
                # no closecomment, zap the line.
                $line = "";
            }
        } elsif ($incomment == 2) {
            #print "CASE 2\n";
            if ($line =~ s/([^\"]*\")//) { #"
                # zap to the closequote
                $oline .= "$1";
                $incomment = 0;
            } else {
                # no closequote, zap the line.
                $oline .= $line;
                $line = "";
            }
        } elsif ($verilog && ($line =~ s/^([^\\\/]*)\\(\S*)//)) {
            # line has a \ with no preceding /
            #print "CASE 3\n";
            $oline .= "$1\\$2";
        } elsif ($line =~ s/^([^\/\"]*\")//) {
            # line has " with no preceding /, go into quote mode
            #print "CASE 4\n";
            $oline .= "$1";
            $incomment = 2;
        } elsif ($line =~ s/^([^\/]*)\/(.)//) {
            # line has a / with no preceding \ or " "
            #print "CASE 5\n";
            my ($prefix,$comm) = ($1,$2);
            $oline .= $prefix;
            if ($comm eq "/") {
                $line = "\n";
            } elsif ($comm eq "*") {
                $incomment = 1;
            } else {
                $oline .= "/$comm";
            }
        } else {
            $oline .= $line; $line = "";
        }
    }
    $oline .= $line;
    #print "OUT: $oline";
    ($oline,$incomment);
}

# returns '1' if current rev is >= provided rev.
sub nv_utils_gte_rev {
    my($comprev) = @_;
    my($myrev) = get_nv_utils_vers();
    my($cmajor);
    my($mmajor);
    while (length($myrev)) {
        $myrev =~ s/^(\d+)\.?//; $mmajor = $1;
        $comprev =~ s/^(\d+)\.?//; $cmajor = $1;
        if ($mmajor > $cmajor) { return(1); }
        elsif ($mmajor < $cmajor) { return(0); }
        elsif (!length($comprev)) { return(1); }
        elsif (!length($myrev)) { return(0); }
    }
    return(0);
}

sub get_nv_utils_vers {   
    my($code,$vers);
    $code = '$Id: //hw/nv/bin/nv_utils.pl#21 $';
    die "nv_utils: couldn't find my version!\n" unless $code =~ /\#(\d+)\s+/;
    $vers = $1;
    $vers;
}

sub make_invocation {
    my($progpath,@progargs) = @_;
    my($invocation,$arg);
    $invocation = $progpath;
    foreach $arg (@progargs) {
        $invocation .= " ";
        if ($arg =~ /[\s\$\!\"]/) { #"
            $invocation .= "\'" . $arg . "\'";
        } elsif ($arg =~ /[\']/) {
            $invocation .= '\"' . $arg . '"';
        } else {
            $invocation .= $arg;
        }
    }
    print "made: \"$invocation\"\n";
    $invocation;
}

sub abspath {
    my($relpath) = @_;
    my($abspath);
    my(@abspath1);
    my(@abspath2);
    my($dir);
    if ($relpath =~ /^\//) {
        $abspath = $relpath;
    } else {
        $abspath = $ENV{PWD} . "/$relpath";
    }
    @abspath1 = split(/\//,$abspath);
    foreach $dir (@abspath1) {
        next if $dir =~ /^\s*$/;
        next if $dir eq ".";
        if ($dir eq "..") {
            pop(@abspath2);
        } else {
            push(@abspath2,$dir);
        }
    }
    $abspath = "";
    foreach $dir (@abspath2) {
        $abspath .= "/$dir";
    }
    $abspath;
}

 # evaluate an expression and return the result.  Cleanly trap errors.
 # usage:
 #  $result = evalexpr("3*4");
 #  ($result,$err) = evalexpr("3*4",0);
 #  ($result,$err) = evalexpr("3*4",0,"f.out","f.err");
sub evalexpr {
    my($expr,$exitonerror,$tmpfile1,$tmpfile2) = @_;
    my($result);
    my($error) = 0;
    my($retexit) = 1;
    my($SAVE_LINE) = $_;
    my($SAVE_LINENO) = $.;
    unless (defined($exitonerror)) {
        $exitonerror = 1;
        $retexit = 0;
    }
    #print "expr:$expr\n";
    $tmpfile1 = ".mk.tmp" unless defined($tmpfile1);
    $tmpfile2 = ".mk.err" unless defined($tmpfile2);
    open SAVEERR, ">&STDERR";
    open SAVEOUT, ">&STDOUT";

#    # Dummy statements to prevent perl reporting typo statements
#    print SAVEERR "";
#    print SAVEOUT "";

    open STDOUT, ">$tmpfile1" || die "can't write tmp out file";
    open STDERR, ">$tmpfile2" || die "can't write tmp err file";
    print eval($expr);
    close(STDOUT);
    close(STDERR);
    open STDERR, ">&SAVEERR";
    open STDOUT, ">&SAVEOUT";

    open(EVAL,"$tmpfile1") || die "can't read tmp out file";
    while(<EVAL>) {
        $error = 1 if defined($result);
        $error = 1 unless $_ =~ /^(\d+)$/;
        $result = $1;
    }
    close(EVAL);
    $error = 1 unless (-z "$tmpfile2");
    if ($error) {
        die "bad eval of \"$expr\" (see $tmpfile1 and $tmpfile2)\n" if $exitonerror;
        return(0,$error);
    }
    system("rm -f $tmpfile1");
    system("rm -f $tmpfile2");
    #print "result:$expr -> $retexit $result\n";

    $_ = $SAVE_LINE;
    $. = $SAVE_LINENO;
    if ($retexit) {
        return($result,0);
    } else {
        return($result);
    }
}

sub gen_histogram {
    my($dataref,$step,$desc,
          $reverse,$cols,$show_hdr,$auto_axis) = @_;
    my($sign,$data,@data,@buckets,$bucket,$min,$minv,$minb,$bval,$max);
    my($len);
    my($output) = "";
    my($delta) = $step/1000;
    die "reverse=1 required\n" unless $reverse == 1;
    if (defined($dataref)) {
        @data = sort { $b <=> $a } @$dataref;
    }
    if ($#data == -1) {
        $min = 0.0;
        $max = 0.0;
        $minv = 0.0;
    } else {
        if ($auto_axis eq "N") {
            $min = 0.0;
        } elsif ($auto_axis eq "Y") {
            $min = $data[0];
        } else {
            $min = $auto_axis; 
        }
        $max = $data[$#data];
        $minv = $data[0];
    }
    # init buckets
    for ($bucket=0;$bucket<$cols;$bucket++) {
        $buckets[$bucket] = 0;
    }
    # align min to a bucket
    $minb = $step * int($min/$step + 2.0);
    while ($minb > ($min-$delta)) { $minb -= $step; }
    $minb += $step;
    foreach $data (@data) {
        #print "$desc got data $data\n";
        $bucket = ($minb-$data)/$step + $delta;
        if ($bucket > 0.0) {
            # convert to int
            $bucket = int($bucket);
        } elsif ($bucket < 0.0) {
            # skip -- out of range
            next;
        } else {
            $bucket = 0;
        }
        # clamp to legal buckets
        $bucket = ($cols-1) if $bucket > ($cols-1);
        #print "$data -> $bucket\n";
        $buckets[$bucket]++;
    }

    # print results
    my (@bval) = ();
    my $tmp;
    my $sigfig;
    if ($step =~ /\.(\d+)$/) {
        $sigfig = length($1);
    } else { $sigfig = 2; }

    $len = length($desc)+1;

    # generate header
    $output .= " "x$len if $show_hdr;
    $bval = $minb;
    for ($bucket=0;$bucket<$cols;$bucket++) {
        if ($show_hdr) {
            $tmp = sprintf("%1.${sigfig}f",$bval);
            $tmp =~ s/^(\-?)0/$1/ if $sigfig > 2;
            $tmp = " " . $tmp if ($bval >= 0);
            $output .= sprintf("%5.5s ",$tmp);
        }
        $bval[$bucket] = $bval;
        $bval -= $step;
    }
    $output .= "  MAX\n" if $show_hdr;

    $output .= "$desc ";
    for ($bucket=0;$bucket<$cols;$bucket++) {
        if (($bval[$bucket] - $step) > $minv) {
            $output .= sprintf("%5s ","??");
        } else {
            $output .= sprintf("%5d ",$buckets[$bucket]);
            if (($bval[$bucket] - $delta) > $minv) {
                $output =~ s/\s$/\*/;
            }
        }
    }
    $output .= " " if $max >= 0;
    $output .= sprintf("%1.${sigfig}f ",$max);
    $output .= "\n";
    return($output);
}


sub expand_argfile {
    my($argstyle,$argvref,$outref) = @_; 
    my($i,$arg,$argfile,$line,$incomment,$str,$space);
    $i=0;
    while(1) {
        $arg = $ {$argvref} [$i];
        #print "i=$i arg=\"$arg\"\n";
        if ($argstyle eq "@") {
            if ($arg =~ /^\@(.*)$/) {
                $argfile = $1;
                splice(@{$argvref},$i,1); # remove argfile from arglist
            }
        } elsif ($argstyle eq "-f") {
            if ($arg eq "-f") {
                splice(@{$argvref},$i,1); # remove -f switch from arglist
                $argfile = $ {$argvref} [$i];
                splice(@{$argvref},$i,1); # remove argfile from arglist
            } elsif ($arg =~ /^\-f(.+)$/) {
                $argfile = $1;
                splice(@{$argvref},$i,1); # remove argfile from arglist
            }
        } else {
            die "expand_argfile: unknown argfile style \"$argstyle\"\n";
        }
        if (defined($argfile)) {
            my $j = $i;
            # expand the argfile
            open(AFILE,"<$argfile") || die "couldn't open arg file \"$argfile\"\n";
            while(<AFILE>) { 
                chomp; $line = $_; 
                $line =~ s/\#.*$//;
                next if /^$/; 
                undef $incomment;
                $arg = "";
                #print " line=$line\n";
                while($line =~ s/^(\s*)(\S+)//) {
                    ($space,$str) = ($1,$2);
                    #print " space=$space str=$str\n";
                    if (defined($incomment)) {
                        # inside a comment
                        $arg .= $space;
                    }
                    while ($str =~ s/^([^\"\']*)([\"\'])//) { # "
                        my ($tmps,$tmpc) = ($1,$2);
                        if (defined($incomment)) {
                            if ($incomment eq $tmpc) {
                                if ($tmps =~ s/\\$//) {
                                    $arg .= "$tmps$tmpc";
                                } else {
                                    $arg .= $tmps; undef $incomment;
                                }
                            } else {
                                $arg .= "$tmps$tmpc";
                            }
                        } else {
                            if ($tmps =~ s/\\$//) {
                                $arg .= "$tmps$tmpc";
                            } else {
                                $arg .= $tmps; $incomment = $tmpc;
                            }
                        }
                    }
                    $arg .= $str;
                    unless (defined($incomment)) {
                        #print " adding \"$arg\"\n";
                        if (defined($outref)) {
                            # add to outref array
                            push(@{$outref},$arg);
                        } else {
                            # add back to argvref array
                            splice(@{$argvref},$j++,0,$arg);
                        }
                        $arg = "";
                    }
                }
                if ($incomment) {
                    die "expand_argfile: no close-comment found\n";
                }

            }
            undef $argfile;
        } else {
            $i++;
        }
        #print " done!\n";
        last if $i > $#{$argvref};
    }
    if (defined($outref)) {
        # do recursive expansion of possible file references in outref
        expand_argfile($argstyle,$outref);
    }
}

1;

# things to remember:
# use diagnostics;
# use English;

# my($var1,@var2,...) 
#  --> makes var1,var2 visible only to sub
# local($var1,@var2,...) 
#  --> makes var1,var2 visible to block and any blocks called by this block
