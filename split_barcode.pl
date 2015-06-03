#! /usr/bin/perl

use File::Basename;
use strict;
use IO::Zlib;
use String::Approx;
use Cwd 'abs_path';

die "$0	<fq1><fq2><lORs barcode><sam_barcode>" unless @ARGV == 4;
my @totalReads = (0, 0);
my $nLines = 0;
my %proSamName; 
my $outDir = dirname(abs_path($ARGV[3]));
my $ssubstrlen = 6;
my $lsubstrlen = 12;

open SAM,"$ARGV[3]" or die "cant open $ARGV[3]\n";
while(<SAM>){
    chomp;
	my @a = split;
	$proSamName{$a[2]} = "$a[0]&$a[1]";
    unless(-e $a[0]){
		mkdir("$outDir\/$a[0]");
	}
#else{
#print "Warning: Exist $outDir\/$a[0]\n";
#}
	unless(-e "Unalign"){
		mkdir ("$outDir\/Unalign");
	}
#else{
#`rm -rf Unalign`;
#}
}

$nLines = checkFastQFormat($ARGV[0]);
if($nLines != checkFastQFormat($ARGV[1])) {
	prtErrorExit("Number of reads in paired end files are not same.\n\t\tFiles: $ARGV[0], $ARGV[1]");
}

processPairedEndFiles($ARGV[0],$ARGV[1],$ARGV[2]);


sub prtErrorExit {
    my $errmsg = $_[0];
    print STDERR "Error:\t", $errmsg, "\n";
    exit;
}

sub checkFastQFormat {              # Takes FASTQ file as an input and if the format is incorrect it will print error and exit, otherwise it will return the number of lines in the file.
    my $file = $_[0];
    my $lines = 0;
    my $fH = openFileGetHandle($file, "r");
    *F = $fH;
    my $counter = 0;
    while(my $line = <F>) {
        $lines++;
        $counter++;
        next if($line =~ /^\n$/);
        if($counter == 1 && $line !~ /^\@/) {
            prtErrorExit("Invalid FASTQ file format.\n\t\tFile: $file");
        }
        if($counter == 3 && $line !~ /^\+/) {
            prtErrorExit("Invalid FASTQ file format.\n\t\tFile: $file");
        }
        if($counter == 4) {
            $counter = 0;
        }
    }
    close(F);
    return $lines;
}

sub processPairedEndFiles {
	my $file1 = $_[0];
	my $file2 = $_[1];
	my $islORs = $_[2];
	
	$totalReads[0] = sprintf("%0.0f", $nLines/4);
	$totalReads[1] = sprintf("%0.0f", $nLines/4);

	my $fH1 = openFileGetHandle($file1, "r");
	*F1 = $fH1;
	my $fH2 = openFileGetHandle($file2, "r");
	*F2 = $fH2;

	my $isEOF = 1;
	if($nLines/4 > 0) {
		$isEOF = 0;
	}
#print $nLines,"\n";	
	my $lineCount = 0;
	while(!$isEOF) {
		my @fRead = ();
		my @rRead = ();
		
		for(my $i=0; $i<4; $i++) {
			$fRead[$i] = <F1>;
			$rRead[$i] = <F2>;
		}
		last if($fRead[0]=~ /^\n$/);
		last if($rRead[0]=~ /^\n$/);
		chomp(my $fQualLine = $fRead[3]);
		chomp(my $rQualLine = $rRead[3]);
		chomp(my $fSeqLine = $fRead[1]);
		chomp(my $rSeqLine = $rRead[1]);

		my $isFWOPriAda = isWOPriAda($fSeqLine, $islORs);
		my $isRWOPriAda = isWOPriAda($rSeqLine, $islORs);
		my @isFWOPriAdas = split /-/,$isFWOPriAda;
		my @isRWOPriAdas = split /-/,$isRWOPriAda;
		my $twoBarcodeF = "F".$isFWOPriAdas[1]."+R".$isRWOPriAdas[1];
		my $twoBarcodeR = "F".$isRWOPriAdas[1]."+R".$isFWOPriAdas[1];
#print "$lineCount\t$twoBarcodeF\t$twoBarcodeR\n";

		if($proSamName{$twoBarcodeF}){
			my @proSam = split /&/,$proSamName{$twoBarcodeF};
#print "$proSam[0] $proSam[1]\n";
			unless(-e "$outDir\/$proSam[0]\/$proSam[1]"){
				mkdir ("$outDir\/$proSam[0]") unless(-e "$outDir\/$proSam[0]");
				mkdir ("$outDir\/$proSam[0]\/$proSam[1]");
			}
print "+Find barcode $lineCount\tin match code $isFWOPriAdas[0]:$isRWOPriAdas[0]\n" if($isFWOPriAdas[0]>1 or $isRWOPriAdas[0]>1);
			my $outFile1 = "$outDir\/$proSam[0]\/$proSam[1]\/".basename($file1)."_filterd";
			my $outFile2 = "$outDir\/$proSam[0]\/$proSam[1]\/".basename($file2)."_filterd";
			open OF1,">>$outFile1" or die "cant open $outFile1\n";
			open OF2,">>$outFile2" or die "cant open $outFile2\n";
			print OF1 @fRead;
			print OF2 @rRead;
			close (OF1);
			close (OF2);
		}elsif($proSamName{$twoBarcodeR}){
			my @proSam = split /&/,$proSamName{$twoBarcodeR};
			unless(-e "$outDir\/$proSam[0]\/$proSam[1]"){
#`mkdir $proSam[0]` unless(-d $proSam[0]);
#`mkdir $proSam[0]\/$proSam[1]`;
				mkdir ("$outDir\/$proSam[0]") unless(-e "$outDir\/$proSam[0]");
				mkdir ("$outDir\/$proSam[0]\/$proSam[1]");
			}
print "-Find barcode $lineCount\tin match code $isFWOPriAdas[0]:$isRWOPriAdas[0]\n" if($isFWOPriAdas[0]>1 or $isRWOPriAdas[0]>1);
			my $outFile1 = "$outDir\/$proSam[0]\/$proSam[1]\/".basename($file1)."_filterd";
			my $outFile2 = "$outDir\/$proSam[0]\/$proSam[1]\/".basename($file2)."_filterd";
			open OF1,">>$outFile1" or die "cant open $outFile1\n";
			open OF2,">>$outFile2" or die "cant open $outFile2\n";
			print OF1 @fRead;
			print OF2 @rRead;
			close (OF1);
			close (OF2);
			
		}else{
			unless(-e "$outDir\/Unalign"){
				mkdir ("$outDir\/Unalign");
			}
			my $outFile1 = "$outDir\/Unalign\/".basename($file1)."_unalign";
			my $outFile2 = "$outDir\/Unalign\/".basename($file2)."_unalign";
			open OF1,">>$outFile1" or die "cant open $outFile1\n";
			open OF2,">>$outFile2" or die "cant open $outFile2\n";
			print OF1 @fRead;
			print OF2 @rRead;
			close (OF1);
			close (OF2);

		}
	
		$lineCount += 4;
	
		if($lineCount >= $nLines) {
			$isEOF = 1;
		}
		if($lineCount % (100000*4) == 0) {
			my $tmpP = sprintf "%0.0f", ($lineCount/4/$totalReads[0]*100);
			print "Number of reads processed: " . $lineCount/4 . "/$totalReads[0] ($tmpP\%)...\n";
		}
	}
	close (F2);
	close (F1);
}

