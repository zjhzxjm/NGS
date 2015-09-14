#!/usr/bin/perl -w
use strict;
use Getopt::Long;
my ($fq1,$fq2,$fq3,$fq4,$fq5,$fq6,$pe,$se,$sese,$g);
my ($pe_reads_count,$pe_bp_count,$se_reads_count,$se_bp_count);
GetOptions(
	"1:s"=>\$fq1,
	"2:s"=>\$fq2,
	"3:s"=>\$fq3,
	"4:s"=>\$fq4,
	"5:s"=>\$fq5,
	"6:s"=>\$fq6,
	"pe:s"=>\$pe,
	"se:s"=>\$se,
	"sese:s"=>\$sese,
	"g"=>\$g,
);
$fq1 && $fq2 && $fq3 && $fq4 && $fq5 && $fq6 && $pe && $se && $sese || &help;
if ($fq1=~/\.gz/){
	open FQ1,"gzip -cd $fq1|" ||die $!;
	open FQ2,"gzip -cd $fq2|" ||die $!;
	open FQ3,"gzip -cd $fq3|" ||die $!;
}else{
	open FQ1,"$fq1"||die $!;
	open FQ2,"$fq2"||die $!;
	open FQ3,"$fq3"||die $!;
}
if ($pe=~/\.gz/){
	open PE,"gzip -cd $pe|" || die $!;
	open SE,"gzip -cd $se|" || die $!;
	open SESE,"gzip -cd $sese|" || die $!;
}else{
	open PE,"$pe" ||die $!;
	open SE,"$se" ||die $!;
	open SESE,"$sese" || die $!;
}
if (defined $g){
	open FQ4,"|gzip >$fq4" ||die $!;
	open FQ5,"|gzip >$fq5" ||die $!;
	open FQ6,"|gzip >$fq6" ||die $!;
}else{
	open FQ4,">$fq4" || die $!;
	open FQ5,">$fq5" || die $!;
	open FQ6,">$fq6" || die $!;
}
my %filter_pe_id;	#soap result for PE cleandata
while(<PE>){
	my $id=(split /\t/)[0];
	$id=~s/\/1//;
	$id=~s/\/2//;
	$id="\@$id";
	$filter_pe_id{$id}=1;
}
close PE;
while(<SE>){
	my $id=(split /\t/)[0];
	$id=~s/\/1//;
	$id=~s/\/2//;
	$id="\@$id";
	$filter_pe_id{$id}=1;
}
close SE;
my %filter_se_id;	#soap result for SE cleandata
while(<SESE>){
	my $id=(split /\t/)[0];
	$id=~s/\/1//;
	 $id=~s/\/2//;
	$id="\@$id";
	$filter_se_id{$id}=1;
}
close SESE;
while(<FQ1>){
	$.%4==1 || next;
	chomp (my $line=$_);
	my $id=(split /\s/)[0];
	$id=~s/\/1//;
	$id=~s/\/2//;
	defined $filter_pe_id{$id} && next;
	chomp (my $seq=<FQ1>);
	my $len=length $seq;
	chomp (my $tag=<FQ1>);
	chomp (my $qlt=<FQ1>);
	print FQ4 "$line\n$seq\n$tag\n$qlt\n";
	$pe_reads_count++;
	$pe_bp_count+=$len;
}
close FQ1;
close FQ4;
while(<FQ2>){
	$.%4==1 || next;
	chomp (my $line=$_);
	my $id=(split /\s/)[0];
	$id=~s/\/1//;
	$id=~s/\/2//;
	defined $filter_pe_id{$id} && next;
	chomp (my $seq=<FQ2>);
	my $len=length $seq;
	chomp (my $tag=<FQ2>);
	chomp (my $qlt=<FQ2>);
	print FQ5 "$line\n$seq\n$tag\n$qlt\n";
	$pe_reads_count++;
	$pe_bp_count+=$len;
}
close FQ2;
close FQ5;
while(<FQ3>){
	$.%4==1 || next;
	chomp(my $line=$_);
	my $id=(split /\s/)[0];
	$id=~s/\/1//;
	$id=~s/\/2//;
	defined $filter_se_id{$id} && next;
	chomp (my $seq=<FQ3>);
	my $len=length $seq;
	chomp (my $tag=<FQ3>);
	chomp (my $qlt=<FQ3>);
	print FQ6 "$line\n$seq\n$tag\n$qlt\n";
	$se_reads_count++;
	$se_bp_count+=$len;
} 
close FQ3;
close FQ6;
sub help{
print "Usage:perl $0\n";
print <<USAGE;
	-1	<input fq1 path> 	gzip file supported
	-2	<input fq2 path>	gzip file supported
	-3	<output single path>	gzip file supported	
	-4	<output fq1 path>
	-5	<output fq2 path>
	-6	<output single path>
	-pe	<PE soap pe result>	gzip file supported
	-se	<PE soap se result>	gzip file supported
	-sese	<Single soap>		gzip file supported
	-g	<output gzip format>
USAGE
exit(0);
}
