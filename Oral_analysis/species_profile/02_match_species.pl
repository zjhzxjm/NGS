#!/usr/bin/perl -w
use strict;
die "perl $0 <Input_MATCH> <OT> <LOG>" unless @ARGV == 3;

open IN,"$ARGV[0]" or die;
open OT,">$ARGV[1]" or die;
open LOG,">$ARGV[2]" or die;

my %SUPER;
my %TAX;
my %STRAINS;
my %LEN;

my %av_LENGTH;

open TAX,"/data_center_01/DNA_Data/data1/Database/NCBI_Bacteria/split/GENOME.TAX.TM7" or die;	#id and taxonomy information
while (<TAX>){
chomp;
my @tax = split /\t/;
$tax[1] eq "Bacteria" || next;
   $TAX{$tax[0]} = $tax[-2];#species information
   $STRAINS{$tax[0]} = $tax[-1];#strain  information
   $SUPER{$tax[0]} = $tax[1];   #Bacterial or Archaea
}
close (TAX);

open L,"/data_center_01/DNA_Data/data1/Database/NCBI_Bacteria/split/GENOME.LEN.TM7" or die;
while (<L>){
chomp;
my @length = split /\t/;
   $LEN{$length[0]} = $length[1]; #id and genome size information
}
close (L);


my %species_name;
my %Species_value_Unique;
my %Species_value_Multiple;

my $reads_unique_num = 0;
my $reads_multip_Unispecies_num = 0;
my $reads_multip_Mulspecies_num = 0;


my %READS_belong_Multiple_Species;

$/ = ">";
while (<IN>){
chomp;
my @array = split /\n/;		#record each match
my $query = shift @array;	#query_id	
	if (defined $query){
	my %species_tem = ();
	my %strains_tem = ();
	my %reads_gi = ();
		foreach my $m (@array){
		my @chot = split /\t/,$m;   # 302346166       P       filter_NCBI_Bacteria_3  a       100M    1
			#if ( ( ($chot[1] eq "P") && ($chot[3] eq "a") ) or ($chot[1] eq "S")  ){
			if  ( ($chot[1] eq "P") && ($chot[3] eq "a") ){
			# Skip Single and Pa;
			}
			else{
			my $Species_tem = $TAX{$chot[0]};	#spcies information
			my $Strains_tem = $STRAINS{$chot[0]};	#strain information
			
			 unless(exists $TAX{$chot[0]}){print "gi:$chot[0]\n"; next;}
			   $species_tem{$Species_tem} = 1;
			   $strains_tem{$Strains_tem} = 1;
			   $reads_gi{"G"} .= "$chot[0]\t";
			   $species_name{$Species_tem} = 1;
			}
		}

		if (scalar keys %species_tem == 1){
			if (scalar keys %strains_tem == 1){
			$reads_unique_num ++;
			}
			else{
			$reads_multip_Unispecies_num ++;
			}
		
		my @GI_pool = split /\t/,$reads_gi{"G"};

		my $LE = 0;
		my $total_LENGTH = 0;
		my $SS;
			foreach my $gi (@GI_pool){
			   $SS = $TAX{$gi};
			   $LE = 3.5e6;
			   $LE = $LEN{$gi} if exists $LEN{$gi};
		#	print "$query\t$gi\t$LE\n";
			$total_LENGTH += $LE;
			}
		my $UV;
		   $UV = $LE if scalar keys %strains_tem == 1;
		   $UV = $total_LENGTH / (scalar keys %strains_tem) if scalar keys %strains_tem >  1;	
		$av_LENGTH{$SS} = $UV;
			$Species_value_Unique{$SS} +=  1 / $UV;
	
		}
		elsif (scalar keys %species_tem > 1){
		$reads_multip_Mulspecies_num ++;
		my @pool = keys %species_tem;
		$READS_belong_Multiple_Species{$query} = join ("\t",@pool);
		}

	}
}
close (IN);


print LOG "$reads_unique_num\t$reads_multip_Unispecies_num\t$reads_multip_Mulspecies_num\n";


foreach my $q (keys %READS_belong_Multiple_Species){
			
my @SPECIES = split /\t/,$READS_belong_Multiple_Species{$q};
my $sum = 0;
	foreach my $SS (@SPECIES){
	$sum += $Species_value_Unique{$SS} if exists $Species_value_Unique{$SS};
	}
		
	if ($sum > 0){
		foreach my $Q (@SPECIES){
		my $coefficient = 0;
		   $coefficient = $Species_value_Unique{$Q} if (exists $Species_value_Unique{$Q});
		my $multiple_value = $coefficient / $sum / $av_LENGTH{$Q} if ($coefficient > 0);
		   $Species_value_Multiple{$Q} += $multiple_value if ($coefficient > 0);
		}
	}
}

foreach my $S_name (keys %species_name){
my $Unique_value = 0;
my $Multiple_value = 0;
   $Unique_value = $Species_value_Unique{$S_name} if exists $Species_value_Unique{$S_name};
   $Multiple_value = $Species_value_Multiple{$S_name} if exists $Species_value_Multiple{$S_name};
my $SSUM = $Unique_value + $Multiple_value;
print OT "$S_name\t$Unique_value\t$Multiple_value\t$SSUM\n" if $SSUM > 0;
}

