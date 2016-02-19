#!/usr/bin/perl -w
use strict;
use Getopt::Long;
my ($profile_tbl,$blast2nog,$prefix);
GetOptions(
	"profile:s"=>\$profile_tbl,
	"gene2nog:s"=>\$blast2nog,
	"prefix:s"=>\$prefix,
);
$profile_tbl && $blast2nog && $prefix || die "perl $0 --profile gent_profile --gene2nog gene2nog --prefix OutPrefix";
open IN,"$profile_tbl";
open TBL,"$blast2nog";
chomp (my $title=<IN>);
$title=~s/^\s+//;
$title=~s/\s+$//;
my @sample=split /\s+/,$title;
my %gene_profile;
while(<IN>){
	chomp;
	my @ab=split /\s+/;
	my $gene_id=shift @ab;
	for my $n(0..$#sample){
	$gene_profile{$gene_id}->[$n]=$ab[$n];
	}
}
my (%nog_profile,%nog_count,%class_profile,%class_count);
while(<TBL>){
	chomp;
	my ($gene_id,$nog,$class)=(split /\t/)[0,-3,-1];
#	$gene_profile{$gene_id} || die "$_";
	$gene_profile{$gene_id} || next;
	my @NOG=split /\&/,$nog;
	$class=~s/\&//g;
	my @class=split //,$class;
	my %count;
	my @uniq_class=grep { ++$count{ $_ } < 2; } @class;
	%count=();
	my @uniq_nog=grep {++$count{$_}<2;} @NOG;
	for my $n(0..$#sample){
		my $profile=$gene_profile{$gene_id}->[$n];
		$profile==0 && next;
		for my $nog(@uniq_nog){
			$nog eq "NA" && next;
			$nog_profile{$nog}->[$n]+=$profile;
			$nog_count{$nog}->[$n]++;
		}
		for my $class(@uniq_class){
			$class eq "NA" && next;
			$class_profile{$class}->[$n]+=$profile;
			$class_count{$class}->[$n]++;
		}
	}
}
open OT1,">$prefix.nog.profile";
open OT2,">$prefix.nog.count";
open OT3,">$prefix.class.profile";
open OT4,">$prefix.class.count";
print OT1 $title,"\n";
print OT2 $title,"\n";
print OT3 $title,"\n";
print OT4 $title,"\n";
while(my ($nog,$tmp)=each %nog_profile){
	print OT1 "$nog";
	for my $n(0..$#sample){
		$tmp->[$n]+=0;
		print OT1 "\t$tmp->[$n]";
	}
	print OT1 "\n";
}
while(my ($nog,$tmp)=each %nog_count){
	print OT2 "$nog";
	for my $n(0..$#sample) {
		$tmp->[$n]+=0;
		print OT2 "\t$tmp->[$n]";
	}
	print OT2 "\n";
}
while(my ($class,$tmp)=each %class_profile){
	print OT3 "$class";
	for my $n(0..$#sample){
		$tmp->[$n]+=0;
		print OT3 "\t$tmp->[$n]";
	}
	print OT3 "\n";
}
while(my ($class,$tmp)=each %class_count){
	print OT4 "$class";
	for my $n(0..$#sample){
		$tmp->[$n]+=0;
		print OT4 "\t$tmp->[$n]";
	}
	print OT4 "\n";
}

