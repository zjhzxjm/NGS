"""
Fish genes name from gene profile table of ZJU carries project, 

$ ./FishGene_Profile.py gene_abun exist_cutoff(0-1) get_sub_abun(0:off[default],1:on)
"""
import sys
import re
import os

def IsExistGene(abun, num):
    num = float(num)
    num = len(abun) - num
    #print("num:\t" + str(num))
    if abun.count('0') <= num:
        return True

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 2: sys.exit(sys.modules[__name__].__doc__)

    f_gene_abun = sys.argv.pop(0)
    cutoff_exists = sys.argv.pop(0)

    lab_get_sub_abun = ''
    A_num = 25*float(cutoff_exists)
    H_num = 19*float(cutoff_exists)
    #print("A_num\t", A_num, "H_num\t", H_num)
    if len(sys.argv) == 1:
        lab_get_sub_abun = sys.argv.pop(0)
    f_A_gene = f_gene_abun + "." + cutoff_exists + '.A_gene.list'
    f_H_gene = f_gene_abun + "." + cutoff_exists +'.H_gene.list'
    fo_abun_all = f_gene_abun + "." + cutoff_exists +'.A_H.gene.profile'
    IN = open(f_gene_abun, 'rt')
    header = IN.readline()
    OT_A = open(f_A_gene, 'wt')
    OT_H = open(f_H_gene, 'wt')
    if lab_get_sub_abun:
        OT_abun_all = open(fo_abun_all, 'wt')
        OT_abun_all.write(header)
    for row in IN:
        a=''
        b=''
        row_v = re.split('\s+',row.strip())
        gene_name = row_v[0] + '\n'
        A_gene_abun = row_v[1:26]
        H_gene_abun = row_v[26:45]
        if IsExistGene(A_gene_abun,str(A_num)):
            OT_A.write(gene_name)
            a = True;
        if IsExistGene(H_gene_abun,str(H_num)):
            OT_H.write(gene_name)
            b = True
        if lab_get_sub_abun:
            if a or b: OT_abun_all.write(row)

    IN.close()
    OT_A.close()
    OT_H.close()
    if lab_get_sub_abun: OT_abun_all.close()
