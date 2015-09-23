#!/usr/bin/perl -w
use strict;

die "perl $0 <IN> <OT> "unless @ARGV == 2;

open IN,"$ARGV[0]" or die;
open OT,">$ARGV[1]" or die;

my $head = <IN>;
print OT  "$head";
my @head = split /\t/,$head;
shift @head;
my $total = scalar @head;

my %SUM;
my $initial=0;
my $index;

while (<IN>){
chomp;
my @a = split /\t/;
my $V = shift @a;
	$initial = 1;
	while ($initial <= $total){
	$index = $initial - 1;
	$SUM{$initial} += $a[$index];
	$initial ++;
	}
}
close (IN);



open IN,"$ARGV[0]" or die;
<IN>;
while (<IN>){
chomp;
my @A = split /\t/;
my $v = shift @A;
print OT "$v";
	$initial = 1;
	while ($initial <= $total){
	$index = $initial - 1;
	my $SUM = $SUM{$initial};
	my $ratio = $A[$index] / $SUM;
	print OT "\t$ratio";
	$initial ++;
	}
print OT "\n";
}
