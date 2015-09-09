#!/usr/bin/perl -w
use strict;
use Getopt::Long;
my $raw_dir;
my $clean_dir;
my $filter_dir;
my $outdir;
my $prefix;
my %hash_add;
GetOptions(
	"rawdir:s"=>\$raw_dir,
	"cleandir:s"=>\$clean_dir,
	"filterdir:s"=>\$filter_dir,
	"prefix:s"=>\$prefix,
	"outdir:s"=>\$outdir,
);
$raw_dir && $clean_dir && $filter_dir && $outdir || &help;

open OT,">$outdir/$prefix.stat" || die $!;
print OT  "Sample\tRawData\(Gb\)\tCleanPE\(Gb\)\tCleanSE\(Gb\)\tHost\(percent\)\tFilter_host_PE\tFilter_host_SE\tQcRemove\(Gb\)\n";
&stat($raw_dir,$prefix,"rawdata");
&stat($clean_dir,$prefix,"cleandata");
&stat($filter_dir,$prefix,"cleandata_rmHost");

	print OT "$prefix\t";
	print OT $hash_add{"rawdata"}->[1]/1000000000,"\t";
	print OT $hash_add{"cleandata"}->[1]/1000000000,"\t";
	print OT $hash_add{"cleandata"}->[3]/1000000000,"\t";
	print OT 1-($hash_add{"cleandata_rmHost"}->[0] + $hash_add{"cleandata_rmHost"}->[2]) / ($hash_add{"cleandata"}->[0] + $hash_add{"cleandata"}->[2]),"\t";
	print OT $hash_add{"cleandata_rmHost"}->[1],"\t",$hash_add{"cleandata_rmHost"}->[3],"\t";
	print OT ($hash_add{"rawdata"}->[1] - $hash_add{"cleandata"}->[1] - $hash_add{"cleandata"}->[3])/1000000000,"\n";



sub stat{
	my ($dir,$sample_name,$type)=@_;
	$dir  && $sample_name && $type ||die $!;
	#print "$sample_name\t$type\n";
		#open FQ1,"gzip -cd $dir/$sample/$sample.$type.R1.fq.gz|" ||die $!;
		if (-s "$dir/$sample_name.$type.R1.fq"){
			open FQ1,"$dir/$sample_name.$type.R1.fq" || die $!;
			open FQ2,"$dir/$sample_name.$type.R2.fq" || die $!;
		}elsif(-s "$dir/$sample_name.$type.R1.fq.gz"){
			open FQ1,"gzip -dc $dir/$sample_name.$type.R1.fq.gz|" || die $!;
			open FQ2,"gzip -dc $dir/$sample_name.$type.R2.fq.gz|" || die $!;
		}else{
			die "$dir/$sample_name.$type.R1.fq";
		}
		my ($line1,$line2,$line3);
		while(<FQ1>){
			$line1++;
			$line1%4==2 || next;
			#print "$sample_name\n$_";
			chomp (my $seq=$_);
			my $len=length $seq;
			$hash_add{$type}->[0]++;	#PE reads count
			$hash_add{$type}->[1]+=$len;	#PE bp count					
		}
		while(<FQ2>){
			$line2++;
			$line2%4==2 || next;
			chomp (my $seq=$_);
			my $len=length $seq;
		#	$hash_add->{$sample}->{$type}->[0]++;		
			$hash_add{$type}->[1]+=$len;
		}
		close FQ1;
		close FQ2;
		$type eq "rawdata" && return;
#		open FQ3,"gzip -cd $dir/$sample/$sample.$type.single.fq.gz|" || die $!;
		if (-s "$dir/$sample_name.$type.single.fq.gz"){
			open FQ3,"gzip -dc $dir/$sample_name.$type.single.fq.gz|" || die $!;
		}else{
			open FQ3,"$dir/$sample_name.$type.single.fq" || die $!;
		}
		while(<FQ3>){
			$line3++;
			$line3%4==2 || next;
			chomp (my $seq=$_);
			my $len=length $seq;
			$hash_add{$type}->[2]++;	#Single reads count
			$hash_add{$type}->[3]+=$len;	 #Single reads count
		}
		close FQ3;
#	print "$sample\t$type\t $hash_add->{$sample}->{$type}->[2]\n";
}
sub help{
	print "Usage: perl $0\n";
	print <<USAGE;
	--rawdir <rawdata dir>
	--cleandir <cleandata dir>
	--filterdir <filter dir>
	--outdir <output file>
	--list <sample list>
USAGE
exit 0;
}


