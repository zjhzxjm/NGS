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
    if len(sys.argv) < 1: sys.exit(sys.modules[__name__].__doc__)