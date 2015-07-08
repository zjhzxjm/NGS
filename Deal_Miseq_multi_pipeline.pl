#!/usr/bin/perl 

use strict;
use Getopt::Long;

my ($configFile)="Deal_Miseq_multi.config";
GetOptions(
		'config=s' => \$configFile
		);

my(%config)=getConfigHashTable($configFile);

our($Sample_info_file)=$config{"Sample_info"};
our($work_dir)=$config{"Work_dir"};


print "
$Sample_info_file
\n"; #test !!!

sub getConfigHashTable{
	my($configFile)=$_[0];
	my(%configHashTable);
	my(@tmp);
	my($x);
	open(CON,"<$configFile");
	while($x=<CON>){
		chomp($x);
		if($x !~ /^#/){
			@tmp=split("\t",$x);
			$configHashTable{$tmp[0]}=$tmp[1];
		}
	}

	close(CON);
#foreach $x (keys(%configHashTable)) {print $x."\n";} # test !!!
	return(%configHashTable);
}

sub checkFolder{
        my($folder)=$_[0];
        if( -e $folder){
                print "$folder already exist! Rename the existed folder or rename the new sample!\n";
                exit 1; # the project folder already exist, exit with error
        }
        else{
                return 1;# pass check successfully
        }
}

sub makeDir{
	my $base = $_[0];

	mkdir("$base/",0755);
}

sub runSplitBarcode{
	print "runSplitBarcode start at".scalar localtime()."\n";
	chdir($workDir)
}
