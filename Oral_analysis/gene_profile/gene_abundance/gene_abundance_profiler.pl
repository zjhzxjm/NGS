#!/usr/bin/perl -w
use strict;
die "perl $0 <Reference_Gene_Length> <Gene_Match> <OT> <LOG> <DUSKO> \nDUSKO\tuse french profiling method" unless @ARGV >= 4;
########################
## gene length
########################
my %gene_length;
open LENGTH,"$ARGV[0]" or die $!;
while (<LENGTH>){
	chomp;
	my ($gene,$length) = split /\t/;
	$gene_length{$gene} = $length;
}
close LENGTH;
########################
## abundance
########################
my $reads_unqiue_gene;
my $reads_multiple_gene;
my %MUL;
my %gene;
my %final_abundance;
my %gene_abundance_unique;
my %gene_abundance_multiple;
$/ = ">";
open MATCH,"$ARGV[1]" or die $!;
while (<MATCH>){
	chomp;
	@_ = split /\n/;
	my $read_id = shift @_;
	if (defined $read_id){
		my $J = "NULL";
		my $num = 0;
		my @pool;
		foreach my $match (@_){
			my @chot = split /\t/,$match;
			my $gene = $chot[0];
			my $tag = $chot[1];
			my $read_length = $chot[3];
			my $sign = $chot[4];
			my $pos = $chot[5];
			exists $gene_length{$gene} or die $gene;
			my $length = $gene_length{$gene};
			if (	($tag eq "P") or
				($sign eq "+" and $pos+800>=$length) or
				($sign eq "-" and $pos+$read_length-800<=0)){
					$num ++;
					$gene{$gene} = 1;
					push (@pool,$gene);
			}
		}
		if ($num == 1){
			if (scalar @pool > 1){
				die "$read_id has multiple genes or unqiue?\n"; # a monitor
			}
			$reads_unqiue_gene ++;
			if (exists $gene_length{$pool[0]}){
				$gene_abundance_unique{$pool[0]} += 1 / $gene_length{$pool[0]};
			}else {
				die "$pool[0]\n";
			}
		}elsif ($num > 1){
			$reads_multiple_gene ++;
			$MUL{$read_id} = join ("\t",@pool);
		}
	}
}
close MATCH;
$/ = "\n";

if( ( defined $ARGV[4]) and ($ARGV[4] eq "Dusko") ){
	foreach my $read_id (keys %MUL){
		my @gene = split /\t/,$MUL{$read_id};
		my $sum = 0;
		foreach my $gene (@gene){
			$sum += $gene_abundance_unique{$gene} if exists $gene_abundance_unique{$gene};
		}
		if ($sum > 0){
			foreach my $gene (@gene){
				my $ratio = 0;
				$ratio = $gene_abundance_unique{$gene} if exists $gene_abundance_unique{$gene};
				if (exists $gene_length{$gene}){
					$gene_abundance_multiple{$gene} += $ratio / $sum / $gene_length{$gene};
				}
			}
		}
	}
	&OT;
}else{
	die;
########################
## unrevised
########################
	foreach my $nn (keys %MUL){
		my @GENE_n = split /\t/,$MUL{$nn};
		my $S = scalar @GENE_n;
		foreach my $Gene_n (@GENE_n){
			$gene_abundance_multiple{$Gene_n} += ( 1 / (scalar @GENE_n) / $gene_length{$Gene_n} );
		}
	}
	&OT;
}

sub OT{
	open LOG,">$ARGV[3]" or die;
	open OT,">$ARGV[2]" or die;
	my $gene_unique = 0;
	my $gene_unique_multi = 0;
	my $gene_multi = 0;
	my $sum;
	foreach my $gene (keys %gene){
		my $unique = 0;
		my $multip = 0;
		$unique = $gene_abundance_unique{$gene} if exists $gene_abundance_unique{$gene};
		$multip = $gene_abundance_multiple{$gene} if exists $gene_abundance_multiple{$gene};
		$final_abundance{$gene} = $unique + $multip;
		$sum += $final_abundance{$gene};
#		print OT "$gene\t$unique\t$multip\n" unless ( ($unique == 0) && ($multip == 0) );
		if ( ($unique == 0)) {
		 	(defined $ARGV[4]) and ($multip > 0) and print "$gene is weired cause its abundance\n" and die;
			$gene_multi ++;
		}elsif ($unique > 0){
			if ($multip > 0){
				$gene_unique_multi ++;
			}
			else{
				$gene_unique ++;
			}
		}
	}
	foreach my $gene (keys %gene){
		next if ($final_abundance{$gene} == 0);
		$final_abundance{$gene} /= $sum; 
		print OT "$gene\t$final_abundance{$gene}\n";
	}
	print LOG "$gene_unique\t$gene_unique_multi\t$gene_multi\n"; 
}
