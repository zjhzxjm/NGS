import sys
import re
import os
from Bio import SeqIO

if __name__ == '__main__':
    app_name = sys.argv.pop(0)
    if len(sys.argv) < 3:
        sys.stderr.write('Usage: python '+ app_name + 'id_list fasta_file out_file\n')
        sys.exit()

    fi_id_list = sys.argv.pop(0)
    fi_fasta = sys.argv.pop(0)
    fo_fasta = sys.argv.pop(0)
    IN_id_list = open(fi_id_list, 'rt')
    OT = open(fo_fasta, 'wt')
    genes = re.split('\n',IN_id_list.read().strip())
    #genes = []
    #for row in IN_id_list:
        #genes.append(row.strip()) 
    IN_id_list.close()
    for seq_record in SeqIO.parse(fi_fasta,"fasta"):
        if seq_record.id in genes:
            out = '>' + seq_record.id + '\n' + str(seq_record.seq) + '\n'
            OT.write(out)
    OT.close()
