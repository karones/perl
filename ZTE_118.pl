package Router::CPE::ZTE_H118N;

use LWPUserAgentSec;
use HTTP::Cookies;
use MIME::Base64; 
use Net::Telnet;
#use Encode;

require Router::CPE::__GENERIC;
@ISA = qw(Router::CPE::__GENERIC);

sub fix_wifi{
#sub PollConfig {
my ($self, %args) = @_;
        my ($fwversion,$sn,$response,$request,$auth);
        my $cookie_jar = HTTP::Cookies->new(ignore_discard => 1);
        $self->_prepare;
	#каналы от 1-13 автоматичесский =0
        # 0=802.11N 1=802.11G
	#канал=0 тип = , шифрование wpa2-

	my $new_channel='6';
	my $new_mode=0;
	for my $c (@{$self->Credentials}){
                $auth = encode_base64($c->[0].":".$c->[1]);
                $self->{_UA}->cookie_jar($cookie_jar);
                $request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:language=en_us&var:menu=status&var:page=system_msg", $self->{_BaseURL}));
                $request->header('Cookie' => 'sessionid="1"; auth=nok;');
                $request->header('Authorization' => "Basic ".$auth);
                $response = $self->HTTPRequest($request);
                #warn $response->content;
                next if(!defined($response) || $response->code != 200);
           }
	#$request-new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:language=en_us&var:menu=wireless&var:page=wireless_setup", $self->{_BaseURL}));
	 $request-new HTTP::Request(GET => sprintf("html/languages/en_us/page/wireless_setup.js?v=trunkr3107", $self->{_BaseURL}));
	$request->header('Authorization' => "Basic ".$auth);
        $response = $self->HTTPRequest($request);
#	warn $response->content;
	$request = new HTTP::Request(POST => sprintf("%scgi-bin/webproc",  $self->{_BaseURL}), ['Content-Type' => 'application/x-www-form-urlencoded'], "%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.Enable=1&var%3Amenu=wireless&var%3Apage=wireless_setup&getpage=html%2Findex.html&errorpage=html%2Findex.html&obj-action=set&var%3Aerrorpage=wireless_setup&var%3ACacheLastData=U0VMRUNUX1N0YW5kYXJkPWJnbnxTRUxFQ1RfQmFuZHdpZHRoPTB8U0VMRUNUX1NwZWVkPUF1dG98U0VMRUNUX1Bvd2VyPTEwMHxTRUxFQ1RfQ3VycmVudENvdW50cnk9UlV8U0VMRUNUX0NoYW5uZWw9MHxJTlBVVF9FbmFibGU9dHJ1ZXxJTlBVVF9FbmFibGVfc2hvcnRHST10cnVl&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.Enable=1&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.Channel=0&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.AutoChannelEnable=1&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.Standard=bgn&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.MaxBitRate=Auto&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.TransmitPower=100&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.RegulatoryDomain=RU&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.OperatingChannelBandwidth=0&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.GuardInterval=1");
	 $request->header('Authorization' => "Basic ".$auth);
        $response = $self->HTTPRequest($request);

	$request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?var:ssidIndex=1&getpage=html/index.html&var:menu=wireless&var:page=multi_ssid&var:index=1&var:subpage=wireless_security", $self->{_BaseURL}));
	$request->header('Authorization' => "Basic ".$auth);
        $response = $self->HTTPRequest($request);
	#warn $response->content;	
	my $ssid;
	my $pass;
	for my $s (split ('\r?\n', $response->content)){
		if ($s=~m/var G_SSID\s+=\s+"(.*?)";/){
			$ssid=$1;
		}
		if($s=~m/var G_KeyPassphrase\s+=\s+"(.*?)";/){
			$pass=$1;
		}
	}
	warn $ssid;
	warn $pass;
	$request = new HTTP::Request(POST => sprintf("%scgi-bin/webproc",  $self->{_BaseURL}), ['Content-Type' => 'application/x-www-form-urlencoded'], "%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.Enable=1&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.X_TWSZ-COM_APIsolate=0&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID=$ssid&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSIDAdvertisementEnabled=0&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.DeviceOperationMode=WirelessStation&var%3Aindex=1&var%3Amenu=wireless&var%3Apage=multi_ssid&getpage=html%2Findex.html&errorpage=html%2Findex.html&var%3AssidIndex=1&var%3Aerrorpage=wireless_security&var%3ACacheLastData=U0VMRUNUX0JlYWNvblR5cGU9NHxTRUxFQ1RfV0VQSW5kZXg9NDAtYml0fFNFTEVDVF9XRVBLZXk9MXxJTlBVVF9TU0lEPVdpRmktRE9NLnJ1LTczMDF8SU5QVVRfSF9TU0lEPWZhbHNlfElOUFVUX1NTSURfQlNTUmVsYXk9ZmFsc2V8SU5QVVRfTUFDQWRkcj18SU5QVVRfRGlzdGFuY2VGcm9tUm9vdD0wfEVuY3J5cHRfb249dHJ1ZXxFbmNyeXB0X29mZj1mYWxzZXxJTlBVVF9XRVBLZXkxPXxJTlBVVF9XRVBLZXkyPXxJTlBVVF9XRVBLZXkzPXxJTlBVVF9XRVBLZXk0PXxJTlBVVF9DaXBoZXJfdHlwZTE9ZmFsc2V8SU5QVVRfQ2lwaGVyX3R5cGUyPWZhbHNlfElOUFVUX0NpcGhlcl90eXBlMz10cnVlfElOUFVUX1BocmFzZT13bXdzbXMzYWFmfElOUFVUX0xpZmVUaW1lPTIwMHxJTlBVVF9VcGdyYWRlS2V5SWZDb25uZWN0RW5hYmxlPWZhbHNlfElOUFVUX0ZpcnN0UmFkaXVzRW5hYmxlPWZhbHNlfElOUFVUX0lQQWRkcmVzcz18SU5QVVRfUG9ydD18SU5QVVRfU2hhcmVfU2VjcmV0PXxJTlBVVF9CYWtSYWRpdXNFbmFibGU9ZmFsc2V8SU5QVVRfSVBBZGRyZXNzX2Jhaz18SU5QVVRfUG9ydF9iYWs9fElOUFVUX1NoYXJlX1NlY3JldF9iYWs9fElOUFVUX1JhZGl1c0NvdW50RW5hYmxlPWZhbHNlfElOUFVUX1JhZGl1c0NvdW50UG9ydD18SU5QVVRfUmFkaXVzQ291bnRQb3J0X2Jhaz18SU5QVVRfUmFkaXVzSW5mb3JtSW50ZXJ2YWw9&%3AInternetGatewayDevice.LANDevice.1.X_TWSZ-COM_WDSConfiguration.EncryptionModes=TKIPandAESEncryption&%3AInternetGatewayDevice.LANDevice.1.X_TWSZ-COM_WDSConfiguration.Passphrase=$pass&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.X_TWSZ-COM_RadiusServer.Enable=0&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.BeaconType=WPAand11i&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.WPAAuthenticationMode=PSKAuthentication&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.WPAEncryptionModes=TKIPandAESEncryption&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.IEEE11iAuthenticationMode=PSKAuthentication&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.IEEE11iEncryptionModes=TKIPandAESEncryption&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.PreSharedKey.1.KeyPassphrase=wmwsms3aaf&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.X_TWSZ-COM_WPAGroupRekey=200&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.X_TWSZ-COM_WPAStrictRekey=0&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.WPS.Enable=1&obj-action=set");	
	 $request->header('Authorization' => "Basic ".$auth);
        warn $request->as_string;
	$response = $self->HTTPRequest($request);



}
sub ResetKey{
#sub PollConfig {
my ($self) = @_;
        my ($fwversion,$sn,$response,$request,$auth);
        my $cookie_jar = HTTP::Cookies->new(ignore_discard => 1);
        $self->_prepare;
        for my $c (@{$self->Credentials}){
                $auth = encode_base64($c->[0].":".$c->[1]);
                $self->{_UA}->cookie_jar($cookie_jar);
                $request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:language=en_us&var:menu=status&var:page=system_msg", $self->{_BaseURL}));
                $request->header('Cookie' => 'sessionid="1"; auth=nok;');
                $request->header('Authorization' => "Basic ".$auth);
                $response = $self->HTTPRequest($request);
                #warn $response->content;
                next if(!defined($response) || $response->code != 200);
           }
		$request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:menu=management&var:page=system_management", $self->{_BaseURL}));
                $request->header('Cookie' => 'sessionid="1"; auth=nok;');
                $request->header('Authorization' => "Basic ".$auth);
                $response = $self->HTTPRequest($request);
		$request = new HTTP::Request(POST => sprintf("%scgi-bin/webproc",  $self->{_BaseURL}), ['Content-Type' => 'application/x-www-form-urlencoded'], "obj-action=recover&var:menu=management&var:page=system_management&var:errorpage=system_management&var:noredirect=1&getpage=html%2Fpage%2Frestarting.html");

		#$request->header('Cookie' => 'sessionid="1"; auth=nok;');
                $request->header('Authorization' => "Basic ".$auth);
                $response = $self->HTTPRequest($request);

}

