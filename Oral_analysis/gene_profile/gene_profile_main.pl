#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Cwd(qw 'abs_path');
use FindBin(qw '$Bin');
my ($fq_list,$fna,$outdir,$run,$OralBin);
GetOptions(
	"fq_list:s"=>\$fq_list,
	"fna:s"=>\$fna,
	"o:s"=>\$outdir,
	"run"=>\$run,
);
$fq_list && $fna || &help;
$fna=abs_path $fna;
$OralBin = "/home/xujm/bin/.self/Oral_analysis";
-s "$fna.index.bwt" || die "please index $fna first";

$outdir||="./";
$outdir=abs_path $outdir;
-s $outdir || mkdir $outdir,0755 || die $!;
-s "$outdir/SH" || mkdir "$outdir/SH",0755 || die $!;
-s "$outdir/1.soap" || mkdir "$outdir/1.soap",0755 || die $!;
-s "$outdir/2.profile" ||mkdir "$outdir/2.profile" || die $!;
open SH1,">$outdir/SH/01.soap.sh" || die $!;
open SH2,">$outdir/SH/02.align_abundance.sh" || die $!;
open SH3,">$outdir/SH/03.get_abundance.sh" || die $!;
open SH4,">$outdir/SH/04.mk_table.sh" || die $!;
open Single_list,">$outdir/2.profile/single_profile.list" || die $!;
my $align_abundance="$OralBin/gene_profile/00_00_align_abundance.pl";
my $get_gene_profile="$OralBin/gene_profile/01_00_parse_contig_abundance_FRENCH.pl";
my $mk_profile_table="$OralBin/gene_profile/02_mk_gene_profiling_table.pl";
my $soap;


open FQ,"$fq_list" || die $!;
while (<FQ>){
	chomp;
 	my ($sample,$lib,$insert_size)=split /\s+/;
	my ($fq1,$fq2);
	if (-s "$lib.R1.fq.gz"){
		$fq1="$lib.R1.fq.gz";
		$fq2="$lib.R2.fq.gz";
		$soap="/data_center_01/soft/soap/soap2.21release/soap_mm_gz";
	}else{
		$fq1="$lib.R1.fq";
		$fq2="$lib.R2.fq";
		$soap="/data_center_01/soft/soap/soap2.21release/soap";
	}
	print SH1 "$soap -a $fq1 -b $fq2 -D $fna.index -o $outdir/1.soap/$sample.PE -2 $outdir/1.soap/$sample.SE -m 100 -x 1000 -p 8 -r 2\n";
	print SH2 "$align_abundance -PP $outdir/1.soap/$sample.PE -PS $outdir/1.soap/$sample.SE -ca $outdir/1.soap/$sample.aboundance\n";
	print SH3 "$get_gene_profile $fna $outdir/1.soap/$sample.aboundance $outdir/2.profile/$sample.profile.do $outdir/2.profile/$sample.profile.log Dusko\n";
	print Single_list "$sample\t$outdir/2.profile/$sample.profile.do\n";
}
close SH1;
close SH2;
close SH3;
close Single_list;
print SH4 "perl $OralBin/gene_profile/02_mk_gene_profiling_table.pl $fna $outdir/2.profile/single_profile.list $outdir/result.txt";
$run && do {
	system "qsub-sge.pl --convert no --reqsub --getmem --resource vf=8g $outdir/SH/01.soap.sh";
	system "qsub-sge.pl  --convert no --reqsub ---getmem -resource vf=2g $outdir/SH/02.align_abundance.sh";
	system "qsub-sge.pl  --convert no --reqsub ---getmem -resource vf=3g $outdir/SH/03.get_abundance.sh";
	system " sh $outdir/SH/04.mk_table.sh";
};
sub help{
print <<USAGE;
perl $0
	--fq_list <list>	sample	reads_prefix	insert size	
	--fna	<file>		GeneSet fasta
	--o	[Dir]		outdir[./]
	--run	[]		run at least
USAGE
exit 0;
}
