#!/usr/bin/perl

use strict;

my $k; 
my $tcp_dump=system 'tcpdump -i any -vv -c 100 host st.perm.ertelecom.ru -l|tee tcpdump.log &';
sleep 2;
my $p=`iperf -c st.perm.ertelecom.ru -t1 `;
sleep 2;
open (my $fh, '<./tcpdump.log');
while (<$fh>){
        if ($_=~m/Flags \[S.\],/){
            if ($_=~m/\[mss\s+(.*?),/) {
                   $k=$1;
        }
}
}

print ("$k\n");
close ($fh);
