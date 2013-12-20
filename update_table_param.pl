#!/usr/bin/perl

use Data::Dumper;
#use warnings;
#use strict;
use HTTP::Cookies;
use MIME::Base64;
use LWP::UserAgent;
use DBI;
use LWP::Authen::Digest;

my $DBCONN;	
my $DB_HOST;
my $DB_DB;
my $DB_USER;
my $DB_PASS;
init_params();
delete_from_match();
insert_match();
delete_from_count();
 insert_count();
insert_count_all();
#delete_from_value();
#insert_value();


sub insert_count{

        my $sth = $DBCONN->prepare("insert into p_otch_count_param (p_hostmodel_id, p_city_id, count) select '-1', '-1', count (distinct p_device_id) from p_actualconfig");
	my $rv = $sth->execute;
}

sub insert_count_all{
	
	foreach my $hostmodel_id(1..7,9,11..26){
		foreach my $city_id(1,2, 4..36,38){
		my @device;
	 my $sth = $DBCONN->prepare("select p_device_id from p_device where p_hostmodel_id=$hostmodel_id and p_city_id=$city_id");
	my $rv = $sth->execute;
	while (my @row=$sth->fetchrow_array){
              #warn  $row[0];
		 push (@device, $row[0]);
                }
	my $device=join(', ', @device);
	$device=~s/,$//;
	#warn $device;
	if ($device=~m/\d+/){
        my $sth = $DBCONN->prepare("insert into p_otch_count_param (p_hostmodel_id, p_city_id, count) select '$hostmodel_id', '$city_id', count (distinct p_device_id) from p_actualconfig where p_device_id in ($device)");
	my $rv = $sth->execute;
	}
}}
}
sub delete_from_count{
#       $city_id=$_[0];
        my $sth = $DBCONN->prepare("DELETE FROM p_otch_count_param");
        my $rv = $sth->execute;


}

sub delete_from_value{
#	$city_id=$_[0];
	my $sth = $DBCONN->prepare("DELETE FROM p_otch_value_count_param");
	my $rv = $sth->execute;


}


sub insert_value{

	my $sth = $DBCONN->prepare("
insert into p_otch_match_param (p_hostmodel_id, p_city_id, p_configparam_id, value, p_actualconfig_id, p_device_id, lastmodified, found) 
select p_device.p_hostmodel_id, p_device.p_city_id, p_actualconfig.p_configparam_id, p_actualconfig.value,  p_actualconfig.p_actualconfig_id, p_actualconfig.p_device_id,  p_actualconfig.lastmodified, p_actualconfig.found 
from p_actualconfig, p_device, p_otch_param where p_actualconfig.p_device_id=p_device.p_device_id and p_device.p_hostmodel_id=p_otch_param.p_hostmodel_id  and p_otch_param.p_configparam_id=p_actualconfig.p_configparam_id and p_otch_param.value=p_actualconfig.value
");
        my $rv = $sth->execute;
}

sub delete_from_match{
#	$city_id=$_[0];
	my $sth = $DBCONN->prepare("DELETE FROM p_otch_match_param");
	my $rv = $sth->execute;


}


sub insert_match{
	
	

	 my $sth = $DBCONN->prepare("
insert into p_otch_match_param (p_hostmodel_id, p_city_id, p_configparam_id, value, p_actualconfig_id, p_device_id, lastmodified, found) 
select p_device.p_hostmodel_id, p_device.p_city_id, p_actualconfig.p_configparam_id, p_actualconfig.value,  p_actualconfig.p_actualconfig_id, p_actualconfig.p_device_id,  p_actualconfig.lastmodified, p_actualconfig.found 
from p_actualconfig, p_device, p_otch_param where p_actualconfig.p_device_id=p_device.p_device_id and p_device.p_hostmodel_id=p_otch_param.p_hostmodel_id  and p_otch_param.p_configparam_id=p_actualconfig.p_configparam_id and p_otch_param.value=p_actualconfig.value
");
        my $rv = $sth->execute;
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
	#$DB_SERVICE_NAME='github;		 
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



