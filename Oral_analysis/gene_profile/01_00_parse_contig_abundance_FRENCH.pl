#!/usr/bin/perl -w
use strict;
die "perl $0 <Reference_Gene_Set> <CTG_ANIMDACE> <OT> <LOG> <DUSKO>
DUSKO\tuse french profiling method
" unless @ARGV >= 4;
my %gene_length;
$/ = ">";
open IN,"$ARGV[0]" or die;
<IN>;
while (<IN>){
  chomp;
  my @array = split /\n/;
  my $query = shift @array;
  my $sequence = join ("",@array);
  $gene_length{$query} = length $sequence;
}
close (IN);
$/ = "\n";

my $reads_PE;
my $reads_SE_But_still_PE;

my $reads_unqiue_gene;
my $reads_multiple_gene;

my %MUL;

my %gene;

my %gene_abundance_unique;
my %gene_abundance_multiple;
$/ = ">";
open CTG,"$ARGV[1]" or die;
while (<CTG>){
chomp;
my @A = split /\n/;
my $Q = shift @A;
	if (defined $Q){
	my $J = "NULL";
	my $num = 0;
	my @pool;
		foreach my $m (@A){
		my @chot = split /\t/,$m;
		my $tag = $chot[2];
		my $gene = $chot[0];
		my $Length = $gene_length{$gene};
			if ($tag eq "P"){
			$J = "P";
			$gene{$gene} ++;
			$num ++;
			push (@pool,$gene);
			}
			else{
			my $MAX = $chot[3] + 800;
				if ($MAX >= $Length){ #test for 800
				$num ++;
				$J = "S";
				$gene{$gene} ++;
				push (@pool,$gene);
				}
			}
		}

	unless ($J eq "NULL"){
	if ($num == 1){
		if (scalar @pool > 1){
		print "$Q has multiple genes or unqiue?\n"; # a monitor
		die;
		}
	$reads_unqiue_gene ++;
	if (exists $gene_length{$pool[0]}){
	$gene_abundance_unique{$pool[0]} += 1 / $gene_length{$pool[0]};
	}
	}
	elsif ($num > 1){
	$reads_multiple_gene ++;
	$MUL{$Q} = join ("\t",@pool);
	}

	if ($J eq "P"){
	$reads_PE ++;
	}
	elsif ($J eq "S"){
	$reads_SE_But_still_PE ++;
	}
	
	}

	}
}
close (CTG);
$/ = "\n";

if( ( defined $ARGV[4]) and ($ARGV[4] eq "Dusko") ){

	foreach my $mm (keys %MUL){
	my @GENE = split /\t/,$MUL{$mm};
	my $sum = 0;
	
		foreach my $n (@GENE){
		$sum += $gene_abundance_unique{$n} if exists $gene_abundance_unique{$n};
		}

		if ($sum > 0){
			foreach my $o (@GENE){
			my $ratio = 0;
			   $ratio = $gene_abundance_unique{$o} if exists $gene_abundance_unique{$o};
				if (exists $gene_length{$o}){
				$gene_abundance_multiple{$o} += $ratio / $sum / $gene_length{$o};
				}
			}
		}
	}

&OT;

}
else{
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

	foreach my $gene (keys %gene){
	my $unique = 0;
	my $multip = 0;
	   $unique = $gene_abundance_unique{$gene} if exists $gene_abundance_unique{$gene};
	   $multip = $gene_abundance_multiple{$gene} if exists $gene_abundance_multiple{$gene};
	print OT "$gene\t$unique\t$multip\n" unless ( ($unique == 0) && ($multip == 0) );
		if ( ($unique == 0)) {
		 	if ( (defined $ARGV[4])){
				if ($multip > 0) {
				print "$gene is weired cause its abundance\n";
				die;
				}
				else{
				$gene_multi ++;
				}
			}

			else{
			$gene_multi ++;
			}
		}
		elsif ($unique > 0){
			if ($multip > 0){
			$gene_unique_multi ++;
			}
			else{
			$gene_unique ++;
			}
		}
	}

print LOG "$gene_unique\t$gene_unique_multi\t$gene_multi\n"; 
}
