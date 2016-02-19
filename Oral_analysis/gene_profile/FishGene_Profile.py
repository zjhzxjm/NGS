"""
Fish genes name from gene profile table of ZJU carries project, 

$ ./FishGene_Profile.py gene_abun exist_cutoff(0-1) get_sub_abun(0:off[default],1:on) median_cutoff([option]off for default)
"""
import sys
import re
import os
import numpy as np
import matplotlib.pyplot as plt

def IsExistGene(abun, num):
    num = float(num)
    num = len(abun) - num
    #print("num:\t" + str(num))
    if abun.count('0') <= num:
        return True

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 3: sys.exit(sys.modules[__name__].__doc__)

    f_gene_abun = sys.argv.pop(0)
    # f_gene_abun = 'lih.homd.gene.profile'
    cutoff_exists = sys.argv.pop(0)
    # cutoff_exists = '0.8'
    lab_get_sub_abun = sys.argv.pop(0)
    # lab_get_sub_abun = '1'
    try:
        cutoff_median = float(sys.argv.pop(0))
    except IndexError:
        cutoff_median = 'off'
    # cutoff_median = '0.00001'

    A_num = 25*float(cutoff_exists)
    H_num = 19*float(cutoff_exists)
    #print("A_num\t", A_num, "H_num\t", H_num)
    if cutoff_median == 'off':
        f_A_gene = f_gene_abun + ".ex" + cutoff_exists + '.A_gene.list'
    else:
        f_A_gene = f_gene_abun + ".ex" + cutoff_exists + '.me' + str(cutoff_median) +  '.A_gene.list'

    if cutoff_median == 'off':
        f_H_gene = f_gene_abun + ".ex" + cutoff_exists + '.H_gene.list'
    else:
        f_H_gene = f_gene_abun + ".ex" + cutoff_exists + '.me' + str(cutoff_median) + '.H_gene.list'

    if cutoff_exists == 'off':
        fo_abun_all = f_gene_abun + ".ex" + cutoff_exists + '.A_H.gene.profile'
    else:
        fo_abun_all = f_gene_abun + ".ex" + cutoff_exists + '.me' + str(cutoff_median) +  '.A_H.gene.profile'

    f_A_median = f_gene_abun + ".A.median"
    f_H_median = f_gene_abun + ".H.median"
    IN = open(f_gene_abun, 'rt')
    header = IN.readline()
    OT_A = open(f_A_gene, 'wt')
    O_A_median = open(f_A_median, "w")
    OT_H = open(f_H_gene, 'wt')
    O_H_median = open(f_H_median, "w")
    if lab_get_sub_abun:
        OT_abun_all = open(fo_abun_all, 'wt')
        OT_abun_all.write(header)

    l_A_median = []
    l_H_median = []
    for row in IN:
        a = ''
        b = ''
        row_v = re.split('\s+', row.strip())
        gene_name = row_v[0] + '\n'

        A_gene_abun = [float(i) for i in row_v[1:26]]
        A_median = np.median(A_gene_abun)
        O_A_median.write(gene_name.strip() + "\t" + str(A_median) + "\n")
        l_A_median.append(A_median)

        H_gene_abun = [float(i) for i in row_v[26:45]]
        H_median = np.median(H_gene_abun)
        O_H_median.write(gene_name.strip() + "\t" + str(H_median) + "\n")
        l_H_median.append(H_median)

        A_gene_abun = row_v[1:26]
        H_gene_abun = row_v[26:45]


        if cutoff_median != 'off':
            if A_median > cutoff_median or H_median > cutoff_median:
                continue
        if IsExistGene(A_gene_abun, str(A_num)):
            OT_A.write(gene_name)
            a = True
        if IsExistGene(H_gene_abun, str(H_num)):
            OT_H.write(gene_name)
            b = True
        if lab_get_sub_abun:
            if a or b: OT_abun_all.write(row)

    IN.close()
    OT_A.close()
    OT_H.close()
    if lab_get_sub_abun: OT_abun_all.close()

    # plt.subplot(221)
    # plt.boxplot(l_A_median, vert=False)
    # plt.xlim(0.00001, 0.001)
    # plt.subplot(222)
    # plt.hist(l_A_median)
    # plt.xlim(0.00001, 0.001)
    # plt.subplot(223)
    # plt.boxplot(l_H_median, vert=False)
    # plt.xlim(0.00001, 0.001)
    # plt.subplot(224)
    # plt.hist(l_H_median)
    # plt.xlim(0.00001, 0.001)
    # plt.savefig('median_chart.png')