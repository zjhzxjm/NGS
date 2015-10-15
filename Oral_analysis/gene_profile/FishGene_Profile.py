import sys
import re
import os

def IsExistGene(abun,num):
    num = len(abun) - num
    if abun.count('0') <= num:
        return True

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 1:
        sys.stderr.write('Usage: python FishGene_Profile.py gene_abun\n')
        sys.exit()
    f_gene_abun = sys.argv.pop(0)
    f_A_gene = f_gene_abun + '.A_gene.list'
    f_H_gene = f_gene_abun + '.H_gene.list'
    IN = open(f_gene_abun, 'rt')
    IN.readline()
    OT_A = open(f_A_gene, 'wt')
    OT_H = open(f_H_gene, 'wt')
    for row in IN:
        row_v = re.split('\t',row.strip())
        gene_name = row_v[0] + '\n'
        A_gene_abun = row_v[1:26]
        H_gene_abun = row_v[26:45]
        if IsExistGene(A_gene_abun,20):
            OT_A.write(gene_name)
        if IsExistGene(H_gene_abun,16):
            OT_H.write(gene_name)
    IN.close()
    OT_A.close()
    OT_H.close()



