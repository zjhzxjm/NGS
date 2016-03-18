#! /usr/bin/perl

use lib "/home/xujm/bin/.self/Fastq_manipulate";
use zjhzxjm;
use File::Basename;
use Cwd 'abs_path';

die "Self自建库中，当没有使用F/R10-F/R15可以同时跑，但是lib_method仍需区分，做单独的sam_barcode.l sam_barcode.l2 sam_barcode.l3文件\n$0	<R1.fastq(.gz)><R2.fastq(.gz)><library:self(paired),hxt,[MiSeq new barcode]self2(U341-U806) or self3(A340/A341-U806),[Hiseq barcode]self4(U806-U341) para:1,0,3,4><sam_barcode>" unless @ARGV == 4;

my $file1 = $ARGV[0];
my $file2 = $ARGV[1];
my $libType = $ARGV[2];
my @totalReads = (0, 0);
my $nLines = 0;
my %proSamName;
my $outDir = dirname(abs_path($ARGV[3]));
my $substrlen;
my %undeterComb;
my %fileOpened;
my $out_barcode = 'ATCTCG'; # self4 时使用该外barcode
if($libType == 1 or $libType == 3 or $libType ==4){
  $substrlen = 6;
}elsif($libType == 0) {
  $substrlen = 7;
}

prtTimeLog("Start");
open SAM,"$ARGV[3]" or die "cant open $ARGV[3]\n";
while(<SAM>){
  chomp;
	my @a = split;
	$proSamName{$a[2]} = "$a[0]&$a[1]";
  unless(-e $a[0]){
		mkdir("$outDir\/$a[0]");
	}
	unless(-e "Unalign"){
		mkdir ("$outDir\/Unalign");
	}
}

if($file1 =~ /\.gz$/i) {
  chomp($nLines = `gzip -cd $file1 |wc -l`);
}else{
  chomp($nLines = `wc -l $file1`);
}
#$nLines = checkFastQFormat($file1);
#if($nLines != checkFastQFormat($ARGV[1])) {
#	prtErrorExit("Number of reads in paired end files are not same.\n\t\tFiles: $ARGV[0], $ARGV[1]");
#}
prtTimeLog("Start Process paired end files");

###############################
#Process paired end files
###############################
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

