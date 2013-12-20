
#!/usr/bin/perl

use Data::Dumper;
use warnings;
#use strict;
use HTTP::Cookies;
use MIME::Base64;
use LWP::UserAgent;
use DBI;
use LWP::Authen::Digest;
use Digest::MD5 qw(md5_hex); 
use threads;
use threads::shared;
my $city_id;
my $addres;
my $passwod;
my @ip;
my $soft_addres;
my $DBCONN;	
my $DB_HOST;
my $DB_DB;
my $DB_USER;
my $DB_PASS;


my $key:shared=0;
my $threads=50;
my @threads;
while (<@ARGV>){
if ($ARGV[0]=~m/\d+/){
 $city_id=shift @ARGV;
  }
}

chomp $city_id;

init_params();
my $password=password($city_id);
@ip=dbi_request($city_id);
close_db();
my $key:shared=0;

for my $t (1..$threads) {
   push @threads, threads->create(\&proc, $t);
}

foreach my $t (@threads) {
   $t->join();
}






sub proc{
while (1){
my $seq=$key++;
if ($seq>=@ip)
     {
       print "- Thread $num done.\n";
       return;
     }
$ip=$ip[$seq];
warn $ip;
$ip=~s/;//g;
my $ua=LWP::UserAgent->new;
	$ua->credentials(
				$ip.':80',
				'spa admin',
				'admin', "$password"
			);
	my $cookie_jar = HTTP::Cookies->new(ignore_discard => 1);
	$ua->cookie_jar($cookie_jar);	
	my $request = new HTTP::Request(GET =>"http://$ip:80/admin/voice/advanced");
	$request->header('Connection' => 'keep-alive');
	warn $request->as_string;
	my $response=$ua->request($request);
	$request = new HTTP::Request(GET =>"http://$ip:80/upgrade?".'http://provisioning.ertelecom.ru/firmware/Linksys/spa2102-5-2-5.bin');
	warn $request->as_string;
	$request->header('Connection' => 'keep-alive');
	
$response=$ua->request($request);
	 $request = new HTTP::Request(GET =>"http://$ip:80/admin/voice/advanced");
        $request->header('Connection' => 'keep-alive');
	
	$request->header('Connection' => 'Referer=http://'."$ip".'/admin/upgrade?http://provisioning.ertelecom.ru/firmware/Linksys/spa2102-5-2-5.bin');
	$response=$ua->request($request);
		




open (FILE, '>>./log');
print (FILE "$ip\n");
close (FILE);
}
}


sub dbi_request{
	$city_id=$_[0];
	my $sth = $DBCONN->prepare("select ip from p_device where p_hostmodel_id=1 and p_city_id=$city_id and fwversion='3.3.6' order by lastpolled desc ");
	my $rv = $sth->execute;
	while (@row=$sth->fetchrow_array){
		my $p=$row[0].";".$row[1];
		push (@ip, $p);
		}
	return @ip;	



}

sub init_db{
	$DBCONN = DBI->connect("DBI:Pg:database=$DB_DB;host=$DB_HOST", $DB_USER, $DB_PASS, {AutoCommit => 1, RaiseError => 1, PrintError => 0});
	if (!defined($DBCONN)){
		die "Cant connect to $DB_DB!";
	}  
}

sub init_params {
	$DB_HOST='github';
	$DB_DB='provisioning';
	$DB_USER='github';
	$DB_PASS='github';
	#$DB_SID='010500000000000515000000ef13c62941c961ff18feea5b063d0000';
	#$DB_SERVICE_NAME='github';		 
	#$DB_PORT='github';
	init_db();
	
}

sub do_commit{
	#debug_print('DEBUG',"Doing COMMIT");
	$DBCONN->commit;
}

sub close_db{
	$DBCONN->{RaiseError}=0;
	$DBCONN->disconnect if defined $DBCONN;
	undef $DBCONN;
}

sub password{
	my $city_id=$_[0];
	my @row;
	warn $city_id;
	my $sth = $DBCONN->prepare("select password from p_credentials where p_hostmodel_id=1 and p_city_id=$city_id");
        my $rv = $sth->execute;
	@row = $sth->fetchrow_array;
	#warn $row[0];
	return $row[0];

}