sub Reboot{
my ($self) = @_;
        my ($fwversion,$sn,$response,$request,$auth);
        my $cookie_jar = HTTP::Cookies->new(ignore_discard => 1);
        $self->_prepare;
        for my $c (@{$self->Credentials}){
                $auth = encode_base64($c->[0].":".$c->[1]);
                $self->{_UA}->cookie_jar($cookie_jar);
                $request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:language=en_us&var:menu=status&var:page=system_msg", $self->{_BaseURL}));
                $request->header('Cookie' => 'sessionid="1"; auth=nok;');
                $request->header('Authorization' => "Basic ".$auth);
                $response = $self->HTTPRequest($request);
                #warn $response->content;
                next if(!defined($response) || $response->code != 200);
           }

$request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:menu=management&var:page=system_management", $self->{_BaseURL}));
                $request->header('Cookie' => 'sessionid="1"; auth=nok;');
                $request->header('Authorization' => "Basic ".$auth);
                $response = $self->HTTPRequest($request);

$request = new HTTP::Request(POST => sprintf("%scgi-bin/webproc",  $self->{_BaseURL}), ['Content-Type' => 'application/x-www-form-urlencoded'], "obj-action=reboot&var%3Amenu=management&var%3Apage=system_management&var%3Aerrorpage=system_management&var%3Anoredirect=1&getpage=html%2Fpage%2Frestarting.html");
 #$request->header('Cookie' => 'sessionid="1"; auth=nok;');
                $request->header('Authorization' => "Basic ".$auth);
                $response = $self->HTTPRequest($request);
	warn $response->code;	
if ($response->code==200){
return 1;
}else{
return 0;
}
}


