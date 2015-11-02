#! /usr/bin/perl

package zjhzxjm;
require Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(prtErrorExit checkFastQFormat isWOPriAda findSeq openFileGetHandle prtTimeLog);
our $VERSION = 1.00;

use File::Basename;
use strict;
use IO::Zlib;
use String::Approx;
use Cwd 'abs_path';


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


sub isWOPriAda {
    my $seq = $_[0];
	my $libType = $_[1];
    my $substrlen = $_[2];

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
			"CCTAAA",
			"TGCAGA",
			"CCATCA",
			"GTGGTA",
			"ACTTTA",
			"GAGCAA",
			"TGTTGC", 
			"ATGTCC", 
			"AGGTAC", 
			"GTTACG", 
			"TACCGC", 
			"CGTAAG",
			"ACAGCC", 
			"TGTCTC", 
			"GAGGAG", 
			"TACCGG", 
			"ATCTAG", 
			"CCAGGG",
			"CACCTT", 
			"ATAGTT", 
			"GCACTT", 
			"TTAACT", 
			"CGCGGT", 
			"GAGACT"
			);
    my @mBarcode = (
        "ACGAGACTGATT",
        "GCTGTACGGATT",
        "ATCACCAGGTGT",
        "TGGTCAACGATA",
        "ATCGCACAGTAA",
        "GTCGTGTAGCCT",
        "AGCGGAGGTTAG",
        "ATCCTTTGGTTC",
        "TACAGCGCATAC",
        "ACCGGTATGTAC",
        "AATTGTGTCGGA",
        "TGCATACACTGG",
        "AGTCGAACGAGG",
        "ACCAGTGACTCA",
        "GAATACCAAGTC",
        "GTAGATCGTGTA",
        "TAACGTGTGTGC",
        "CATTATGGCGTG",
        "CCAATACGCCTG",
        "GATCTGCGATCC",
        "CAGCTCATCAGC",
        "CAAACAACAGCT",
        "GCAACACCATCC",
        "GCGATATATCGC",
        "CGAGCAATCCTA",
        "AGTCGTGCACAT",
        "GTATCTGCGCGT",
        "CGAGGGAAAGTC",
        "CAAATTCGGGAT",
        "AGATTGACCAAC",
        "AGTTACGAGCTA",
        "GCATATGCACTG",
        "CAACTCCCGTGA",
        "TTGCGTTAGCAG",
        "TACGAGCCCTAA",
        "CACTACGCTAGA",
        "TGCAGTCCTCGA",
        "ACCATAGCTCCG",
        "TCGACATCTCTT",
        "GAACACTTTGGA",
        "GAGCCATCTGTA",
        "TTGGGTACACGT",
        "AAGGCGCTCCTT",
        "TAATACGGATCG",
        "TCGGAATTAGAC",
        "TGTGAATTCGGA",
        "CATTCGTGGCGT",
        "TACTACGTGGCC",
        "GGCCAGTTCCTA",
        "GATGTTCGCTAG",
        "CTATCTCCTGTC",
        "ACTCACAGGAAT",
        "ATGATGAGCCTC",
        "GTCGACAGAGGA",
        "TGTCGCAAATAG",
        "CATCCCTCTACT",
        "TATACCGCTGCG",
        "AGTTGAGGCATT",
        "ACAATAGACACC",
        "CGGTCAATTGAC",
    );

	my %tagPriStr = ();
	my @priAdaSeqs = ();
	

	if($libType == 1){
		my $i = 0;
        my $misMatch = 0;
		foreach my $barcode (@lBarcode){
			$i++;
			my $f = findSeq($barcode, $substrlen, $seq, $misMatch );
			if($f>0){
				if(defined $tagPriStr{$f}){
					$tagPriStr{$f} = 0;
#print "Match code $f: \t There is one more match\n";
				}else{
					$tagPriStr{$f} = $i;
				}
			}
		}
	}elsif($libType == 0) {
		my $i = 0;
        my $misMatch = 1;
		foreach my $barcode (@sBarcode){
			$i++;
#print "barcode:$i\t$barcode\n";
			my $f = findSeq($barcode, $substrlen, $seq, $misMatch );
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
	}elsif($libType == 2) {
        my $i = 0;
        my $misMatch = 1;
		foreach my $barcode (@mBarcode){
			$i++;
#print "barcode:$i\t$barcode\n";
			my $f = findSeq($barcode, $substrlen, $seq, $misMatch );
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
#exact match
		$returnStr = "1-".$tagPriStr{1};
		return $returnStr;
	}elsif($tagPriStr{2}){
#one mismatch
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
    my $misMatch = $_[3];
#print "substr $seq\n";

	if($misMatch == 0){
		my $loc = index($seq, $pri);
		unless($loc < 0){
			return 1
		}
	}elsif($misMatch == 1){
		my $tag = 0;
		my $loc = index($seq, $pri);
		unless($loc < 0){
			$tag = 1;
			return 1;
		}
		unless($tag != 0){
			my @catches1 = String::Approx::amatch($pri, $seq);
			if(@catches1 !=0 ){
##print "Mismatch 1bp:\t$pri\t",@catches1,"\n";
				return 2;
			}
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
		open($fh, ">>$file") or die "Can not create file $file" if($rOrw eq "w");
	}
	return $fh;
}

sub prtTimeLog {
  my $message = $_[0];
  my $time = `date +"%Y-%m-%d %H:%M"`;
  print STDERR "$message at $time\n";
}
1;
