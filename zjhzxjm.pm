#! /usr/bin/perl

package zjhzxjm;

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
		my $twoBarcodeF;
    my $checkPairBar;

		if($ARGV[2] == 1){
			$twoBarcodeF = "F".$isRWOPriAdas[1]."+R".$isFWOPriAdas[1];
		}elsif($ARGV[2] == 0){
			$twoBarcodeF = "F".$isFWOPriAdas[1]."+R".$isRWOPriAdas[1];
		}elsif($ARGV[2] == 2){
      if($rRead[0] =~ /:([ATCG]{16})$/){
        $checkPairBar = $1;
      }
      if($fRead[0]=~ /:([ATCG]{16})$/) {
        unless($checkPairBar eq $1) {
          print "Warning: not the same paired barcode\n";
        }
        if($proSamName{$1}) {
          my @proSam = split /&/,$proSamName{$1};
          unless(-e "$outDir\/$proSam[0]\/$proSam[1]"){
            mkdir ("$outDir\/$proSam[0]") unless(-e "$outDir\/$proSam[0]");
            mkdir ("$outDir\/$proSam[0]\/$proSam[1]");
          }
          my $outFile1 = "$outDir\/$proSam[0]\/$proSam[1]\/".basename($file1)."_filterd";
          my $outFile2 = "$outDir\/$proSam[0]\/$proSam[1]\/".basename($file2)."_filterd";
          unless($fileOpened{$outFile1}) {
            my $fHw1 = openFileGetHandle($outFile1,"w");
            $fileOpened{$outFile1} = $fHw1;
          }
          unless($fileOpened{$outFile2}) {
            my $fHw2 = openFileGetHandle($outFile2,"w");
            $fileOpened{$outFile2} = $fHw2;
          }
          *FW1 = $fileOpened{$outFile1};
          *FW2 = $fileOpened{$outFile2};
          print FW1 @fRead;
          print FW2 @rRead;
        }else{
          my $outFile1 = "$outDir\/Unalign\/".basename($file1)."_unalign";
          my $outFile2 = "$outDir\/Unalign\/".basename($file2)."_unalign";
          unless($fileOpened{$outFile1}){
            my $fHw1 = openFileGetHandle($outFile1,"w");
            $fileOpened{$outFile1} = $fHw1;
          }
          unless($fileOpened{$outFile2}){
            my $fHw2 = openFileGetHandle($outFile2,"w");
            $fileOpened{$outFile2} = $fHw2;
          }
          *FW1 = $fileOpened{$outFile1};
          *FW2 = $fileOpened{$outFile2};
          print FW1 @fRead;
          print FW2 @rRead;
        }
      } 
    }else{
      die "ERR: wrong parameter for library";
    }
#print "$lineCount\t$twoBarcodeF\n";
    if($ARGV[2] == 0 or $ARGV[2] == 1){
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
      unless($fileOpened{$outFile1}){
        my $fHw1 = openFileGetHandle($outFile1,"w");
        $fileOpened{$outFile1} = $fHw1;
      }
      unless($fileOpened{$outFile2}){
        my $fHw2 = openFileGetHandle($outFile2,"w");
        $fileOpened{$outFile2} = $fHw2;
      }
      *FW1 = $fileOpened{$outFile1};
      *FW2 = $fileOpened{$outFile2};
      print FW1 @fRead;
      print FW2 @rRead;
		}else{
			$undeterComb{$twoBarcodeF} += 1;
			unless(-e "$outDir\/Unalign"){
				mkdir ("$outDir\/Unalign");
			}
			my $outFile1 = "$outDir\/Unalign\/".basename($file1)."_unalign";
			my $outFile2 = "$outDir\/Unalign\/".basename($file2)."_unalign";
      unless($fileOpened{$outFile1}){
        my $fHw1 = openFileGetHandle($outFile1,"w");
        $fileOpened{$outFile1} = $fHw1;
      }
      unless($fileOpened{$outFile2}){
        my $fHw2 = openFileGetHandle($outFile2,"w");
        $fileOpened{$outFile2} = $fHw2;
      }
      *FW1 = $fileOpened{$outFile1};
      *FW2 = $fileOpened{$outFile2};
      print FW1 @fRead;
      print FW2 @rRead;
		}
    }
	
		$lineCount += 4;
	
		if($lineCount >= $nLines) {
			$isEOF = 1;
		}
		if($lineCount % (100000*4) == 0) {
			my $tmpP = sprintf "%0.0f", ($lineCount/4/$totalReads[0]*100);
      my $time = `date +"%Y-%m-%d %H:%M"`;
			print STDERR "Number of reads processed: " . $lineCount/4 . "/$totalReads[0] ($tmpP\%)...$time\n";
		}
	}
######Close all fileHandle####
	close (F2);
	close (F1);
	foreach my $f (values %fileOpened){
    *F = $f;
    close(F);
  }

	my $logFile = "$outDir\/".basename($ARGV[3]).".log";
	open LOG,">$logFile" or die "cant open $logFile\n";
	foreach my $k (keys %undeterComb){
		print LOG "Undetermined Combination: $k\t$undeterComb{$k}\n"; 
	}
	close (LOG);
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

	my %tagPriStr = ();
	my @priAdaSeqs = ();
	

	if($islORs == 1){
		my $i = 0;
		foreach my $barcode (@lBarcode){
			$i++;
			my $f = findSeq($barcode, $lsubstrlen, $seq, $islORs );
			if($f>0){
				if(defined $tagPriStr{$f}){
					$tagPriStr{$f} = 0;
#print "Match code $f: \t There is one more match\n";
				}else{
					$tagPriStr{$f} = $i;
				}
			}
		}
	}elsif($islORs == 0) {
		my $i = 0;
		foreach my $barcode (@sBarcode){
			$i++;
#print "barcode:$i\t$barcode\n";
			my $f = findSeq($barcode, $ssubstrlen, $seq, $islORs );
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

	if($_[3]){
		my $loc = index($seq, $pri);
		unless($loc < 0){
			return 1
		}
	}else{
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
		open($fh, ">$file") or die "Can not create file $file" if($rOrw eq "w");
	}
	return $fh;
}
1;