sub Upgrade{
#sub Configure{
my ($self, %args) = @_;
        my ($fwversion,$sn,$response,$request,$auth);
        my $cookie_jar = HTTP::Cookies->new(ignore_discard => 1);
        $self->_prepare;
	warn 'upg';
        for my $c (@{$self->Credentials}){
                $auth = encode_base64($c->[0].":".$c->[1]);
                $self->{_UA}->cookie_jar($cookie_jar);
                $request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:language=en_us&var:menu=status&var:page=system_msg", $self->{_BaseURL}));
                $request->header('Cookie' => 'sessionid="1"; auth=nok;');
                $request->header('Authorization' => "Basic ".$auth);
                $response = $self->HTTPRequest($request);
                #warn $response->content;
                next if(!defined($response) || $response->code != 200);
                last;
        }
for my $s (split ('\r?\n', $response->content)){
                if ($s =~ m/var G_SoftwareVersion[\s\t]+= "(.*?)";/){
                        $fwversion = $1;
                        $fwversion =~ s/\s$//;
			last;
}}

$request = new HTTP::Request(GET =>sprintf("%scgi-bin/webproc?getpage=html/index.html&var:language=en_us&var:menu=advanced&var:page=remote_access_ctrl", $self->{_BaseURL}));
$request->header('Cookie' => 'sessionid="1"; auth=nok;');
$request->header('Authorization' => "Basic ".$auth);
$response = $self->HTTPRequest($request);
my $number;
for my $i (split '\r?\n', $response->as_string){
	if ($i =~ m/G_Path\[t\] = "InternetGatewayDevice\./){
		$i =~ m/"(\d+),"\+\s"\d+";$/;
		$number = $1;
	}

}
#warn $number;	
$response->as_string =~ m/G_Path[t] = "InternetGatewayDevice\.WANDevice/;
#warn "http auth ok $number";

#warn $response->content;
$ip=$self->{_BaseURL};
#warn $ip;
my @ip=split ('/',$ip);
#warn $ip[2];
$ip[2]=~s/:\d+//g;
#warn $ip[2];
#warn $response->content;
$request = new HTTP::Request(POST => sprintf("%scgi-bin/webproc",  $self->{_BaseURL}), ['Content-Type' => 'application/x-www-form-urlencoded'], "%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACLEnable=1&var%3Amenu=advanced&var%3Apage=remote_access_ctrl&getpage=html%2Findex.html&errorpage=html%2Findex.html&obj-action=set&var%3ApathIndex=0&var%3AselectedIndex=0&var%3Aerrorpage=remote_access_ctrl&var%3ACacheLastData=U0VMRUNUX0Nvbm5MaXN0PUludGVybmV0R2F0ZXdheURldmljZS5XQU5EZXZpY2UuMS5XQU5Db25uZWN0aW9uRGV2aWNlLjMuV0FOUFBQQ29ubmVjdGlvbi4xfEVuYWJsZV8wPXRydWV8SVBfMD0wLjAuMC4wfE1hc2tfMD0yNTUuMjU1LjI1NS4yNTV8RW5hYmxlXzE9ZmFsc2V8SVBfMT0wLjAuMC4wfE1hc2tfMT0yNTUuMjU1LjI1NS4yNTV8RXh0UG9ydF8xPTgwODB8RW5hYmxlXzI9dHJ1ZXxJUF8yPTAuMC4wLjB8TWFza18yPTI1NS4yNTUuMjU1LjI1NXxFeHRQb3J0XzI9MjN8RW5hYmxlXzM9ZmFsc2V8SVBfMz0wLjAuMC4wfE1hc2tfMz0yNTUuMjU1LjI1NS4yNTV8RXh0UG9ydF8zPTIy&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.1.Enable=1&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.1.SrcIP=0.0.0.0&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.1.EndSrcIP=255.255.255.255&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.1.ExternalPort=0&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.2.Enable=0&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.2.SrcIP=0.0.0.0&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.2.EndSrcIP=255.255.255.255&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.2.ExternalPort=8080&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.3.Enable=1&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.3.SrcIP=212.33.0.0&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.3.EndSrcIP=212.33.255.255&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.3.ExternalPort=23&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.4.Enable=0&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.4.SrcIP=0.0.0.0&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.4.EndSrcIP=255.255.255.255&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.4.ExternalPort=22");
$request->header('Authorization' => "Basic ".$auth);
$response = $self->HTTPRequest($request);
$t = Net::Telnet->new( Timeout=>5, Errmode => "return");
$t->open(Host=>"$ip[2]");
$t->waitfor(String=>'login:');
$t->print("admin");
$t->waitfor(String=>'Password:');
#$t->print($MODELS{'ZXHN H218N'}->{'http_passw'}->{'admin'});
$t->print("H*27nG46Lm"); 
$t->waitfor(String=>'#');
@ps = $t->cmd(String=>'cat /proc/mtd');
my $size;
my $name;
my $file_name;
foreach $i (@ps){
	if ($i =~ m/mtd\d:\s(.*?)\s/){
		my $hex_number = hex("0x".$1);
		$size+=$hex_number;
	}
}
warn $size;
my $url16 = '/var/www/provisioning.ertelecom.ru/data/firmwares/zte118/ZXHN_H118NV2.2.3i_EH4_RU4.img';
my $url8 = '/var/www/provisioning.ertelecom.ru/data/firmwares/zte118/ZXHN_H118NV2.1.2d_EH4_RU4.img';
my $name8='ZXHN_H118NV2.1.2d_EH4_RU4.img';
my $name16='ZXHN_H118NV2.2.3i_EH4_RU4.img';
my $name;
if (defined $size){ 
if($size > 9000000){
	$url = $url16;
	$name=$name16;
	warn $url
}else{
	#print (FILE "$id : $ip : $login \n");
	if($server_address !~ /cpe\.domru\.ru\/wifi\/h118n\/single/){
		$url = $url8;
		$name=$name8;
		warn $url;
	#	print (FILE "$id : $ip : $login \n");

	}else{
		warn "Image url is right";
		#exit;
	}
}


# накатываем файл без автообновления. 
#warn "1";
$request = new HTTP::Request(POST => sprintf("%scgi-bin/webupg",  $self->{_BaseURL}), ['Content-Type' => 'application/x-www-form-urlencoded']);
my @rand = ('0'..'9');
        for (0..14) {$boundary .= $rand[rand(@rand)];}

 open (my $fh, "<$url");
        binmode($fh);
#       my $size = (stat $file)[7];

my %request_params =(
	'btn' => 'Upgrade',
); 
my $header = HTTP::Headers->new;
	
        $request->header('Content-Type' => 'multipart/form-data; boundary='.$boundary);
        $header->header('Content-Disposition' => 'form-data; name="firmware"; filename="$name"');
$request->header('Accept-Language' => 'ru-ru,ru;q=0.8,en-us;q=0.5,en;q=0.3');
        $request->header('Accept-Encoding' => 'gzip, deflate');
        $request->header('Accept-Charset' => 'windows-1251,utf-8;q=0.7,*;q=0.8');
        $request->header('Connection' => 'keep-alive');
	$request->header('Authorization' => "Basic ".$auth);
      
  my $file_content = HTTP::Message->new($header);
        $file_content->add_content($_) while <$fh>;
        $file_content->add_content($config);
        $request->add_part($file_content);
        close $fh;
for my $key (keys %request_params){
	my $field = HTTP::Message->new(
									[
										'Content-Disposition'   => "form-data; name=\"firmware\"; filename=\"$name\""
										#'Content-Type'          => 'text/plain; charset=utf-8',
										]); 
	$field->add_content_utf8($request_params{$key});
	$request->add_part($field);
}
	$response = $self->HTTPRequest($request);
#warn $request->as_string;
$request = new HTTP::Request(POST => sprintf("%scgi-bin/webproc",  $self->{_BaseURL}), ['Content-Type' => 'application/x-www-form-urlencoded'],'%3AInternetGatewayDevice.X_TWSZ-COM_AutoUpg.Lan_Reboot=2222&getpage=html%2Fpage%2Fupgrading.html&errorpage=html%2Fpage%2Fupgrading.html&obj-action=set&var%3Amenu=management&var%3Apage=firmware&var%3Aerrorpage=firmware');

$request->header('Authorization' => "Basic ".$auth);
$response = $self->HTTPRequest($request);


return 1;




#ecли $size не существует тогда ничего не делаем	
}
#warn "ne 1";
return 0;
}



