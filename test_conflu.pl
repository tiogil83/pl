#! /home/utils/perl-5.14/5.14.1-threads-64/bin/perl

use lib "/home/scratch.asicpd_methodology/LocalPerlModules/5.14/lib/perl5/";
use NVEnv ;
use CadConfig ;
use Getopt::Long ;
use Data::Dumper ;
use File::stat;
use REST::Client;
use URI::Encode qw(uri_encode);
use MIME::Base64;
use JSON::XS;

my $chiplet ;
my $dirs ;
my $confluence ;
my $toppage ;
my $space ;
my $help ;

GetOptions (
    "chiplet=s"    => \$chiplet ,
    "dir=s"        => \$dirs ,
    "conflu=i"     => \$confluence,
    "toppage=s"    => \$toppage,
    "space=s"      => \$space,
    "help|h"       => \$help ,
)
or die("Error in command line arguments\n");

my $USAGE = "USAGE:\n" ;
$USAGE .= "$0 [<options>] \n" ;
$USAGE .= "    -chiplet     chiplet name \n" ;
$USAGE .= "    -dir         specify the report dirs, \${proj}\/rep by default \n" ;
$USAGE .= "    -conflu      \[0\|1\], to generate the confluence page \n" ;
$USAGE .= "    -toppage     specify the toppage, it is the parent page of the custom report page  \n" ;
$USAGE .= "    -space       this is the container name of confluence pages. GA100VLSI for ga100 vlsi \n" ;
$USAGE .= "$0 -chiplet NV_gaa_s0 -dir \"/home/scratch.ga100_test_NV_gaa_s0/ga100/ga100/timing/ga100/rep /home/scratch.ga100_test_NV_gaa_s0_capture/ga100/ga100/timing/ga100/rep\"\n" ;
$USAGE .= "$0 -chiplet NV_gaa_s0 -conflu 1 -toppage \"S0 test timing status\" -space \"GA100VLSI\"\n" ;


if (defined $help) {
    die ($USAGE) ;
}

if ($confluence == 1 && ($toppage eq "" || $space eq "")) {
   die "Please specify the toppage and space name when generate confluence page.\n" ;
}


my $output = "ga100/rep/NV_gaa_s0.test_timing.custom_check.sum" ;

# start to generate the confluence page 

if (defined $confluence && $confluence == 1) {
    print "\nStarting to generate the conflunce page\n" ;
    # need to get the authority 
    print "\nYour Confluence User Name : ";
    system ("stty -echo");
    my $username = <STDIN>;
    system ("stty echo");
    chomp($username);
    print "\nYour Confluence Password  : ";
    system ("stty -echo");
    my $password = <STDIN>;
    system ("stty echo");
    chomp($password);
    print "\n";
    
    our $client = REST::Client->new();
    
    $client->setHost('https://confluence.nvidia.com') ;
    
    $client->getUseragent()->ssl_opts(verify_hostname => 0);
    $client->getUseragent()->ssl_opts(SSL_verify_mode => SSL_VERIFY_NONE);

    my $title = $toppage;
    print "Looking for top page \"$title\" in space \"$space\"\n";
    
    my @toppage_info = _get_confluence_page ($username, $password, $title, $space) ;
    my $id = $toppage_info[0] ;
    
    if ($id eq "") {
        die "Can't find the toppage \"$toppage\"\n" ;
    }
    
    my $custom_page = "$chiplet Custom Check Reports" ;
    my $message     = _transfer_file_to_confluence ($output) ;
    #print "$message" ;

    my ($custom_page_id, $custom_page_version) = _get_confluence_page ($username, $password, $custom_page, $space) ;
    
    if ($custom_page_id eq "") {
        print "Can't find \"$custom_page\" in space \"$space\"...Creating...\n" ;
        _create_confluence_page ($username, $password, $custom_page, $space, $id, $message) ;
    } else {
        print "Already exists \"$custom_page\" in space \"$space\"...Updating...\n" ;
        $custom_page_version = $custom_page_version + 1 ;
        print "$custom_page_version\n" ;
        _update_confluence_page ($username, $password, $custom_page, $space, $custom_page_id, $custom_page_version, $message) ;
    }


} 

sub _get_confluence_page {
    my ($username, $password, $title, $space) = @_ ;


    my $query="title=$title&spaceKey=$space";
    $query = uri_encode($query);

    my $getheaders = {
        Accept => 'application/json',
        Authorization => 'Basic ' . encode_base64($username . ':' . $password)
    };

    $client->GET(
        "rest/api/content/?$query",
        $getheaders ,
    );

    my $content = decode_json($client->responseContent()) ;

    my $results = $content->{results}[0] ;
    my $id ;
    my $version ;

    #print (Dumper $content) ;

    if (defined $results) {
        $id = $results->{id} ;
        $version = $results->{version}{number} ;
        return ($id, $version) ;
    } else {
        $id = "" ;
        $version = "" ;
        return ($id, $version) ;
    }
}

sub _create_confluence_page {
    my ($username, $password, $title, $space, $contentid, $message) = @_ ; 

    my $func_content = {
        "title" =>  $title ,
        "type" =>  "page",
        "ancestors" => [{'id'=>$contentid}],
        "space" => {"key"=>$space},
        "body" =>  {
            "storage" =>  {
                "value" => "$message",
                "representation" =>  "storage",
            },
        },
    } ;

    my $headers = {
        'Content-Type' => 'application/json',
        Authorization => 'Basic ' . encode_base64($username . ':' . $password) ,
    };

    $client->POST(
          "rest/api/content/",
          encode_json($func_content),
          $headers,
    );
    #print "return code : $client->responseCode()\n" ;
    if( $client->responseCode() eq '200' ){
        print "Created.\n";
    }
}

sub _update_confluence_page {
    my ($username, $password, $title, $space, $contentid, $version, $message) = @_ ;
    
    my $func_content = {
        "title" =>  $title ,
        "type" =>  "page",
        "version"=>{
            "number"=> "2",
            },
        "body" =>  {
            "storage" => {
                "value" => "$message",
                "representation" =>  "storage",
            },
        },
    } ;

    my $headers = {
        'Content-Type' => 'application/json',
        Authorization => 'Basic ' . encode_base64($username . ':' . $password) ,
    };
    
    $client->PUT(
          "rest/api/content/$contentid",
          encode_json($func_content),
          $headers,
    );
    
    if( $client->responseCode() eq '200' ){
        print "Updated\n";
    }
}


sub _transfer_file_to_confluence {
    my ($input) = @_ ;
    #print "report file $input\n" ;
    my $rtn   = "<pre>\n" ;
    open IN, "$input" or die "Can't open file $input\n" ;  
    while (<IN>) {
        my $line = $_ ;
        $rtn = $rtn . $line ; 
    }
    close IN ;
    $rtn = $rtn . "<\/pre>\n" ;
    return $rtn ;
}

