"""
Author: xujm@realbio.cn
Ver:

$ ./cds2pep.py seq.fna seq.pep
:

"""

import os, re, sys
from Bio.Seq import Seq
from Bio import SeqIO
from Bio.Alphabet import IUPAC
# from matplotlib import pyplot as plt
# import numpy as np

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 2: sys.exit(sys.modules[__name__].__doc__)

    f_fna = sys.argv.pop(0)
    # f_fna = '1.fna'
    O_pep = open(sys.argv.pop(0), 'w')
    # O_pep = open('1.pep','w')

    for seq_record in SeqIO.parse(f_fna, "fasta"):
        str_seq_tran = str(seq_record.seq.translate())
        str_out = ">%s\n%s\n" % (seq_record.id, str_seq_tran)
        O_pep.write(str_out)





