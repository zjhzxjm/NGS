#!/usr/bin/perl -w

=pod
description: blast2ko
author: Zhang Fangxian, zhangfx@genomics.cn
create date: 20090706
modify date: 20100326, 20091120, 20091119, 20091111, 20091024, 20091009, 20090916, 20090915, 20090914, 20090911, 20090906, 20090903, 20090821, 20090820, 20090804, 20090730, 20090717, 20090710
=cut

use Getopt::Long;
use File::Basename 'dirname';
use FindBin '$Bin';
use lib $Bin;
use SeqType;

our ($input, $type, $blast_out, $blast, $kegg, $evalue, $rank, $output, $help);

GetOptions(
	"input:s" => \$input,
	"type:s" => \$type,
	"blastout:s" => \$blast_out,
	"blast:s" => \$blast,
	"kegg:s" => \$kegg,
	"evalue:f" => \$evalue,
	"rank:i" => \$rank,
	"output:s" => \$output,
	"help|?" => \$help,
);
$evalue = 1e-5 if (!defined $evalue);
$rank = 5 if (!defined $rank);

our ($idPath);

$kegg0 = $kegg if (defined $kegg);
do "$Bin/keggConf.pl" || die $!;
$kegg2 = $kegg;
$kegg = $kegg0 if (defined $kegg0);

$id_ko = "$idPath/genes_ko.list";
%ids = ("seqids:ncbigene" => "genes_ncbi-geneid.list", "seqids:ncbigi" => "genes_ncbi-gi.list", "seqids:uniprot" => "genes_uniprot.list");
%ids_fix = ("seqids:ncbigene" => "ncbi-geneid:", "seqids:ncbigi" => "ncbi-gi:", "seqids:uniprot" => "up:");

sub usage {
	print STDERR << "USAGE";
description: blast2ko
usage: perl $0 [options]
options:
	-input: gene id list file or FASTA file
	-type: input type (fasta, blastout, seqids), can specify db by the format of 'seqids:db' from (ncbigene, ncbigi, uniprot) when using seqids option
	-blastout: output of blast in format -m 8
	-blast: blastall program, determined automatically if not specified
	-kegg: kegg database, default is "$kegg2"
	-evalue: expectation value, default is 1e-5
	-rank: rank cutoff for valid hit from blastall, default is 5
	-output: output file, default is "./[input].ko"
	-help|?: help information
e.g.:
	perl $0 -input idFile -type seqids:ncbigene -output ./out.ko
	perl $0 -input faFile -type fasta -blast blastx -output ./out.ko
	perl $0 -input faFile -type blastout -blastout blastoutFile -output ./out.ko
USAGE
	exit 1;
}

if (defined $help || !defined $input || !defined $type || (defined $type && $type eq "blastout" && !defined $blast_out)) {
	&usage();
}

# check type
if (index("fasta, blastout, seqids:ncbigene, seqids:ncbigi, seqids:uniprot,", $type . ",") == -1) {
	print STDERR "option -type must be one of the following: fasta, blastout, seqids:ncbigene, seqids:ncbigi, seqids:uniprot\n";
	exit 1;
}

# check input files
push @inputs, $input;
push @inputs, $blast_out if (defined $blast_out);
push @inputs, $kegg;
$exit = 0;
for $file (@inputs) {
	if (!-f $file) {
		print STDERR "file $file not exists\n";
		$exit = 1;
	}
}

if ($exit == 1) {
	exit 1;
}

# check blast
if ($type eq "fasta") {
	%blasts = ("nn" => "blastn", "pp" => "blastp", "np" => "blastx", "pn" => "tblastn"); # query_database
	if (!defined $blast) {
		$queryType = getSeqType($input);
		$dbType = getSeqType($kegg);
		$blast = $blasts{"$queryType$dbType"};
	}
	if (index("blastn, blastp, blastx, tblastn, tblastx,", $blast . ",") == -1) {
		print STDERR "option -blast must be one of the following: blastn, blastp, blastx, tblastn, tblastx\n";
		exit 1;
	}
}

# main
$output ||= &getFileName($input) . ".ko";

