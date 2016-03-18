"""
Author: xujm@realbio.cn
Ver:20160317

$ ./stat_barcode.py R1.fsatq.gz R2.gastq.gz out
:

"""

import re
import sys
import time
from Bio import SeqIO

import fuzzysearch
import gzip
import setting


def get_barcode_index(fq, barcode = 'hiseq'):
    sys.stdout.write("%s get barcode index start process at %s" % (fq, time.ctime()))
    if re.findall(r'gz', fq):
        fq = gzip.open(fq)
    out_barcode = setting.SeqIndex.out_barcode

    barcode_index = {}
    for k, v in enumerate(setting.SeqIndex.barcode[barcode]):
        barcode_index[v] = k + 1

    iter_fq = SeqIO.parse(fq, "fastq")

    l_barcode = []
    for ob_fq in iter_fq:
        fq_out_barcode = ob_fq.description[-6:]
        fq_barcode = str(ob_fq.seq)[:6]

        try:
            if fuzzysearch.find_near_matches(out_barcode, fq_out_barcode, 1, 1, 1, 1):
               out_str = '1\t' + fq_out_barcode + '\t' + str(barcode_index[fq_barcode]) + '\t' + fq_barcode
            else:
               out_str = '0\t' + fq_out_barcode + '\t' + str(barcode_index[fq_barcode]) + '\t' + fq_barcode
        except KeyError:
            out_str = '2\t' + fq_out_barcode
        l_barcode.append(out_str)

    return l_barcode


if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 3: sys.exit(sys.modules[__name__].__doc__)

    (fq1, fq2, out) = sys.argv
    # (fq1, fq2, out) = ('../Test/Fastq_manipulate/H16A28P250-1-XIN__L2_1.clean.test.R1.fastq.gz', '../Test/Fastq_manipulate/H16A28P250-1-XIN__L2_2.clean.test.R2.fastq.gz', 'out')
    # (fq1, fq2, out) = ('../Test/Fastq_manipulate/1', '../Test/Fastq_manipulate/2', 'out')

    l_fq1 = get_barcode_index(fq1)
    l_fq2 = get_barcode_index(fq2)
    f_out = open(out, 'w')

    if len(l_fq1) == len(l_fq2):
        sum_barcode = {}
        sum_other_barcode = {}
        num_read = len(l_fq1)
        sys.stdout.write("Sum start process at %s" % time.ctime())
        for i in xrange(num_read):
            f_out.write('Read1:\t' + l_fq1[i] + ' Read2:\t' + l_fq2[i] + '\n')
            sp_l_fq1 = l_fq1[i].split('\t')
            sp_l_fq2 = l_fq2[i].split('\t')

            if sp_l_fq1[0] == '1' and sp_l_fq2[0] == '1':
                pair_barcode = 'F' + sp_l_fq1[2] + '+R' + sp_l_fq2[2]
                try:
                    sum_barcode[pair_barcode] += 1
                except KeyError:
                    sum_barcode[pair_barcode] = 1
            elif sp_l_fq1[0] != '2' and sp_l_fq2[0] != '2':
                pair_barcode = 'F' + sp_l_fq1[2] + '+R' + sp_l_fq2[2]
                try:
                    sum_other_barcode[pair_barcode] += 1
                except KeyError:
                    sum_other_barcode[pair_barcode] = 1
            else:
                continue

        print "#########our out barcode########\n"
        sort_sum_barcode = sorted(sum_barcode.iteritems(), key=lambda d:d[1], reverse=True)
        for i in sort_sum_barcode:
            print i
        print "#########other out barcode########\n"
        sort_sum_other_barcode = sorted(sum_other_barcode.iteritems(), key=lambda d:d[1], reverse=True)
        for i in sort_sum_other_barcode:
            print i
    else:
        sys.stderr("Error: not the same number betwwen fq1 and fq2\n")

    sys.stdout.write("Finish at %s" % time.ctime())

