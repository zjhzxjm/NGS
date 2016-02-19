"""
Author: xujm@realbio.cn

$ ./id_list2ven.py A_list.id,B_list.id,C_list.id,...
list.id:
"""

import os, re, sys
from matplotlib import pyplot as plt
import numpy as np
import itertools

def set_ope()

if __name__ == '__main__':
    sys.argv.pop(0)
    # if len(sys.argv) < 1: sys.exit(sys.modules[__name__].__doc__)

    # l_file = re.split(',',sys.argv.pop(0).strip())
    l_file = re.split(',', "pro_ven_id_from_clstr/1.list.id,pro_ven_id_from_clstr/2.list.id,pro_ven_id_from_clstr/3.list.id")

    i = 0
    for f in l_file:
        locals()['l_'+ str(i)] = []
        with open(f) as F:
            for line in F:
                locals()['l_' + str(i)].append(line.strip())
        i += 1

    l_set = []
    for j in range(i):
        l_set.append(set(locals()['l_' + str(j)]))
        
    for j in range(2, i+1):
        for t in itertools.combinations(l_set, j):


        

