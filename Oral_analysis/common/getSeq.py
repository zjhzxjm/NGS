"""
Extract some sequences from a FASTA file given the id list

$ ./getSeq.py id_list fasta_file out_file
"""

import sys
import re
from Bio import SeqIO

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 3: sys.exit(sys.modules[__name__].__doc__)

    fi_id_list = sys.argv.pop(0)
    fi_fasta = sys.argv.pop(0)
    fo_fasta = sys.argv.pop(0)
    IN_id_list = open(fi_id_list, 'rt')
    OT = open(fo_fasta, 'wt')
    d_gene = {}
    for row in IN_id_list:
        gene = row.strip()
        d_gene[gene] = 1
    # genes = re.split('\n', IN_id_list.read().strip())
    IN_id_list.close()
    for seq_record in SeqIO.parse(fi_fasta, "fasta"):
        # if seq_record.id in genes:
        try:
            if d_gene[seq_record.id]:
                out = '>' + seq_record.id + '\n' + str(seq_record.seq) + '\n'
                OT.write(out)
        except KeyError:
            # print(seq_record.id)
            continue
    OT.close()
