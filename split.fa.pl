#!/usr/bin/perl -w
use strict;

die "perl $0 <fa> <how_many>" unless @ARGV ==2;


my $total = `grep '>' $ARGV[0] | wc -l`;
my $count=0;
my $number = 1;
my $flag = 0;

open FA,$ARGV[0] or die $!;
while(<FA>)
{
    if(/>/)
    {
        $flag = 1;
        $count++;
        if($count > $ARGV[1])
        {
            $count = 0;
            $number++;
        }
        open(FL,">>","$ARGV[0]_$number") or die $!;
        print FL $_;
        close FL or die $!;
    }
    elsif($flag == 1)
    {
        open(FL,">>","$ARGV[0]_$number") or die $!;
        print FL $_;
        close FL or die $!;
    }
}
close FA or die $!;