sub isWOPriAda {
	my $seq = $_[0];
	my $islORs = $_[1];
	chomp($seq);

	my @sBarcode = (
			"ATCACG", 
			"CGATGT", 
			"TTAGGC", 
			"TGACCA", 
			"ACAGTG", 
			"GCCAAT",
			"CAGATC", 
			"ACTTGA",
			"GATCAG",
			"TAGCTT",
			"GGCTAC",
			"CTTGTA"
			);
	my @lBarcode = (
			"CCTAAACTACGG",
			"TGCAGATCCAAC",
			"CCATCACATAGG",
			"GTGGTATGGGAG",
			"ACTTTAAGGGTG",
			"GAGCAACATCCT",
			"TGTTGCGTTTCT", 
			"ATGTCCGACCAA", 
			"AGGTACGCAATT", 
			"GTTACGTGGTTG", 
			"TACCGCCTCGGA", 
			"CGTAAGATGCCT",
			"ACAGCCACCCAT", 
			"TGTCTCGCAAGC", 
			"GAGGAGTAAAGC", 
			"TACCGGCTTGCA", 
			"ATCTAGTGGCAA", 
			"CCAGGGACTTCT",
			"CACCTTACCTTA", 
			"ATAGTTAGGGCT", 
			"GCACTTCATTTC", 
			"TTAACTGGAAGC", 
			"CGCGGTTACTAA", 
			"GAGACTATATGC"
			);

	my %tagPriStr = ();
	my @priAdaSeqs = ();
	

	if($islORs){
		my $i = 0;
		foreach my $barcode (@lBarcode){
			$i++;
			my $f = findSeq($barcode, $lsubstrlen, $seq );
			if($f>0){
				if(defined $tagPriStr{$f}){
					$tagPriStr{$f} = 0;
#print "Match code $f: \t There is one more match\n";
				}else{
					$tagPriStr{$f} = $i;
				}
			}
		}
	}else{
		my $i = 0;
		foreach my $barcode (@sBarcode){
			$i++;
#print "barcode:$i\t$barcode\n";
			my $f = findSeq($barcode, $ssubstrlen, $seq );
			if($f>0){
#print "$barcode\t$seq\n";
				if(defined $tagPriStr{$f}){
					$tagPriStr{$f} = 0;
#print "Match code $f: \t There is one more match\n";
				}else{
					$tagPriStr{$f} = $i;
				}
			}
		}
	}
#print values %tagPriStr,"\n";
	my $returnStr;
	if($tagPriStr{1}){
		$returnStr = "1-".$tagPriStr{1};
		return $returnStr;
	}elsif($tagPriStr{2}){
		$returnStr = "2-".$tagPriStr{2};
		return $returnStr;
	}else{
		return 0;
	}
}

sub findSeq {
	my $pri = $_[0];
	my $substrlen = $_[1];
	my $seq = substr($_[2], 0, $substrlen);
#print "substr $seq\n";
	my $tag = 0;

	my @catches0 = String::Approx::amatch($pri, ['I0 D0 S0'], $seq);
	if(@catches0 !=0 ){
#print "0\t$pri\t",@catches0,"\n";
		$tag =1;
		return 1;
	}
	unless($tag != 0){
		my @catches1 = String::Approx::amatch($pri, ['I0 D0 S1'], $seq);
		if(@catches1 !=0 ){
#print "Mismatch 1bp:\t$pri\t",@catches1,"\n";
			return 2;
		}
	}
	return 0;
}
sub openFileGetHandle {
	my ($file, $rOrw) = @_;
	my $fh;
	if($file =~ /\.gz$/i) {
		$fh = new IO::Zlib;
		$fh->open("$file", "rb") or die "Can not open file $file" if($rOrw eq "r");
		$fh->open("$file", "wb") or die "Can not create file $file" if($rOrw eq "w");
	}
	else {
		open($fh, "<$file") or die "Can not open file $file" if($rOrw eq "r");
		open($fh, ">$file") or die "Can not create file $file" if($rOrw eq "w");
	}
	return $fh;
}

