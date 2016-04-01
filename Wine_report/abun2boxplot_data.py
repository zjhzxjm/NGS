"""
Author: xujm@realbio.cn
Ver:

$ ./.py 
:

"""

import os, re, sys
from matplotlib import pyplot as plt
import numpy as np

if __name__ == '__main__':
    sys.argv.pop(0)
    # if len(sys.argv) < 1: sys.exit(sys.modules[__name__].__doc__)

    # f_abun = sys.argv.pop(0)
    f_abun = "03_10_otu_table_L6_manual.csv"

    F_abun = open(f_abun)

    header = F_abun.readline()
    l_header = re.split(',', header.strip())
    O_abun = []
    str_out = ",".join(l_header[0:3]) + ",Abun\n"
    for (i, tax_name) in enumerate(l_header[3:]):
        out = tax_name + ".csv"
        O_abun.append(open(out, 'w'))
        O_abun[i].write(str_out)

    for line in F_abun:
        l_line = re.split(',', line.strip())

        for (i,abun) in enumerate(l_line[3:]):
            str_out = ",".join(l_line[0:3]) + "," + abun + "\n"
            O_abun[i].write(str_out)

    for handle in O_abun:
        handle.close()




