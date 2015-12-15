perl -e 'open IN,"KO_bar/two-tail_p0.05/A.list";while(<IN>){chomp;my $ko=(split /\t/)[0];$hash{$ko}=1;}open IN,"A.stat";while(<IN>){chomp;for my $ko(keys %hash){/$ko/ && print "$_\n";}}'
