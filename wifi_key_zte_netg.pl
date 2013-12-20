#!/usr/bin/perl
use Data::Dumper; 
#use strict;
use LWP::UserAgent;
use HTTP::Cookies;
my $ip=$ARGV[0];

my $ua=LWP::UserAgent->new;
$ua->credentials(
				"$ip:8080",
				'NETGEAR EVG1500',
				'admin'=>'github'
			);
$ua->timeout(5);
my $cookie_jar = HTTP::Cookies->new(ignore_discard => 1);
$ua->cookie_jar($cookie_jar);
my $request = new HTTP::Request(GET =>"http://$ip:8080/");
my $response=$ua->request($request);
#warn $response->content;
my $model;
#my $wifi;
my $message=$response->content;
	for my $s (split ('\r?\n', $message))
		{
		if ($s=~m/ZXHN H218N/){
		$model="ZTE";
		last;
		}
		if ($s=~m/NETGEAR Router EVG1500/){
		$model="EVG";
		last;
		}
				
}
warn $model;
if ($response->code == 401){
$ua->credentials(
				"$ip:8080",
				'ZXHN H218N',
				'admin'=>'github'
			);
$request = new HTTP::Request(POST => "http://$ip:8080/", ['Content-Type' => 'application/x-www-form-urlencoded'],"frashnum=&action=login&Frm_Logintoken=$token&Username=admin&Password=github");
$response=$ua->request($request);
$request = new HTTP::Request(GET =>"http://$ip:8080/getpage.gch?pid=1002&nextpage=net_wlan_secrity_t.gch");
$response=$ua->request($request);

$request = new HTTP::Request(GET =>"http://$ip:8080/getpage.gch?pid=1002&nextpage=net_wlan_secrity_t.gch");
$response=$ua->request($request);
#warn $response->content;
#warn $response->code; 
$message=$response->content;
#warn $message;
	       for my $s (split ('\r?\n', $message))
                {
			warn $s;
		if ($s=~m/\'KeyPassphrase\'\,\'(.*?)\'/){
			
		$wifi=$1;
		warn $wifi;
		}

}
print $wifi;
$request = new HTTP::Request(POST => "http://$ip:8080/", ['Content-Type' => 'application/x-www-form-urlencoded'],"logout=1");
$response=$ua->request($request);





}


if ($model eq 'ZTE') {

#$request = new HTTP::Request(POST => "http://$ip:8080/", ['Content-Type' => 'application/x-www-form-urlencoded'],"frashnum=&action=login&Frm_Logintoken=0&Username=admin&Password=H*27nG46Lm");
#$response=$ua->request($request);
$response->content =~ m/getObj\("Frm_Logintoken"\)\.value\s=\s"(.*?)"/g;
my $token = $1;

$request = new HTTP::Request(POST => "http://$ip:8080/", ['Content-Type' => 'application/x-www-form-urlencoded'],"frashnum=&action=login&Frm_Logintoken=$token&Username=admin&Password=H*27nG46Lm");
$response=$ua->request($request);
#$ua->cookie_jar($cookie_jar);
#warn $response->content;	
$request = new HTTP::Request(GET =>"http://$ip:8080/getpage.gch?pid=1002&nextpage=net_wlan_secrity_t.gch");
$response=$ua->request($request);
#warn $response->content;
#warn $response->code; 
$message=$response->content;
#warn $message;
	       for my $s (split ('\r?\n', $message))
                {
			#warn $s;
		if ($s=~m/\'KeyPassphrase\'\,\'(.*?)\'/){
			
		$wifi=$1;
}

}
print $wifi;
$request = new HTTP::Request(POST => "http://$ip:8080/", ['Content-Type' => 'application/x-www-form-urlencoded'],"logout=1");
$response=$ua->request($request);


}elsif ($model eq 'EVG'){
#$request = new HTTP::Request(GET =>"http://$ip:8080/WLG_wireless.htm&todo=cfg_init");
$request = new HTTP::Request(GET =>"http://$ip:8080/WLG_wireless2.htm");
 $response=$ua->request($request);
#warn $response->content;
$message=$response->content;
        for my $s (split ('<tr>', $message))
                {
		#warn $s;
		if ($s=~m/>Passphrase</){
		#warn $s;
		if ($s=~m/value="\w+/){
		$wifi=$&;
		$wifi=~s/value="//;
		#warn $wifi;
		}
#last;
}}

print $wifi;

}else{
$ua->credentials(
				"$ip:8080",
				'NETGEAR JWNR2000-4EMRUS',
				'admin'=>'IEMG4iakmF0Y7sT'

			);
my $cookie_jar = HTTP::Cookies->new(ignore_discard => 1);
$ua->cookie_jar($cookie_jar);
my $request = new HTTP::Request(GET =>"http://$ip:8080/");
my $response=$ua->request($request);
#warn $response->content;
$request = new HTTP::Request (GET =>"http://$ip:8080/WLG_wireless.asp");
 $response=$ua->request($request);
#warn $response->content;
my ($ssid, $key);
for my $s (split ('\r?\n', $response->content)){
	if ($s=~m/var WlanSecConfig_WpaKey = new Array\(\"(.*?)\"\);/){
	$key=$1;
	
	}
	 if ($s=~m/var WlanConfig_SSID = new Array\(\"(.*?)\"\);/){
	$wifi=$1;
	}
	
}


print $key;
}


