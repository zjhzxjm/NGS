#!/usr/bin/perl
use strict;

die "$0 <m8><profile.log.picked1><profile.nohead.log.picked2>" unless @ARGV == 3;

my (%prof1,%prof2);

open PROF1,"$ARGV[1]" or die "\n cant open $ARGV[1]\n";
while(<PROF1>){
	chomp;
	split;
	$prof1{$_[0]} = $_[-1];
}
close PROF1;

open PROF2,"$ARGV[2]" or die "\n cant open $ARGV[1]\n";
while(<PROF2>){
	chomp;
	split;
	$prof2{$_[0]} = $_[-1];
}
close PROF2;

open M8,"$ARGV[0]" or die "\n cant open $ARGV[0]\n";
open OUT,">$ARGV[0].annlog" or die "\n cant open $ARGV.log\n";
while(<M8>){
	chomp;
	split;
	next unless($prof1{$_[0]});
	next unless($prof2{$_[1]});
	next if($prof1{$_[0]}>-1);
	next if($prof2{$_[1]}>-2);
	print OUT "$_\t$prof1{$_[0]}\t$prof2{$_[1]}\n";
}
close M8;
close OUT;
