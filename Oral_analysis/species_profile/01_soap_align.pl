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
	$pe{$array[1]} = 1;	#soap file name
	}
	else{
	$se{$array[1]} = 1;
	}
}
close (IN);

open OT,">$ARGV[1]" or die;

&READ_PE;
&READ_SE;
#
my %INF;
#
foreach my $m (keys %INF){
print OT ">$m\n$INF{$m}\n";
}
#
sub READ_PE{
foreach my $m (keys %pe){#match file
	chomp (my $type=`file $m`);
	if ($type=~/gzip/){
		open IN,"gzip -cd $m|" or die;
	}else{
    open IN,"$m" or die;
	}
	my @M = split /\.|\-/,$m;
	my $string = $M[-3];	#the second word from terminal # prefix of the file with absolute path
	while (<IN>){
	chomp;
	my @array = split /\t/;
	my $query = $array[0];
	$query=~s/\/1|\/2//;	# modify for reads from BGI
	my $refer = $array[7];
	my $flag = $array[4];
	my $value = "$refer\tP\t$string\t$flag\t$array[-2]\t$array[9]";
		if (exists $INF{$query}){
		$INF{$query} = "$value\n$INF{$query}";
		}
		else{
		$INF{$query} = $value;
		}
	}
	close (IN);
}
}
sub READ_SE{
foreach my $m (keys %se){
	open IN,"$m" or die;
	my @M = split /\.|\-/,$m;
	my $string = $M[-2];
	while (<IN>){
	chomp;
	my @array = split /\t/;
	my $query = $array[0];
	$query=~s/\/1|\/2//;
	my $refer = $array[7];
	my $flag = $array[4];
	my $value = "$refer\tS\t$string\t$flag\t$array[-2]\t$array[9]";
		if (exists $INF{$query}){
		$INF{$query} = "$value\n$INF{$query}";
		}
		else{
		$INF{$query} = $value;
		}
	}
}
}