if ($type eq "fasta" || $type eq "blastout") { # FASTA or blastout
	# step 1.1: ko
	if ($type eq "fasta") {
		$blast_out = &getFileName($input) . ".blast";
#		system("blastall -d $kegg -i $input -o $blast_out -p $blast -e $evalue -m 8");
	}

	# step 1.2: statistics
	%genes = split /\s/, `grep '^>' $input | awk '{print \$1, 1}'`;
	$total = 0;
	$yes = 0;
	$content = "";
	open BLAST, "< $blast_out" || die $!;
	$cutoff = 0;
	while (<BLAST>) {
		chomp;
		@tabs = split /\t/, $_;
		$tabs[0] = (split /\s/, $tabs[0])[0];
		if (exists $blast_r{$tabs[0]}) {
			$cutoff++;
			next if ($cutoff > $rank);
		} else {
			$cutoff = 1;
		}
		$tabs[-1] = &trim($tabs[-1]);
		push @{$blast_r{$tabs[0]}}, [$tabs[-2], $tabs[-1], $tabs[1], $cutoff];
		@{$kos{$tabs[1]}} = ();
	}
	close BLAST;

	# get kegg-ko relations
	open KO, "< $kegg" || die $!;
	while (<KO>) {
		chomp;
		next unless (/^>.*[\s;]\sK\d+/);
		$_ =~ s/^>//;
		@tabs = split /\s/, $_, 2;
		next if (not exists $kos{$tabs[0]});
		$tabs[1] = " $tabs[1]";
		$tabs[1] =~ s/([ ;]) [^K][^;]*\s;/$1/g;
		$tabs[1] =~ s/; (K[\d]+)/\|$1/g;
		$tabs[1] =~ s/^ *//;
		for (split /\|/, $tabs[1]) {
			$_ = &trim($_);
			@tabs2 = split / /, $_, 2;
			$id = $tabs2[0];
			next if ($id !~ /^K\d+/);
			$def = $tabs2[1] || "";
			push @{$kos{$tabs[0]}}, [$id, $def];
		}
	}
	close KO;

	for $gene (sort keys %genes) {
		$total++;
		$gene =~ s/>//;
		$content .= "$gene\t";
		$first = 1;
		@koids = ();
		if (exists $blast_r{$gene}) {
			for $result (@{$blast_r{$gene}}) {
				if (exists $kos{$result->[2]} && $#{$kos{$result->[2]}} > -1) {
					if ($first == 1) {
						$yes++;
						$content .= "$kos{$result->[2]}->[0]->[0]|$result->[3]|$result->[0]|$result->[1]|$result->[2]|$kos{$result->[2]}->[0]->[1]";
						push @koids, $kos{$result->[2]}->[0]->[0];
						for $i (1 .. $#{$kos{$result->[2]}}) {
							$content .= "!$kos{$result->[2]}->[$i]->[0]|$result->[3]|$result->[0]|$result->[1]|$result->[2]|$kos{$result->[2]}->[$i]->[1]";
							push @koids, $kos{$result->[2]}->[$i]->[0];
						}
						$first = 0;
					} else {
						for $i (0 .. $#{$kos{$result->[2]}}) {
							if (index("," . join(",", @koids) . ",", "," . $kos{$result->[2]}->[$i]->[0] . ",") < 0) {
								$content .= "!$kos{$result->[2]}->[$i]->[0]|$result->[3]|$result->[0]|$result->[1]|$result->[2]|$kos{$result->[2]}->[$i]->[1]";
								push @koids, $kos{$result->[2]}->[$i]->[0];
							}
						}
					}
				}
			}
		}
		$content .= "\n";
	}

	open OUT, "> $output" || die $!;
	print OUT "# Method: BLAST\tCondition: expect <= $evalue; rank <= $rank\n";
	print OUT "# Summary:\t$yes succeed, " . ($total - $yes) . " fail\n\n";
	print OUT "# query\tko_id:rank:evalue:score:identity:ko_definition\n";
	print OUT $content;
	close OUT;
} else { # ID Mapping
	$total = 0;
	$yes = 0;

	open ID, "< $input" || die $!;
	while (<ID>) {
		chomp;
		$id = (split /\s/, $_)[0];
		next if ($id =~ /^Gene/i);
		next if (/^\s*$|^#/);
		$total++;
		$stats{$id} = 1;
	}

	open DB, "< $idPath/$ids{$type}" || $!;
	while (<DB>) {
		chomp;
		@tabs = split /\t/, $_;
		$tabs[1] =~ s/^$ids_fix{$type}//;
		if (exists $stats{$tabs[1]}) {
			$dbs{$tabs[1]} = $tabs[0];
			$dbs2{$tabs[0]} = $tabs[1];
		}
	}
	close DB;

	open KO, "< $id_ko" || ide $!;
	while (<KO>) {
		chomp;
		@tabs = split /\t/, $_;
		$tabs[1] =~ s/^ko://;
		push @{$kos{$tabs[0]}}, $tabs[1] if (exists $dbs2{$tabs[0]});
	}
	close KO;

	for $id (keys %stats) {
		$yes++ if (exists $dbs{$id} && exists $kos{$dbs{$id}});
	}

	open OUT, "> $output" || die $!;
	print OUT "# Method: Id mapping\n";
	print OUT "# Summary:\t$yes succeed, " . ($total - $yes) . " fail\n\n";
	print OUT "# query\tko_id\n";
	for $id (sort keys %stats) {
		print OUT $id;
		if (exists $dbs{$id} && exists $kos{$dbs{$id}}) {
			print OUT "\t" . (join "!", @{$kos{$dbs{$id}}});
		}
		print OUT "\n";
	}
	close OUT;
}

exit 0;

sub getFileName {
	my ($file_name) = @_;
	$file_name = (split /[\/\\]/, $file_name)[-1];
	$file_name =~ s/\.[^\.]*$//;
	return $file_name;
}

sub trim {
	my ($string) = @_;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
