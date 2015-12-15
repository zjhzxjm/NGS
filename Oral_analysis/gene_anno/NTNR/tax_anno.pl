#!/usr/bin/perl -w
use strict;
my ($input,$output)=@ARGV;
open IN,"/data_center_02/Database/NCBI_TAX/20140515/nt/gi_tax_id_species";
my @a;
my @b;
while(<IN>){
	chomp;
	my ($gi,$species_id,$tax)= (split /\t/)[0,1,2];
	$a[$gi]=$species_id;
	$b[$species_id]=$tax;
}
my $l=0;my $m=0;my $n=0;
close IN;
open IN,"$input";
open OT,">$output";
while(<IN>){
	chomp;
	#my ($q,$t)=(split /\t/)[9,13];
	my ($q,$t)=(split /\t/)[0,1];
	$t=~/gi\|(\d+)\|/;
	my $gi=$1;
	$gi||do{print "$t\t-\n";next;};
	my $species_id=$a[$gi];
	$species_id || do{print "$t\t-\n";next;};
	my $tax;
	$species_id && do {$tax=$b[$species_id];};
	$tax||="-";
	print OT "$q\t$tax\n";
}
close IN;
close OT;
