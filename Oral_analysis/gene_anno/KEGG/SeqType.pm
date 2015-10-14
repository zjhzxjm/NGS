package SeqType;

=pod
description: get type of sequence files
author: Zhang Fangxian, zhangfx@genomics.org.cn
created: 20091111
modified: 20091111
=cut

use warnings;
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(getSeqType);

sub getSeqType {
	my (@files) = @_;
	my $nt = "ACTGUN";
	my $type = "n"; # n: nucleotide, p: protein
	my $result = "";
	for my $file (@files) {
		$type = "n";
		open IN, "< $file" || die "file $file: $!";
		while (<IN>) {
			chomp;
			next if (/^[>@]|^[\s]*$/);
			$_ = uc($_);
			for (my $i = 0; $i < length($_); $i++) {
				if (index($nt, substr($_, $i, 1)) < 0) {
					$type = "p";
					last;
				}
			}
			last;
		}
		close IN;
		$result .= $type;
	}
	return $result;
}
