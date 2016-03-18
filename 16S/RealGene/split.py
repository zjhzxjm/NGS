#!/usr/bin/env python
# -*- coding: utf-8 -*- \#
"""
@author = 'Junming Xu'
@date = '2016.03.15'

$ ./split.py work_path R1.fastq.gz R2.fastq.gz sam_barcode.h(hiseq)
"""

import gzip, sys, os
from collections import defaultdict
from Bio import SeqIO
from settings import outer_barcode, inner_barcode


class Sample(object):
    def __init__(self, work_path, compact, sample_name):
        self.compact = compact
        self.sample_name = sample_name
        self.work_path = work_path

        try:
            self.make_path()
        except:
            sys.stderr.write('## Permisson ERROR!\t#some problem accured when create path!\n')

    def make_path(self):
        path = {
            'compact': '%s/QC/%s' % (self.work_path, self.compact),
            'sample': '%s/QC/%s/%s' % (self.work_path, self.compact, self.sample_name)
        }
        for _path in path.intervalues():
            if not os.path.isdir(_path):
                os.makedirs(_path)


if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 4: sys.exit(sys.modules[__name__].__doc__)
    (work_path, file1, file2, sam_barcode) = sys.argv
    work_path = os.path.abspath(work_path)

    sample_info = defaultdict(Sample)
    with open(sam_barcode) as fp:
        fp.next()
        for line in fp:
            (compact, sample_name, barcode, data_type, lib_method, need_seq) = line.rstrip().split('\s+')

            Sample(work_path, compact, sample_name)
            com_sam = compact + "/" + sample_name
            sample_info[com_sam].forward = inner_barcode[tabs[1].split('+')[0]].upper()[:6]
            sample_info[com_sam].reverse = inner_barcode[tabs[1].split('+')[1]].upper()[:6]

    for sample in sample_info:
        sample_info[sample].out1 = open('Split/%s/file1__filterd' % sample, 'w')
        sample_info[sample].out2 = open('Split/%s/file2__filterd' % sample, 'w')

    reads1 = SeqIO.parse(gzip.open(file1), 'fastq')
    reads2 = SeqIO.parse(gzip.open(file2), 'fastq')
    for read1 in reads1:
        read2 = reads2.next()
        if read1.description.split(':')[-1] != outer_barcode or \
                        read2.description.split(':')[-1] != outer_barcode:
            continue
        for sample in sample_info:
            if 0 <= str(read1.seq).upper().find(sample_info[sample].forward) < 6 and \
                                    0 <= str(read2.seq).upper().find(sample_info[sample].reverse) < 6:
                sample_info[sample].out1.write(read1.format('fastq'))
                sample_info[sample].out2.write(read2.format('fastq'))
                break

    for sample in sample_info:
        sample_info[sample].out1.close()
        sample_info[sample].out2.close()
