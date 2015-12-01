"""
Author: Junming Xu
Contact: xujm@realbio.cn
This script extracts the abundance by the qvalue or pvalue cutoff and sorts the result by qvalue

$ ./extract.py abun_file qvalue_file enrich_file cutoff
qvalue_file and enrich_file are all produced by wilcoxtest script
cutoff: p_0.01 or q_0.01
"""

import sys, re, os, operator

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 4: sys.exit(sys.modules[__name__].__doc__)

    f_abun  = sys.argv.pop(0)
    f_qvalue = sys.argv.pop(0)
    f_enrich = sys.argv.pop(0)
    F_abun, F_qvalue, F_enrich, cutoff = open(f_abun), open(f_qvalue), open(f_enrich), sys.argv.pop(0)

    header = F_abun.readline()
    d_abun = {}
    for line in F_abun:
        l_line = re.split('\s+',  line.strip())
        d_abun[l_line[0]] = line

    d_group = {}
    for line in F_enrich:
        l_line = re.split('\s+', line.strip())
        try:
            d_group[l_line[-1]].append(l_line[0])
        except KeyError:
            d_group[l_line[-1]] = []
            d_group[l_line[-1]].append(l_line[0])

    d_value = {}
    for line in F_qvalue:
        l_line = re.split('\s+', line.strip())
        l_cutoff = re.split('_', cutoff)
        if l_cutoff[0].rstrip() == 'q':
            value = float(l_line[-1])
        elif l_cutoff[0].rstrip() == 'p':
            value = float(l_line[1].rstrip())

        if value > float(l_cutoff[1].rstrip()):
            continue

        for k in d_group:
            try:
                if l_line[0] in d_group[k]: d_value[k][l_line[0]] = value
            except KeyError:
                d_value[k] = {}
                if l_line[0] in d_group[k]: d_value[k][l_line[0]] = value

    for key in d_group:
        try:
            o_abun = key + '_' + str(cutoff) + '.abun'
            O_abun = open(o_abun, 'w')
            O_abun.write(header)
            for species in sorted(d_value[key].items(), key=operator.itemgetter(1),reverse=True):
                O_abun.write(d_abun[species[0]])
            O_abun.close()
        except KeyError:
            continue

