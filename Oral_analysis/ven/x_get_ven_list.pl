#!/usr/perl -w
use strict;
use Getopt::Long;
my ($log,$names);
GetOptions(
	"log:s"=>\$log,
	"names:s"=>\$names,
);
$log && $names || die "perl $0 --log log_file --names names1,names2,names3";
my %hash;
my @project=split /\,/,$names;
my $file;
for $file(@project){
	open IN,"$file";
	while(<IN>){
		chomp;
		$hash{$file}->{$_}=1;
	}
}
open Merge,"$log" or die $!;
<Merge>;
while(<Merge>)
{
    chomp;
    my %hs_cluster=();
    my @tmps1=split /\s+/;
    my $tmps1=@tmps1;#gene num+1
    $hs_cluster{$tmps1[1]}=1;#represent gene
    
    if( $tmps1 > 2)	# cluster has two gene
    {
        my @tmps2=split /\,/,$tmps1[2];
        my $tmps2=@tmps2;
        for(my $i=0;$i< $tmps2 ;$i++)
        {
            $hs_cluster{$tmps2[$i]}=1;#put follow gene in it
        }
        my $rep = $tmps1[1];#represent gene
	    foreach my $key(keys %hs_cluster)
	    {
		for my $file( keys  %hash){
			$hash{$file}->{$key} || next; 
				delete $hash{$file}->{$key};
				$hash{$file}->{$rep}=1;
		}
	    }   
    }
}
close Merge or die $!;
for $file(@project){
	open FILE,">$file.id";
	for my $key(keys %{$hash{$file}}){
		print FILE "$key\n";
	}
}
