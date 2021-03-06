#!usr/bin/perl -w
die "perl $0 <A.blast4.anno> <fun.txt><output.blast.table>" unless(@ARGV==3);

my ($blast,$fun,$out)=@ARGV;

my %CLASS;
my %gene;
open IN,$fun || die "can not open $fun\n";
my $class;
while(<IN>){
        chomp;
        if($_!~/^\s*\[/){$class=$_;$class=~s/^\s*//;}
        else{
                if($_=~/^\s*\[(\w+)\]\s*(.*)/){
                        my $nog=$1;
                        my $name=$2;
                        $CLASS{$nog}{name}=$name;
                        $CLASS{$nog}{class}=$class;
                }
        }
}
close IN;

open IN,$blast || die "can not open $blast\n";
open OUT,">$out" || die "can not open $out\n";
while(<IN>){
	chomp;
	my @tab=split/\t/; 
	next if ($tab[14]=~m/NA/);
	my @class=split(/&/,$tab[14]);
        my @class1=split(//,join("",@class));
        foreach my $nog(@class1){$gene{$nog}.="$tab[0],";}  
}
my %count;
my %genelist;
my $sum;
foreach my $nog( keys %gene){
    my %gene_nodup;
    my @gene=split(/,/,$gene{$nog});foreach my $gene(@gene){$gene_nodup{$gene}=1;}
    foreach my $gene(keys %gene_nodup){$genelist{$nog}.="$gene,";}
    chop $genelist{$nog};
    my @genelist_nog=split(/,/,$genelist{$nog});
    $count{$nog}=scalar(@genelist_nog);
    $sum+=$count{$nog};
}   
foreach my $nog(sort{$CLASS{$a}{class} cmp $CLASS{$b}{class}} keys %gene){
    my $radio=$count{$nog}/$sum;
    print OUT "$CLASS{$nog}{class}\t $CLASS{$nog}{name}\t$nog\t $count{$nog}\t$radio\n"; 
}
close IN;
close OUT;
