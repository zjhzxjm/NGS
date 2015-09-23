#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Basename;
my %opt;

GetOptions(\%opt,"PP:s","PS:s","-ca:s");

my $usage = "
perl -PP -PS -SP -ca
-PP	Pair End output file with pair 	(-o)
-PS	Pair End output file without pair (-2)
-ca	Gene Abundance
";

if (scalar keys %opt == 0){
print "$usage\n";
exit;
}
#
my $PP;
my $PS;
my $SP;
my $ca;
#
&CH;
############
my %INF;
############
&Read($PP,"P") if (exists $opt{"PP"});
&Read($PS,"S") if (exists $opt{"PS"});
############
&OUTPUT_CA;
############
sub CH{
	if (exists $opt{"PP"}){
	$PP = $opt{"PP"};
	}
        if (exists $opt{"PS"}){
        $PS = $opt{"PS"};
        }
        if (exists $opt{"ca"}){
        $ca = $opt{"ca"};
	open CA,">$ca" or die;
        }
}
#
sub Read{
  my $file = $_[0];
  chomp (my $gz=`file $file`);
  if($gz=~/gzip/){
    open IN,"gzip -cd $file|" or die;
  }else{
    open IN,"$file" || die $!
  };
  while (<IN>){
    chomp;
    my @array = split /\t/;
    my $reads = $array[0];
    my $copy = $array[3];
    my $tag = $_[1];
    my $value;
    $value = "$array[7]\t$copy\t$tag" if $tag eq "P";
    $value = "$array[7]\t$copy\t$tag\t$array[8]\t$array[4]" if $tag eq "S";
    if (exists $INF{$reads}){
      unless ($INF{$reads} =~ "$value"){
        $INF{$reads} = "$INF{$reads}\n$value";
      }
    }else{
      $INF{$reads} = $value;
    }
  }
  close (IN);
}
#
sub OUTPUT_CA{
	foreach my $m (keys %INF){
	print CA ">$m\n$INF{$m}\n";
	}
}
