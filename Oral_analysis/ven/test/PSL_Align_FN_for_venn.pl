#!/usr/bin/perl -w
use strict;
# Furthest neighbor clustring


die "perl $0 <PSL> <OT_LOG>" unless @ARGV == 2;
#
my %Sister;
my %LINK;
my %LEN;

my %Represent;
my %Follows;

open LOG,">$ARGV[1]" or die;
my $I = 0;
print LOG "cluster\tRepresent\tFollows\n";
&READ_PSL;
&MAKE_CLUSTER;
#&Find_ORPHAN;

sub READ_PSL{
open P,"$ARGV[0]" or die;
while (<P>){
chomp;
my @P = split /\s+/;
my $Match = $P[0];
my $Mismatch = $P[1];
my $gap = $P[5] + $P[7];
	unless ($P[9] eq $P[13]){
	if ($gap == 0){
	my $G1 = $P[9];
	my $G2 = $P[13];
	my $L1 = $P[10];
	my $L2 = $P[14];
	my $Big_G; my $Big_L;
	my $Sma_G; my $Sma_L;
		if ($L1 >= $L2){
		$Big_G = $G1; $Big_L = $L1;
		$Sma_G = $G2; $Sma_L = $L2;
		}
		else{
		$Big_G = $G2; $Big_L = $L2;
		$Sma_G = $G1; $Sma_L = $L1;
		}
print $Big_G,"\n";
	my $Identity = $Match / ($Match + $Mismatch);	
	my $Coverage = ($Match + $Mismatch) / $Sma_L;
		if ( ($Identity > 0.9) && ($Coverage > 0.95) ){
			if (exists $LINK{$Big_G}){
			$LINK{$Big_G} = "$LINK{$Big_G},$Sma_G";
			}
			else{
			$LINK{$Big_G} = $Sma_G;
			}
		$Sister{"$Big_G\t$Sma_G"} = 1;
		$Sister{"$Sma_G\t$Big_G"} = 1;
print "Store: $Big_G\t$Sma_G\n";
		$LEN{$G1} = $L1; $LEN{$G2} = $L2;
		}
#print $LINK{$Big_G},"\n";
	}
	}
}
close (P);
}
#
sub MAKE_CLUSTER{
	foreach my $m (sort {$LEN{$b} <=> $LEN{$a}} keys %LINK){
#print "$m\t$LINK{$m}\n";
		unless (exists $Follows{$m} ){
        #$Represent{$m} = 1;
		my @CLUSTER = split /\,/,$LINK{$m};
#print @CLUSTER,"\n";
		my %CLUSTER = ();
			foreach my $c (@CLUSTER){
			$CLUSTER{$c} = 1;
			}
		my @C_POOL = ();
#
			foreach my $n (sort {$LEN{$a} <=> $LEN{$b}} keys %CLUSTER){
			if ((exists $Follows{$n}) or (exists $Represent{$n})){
			}
			else{
			my $J = "T";
			my $K1 = $n;
print "1-$K1\t$CLUSTER{$K1}\n";
			delete $CLUSTER{$K1};
				foreach my $next (sort {$LEN{$b} <=> $LEN{$a}} keys %CLUSTER){
				my $K2 = $next;
				my $Key1 = "$K1\t$K2";
				my $Key2 = "$K2\t$K1";
print "\t2-key1:$Key1\tkey2:$Key2\n";
					if ( (exists $Sister{$Key1}) or (exists $Sister{$Key2}) ){
					$J = "T";
					}
					else{
					$J = "F";
#					last;
					}
				}
			#
				if ($J eq "T"){
				push (@C_POOL,$K1);
print "C_POOL:@C_POOL\t$K1\n";
#				$Follows{$K1} = 1;
				}
			}
			}
			if (scalar @C_POOL > 0){
			my %U = ();
				foreach my $u (@C_POOL){
				$U{$u} ++;
				$Follows{$u} = 1;
				}
			my $Followers = join ("\,",keys %U);
			print LOG "Cluster_$I\t$m\t$Followers\n";
			$Represent{$m} = 1;
			$I ++;
			}
		}
	}
}

sub Find_ORPHAN{
	$/ = ">";
	open FNA,">$ARGV[3]" or die;
	open CDS,"$ARGV[0]" or die;
	while (<CDS>){
	chomp;
	my @array = split /\n/;
	my $query = shift @array;
		if (defined $query){
		my $S = join ("\n",@array);
			if (exists $Represent{$query}){
				print FNA ">$query\n$S\n";
			}
			elsif (exists $Follows{$query}){
				
			}
			else{
				print LOG "Cluster_$I\t$query\n";
				print FNA ">$query\n$S\n";
				$I ++;
			}
		}
	}
	$/ = "\n";
}

