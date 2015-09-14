#!/usr/bin/perl -w
use strict;
die "perl $0 <sample_list> <species_abundance> <OT>" unless (@ARGV == 3);


open OT,">$ARGV[2]" or die;

my %s;
my %INF;
my %GENUS;

open OA,"$ARGV[1]" or die;
while (<OA>){
chomp;
my @array = split /\/|\./;
my $Sample = $array[-2];
	open IN,"$_" or die;
	while (<IN>){
	chomp;
	my $a = $_;
	my @abundance = split /\t/,$a;	#species name
	my $key = "$abundance[0]\t$Sample";
	$GENUS{$abundance[0]} = 1;
	$INF{$key} = $abundance[-1];	#INF {species sample}= aboundance
	}
	close (IN);
}

my $m = 1;
open OB,"$ARGV[0]" or die;
while (<OB>){
chomp;
my $id=(split /\s+/)[0];##modify by lihang for sample list file format change	# $id = sample id
## print OT"\t$_";
$s{$id}=$id;
#$s{$m} = $id;## $s{$m}=$_;
#$m ++;
}
close (OB);
for my $id(keys %s){
	print OT "\t$id";
}
print OT "\n";
$m = 1;

foreach my $m (keys %GENUS){	#species name
print OT "$m";
	#foreach my $n (1..(scalar (keys %s) )){
	for my $n (keys %s){	#sample id
	#my $sample = $s{$n};
	#my $n = "$m\t$sample";
		$n="$m\t$n";
		if (exists $INF{$n}){
		print OT "\t$INF{$n}";
		}
		else{
		print OT "\t0";
		}
	}
print OT "\n";
}
