#!/usr/bin/perl -w
use strict;
use Cwd(qw 'abs_path');
#open GI,"gi_list" ||die $!;
my $dir=abs_path $ARGV[0];
open GI_taxid,"$dir/gi_taxid_prot.dmp" ||die $!;#gi	tax_id
open NODES,"$dir/nodes.dmp" || die $!;   #tax_id	parent_id	rank
open NAMES,"$dir/names.dmp" || die $!;  #tar_id	discription
open MERGE,"$dir/merged.dmp" || die $!;	#modified tax_id
open OUT,">gi2tax.txt";

my %rank;
%rank=("species"=>1,
	"genus"=>1,
	"family"=>1,
	"class"=>1,
	"order"=>1,
	"phylum"=>1,
	"kingdom"=>1,
	"superkingdom"=>1,
	);


my %tax2name;
my %tax2rank;
my %merged;
my %gi2tax;
while(<NAMES>){
chomp;
s/\t//g;
my ($tax_id,$desc,$type)=(split /\|/)[0,1,3];
$type eq "scientific name" || next;
$tax2name{$tax_id}=$desc;
}
close NAMES;
while(<NODES>){
chomp;
s/\t//g;
	my ($tax_id,$parent_id,$rank)=(split /\|/)[0,1,2];
	$tax2rank{$tax_id}=[$parent_id,$rank];
}
close NODES;
while(<MERGE>){
	chomp;
	s/\t//g;
	my ($old,$new)=(split /\|/)[0,1];
	$merged{$old}=$new;
	
}

print "intial end";
while(<GI_taxid>){
	chomp;
	my $print;	
	$print.=" $.\t";
	my @taxonomy=("-","-","-","-","-","-","-","-"); #species genus family class order phylum kingdom superkingdom 
	my @tax_id=("-","-","-","-","-","-","-","-");
	my ($gi,$tax_id)=split /\t/;
	$tax_id || next;
	if (!defined $tax2rank{$tax_id}){
		$merged{$tax_id} || (print "$tax_id no tax\n" && next);
		$tax_id=$merged{$tax_id};
	}
	my $parent_id=$tax2rank{$tax_id}->[0];
	$parent_id || die "$tax_id parent";
	my $rank=$tax2rank{$tax_id}->[1]; 
	$rank ||die "$tax_id rank";
	$print.="$gi\t$tax_id\t";
	my $n=0;
	while($tax_id !=1){	#search rank to the root of life
		$n>100 &&  die "$gi\t$tax_id\n";
		if (defined $rank{$rank}){
			if ($rank eq "species"){$taxonomy[0]=$tax2name{$tax_id};$tax_id[0]=$tax_id;}
			elsif ($rank eq "genus" ) {$taxonomy[1]=$tax2name{$tax_id};$tax_id[1]=$tax_id;}
                	elsif($rank eq "family"){$taxonomy[2]=$tax2name{$tax_id};$tax_id[2]=$tax_id;}
                	elsif($rank eq "order"){$taxonomy[3]=$tax2name{$tax_id};$tax_id[3]=$tax_id;}
                	elsif($rank eq "class"){$taxonomy[4]=$tax2name{$tax_id};$tax_id[4]=$tax_id;}
                	elsif($rank eq "phylum"){$taxonomy[5]=$tax2name{$tax_id};$tax_id[5]=$tax_id;}
			elsif($rank eq "kingdom"){$taxonomy[6]=$tax2name{$tax_id};$tax_id[6]=$tax_id;}
                	elsif($rank eq "superkingdom"){$taxonomy[7]=$tax2name{$tax_id};$tax_id[7]=$tax_id;}
		}
		up_rank($tax_id,$parent_id,$rank);
		$n++;
	}
	$print.=join "\t",@taxonomy;
	$print.="\t";
	$print.=join "\t",@tax_id;
	$print.="\n";
	print OUT $print;	
}

print "\nend\n";

sub up_rank{
	$_[0]=$_[1];
	$_[1]=$tax2rank{$_[1]}->[0];
	$_[2]=$tax2rank{$_[0]}->[1];
}
