%KEGG;
open IN,"kegg.fa" or die $!;
open OUT,">kegg_no_repeat.fa" or die $!;
$/ = '>';
<IN>;
while(<IN>){
	chomp;
	@a = split /\n/;
	$gi = shift @a;
	next if exists $KEGG{$gi};
	$KEGG{$gi}++;
	print OUT ">$_";
}
close IN;
close OUT;
