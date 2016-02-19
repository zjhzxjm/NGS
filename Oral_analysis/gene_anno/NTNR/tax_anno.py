"""
Author: Junming Xu
Contact: xujm@realbio.cn
This script transfer the taxid to tax from blast m8 file

python3 $ ./tax_anno.py best.m8

"""

import sys, re, os

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 1: sys.exit(sys.modules[__name__].__doc__)

f_best_m8 = sys.argv.pop(0)
# f_best_m8 = "best.m8"
f_id_tax = "/data_center_02/Database/NCBI_TAX/20140515/nt/gi_tax_id_species"
# f_id_tax = "gi_tax_id_species"
f_out = f_best_m8 + '.tax'
F_best_m8 = open(f_best_m8)
F_id_tax = open(f_id_tax)
O_out = open(f_out, 'w')

d_flag = {}
for line in F_best_m8:
    l_line = line.strip().split("\t")
    gi = re.findall(r'gi\|(\d+)', l_line[1])
    d_flag[gi[0]] = 1
F_best_m8.close()

d_tax = {}
for line in F_id_tax:
    l_line = line.strip().split("\t")
    if l_line[0] in d_flag:
        d_tax[l_line[0]] = l_line[2]

F_best_m8 = open(f_best_m8)
for line in F_best_m8:
    line = line.strip()
    l_line = line.split("\t")
    gi = re.findall(r'gi\|(\d+)', l_line[1])
    try:
        prt_line = l_line[0] + "\t" + gi[0] + "\t" + d_tax[gi[0]] + "\n"
    except KeyError:
        prt_line = l_line[0] + "\t" + gi[0] + "\t" + "-" + "\n"
    O_out.write(prt_line)

# d_tax = {}
# for line in F_id_tax:
#     line = line.strip()
#     l_line = line.split("\t")
#     d_tax[l_line[0]] = l_line[2]
#
# for line in F_best_m8:
#     line = line.strip()
#     l_line = line.split("\t")
#     gi = re.findall(r'gi\|(\d+)', l_line[1])
#     try:
#         prt_line = l_line[0] + "\t" + d_tax[gi[0]] + "\n"
#     except KeyError:
#         prt_line = l_line[0] + "\t" + "-" + "\n"
#     O_out.write(prt_line)
