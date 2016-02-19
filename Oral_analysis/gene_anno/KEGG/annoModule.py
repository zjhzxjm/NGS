"""
Author: Junming Xu
Contact: xujm@realbio.cn
This script is anno

python3 $ ./annodule.py blast2ko

"""

import sys, re, os

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 1: sys.exit(sys.modules[__name__].__doc__)


    f_blast2ko = sys.argv.pop(0)
    # f_blast2ko = "DB/module_20150211/blast2ko"
    f_module_class = "/data_center_02/Database/KEGG/module_20150211/module.class"
    f_module_ko = "/data_center_02/Database/KEGG/module_20150211/module_KO.list"
    f_out = f_blast2ko + '.module'
    F_blast2ko = open(f_blast2ko)
    F_module_class = open(f_module_class)
    F_module_ko = open(f_module_ko)
    O_out = open(f_out, 'w')

    l_ko = []
    for line in F_blast2ko:
        row = re.split("\t", line.rstrip())
        try:
            s_ko = re.search(r'(K\d+)', row[1]).group(0)
            l_ko.append(s_ko)
        except IndexError:
            continue
        except AttributeError:
            continue

    d_module = {}
    for line in F_module_ko:
        row = re.split("\t", line.strip())
        for ko in re.split("\(|\)|,|\s", row[1]):
            if ko in l_ko:
                try:
                    d_module[row[0]].append(ko)
                except KeyError:
                    d_module[row[0]] = []
                    d_module[row[0]].append(ko)


    d_class = {}
    d_class_level = {}
    F_module_class.readline()
    for line in F_module_class:
        row = re.split("\t", line.strip())
        if row[0] in d_module.keys():
            s_level = row[1] + ';' + row[2] + ';' + row[3]
            for ko in d_module[row[0]]:
                try:
                    d_class_level[s_level].append(row[0] + '\t' + ko +'\t' + row[4] + '\n')
                except KeyError:
                    d_class_level[s_level] = []
                    d_class_level[s_level].append(row[0] + '\t' + ko +'\t' + row[4] + '\n')

    for k in d_class_level.keys():
        O_out.write(k + "\n")
        for ko in d_class_level[k]:
            O_out.write("\t" + ko)
