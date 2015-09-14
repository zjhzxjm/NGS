#!/usr/bin/perl -w
use strict;
die "perl $0 <RefGeneSet> <SAMPLE_LIST> <OT>" unless (@ARGV ==3);

my %length;
$/ = ">";
open REF,$ARGV[0] or die;
open OT,">$ARGV[2]" or die;
while (<REF>){
chomp;
my @array = split /\n/;
my $query = shift @array;
	if (defined $query){
	shift @array;
	my $length = length (join ("",@array) );
	$length{$query} = $length;
	}
}
$/ = "\n";

print "Length read\n";
######################
my %if;
my %sample;
my $i = 1;
open LIST,"$ARGV[1]" or die;
while (<LIST>){
chomp;
my ($sample,$profile) = split /\t/;
$sample{$i} = $sample;
$i ++;
	print OT "\t$sample";
	open AFL,"$profile" or die;
	while (<AFL>){
	chomp;
	my @chot = split /\t/;
	my $key = "$chot[0]\t$sample";
	$if{$key} = ($chot[1] + $chot[2]);
	}
	close (AFL);
	print "$sample read\n";
	
}
close (LIST);
print OT "\n";
######################

print "Cal begins\n";

my $L;

foreach my $m (keys %length){
print OT "$m";
$L = $length{$m};
my $initial = 1;
	while ($initial <= ( scalar (keys %sample) )){
	my $K = "$m\t$sample{$initial}";
		if (exists $if{$K}){
		my $ra = $if{$K};
		print OT "\t$ra";
		}
		else{
		print OT "\t0";
		}
	$initial ++;
	}
print OT "\n";
}
print "End\n";
