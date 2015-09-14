#!/usr/bin/perl -w
use strict;

die "perl $0 <SPECIES> <OT> <RANK> <W.tax>

RAMK
5	phylum
4	class
3	order
2	family
1	genus
0	species
" unless @ARGV == 4;

open TAX,"$ARGV[3]" or die;

my %tax;
my %super;

my $index =  0 -  $ARGV[2] - 2;
while (<TAX>){
chomp;
my @TAX = split /\t/;
my $species = $TAX[-2];
my $target = $TAX[$index];
   $super{$species} = $TAX[1];
	if (exists $tax{$species}){
		if ($tax{$species} eq $target){
		}
		else{
	#	print "$target\t$tax{$species}\n";
		#$tax{$species} = "$tax{$species}|$target";
		}
	}
	else{
	$tax{$species} = $target;
	}
}
close (TAX);

my %Z;
my %inf;
open S,"$ARGV[0]" or die;
open OT,">$ARGV[1]" or die;
my $head = <S>;
print OT "$head";
while (<S>){
my @array = split /\t/;
$array[0] || die $_;
$super{$array[0]}|| die $_;
	if ($super{$array[0]} eq "Bacteria"){
	my $genus = $tax{$array[0]};
	$Z{$genus} = 1;		#target
	$inf{$array[0]} = $_;   #aboudance
	}
}
close (S);

foreach my $m (keys %Z){
print OT "$m";
my %sum = ();
my $scalar;
	foreach my $n (keys %inf){
	my $j = $tax{$n};
		if ($j eq $m){
		my @CHOT = split /\t/,$inf{$n};
		shift @CHOT;
			foreach my $chot (0..(scalar @CHOT - 1)){
			$scalar = scalar @CHOT;
			$sum{$chot} += $CHOT[$chot];
			}
		}
	}

	foreach my $opq (0..($scalar -1 )){
	
	print OT "\t$sum{$opq}";
	}

print OT "\n";
}
