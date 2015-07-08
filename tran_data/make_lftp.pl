#!usr/bin/perl-w
use strict;
use Cwd;

die "$0 <samlist><remote_Project_name>" unless @ARGV == 2;

my $dir = getcwd;

open QSUB,">qsub.sh" or die "cant open qsub.sh\n";
unless(-e $ARGV[0]){
	open OUT,">lftp.sh" or die "\n cant open lftp.sh \n";
	print OUT "HOST=genomics.wuxiapptec.com.cn
		USER=Realbio_LYQ
		PASS=REALBIO8o9y%lyq
		echo 'Starting to sftp...'
		lftp -u \${USER},\${PASS} sftp:\/\/\${HOST} <<EOF
		lcd $dir
		cd \/data
		mirror --use-pget-n=10 $ARGV[1]\/
		bye
		EOF
		echo 'mirror done'";
		
		close OUT;
		print QSUB "sh $dir\/lftp.sh\n";
}else{

open LIST,"$ARGV[0]" or die "\n cant open $ARGV[0] \n";
while (<LIST>) {
	chomp;
	mkdir $_;
	open OUT,">$_\/$_\_lftp.sh" or die "\n cant open $_\_lftp.sh \n";
#print "$_\/$_\_lftp.sh";
	print OUT "HOST=genomics.wuxiapptec.com.cn
		USER=Realbio_LYQ
		PASS=REALBIO8o9y%lyq
		echo 'Starting to sftp...'
		lftp -u \${USER},\${PASS} sftp:\/\/\${HOST} <<EOF
		lcd $dir\/$_\/
		cd \/data\/$ARGV[1]\/$_\/
		mget -c n 10 *.*
		bye
		EOF
		echo 'done'";
	close OUT;
	print QSUB "sh $dir\/$_\/$_\_lftp.sh\n cd $dir\/$_\n md5sum -c *.md5 >md5.ck\nrm -f *.sh\n";
}
close LIST;
}
close QSUB;

