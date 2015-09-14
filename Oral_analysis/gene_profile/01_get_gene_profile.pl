open IN,"$ARGV[0]" or die;
while (<IN>){
chomp;
print $_,"\n";
$_=(split /\s/)[1];
my @array = split /\//;
my $dir = "$array[0]/$array[1]";
my $sample = $array[1];
print "perl 01_00_parse_contig_abundance_FRENCH.pl /work/Project_ZG/05_GENESET_PROFILING/ZG_LC.Merged.fna $_ $dir/$sample.gene_profile.do $dir/$sample.log.do Dusko \n";
}
close (IN);
