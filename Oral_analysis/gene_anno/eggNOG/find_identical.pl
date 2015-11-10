#!usr/bin/perl
use strict;
use warnings;
die "output type\tyou can chose 1,2,3,4,5\n1\toutput the identical in file1\n2\toutput the identical in file2\n3\toutput the identical in the file1 and file2\n4\toutput the different in file1\n5\toutput the different in file2\nuseage:perl $0 <file1> <file2> <the same site 1> <the same site 2> <output type>\n" unless (@ARGV==5);
open A,$ARGV[0] || die "can't open the $!";
open B,$ARGV[1] || die "can't open the $!";
my %hash1;
my %hash2;
my $type=$ARGV[4];
my $site1=$ARGV[2]-1;
my $site2=$ARGV[3]-1;
while(<A>)
{
	chomp;
	my $aa=$_;
	my @a=split /\t+/,$_;
	$hash1{$a[$site1]}=$aa;
	#print "$a[0]\t$a[1]\t$a[2]\n";	
}
while(<B>)
{
	chomp;
	my $bb=$_;
        my @b=split /\t+/,$_;
	$hash2{$b[$site2]}=$bb;
        #print "$b[0]\t$b[1]\t$b[2]\n";
}
if($type==4)
{
    foreach(keys %hash2)
    {
        if(exists $hash1{$_})
        {
            delete $hash1{$_};
        }
    }
    foreach(keys %hash1)
    {
        print "$hash1{$_}\n";
    }
}
if($type==5)
{
foreach (keys %hash1)
{
     if(exists $hash2{$_})
    {
         delete $hash2{$_};
    }
}
foreach(keys %hash2)
{
    print "$hash2{$_}\n";
}
}
if($type==1)
{
    foreach(keys %hash1)
    {
        if(exists $hash2{$_})
        {
            print "$hash1{$_}\n";
        }
    }
}
if($type==2)
{
   foreach(keys %hash1)
   {
       if(exists $hash2{$_})
       {
           print "$hash2{$_}\n";
       }
   }
}
if($type==3)
{
foreach (keys %hash1)
{
	if(exists $hash2{$_})
	{
		print "$hash1{$_}\t$hash2{$_}\n";
	}
}
}