sub BasicInfo {
#sub PollConfig{
	my ($self) = @_;
	my ($pppoe_login,$model,$mac,$fwversion,$sn,$response,$request,$auth,$SecInd);
	my $cookie_jar = HTTP::Cookies->new(ignore_discard => 1);
	$self->_prepare;
	for my $c (@{$self->Credentials}){
		$auth = encode_base64($c->[0].":".$c->[1]);
		$self->{_UA}->cookie_jar($cookie_jar);
		$request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:language=en_us&var:menu=status&var:page=system_msg", $self->{_BaseURL}));
		$request->header('Cookie' => 'sessionid="1"; auth=nok;');
		$request->header('Authorization' => "Basic ".$auth);
		$response = $self->HTTPRequest($request);
		#warn $response->content;
		next if(!defined($response) || $response->code != 200);
		last;
	}
	$request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:language=en_us&var:menu=status&var:page=system_msg", $self->{_BaseURL}));
	$request->header('Cookie' => 'sessionid="1"; auth=nok;');
	$request->header('Authorization' => "Basic ".$auth);
	#http://46.146.251.117:8080/cgi-bin/webproc?getpage=html/index.html&var:language=en_us&var:menu=status&var:page=system_msg
	$response = $self->HTTPRequest($request);
	for my $s (split ('\r?\n', $response->content)){
		if ($s =~ m/var G_SoftwareVersion[\s\t]+= "(.*?)";/){
			$fwversion = $1;
			$fwversion =~ s/\s$//;
		}elsif ($s =~ m/var G_LanMac[\s\t]+= "(.*?)";/){
			$mac = lc($1);
		}elsif ($s =~ m/var G_SerialNumber[\s\t]+= "(.*?)";/){
			$sn = $1;
		}
	}


	$request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:menu=setup&var:page=connected&var:menuwan=1", $self->{_BaseURL}));
	$request->header('Cookie' => 'sessionid="1"; auth=nok;');
	$request->header('Authorization' => "Basic ".$auth);
	$response = $self->HTTPRequest($request);
	return if(!defined($response) || $response->code != 200);
	for my $s (split ('\r?\n', $response->content)){
		if ($s =~ m/var G_DefaultRouter[\s\t]+= "(.*?)";/){
			my $default_router = $1;
			$default_router =~ m/WANConnectionDevice\.(.*?)\.WANPPPConnection/;
			$SecInd = $1;
		}
	}
	$request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&errorpage=html/index.html&var:language=en_us&var:menu=setup&var:page=connected&var:subpage=wanadsl&var:SecIndex=%d&var:ThdIndex=1&var:WanType=PPP&var:isAcFromLan=0", $self->{_BaseURL}, $SecInd));
	$request->header('Cookie' => 'sessionid="1"; auth=nok;');
	$request->header('Authorization' => "Basic ".$auth);
	$response = $self->HTTPRequest($request);
	return if(!defined($response) || $response->code != 200);
	for my $s (split ('\r?\n', $response->content)){
		if ($s =~ m/G_WanConns\['Username'\][\s\t]+= "(.*?)";/){
			$pppoe_login = $1;
		}
	}
	#warn $mac;
	#warn $pppoe_login;
	if(!defined($mac)||!defined($pppoe_login)){
		$self->errmsg('zte: unrecognized parameters');
		return;
    }
	$mac =~ s/://g;
	$bit=hex $mac;
	#warn $bit;
	$bit++;
	$mac=sprintf("%x", $bit);
	#warn $bit;
	
	#warn $mac;
	return {
		modelname => 'ZTE H118N',
		sn => $sn,
		fwversion => $fwversion,
		mac => $mac,
		pppoe_login => $pppoe_login,
    };
}

