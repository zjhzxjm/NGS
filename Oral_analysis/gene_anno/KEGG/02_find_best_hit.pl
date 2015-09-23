#!/usr/bin/perl

use strict;
use warnings;

die "$0 <blast_result.list> <output_blast_table>" unless @ARGV == 2;

my %gene_reference;
my %gene_score;
my %gene_p_value;
my %identity;
my %best_line;
open BLAST, "$ARGV[0]" or die "\n\ncan't open blast result list!\n\n";
while(<BLAST>){
    chomp;
    open BLAST_TABLE, "$_" or die "\n\ncan't open file $_\n\n";
    while(my $one_line = <BLAST_TABLE>){
        chomp;
        my @line = split /\t/, $one_line;
	my $tag=0;
	for my $tmp(0..11){
	defined $line[$tmp] || do {$tag=1;last;};
	}
	$tag==1 && do {print "$_\t$one_line\n";next;};
        if( $line[-1] >= 60 and $line[-2] <= 1e-5){
            if(exists $gene_reference{$line[0]}){
                if($gene_score{$line[0]} < $line[-1]){
                    $gene_reference{$line[0]} = $line[1];
                    $gene_score{$line[0]} = $line[-1];
                    $gene_p_value{$line[0]} = $line[-2];
                    $identity{$line[0]} = $line[2];
                    $best_line{$line[0]} = $one_line;
                }elsif($gene_score{$line[0]} == $line[-1] and $line[-2] < $gene_p_value{$line[0]} ){
                    $gene_reference{$line[0]} = $line[1];
                    $gene_score{$line[0]} = $line[-1];
                    $gene_p_value{$line[0]} = $line[-2];
                    $identity{$line[0]} = $line[2];
                    $best_line{$line[0]} = $one_line;
                }elsif($gene_score{$line[0]} == $line[-1] and $line[-2] == $gene_p_value{$line[0]}){
                    unless( $gene_reference{$line[0]} eq $line[1] ){
                        if( $identity{$line[0]} < $line[2]){
                            $gene_reference{$line[0]} = $line[1];
                            #$gene_score{$line[0]} = $line[-1];
                            #$gene_p_value{$line[0]} = $line[-2];
                            $identity{$line[0]} = $line[2];
                            $best_line{$line[0]} = $one_line;
                        }elsif($identity{$line[0]} < $line[2]){
                            print "\n\nbe careful, gene $line[0] might have two best hits with references $gene_reference{$line[0]} and $line[1]\n\n";
                    
                        }
                    }
                }
            }else{
                $gene_reference{$line[0]} = $line[1];
                $gene_score{$line[0]} = $line[-1];
                $gene_p_value{$line[0]} = $line[-2];
                $identity{$line[0]} = $line[2];
                $best_line{$line[0]} = $one_line;
            }
        }
    }
}

open OUTPUT, ">$ARGV[1]" or die "\n\ncan't open $ARGV[1]\n\n";
for my $key ( keys %best_line ){
	print OUTPUT $best_line{$key};
}