my $lineCount = 0;
while(!$isEOF) {
  my @fRead = ();
  my @rRead = ();

  for(my $i=0; $i<4; $i++) {
    $fRead[$i] = <F1>;
    $rRead[$i] = <F2>;
  }
  last if ($fRead[0]=~ /^\n$/);
  last if($rRead[0]=~ /^\n$/);
  chomp(my $fQualLine = $fRead[3]);
  chomp(my $rQualLine = $rRead[3]);
  chomp(my $fSeqLine = $fRead[1]);
  chomp(my $rSeqLine = $rRead[1]);

  my $isFWOPriAda = isWOPriAda($fSeqLine, $libType, $substrlen);
  my $isRWOPriAda = isWOPriAda($rSeqLine, $libType, $substrlen);
  my @isFWOPriAdas = split /-/,$isFWOPriAda;
  my @isRWOPriAdas = split /-/,$isRWOPriAda;
  my $twoBarcodeF;


    if($libType == 1 or $libType == 3){
    #注意，F和R对调
        $twoBarcodeF = "F".$isRWOPriAdas[1]."+R".$isFWOPriAdas[1];
        if($fRead[0] =~ /:([ATCG]{16})$/) {
          #sam_barcode.* 文件中barcode直接给入外barcode序列，根据外barcode 进行拆分
          if($proSamName{$1}) {
            my @proSam = split /&/,$proSamName{$1};
            unless(-e "$outDir\/$proSam[0]\/$proSam[1]"){
              mkdir ("$outDir\/$proSam[0]") unless(-e "$outDir\/$proSam[0]");
              mkdir ("$outDir\/$proSam[0]\/$proSam[1]");
            }
            my $outFile1 = "$outDir\/$proSam[0]\/$proSam[1]\/".basename($file1)."_filterd.gz";
            my $outFile2 = "$outDir\/$proSam[0]\/$proSam[1]\/".basename($file2)."_filterd.gz";
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
            next;
          }
        }
        if($proSamName{$twoBarcodeF}){
          my @proSam = split /&/,$proSamName{$twoBarcodeF};
          unless(-e "$outDir\/$proSam[0]\/$proSam[1]"){
            mkdir ("$outDir\/$proSam[0]") unless(-e "$outDir\/$proSam[0]");
            mkdir ("$outDir\/$proSam[0]\/$proSam[1]");
          }
          print "+Find barcode $lineCount\tin match code $isFWOPriAdas[0]:$isRWOPriAdas[0]\n" if($isFWOPriAdas[0]>1 or $isRWOPriAdas[0]>1);
          my $outFile1 = "$outDir\/$proSam[0]\/$proSam[1]\/".basename($file1)."_filterd.gz";
          my $outFile2 = "$outDir\/$proSam[0]\/$proSam[1]\/".basename($file2)."_filterd.gz";
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
          my $outFile1 = "$outDir\/Unalign\/".basename($file1)."_unalign.gz";
          my $outFile2 = "$outDir\/Unalign\/".basename($file2)."_unalign.gz";
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
    }elsif($libType == 4){
        $twoBarcodeF = "F".$isFWOPriAdas[1]."+R".$isRWOPriAdas[1];
        # 考虑外barcode，允许一个错配
        if($fRead[0] =~ /:([ATCG]{6})$/) {
            $f = findSeq($out_barcode, 6, $1, 1)
        }
        if($rRead[0] =~ /:([ATCG]{6})$/) {
            $r = findSeq($out_barcode, 6, $1, 1)
        }
        if($proSamName{$twoBarcodeF} and $f>0 and $r>0){
          my @proSam = split /&/,$proSamName{$twoBarcodeF};
          unless(-e "$outDir\/$proSam[0]\/$proSam[1]"){
            mkdir ("$outDir\/$proSam[0]") unless(-e "$outDir\/$proSam[0]");
            mkdir ("$outDir\/$proSam[0]\/$proSam[1]");
          }
          print "+Find barcode $lineCount\tin match code $isFWOPriAdas[0]:$isRWOPriAdas[0]\n" if($isFWOPriAdas[0]>1 or $isRWOPriAdas[0]>1);
          my $outFile1 = "$outDir\/$proSam[0]\/$proSam[1]\/".basename($file1)."_filterd.gz";
          my $outFile2 = "$outDir\/$proSam[0]\/$proSam[1]\/".basename($file2)."_filterd.gz";
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
        }elsif($f>0 and $r>0){
          $undeterComb{$twoBarcodeF} += 1;
          unless(-e "$outDir\/Unalign"){
            mkdir ("$outDir\/Unalign");
          }
          my $outFile1 = "$outDir\/Unalign\/".basename($file1)."_unalign.gz";
          my $outFile2 = "$outDir\/Unalign\/".basename($file2)."_unalign.gz";
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
    }elsif($libType == 0){
    $twoBarcodeF = "F".$isFWOPriAdas[1]."+R".$isRWOPriAdas[1];
    if($proSamName{$twoBarcodeF}){
      my @proSam = split /&/,$proSamName{$twoBarcodeF};
      unless(-e "$outDir\/$proSam[0]\/$proSam[1]"){
        mkdir ("$outDir\/$proSam[0]") unless(-e "$outDir\/$proSam[0]");
        mkdir ("$outDir\/$proSam[0]\/$proSam[1]");
      }
      print "+Find barcode $lineCount\tin match code $isFWOPriAdas[0]:$isRWOPriAdas[0]\n" if($isFWOPriAdas[0]>1 or $isRWOPriAdas[0]>1);
      my $outFile1 = "$outDir\/$proSam[0]\/$proSam[1]\/".basename($file1)."_filterd.gz";
      my $outFile2 = "$outDir\/$proSam[0]\/$proSam[1]\/".basename($file2)."_filterd.gz";
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
      my $outFile1 = "$outDir\/Unalign\/".basename($file1)."_unalign.gz";
      my $outFile2 = "$outDir\/Unalign\/".basename($file2)."_unalign.gz";
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
  }else{
    die "ERR: Wrong parameter for library";
    }

  $lineCount += 4;
  if($lineCount >= $nLines) {
    $isEOF = 1;
  }
  if($lineCount % (100000*4) == 0) {
    my $tmpP = sprintf "%0.0f", ($lineCount/4/$totalReads[0]*100);
    my $message = "Number of reads processed:"  . $lineCount/4 . "/$totalReads[0] ($tmpP\%)";
    prtTimeLog($message);
  }
}

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