sub PollConfig {
	my ($self) = @_;
	my %cfg;
	my %vservers =(
		'G_PortMapping[m][1]' => 'name',
		'G_PortMapping[m][3]' => 'proto',
		'G_PortMapping[m][7]' => 'ipd',
		'G_PortMapping[m][6]' => 'ports_begin',
		'G_PortMapping[m][4]' => 'portd_begin',
	);
	my %beacons =(
		'WPA' => 'WPA',
		'11i' => 'WPA2',
		'WPAand11i' => 'WPA/WPA2',
	);
	my ($response,$request,$auth,$ssid,$key);
	my $cookie_jar = HTTP::Cookies->new(ignore_discard => 1);
	$self->_prepare;
	for my $c (@{$self->Credentials}){
		$auth = encode_base64($c->[0].":".$c->[1]);
		$self->{_UA}->cookie_jar($cookie_jar);
		$request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?var:ssidIndex=1&getpage=html/index.html&var:menu=wireless&var:page=multi_ssid&var:index=1&var:subpage=wireless_security", $self->{_BaseURL}));
		$request->header('Cookie' => 'sessionid="1"; auth=nok;');
		$request->header('Authorization' => "Basic ".$auth);
		$response = $self->HTTPRequest($request);
		next if(!defined($response) || $response->code != 200);
		last;
	}
	#G_BeaconType = (opt_id == 0 ? 'None' : opt_id == 1 ? 'Basic' : opt_id == 2 ? 'WPA' : opt_id == 3 ? '11i' : opt_id == 4 ? 'WPAand11i' :opt_id == 5 ? 'WPA' : opt_id == 6 ? 'lli' : 'WPAand11i') ;
	#warn $response->content;
	$request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?var:ssidIndex=1&getpage=html/index.html&var:menu=wireless&var:page=multi_ssid&var:index=1&var:subpage=wireless_security", $self->{_BaseURL}));
	$request->header('Cookie' => 'sessionid="1"; auth=nok;');
	$request->header('Authorization' => "Basic ".$auth);
	$response = $self->HTTPRequest($request);
	for my $s (split ('\r?\n', $response->content)){
		if ($s =~ m/var G_SSID[\s\t]+= "(.*?)";/){
			$cfg{"ssid"} = $1;
		}elsif ($s =~ m/var G_KeyPassphrase[\s\t]+= "(.*?)";/){
			$cfg{"wifi_key"} = $1;
		}elsif ($s =~ m/var G_WPAEncryptionModes[\s\t]+= "(.*?)";/){
			$cfg{"encryption"} = $1;
		}elsif ($s =~ m/var G_BeaconType[\s\t]+= "(.*?)";/){
			my $beacon = $1;
			$cfg{"WscAuth"} = $beacons{$beacon};
		}
	}
	  $request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:language=en_us&var:menu=wireless&var:page=wireless_setup", $self->{_BaseURL}));
        $request->header('Cookie' => 'sessionid="1"; auth=nok;');
        $request->header('Authorization' => "Basic ".$auth);
        $response = $self->HTTPRequest($request);
        #warn $response->content;
        for my $s (split ('\r?\n', $response->content)){
                if ($s=~m/var W_Channel="(.*?)";/){
                        $cfg{"channel"}=$1;
                }
        }
	if ($cfg{"channel"} eq 0 ){
		$cfg{"channel"}='auto';
	}
	$request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:menu=status&var:page=lan_clients", $self->{_BaseURL}));
	$request->header('Cookie' => 'sessionid="1"; auth=nok;');
	$request->header('Authorization' => "Basic ".$auth);
	$response = $self->HTTPRequest($request);
	for my $s (split ('\r?\n', $response->content)){
		if ($s =~ m/LanHosts\[m\]\[1\][\s\t]+=\s"(.*?)";/){
			$cfg{"lan_ip"} = $1;
		}
	}
	###########௨񪠢鱲󠫼 񥰢汮⬠౮Ɱ񠯮𲮢
	$request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:menu=advanced&var:page=napt_list", $self->{_BaseURL}));
	$request->header('Cookie' => 'sessionid="1"; auth=nok;');
	$request->header('Authorization' => "Basic ".$auth);
	$response = $self->HTTPRequest($request);
	#warn $response->content;
	my $vserver_state = 0;
	my $i = 1;
	for my $s (split ('\r?\n', $response->content)){
		if($s=~m/G_PortMapping\[m\][\s\t]+=\s\[\];/){
			$vserver_state = 1;
		}elsif(($vserver_state == 1)&&($s =~ m/(G_PortMapping\[m\]\[\d\])\s=\s"(.*?)";/)){
			my $param = $1;
			my $value = $2;
			if (exists $vservers{$param}){
				$cfg{"vserver".$i."_".$vservers{$param}} = $value;
			}
		}elsif(($vserver_state == 1)&&($s=~m/m\+\+/)){
			$i++;
		}
	}
	
	###########################################################
	
	if(!defined($cfg{"wifi_key"})){
		$self->errmsg('zte: unrecognized parameters');
		return;
    }
	return $cfg{"wifi_key"},{%cfg};
}

