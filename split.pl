#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Cwd(qw 'abs_path');
my ($n,$in,$N,$outdir,$help);
GetOptions(
        "in:s"=>\$in,
        "split_n:s"=>\$N,
        "o:s"=>\$outdir,
        "help"=>\$help,
);
$help && &help;
$in || &help;
$outdir||="./";
$outdir=abs_path($outdir);
-s $outdir || mkdir $outdir,0755 || die $!;
$N||=10;
my $total_len;
my %hash;
open IN,"$in" || die $!;
$/=">";<IN>;
while(<IN>){
        chomp;
        my ($id,$seq)=split /\n/,$_,2;
        $seq=~s/\n//g;
        my $len=length $seq;
        $total_len+=$len;
        $hash{$id}=[$seq,$len];
}
my $aver_len=int ($total_len/$N);
my $now_len;
$n=1;
open OT,">$outdir/split.$n.fa" || die $!;
while(my ($id,$tmp)=each %hash){
        my ($seq,$len)=@{$tmp};
        $now_len+=$len;
        print OT ">$id\n$seq\n";
        $now_len >=$aver_len && do {
                $now_len=0;
                close OT;
                $n++;
                open OT,">$outdir/split.$n.fa" || die $!;
        }
}
sub help{
print "Usage: perl $0\n";
print <<USAGE;
        --in    <input_file>
        --split_n [split num]
        --o     [outdir]
        --help
USAGE
exit(0);
}
