#!/usr/bin/perl -w
use Net::FTP;
use strict;


die "$0 <list_file>" unless @ARGV==1;  

my $server="ftp-trace.ncbi.nlm.nih.gov";
my $user = "anonymous"; 
my $pw = ""; 
my $time=`date +"%Y-%m-%d %H:%M"`;

my $ftp = Net::FTP->new($server) ;
$ftp->login($user,$pw) ;
print STDERR "login ok! starting list files on $server $time...\n";
open LIST,$ARGV[0] or die "cant open $ARGV[0]\n"; 
while(<LIST>){
	chomp;
	my $sub = substr($_,0,6);
	if(/^SRS/){
		&list("/sra/sra-instant/reads/BySample/sra/SRS/$sub/$_/");
	}
	elsif(/^SRP/)
	{
		&list("/sra/sra-instant/reads/ByStudy/sra/SRP/$sub/$_/");	
	}
	elsif(/^SRX/)
	{
		&list("/sra/sra-instant/reads/ByExp/sra/SRX/$sub/$_/");
	}
	else
	{
		print "other\n";
	}
}
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
			print $current."\t$_\n";
			
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