sub Configure {
	my ($self,%args) = @_;
	my ($response,$request,$conn,$proto,$portd,$ports,$ipd,$port_name);
	my $cookie_jar = HTTP::Cookies->new(ignore_discard => 1);
	$self->_prepare;
	for my $c (@{$self->Credentials}){
		$auth = encode_base64($c->[0].":".$c->[1]);
		$self->{_UA}->cookie_jar($cookie_jar);
		$request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc", $self->{_BaseURL}));
		$request->header('Cookie' => 'sessionid="1"; auth=nok;');
		$request->header('Authorization' => "Basic ".$auth);
		$response = $self->HTTPRequest($request);
		next if(!defined($response) || $response->code != 200);
		last;
	}
	$request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc", $self->{_BaseURL}));
	$request->header('Cookie' => 'sessionid="1"; auth=nok;');
	$request->header('Authorization' => "Basic ".$auth);
	$response = $self->HTTPRequest($request);

	$request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:language=en_us&var:menu=wireless&var:page=wireless_setup", $self->{_BaseURL}));
	$request->header('Authorization' => "Basic ".$auth);
        $response = $self->HTTPRequest($request);
#	warn $response->content;
	#  $request-new HTTP::Request(POST => sprintf("evice.X_TWSZ-COM_Radio.1.MaxBitRate=Auto&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.TransmitPower=100&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.RegulatoryDomain=RU&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.OperatingChannelBandwidth=0&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.GuardInterval=1", $self->{_BaseURL}));
	#warn $response->content;
	my $channel;
	my $mode;
	for my $s (split ('\r?\n', $response->content)){
		if ($s=~m/var\s+W_Channel="(.*?)";/){
			$channel=$1;
		}elsif ($s=~m/var\s+W_Standard="(.*?)";/){
			$mode=$1;
		}
	}
#	warn $channel;
#	warn $mode;
	#если подается канал то не трогаем мод и наоборот.
	if (defined $args{'new_channel'}){
        my $new_channel=$args{'new_channel'};
	warn "channe";
	$request = new HTTP::Request(POST => sprintf("%scgi-bin/webproc",  $self->{_BaseURL}), ['Content-Type' => 'application/x-www-form-urlencoded'], "%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.Enable=1&var%3Amenu=wireless&var%3Apage=wireless_setup&getpage=html%2Findex.html&errorpage=html%2Findex.html&obj-action=set&var%3Aerrorpage=wireless_setup&var%3ACacheLastData=U0VMRUNUX1N0YW5kYXJkPWJnbnxTRUxFQ1RfQmFuZHdpZHRoPTB8U0VMRUNUX1NwZWVkPUF1dG98U0VMRUNUX1Bvd2VyPTEwMHxTRUxFQ1RfQ3VycmVudENvdW50cnk9UlV8U0VMRUNUX0NoYW5uZWw9MHxJTlBVVF9FbmFibGU9dHJ1ZXxJTlBVVF9FbmFibGVfc2hvcnRHST10cnVl&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.Enable=1&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.Channel=$new_channel&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.AutoChannelEnable=1&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.Standard=$mode&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.MaxBitRate=Auto&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.TransmitPower=100&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.RegulatoryDomain=RU&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.OperatingChannelBandwidth=0&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.GuardInterval=1");	
	$request->header('Authorization' => "Basic ".$auth);
	warn $request->as_string;
       $response = $self->HTTPRequest($request);
	if ($response->code==200){
	return 1;
	}else{
	return 0;
	}
	}
	
if (defined $args{'upgrade_url'}){
	

	$request = new HTTP::Request(GET =>sprintf("%scgi-bin/webproc?getpage=html/index.html&var:language=en_us&var:menu=advanced&var:page=remote_access_ctrl", $self->{_BaseURL}));
$request->header('Cookie' => 'sessionid="1"; auth=nok;');
$request->header('Authorization' => "Basic ".$auth);
$response = $self->HTTPRequest($request);
my $number;
for my $i (split '\r?\n', $response->as_string){
	if ($i =~ m/G_Path\[t\] = "InternetGatewayDevice\./){
		$i =~ m/"(\d+),"\+\s"\d+";$/;
		$number = $1;
	}

}
#warn $number;	
$response->as_string =~ m/G_Path[t] = "InternetGatewayDevice\.WANDevice/;
#warn "http auth ok $number";

#warn $response->content;
$ip=$self->{_BaseURL};
#warn $ip;
my @ip=split ('/',$ip);
#warn $ip[2];
$ip[2]=~s/:\d+//g;
#warn $ip[2];
#warn $response->content;
$request = new HTTP::Request(POST => sprintf("%scgi-bin/webproc",  $self->{_BaseURL}), ['Content-Type' => 'application/x-www-form-urlencoded'], "%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACLEnable=1&var%3Amenu=advanced&var%3Apage=remote_access_ctrl&getpage=html%2Findex.html&errorpage=html%2Findex.html&obj-action=set&var%3ApathIndex=0&var%3AselectedIndex=0&var%3Aerrorpage=remote_access_ctrl&var%3ACacheLastData=U0VMRUNUX0Nvbm5MaXN0PUludGVybmV0R2F0ZXdheURldmljZS5XQU5EZXZpY2UuMS5XQU5Db25uZWN0aW9uRGV2aWNlLjMuV0FOUFBQQ29ubmVjdGlvbi4xfEVuYWJsZV8wPXRydWV8SVBfMD0wLjAuMC4wfE1hc2tfMD0yNTUuMjU1LjI1NS4yNTV8RW5hYmxlXzE9ZmFsc2V8SVBfMT0wLjAuMC4wfE1hc2tfMT0yNTUuMjU1LjI1NS4yNTV8RXh0UG9ydF8xPTgwODB8RW5hYmxlXzI9dHJ1ZXxJUF8yPTAuMC4wLjB8TWFza18yPTI1NS4yNTUuMjU1LjI1NXxFeHRQb3J0XzI9MjN8RW5hYmxlXzM9ZmFsc2V8SVBfMz0wLjAuMC4wfE1hc2tfMz0yNTUuMjU1LjI1NS4yNTV8RXh0UG9ydF8zPTIy&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.1.Enable=1&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.1.SrcIP=0.0.0.0&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.1.EndSrcIP=255.255.255.255&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.1.ExternalPort=0&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.2.Enable=0&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.2.SrcIP=0.0.0.0&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.2.EndSrcIP=255.255.255.255&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.2.ExternalPort=8080&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.3.Enable=1&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.3.SrcIP=212.33.0.0&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.3.EndSrcIP=212.33.255.255&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.3.ExternalPort=23&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.4.Enable=0&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.4.SrcIP=0.0.0.0&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.4.EndSrcIP=255.255.255.255&%3AInternetGatewayDevice.X_TWSZ-COM_ACL.RACL.$number.Service.4.ExternalPort=22");
$request->header('Authorization' => "Basic ".$auth);
$response = $self->HTTPRequest($request);
$t = Net::Telnet->new( Timeout=>5, Errmode => "return");
$t->open(Host=>"$ip[2]");
$t->waitfor(String=>'login:');
$t->print("admin");
$t->waitfor(String=>'Password:');
#$t->print($MODELS{'ZXHN H218N'}->{'http_passw'}->{'admin'});
$t->print("H*27nG46Lm"); 
$t->waitfor(String=>'#');
@ps = $t->cmd(String=>'cat /proc/mtd');
my $size;
my $name;
my $file_name;
foreach $i (@ps){
	if ($i =~ m/mtd\d:\s(.*?)\s/){
		my $hex_number = hex("0x".$1);
		$size+=$hex_number;
	}
}
warn $size;
my $url16 = '/var/www/provisioning.ertelecom.ru/data/firmwares/zte118/ZXHN_H118NV2.2.3i_EH4_RU4.img';
my $url8 = '/var/www/provisioning.ertelecom.ru/data/firmwares/zte118/ZXHN_H118NV2.1.3i_EH4_RU4.bin';
my $name8='ZXHN_H118NV2.1.3i_EH4_RU4.bin';
my $name16='ZXHN_H118NV2.2.3i_EH4_RU4.img';
my $name;
if (defined $size){ 
if($size > 9000000){
	$url = $url16;
	$name=$name16;
	warn $url
}else{
	#print (FILE "$id : $ip : $login \n");
	if($server_address !~ /cpe\.domru\.ru\/wifi\/h118n\/single/){
		$url = $url8;
		$name=$name8;
		warn $url;
	#	print (FILE "$id : $ip : $login \n");
		exit;

	}else{
		warn "Image url is right";
		#exit;
	}
}

# накатываем файл без автообновления. 
#warn "1";
$request = new HTTP::Request(POST => sprintf("%scgi-bin/webupg",  $self->{_BaseURL}), ['Content-Type' => 'application/x-www-form-urlencoded']);
my @rand = ('0'..'9');
        for (0..14) {$boundary .= $rand[rand(@rand)];}

 open (my $fh, "<$url");
        binmode($fh);
#       my $size = (stat $file)[7];

my %request_params =(
	'btn' => 'Upgrade',
); 
my $header = HTTP::Headers->new;
	
        $request->header('Content-Type' => 'multipart/form-data; boundary='.$boundary);
        $header->header('Content-Disposition' => 'form-data; name="firmware"; filename="$name"');
$request->header('Accept-Language' => 'ru-ru,ru;q=0.8,en-us;q=0.5,en;q=0.3');
        $request->header('Accept-Encoding' => 'gzip, deflate');
        $request->header('Accept-Charset' => 'windows-1251,utf-8;q=0.7,*;q=0.8');
        $request->header('Connection' => 'keep-alive');
	$request->header('Authorization' => "Basic ".$auth);
      
  my $file_content = HTTP::Message->new($header);
        $file_content->add_content($_) while <$fh>;
        $file_content->add_content($config);
        $request->add_part($file_content);
        close $fh;
for my $key (keys %request_params){
	my $field = HTTP::Message->new(
									[
										'Content-Disposition'   => "form-data; name=\"firmware\"; filename=\"$name\""
										#'Content-Type'          => 'text/plain; charset=utf-8',
										]); 
	$field->add_content_utf8($request_params{$key});
	$request->add_part($field);
}
	$response = $self->HTTPRequest($request);
#warn $request->as_string;
$request = new HTTP::Request(POST => sprintf("%scgi-bin/webproc",  $self->{_BaseURL}), ['Content-Type' => 'application/x-www-form-urlencoded'],'%3AInternetGatewayDevice.X_TWSZ-COM_AutoUpg.Lan_Reboot=2222&getpage=html%2Fpage%2Fupgrading.html&errorpage=html%2Fpage%2Fupgrading.html&obj-action=set&var%3Amenu=management&var%3Apage=firmware&var%3Aerrorpage=firmware');

$request->header('Authorization' => "Basic ".$auth);
$response = $self->HTTPRequest($request);


return 1;
#}



#ecли $size не существует тогда ничего не делаем	
}
#warn "ne 1";
return 0;



	}



	 if (defined $args{'new_mode'}){
        my $new_mode=$args{'new_mode'};
        #mode принемает значение b, bg, bgn 
	warn "mode";
        $request = new HTTP::Request(POST => sprintf("%scgi-bin/webproc",  $self->{_BaseURL}), ['Content-Type' => 'application/x-www-form-urlencoded'], "%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.Enable=1&var%3Amenu=wireless&var%3Apage=wireless_setup&getpage=html%2Findex.html&errorpage=html%2Findex.html&obj-action=set&var%3Aerrorpage=wireless_setup&var%3ACacheLastData=U0VMRUNUX1N0YW5kYXJkPWJnbnxTRUxFQ1RfQmFuZHdpZHRoPTB8U0VMRUNUX1NwZWVkPUF1dG98U0VMRUNUX1Bvd2VyPTEwMHxTRUxFQ1RfQ3VycmVudENvdW50cnk9UlV8U0VMRUNUX0NoYW5uZWw9MHxJTlBVVF9FbmFibGU9dHJ1ZXxJTlBVVF9FbmFibGVfc2hvcnRHST10cnVl&%3AInternetGatewayDevice.LANDevice.1.WLANConfiguration.1.Enable=1&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.Channel=$channel&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.AutoChannelEnable=1&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.Standard=$new_mode&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.MaxBitRate=Auto&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.TransmitPower=100&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.RegulatoryDomain=RU&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.OperatingChannelBandwidth=0&%3AInternetGatewayDevice.X_TWSZ-COM_Radio.1.GuardInterval=1");
        $request->header('Authorization' => "Basic ".$auth);
        warn $request->as_string;
       $response = $self->HTTPRequest($request);
        if ($response->code==200){
        return 1;
        }else{
        return 0;
        }
        }

	
#добавить в смену канала не менять моде
# меняем мод не менять канал

	



	#o}
#________________________________________________________________________

	
	my $new_server = delete $args{new_vserver};
	my $del_server = delete $args{del_vserver};
	if((defined $new_server) || (defined $del_server)){
		local @LWP::Protocol::http::EXTRA_SOCK_OPTS = (
				SendTE => 0,
				KeepAlive => 1,
				SendClose => 0,
		);	
		$request = new HTTP::Request(GET => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:menu=advanced&var:page=napt_list", $self->{_BaseURL}));
		#$request->header('Cookie' => 'sessionid="1"; auth=nok;');
		$request->header('Authorization' => "Basic ".$auth);
		$response = $self->HTTPRequest($request);
		if(!defined($response) || $response->code != 200){
			$self->errmsg('Cant determine vservers list');
			return 0;
		}
		#麥족汢池, 鵠㡭鿠衴r069 ࡰ᭥򰻊		my %vservers;
		my $vserver_state = 0;
		my $name = '';
		my $tr = '';
		for my $s (split ('\r?\n', $response->content)){
			#G_WanConns[n][1] =
			if($s=~m/G_PortMapping\[m\][\s\t]+=\s\[\];/){
				$vserver_state = 1;
			}elsif($s=~m/G_WanConns\[n\]\[1\][\s\t]+= "(.*?)";/){
				$conn = $1;
			}elsif(($vserver_state == 1)&&($s =~ m/(?:G_PortMapping\[m\]\[1\])\s=\s"(.*?)";/)){
				$name = $1;
			}elsif(($vserver_state == 1)&&($s =~ m/(?:G_PortMapping\[m\]\[8\])\s=\s"(.*?)";/)){
				$tr = $1;
			}elsif(($vserver_state == 1)&&($s=~m/m\+\+/)){
				$vservers{$name} = $tr; 
			}
		}
		#while (@Res = each %vservers){
		#		warn "$Res[0] = $Res[1]\n";
		#}
		#寡ᣫ殨堭 'name':'120456','proto':'tcp','ports_begin':'456564','ports_end':'','portd_begin':'123654','portd_end':'','source_iface':'ppp0','ipd':'123654','remote_ip':''
		if (defined $new_server) {
			$new_server =~ m/'name':'(.*?)','proto':'(.*?)','ports_begin':'(.*?)','ports_end':'','portd_begin':'(.*?)','portd_end':'','source_iface':'ppp0','ipd':'(.*?)','remote_ip':''/;
			$proto = $2;
			$portd = $4;
			$ports = $3;
			$ipd = $5;
			$port_name = $1;
			if ($proto eq 'tcp/udp'){
				$proto = 'tcp';
			}
			my $cache = encode_base64("SELECT_Protocol=$proto|INPUT_Enable=true|INPUT_Description=$port_name|INPUT_RemoteHost=|INPUT_RemoteMask=|INPUT_ExternalPort=$ports|INPUT_ExternalPortEndRange=$ports|INPUT_InternalPort=$portd|INPUT_InternalClient=$ipd");
			$request = new HTTP::Request(POST => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:menu=advanced&var:page=napt_list", $self->{_BaseURL}), ['Content-Type' => 'application/x-www-form-urlencoded'],"add-obj=$conn.PortMapping.&%3APortMappingEnabled=1&%3APortMappingDescription=$port_name&%3ARemoteHost=&%3AX_TWSZ-COM_RemoteMask=&%3APortMappingProtocol=$proto&%3AExternalPort=$portd&%3AExternalPortEndRange=$portd&%3AInternalPort=$ports&%3AInternalClient=$ipd&obj-action=add-set&var%3Amenu=advanced&var%3Apage=napt_list&var%3AWanType=PPP&var%3AFstIndex=9&var%3ASecIndex=1&var%3AThdIndex=-&getpage=html%2Findex.html&errorpage=html%2Findex.html&var%3Aerrorpage=napt_port&var%3AwanEditable=$conn&var%3ACacheLastData=$cache");
			$request->header('Authorization' => "Basic ".$auth);
			$response = $self->HTTPRequest($request);
			return 1 if(!defined($response) || $response->code != 200);
		} else {
			#del-obj=InternetGatewayDevice.WANDevice.1.WANConnectionDevice.9.WANPPPConnection.1.PortMapping.3.&var%3Amenu=advanced&var%3Apage=napt_list&getpage=html%2Findex.html&errorpage=html%2Findex.html&obj-action=del
			$del_server =~ m/'name':'(.*?)','proto':'(.*?)','ports_begin':'(.*?)','ports_end':'','portd_begin':'(.*?)','portd_end':'','source_iface':'ppp0','ipd':'(.*?)','remote_ip':''/;
			$proto = $2;
			$portd = $4;
			$ports = $3;
			$ipd = $5;
			$port_name = $1;
			$request = new HTTP::Request(POST => sprintf("%scgi-bin/webproc?getpage=html/index.html&var:menu=advanced&var:page=napt_list", $self->{_BaseURL}), ['Content-Type' => 'application/x-www-form-urlencoded'],"del-obj=$vservers{$port_name}&var:menu=advanced&var:page=napt_list&getpage=html/index.html&errorpage=html/index.html&obj-action=del");
			$request->header('Authorization' => "Basic ".$auth);
			$response = $self->HTTPRequest($request);
			if($response->code == 500){
				return 1;
			}else{
				$self->errmsg('Cant configure cpe');
				return 0;
			};
			
		}

	}
	$self->errmsg('vservers parameters not defined');
	return 0;
}
1;

