"""
Author: Junming Xu
Contact: xujm@realbio.cn
This script filters the abundance by giving abundance file among different groups

$ ./filter_abun.py abun_file groups_file exists_cutoff
groups_file:
group_name\tabun_header1,abun_header2
"""

import sys, re, os
if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 3: sys.exit(sys.modules[__name__].__doc__)

    f_abun = sys.argv.pop(0)
    F_abun, F_group, cutoff = open(f_abun), open(sys.argv.pop(0)), float(sys.argv.pop(0))

    O_abun = open(f_abun + '_' + str(cutoff),'w')

    d_group  = {}
    d_exist_num = {}
    d_filtered_abun = {}
    for line in F_group:
        l_line = re.split('\s+', line.rstrip())
        l_sample = re.split(',', l_line[1])
        for sample in l_sample:
            d_group[sample] = l_line[0]
        d_exist_num[l_line[0]] = len(l_sample)*cutoff
        d_filtered_abun[l_line[0]] = []

    header = F_abun.readline()
    O_abun.write(header)
    l_header = re.split('\s+', header.rstrip())
    for line in F_abun:
        prt_flag = 0
        l_line = re.split('\s+', line.rstrip())
        for num in list(range(1,len(l_header))):
            if float(l_line[num]) > 0:
                d_filtered_abun[d_group[l_header[num]]].append(l_line[num])
        for key in d_filtered_abun:
            if len(d_filtered_abun[key]) > d_exist_num[key]:
                prt_flag = 1
            d_filtered_abun[key] = []
        if prt_flag == 1:
            O_abun.write(line)
