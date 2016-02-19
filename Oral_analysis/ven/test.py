"""
Author: xujm@realbio.cn
Ver:

$ ./.py 
:

"""

import os, re, sys
from matplotlib import pyplot as plt
import numpy as np
from draw.VennTool import  VennTool

if __name__ == '__main__':
    sys.argv.pop(0)
    # if len(sys.argv) < 1: sys.exit(sys.modules[__name__].__doc__)

    sub_set = (1, 1, 1, 1, 1, 1, 1)
    set_lab = ('A', 'B', 'C')
    out = './'
    VennTool.draw_venn3(sub_set, set_lab, out)


