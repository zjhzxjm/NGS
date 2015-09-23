#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Cwd (qw 'abs_path');
use FindBin(qw '$Bin');
my ($list,$outdir,$help,$run);
GetOptions(
	"list:s"=>\$list,
	"outdir:s"=>\$outdir,
	"help"=>\$help,
	"run"=>\$run,
);
$help && &help;
$list || &help;
$outdir||="./";
$outdir=abs_path $outdir;
my $metaGenMark="/data_center_01/soft/metagenemark/MetaGeneMark_linux_64_V3.26/mgm/gmhmmp";
my $mod="/data_center_01/soft/metagenemark/MetaGeneMark_linux_64_V3.26/mgm/MetaGeneMark_v1.mod";
my $get_fna="/home/xujm/bin/.self/Oral_analysis/gene_predict/nt_from_gff.pl";
my $get_faa="/home/xujm/bin/.self/Oral_analysis/gene_predict/aa_from_gff.pl";
my $qsub="/home/xujm/bin/qsub-sge.pl";
open LIST,"<$list"|| die $!;
-s $outdir || mkdir $outdir ,0755 || die $!;
-s "$outdir/SH" || mkdir "$outdir/SH" || die $!;
open SH1,">$outdir/SH/1.predict.sh" || die $!;
open SH2,">$outdir/SH/2.get_seq.sh" || die $!;
open GFF_list,">$outdir/GFF.list" || die $!;
open FAA_list,">$outdir/FAA.list" || die $!;
open FNA_list,">$outdir/FNA.list" || die $!;
while(<LIST>){
	chomp;
	my ($id,$seq_file)=split /\s+/;
	print SH1 "$metaGenMark -a -d -f G -m $mod -o $outdir/$id.gff $seq_file\n";
	print SH2 "perl $get_fna <$outdir/$id.gff >$outdir/$id.fna\nperl $get_faa <$outdir/$id.gff >$outdir/$id.faa\n";
	print GFF_list "$id\t$outdir/$id.gff\n";
	print FAA_list "$id\t$outdir/$id.faa\n";
	print FNA_list "$id\t$outdir/$id.fna\n";
}
close LIST;
close SH1;
close SH2;
close GFF_list;
close FAA_list;
close FNA_list;
$run && do{
	system "perl $qsub --queue all.q --convert no --reqsub --jobprefix pred --resource vf=2g $outdir/SH/1.predict.sh";
	system "perl $qsub --queue all.q --convert no --reqsub --jobprefix gt_seg --resource vf=500m $outdir/SH/2.get_seq.sh";
	};
sub help{
print "Usage:perl $0\n";
print <<USAGE;
	--list		<file list>	sample	fasta_file
	--outdir	[Outdir]
	--help		
	--run 	run right now
USAGE
exit 0;
}


