open IN,"<$ARGV[0]";
open OT,">$ARGV[1]";

my @H=qw( 13 14 15 36 37 38 40 41 42 43 44 45 47 48 49 50 51 52 53 );
my @A=qw( 5 8 10 11 12 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 );
my %hash;
chomp(my $line=<IN>);
$line=~s/M//g;
$line=~s/H//g;
$line=~s/A//g;
$line=~s/^\t//;
my @sample=split /\t/,$line;
while(<IN>){
	chomp;
	my @ab=split /\t/;
	my $gene_id=shift @ab;
	for my $n(0..$#ab){
		defined $ab[$n] || do {print "$n"; die};
		$hash{$gene_id}->{$sample[$n]}=$ab[$n];
	}
}
my $id;

for $id(@H){
	print OT "H$id\t";
}
my $line;
for $id(@A){
	$line.="A$id\t";
}
$line=~s/\t$//;
print OT "$line\n";
while(my ($gene_id,$tmp)=each %hash){
	print OT "$gene_id";
	my $id;
	for $id(@H){
		defined $tmp->{$id}  || print $tmp->{$id};#"$gene_id\t$id\n";
		print OT "\t$tmp->{$id}";
	}
	for $id(@A){
		defined $tmp->{$id}  || print "$gene_id\t$id\n";
		print OT "\t$tmp->{$id}";
	}
	print OT "\n";
}
