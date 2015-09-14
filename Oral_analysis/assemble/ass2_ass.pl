#!/usr/bin/perl -w 
use strict;
use Getopt::Long;
use FindBin(qw '$Bin');
use Cwd (qw 'abs_path');
my ($list,$outdir,$dir);
GetOptions(
	"read_list:s"=>\$list,
	"unmap_dir:s"=>\$dir,
	"o:s"=>\$outdir,
);
$list || &help;
$outdir||="./";
$outdir=abs_path $outdir;
$dir=abs_path $dir;
-s $outdir || mkdir $outdir,0755 ||die $!;
-s "$outdir/1.reads" || mkdir "$outdir/1.reads" || die $!;
my %hash;
open LIST,"$list" || die $!;
my $n=0;
my $N=0;
while(<LIST>){
	chomp;
	$n%7==0 && do {
		$N++;
		open CFG,">$outdir/$N.cfg" || die $!;
		print CFG "max_rd_len=100\n";
	};
	my ($sample,$insert_size)=(split /\t/)[0,2];
	my $pe="$dir/$sample.pe.unmap.gz";
	my $se="$dir/$sample.se.fna.gz";
	open IN,"gzip -cd $pe |" || die $!;
	open FQ1,"| gzip  >$outdir/1.reads/$sample.1.fna.gz"|| die $!;
	open FQ2,"| gzip  >$outdir/1.reads/$sample.2.fna.gz"|| die $!;
	print CFG "[LIB]\n";
	print CFG "avg_ins=$insert_size\n";
	print CFG "asm_flags=3\n";
	print CFG "rank=1\n";
	print CFG "q1=$outdir/1.reads/$sample.1.fna.gz\n";
	print CFG "q2=$outdir/1.reads/$sample.2.fna.gz\n";
	print CFG "[LIB]\n";
	print CFG "asm_flags=1\n";
	print CFG "q=$se\n";
	$/=">";<IN>;
	while(<IN>){
		chomp;
		my ($id,$seq)=split /\n/,$_,2;
		my $tag=(split /\//,$id)[-1];
		if ($tag==1){
			print FQ1 ">$id\n$seq";
		}else {
			print FQ2 ">$id\n$seq";
		}
	}
	close IN;
	$/="\n";
	$n++;
}
sub help{
print "
perl $0
	--read_list	<read list>
	--unmap_dir	<unmap dir>
	--o		[outdir]
";
exit 0;
}
