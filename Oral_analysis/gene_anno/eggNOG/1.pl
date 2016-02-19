my (%A,%H);
open IN,"A.list";
while(<IN>){
	chomp;
	$A{$_}=1;
}
open IN,"H.list";
while(<IN>){
	chomp;
	$H{$_}=1;
}
open IN,"/data_center_01/DNA_Data/data1/Database/eggNOGv4.0/NOG.funccat.txt";
my %hash;
while(<IN>){
	chomp;
	my ($nog,$class)=(split /\t/)[0,-1];
#	$A{$nog} || $H{$nog} || next;
	$class=~s/\&//g;
	my @a=split //,$class;
	my %count;
	my @b=grep {++$count{$_}<2} @a;
	for $t(@b){
		$A{$nog} && $hash{$t}->[0]++;
		$H{$nog} && $hash{$t}->[1]++;
		$hash{$t}->[2]++;
	}
}
while(my ($class,$tmp)=each %hash){
	$hash{$class}->[0]||=0;
	$hash{$class}->[1]||=0;
	$hash{$class}->[2]||=0;
	print "$class\t$hash{$class}->[0]\t$hash{$class}->[1]\t$hash{$class}->[2]\n";
#	print "$class\t$tmp\n";
}

