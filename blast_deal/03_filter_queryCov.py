"""
Author: Junming Xu
Contact: xujm@realbio.cn
This script

python3 $ ./03_filter_queryCov.py best.m8 query.len

"""

import sys, re, os

cutoff_cov = 0.95

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 2: sys.exit(sys.modules[__name__].__doc__)

f_best_m8 = sys.argv.pop(0)
# f_best_m8 = "best.m8"
f_query_len = sys.argv.pop(0)
# f_query_len = "A_p_0.001.abun.gene.list.fna.len"
F_best_m8 = open(f_best_m8)
F_query_len = open(f_query_len)
O_best = open(f_best_m8 + ".cov", 'w')

d_len = {}
for line in F_query_len:
    line = line.rstrip()
    l_line = line.split('\t')
    d_len[l_line[0]] = l_line[1]

for line in F_best_m8:
    l_line = line.rstrip().split('\t')
    cov = float(l_line[3]) / float(d_len[l_line[0]])
    if cov > cutoff_cov:
        O_best.write(line)

