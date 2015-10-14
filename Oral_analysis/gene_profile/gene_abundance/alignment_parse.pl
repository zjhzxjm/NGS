####################################
#!/usr/bin/perl -w
use strict;
die "perl $0 <SOAP_LIST> <OT>" unless (@ARGV == 2); 

my %pe;
my %se;
open IN,"$ARGV[0]" or die;
while (<IN>){
	chomp;
	my @array = split /\t/;
	if ($array[0] eq "PE"){
		$pe{$array[1]} = 1;
	}else{
		$se{$array[1]} = 1;
	}
}
close IN;

open OT,">$ARGV[1]" or die;
my %INF;
&READ_PE;
&READ_SE;
foreach my $match (keys %INF){
	print OT ">$match\n$INF{$match}\n";
}
###################################
sub READ_PE{
	foreach my $match (keys %pe){
		open IN,"$match" or die;
		my @Match = split /\.|\-/,$match;
		my $string = $Match[-2];
		while (<IN>){
			chomp;
			my @array = split /\t/;
			if ($array[4] eq "b"){
				next;
			}
			my $query = $array[0];
			$query =~ s/\/[12]$//g;
			my $length = $array[5];
			my $sign = $array[6];
			my $refer = $array[7];
			my $pos = $array[8];
			my $value = "$refer\tP\t$string\t$length\t$sign\t$pos";
			if (exists $INF{$query}){
				$INF{$query} = "$value\n$INF{$query}";
			}else{
				$INF{$query} = $value;
			}
		}
		close IN;
	}
}
#################################
sub READ_SE{
	foreach my $match (keys %se){
		open IN,"$match" or die;
		my @Match = split /\.|\-/,$match;
		my $string = $Match[-2];
		while (<IN>){
			chomp;
			my @array = split /\t/;
			my $query = $array[0];
			$query =~ s/\/[12]$//g;
			my $length = $array[5];
			my $sign = $array[6];
			my $refer = $array[7];
			my $pos = $array[8];
			my $value = "$refer\tS\t$string\t$length\t$sign\t$pos";
			if (exists $INF{$query}){
				$INF{$query} = "$value\n$INF{$query}";
			}else{
				$INF{$query} = $value;
			}
		}
	}
}
