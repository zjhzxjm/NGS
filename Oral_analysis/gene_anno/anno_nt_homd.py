"""
Author: Junming Xu
Contact: xujm@realbio.cn
This script is anno

python3 $ ./anno_homd.py best.m8.cov.tax

"""

import sys, re, os

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 1: sys.exit(sys.modules[__name__].__doc__)

# f_best_m8_cov_tax = 'best.m8.cov.tax'
f_best_m8_cov_tax = sys.argv.pop(0)
f_homd_tax = '/data_center_07/User/xujm/Oral_ZJU/data/seqs/04.GeneSet/homd/oral_microbiome.na.title'
f_out = f_best_m8_cov_tax + ".homd"
F_best_m8_cov_tax = open(f_best_m8_cov_tax)
F_homd_tax = open(f_homd_tax)
O_out = open(f_out, 'w')

d_tax = {}
for line in F_homd_tax:
    l_line = line.strip().split(",")
    l_tax = l_line[0].split(" ")
    d_tax[l_tax[0].lstrip('>')] = ' '.join(l_tax[1:])

for line in F_best_m8_cov_tax:
    line = line.strip()
    l_line = line.split("\t")
    try:
        prt_line = line + "\t" + d_tax[l_line[0]] + "\n"
    except KeyError:
        prt_line = line + "\t" + "-" + "\n"
    O_out.write(prt_line)






# for line in F_best_m8_cov_tax:

