#!/usr/bin/perl -w
use Net::FTP;
use strict;


die "$0 <ftp_dir_str>" unless @ARGV==1;  

my $server="ftp-trace.ncbi.nlm.nih.gov";
my $user = "anonymous"; 
my $pw = ""; 
my $time=`date +"%Y-%m-%d %H:%M"`;

my $ftp = Net::FTP->new($server) ;
$ftp->login($user,$pw) ;
print "login ok! starting list files on $server $time...\n";
&list("$ARGV[0]");
print "list ok!  $time...\n";
$ftp->quit;

#*************************************************#
sub list()
{
	my $current = $_[0];
	my @subdirs;

	$ftp->cwd($current);
	my @allfiles = $ftp->ls();

	foreach (@allfiles){
		if(&find_type($_) eq "d"){
			push @subdirs,$_;
		}else{
			print $current."/$_\n";
			
		}
	}

	foreach (@subdirs){
		&list($current . "/" . $_);
	}
}

sub find_type{
	my $path = shift;
	my $pwd = $ftp->pwd;
	my $type = '-';
	if ($ftp->cwd($path)) {
		$ftp->cwd ($pwd);
		$type = 'd';
	}
	return $type;
}
