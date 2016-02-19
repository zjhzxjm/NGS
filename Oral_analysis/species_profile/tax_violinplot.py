"""
Author: xujm@realbio.cn
Ver:

$ ./tax_violinplot.py tax.profile
:

"""

import os, re, sys
from matplotlib import pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

def filter_abun(f_tax_profile, o_filtered_profile):
    i = 0
    O_tax_filterd_profile = open(o_filtered_profile, 'w')
    l_samples = []
    d_abun = {}
    d_med = {}
    with open(f_tax_profile) as f:
        for l in f.readlines():
            i += 1
            if i == 1:
                l_samples = [sam for sam in re.split('\s+', l.strip())]
            else:
                l_abun = l.strip().split()
                tax_name = l_abun.pop(0)
                d_abun[tax_name] = [float(abun) for abun in l_abun]
                d_med[tax_name] = np.median(d_abun[tax_name])

    # for v in sorted(d_med.values(), reverse=True):
    #     pass
    l_sorted = sorted(d_med.items(), key=lambda d: d[1], reverse=True)
    prt_line = "Relative abundance\tGroup\ttax\n"
    O_tax_filterd_profile.write(prt_line)
    for i in range(10):
        tax_name = l_sorted[i][0]
        for s_index in range(len(l_samples)):
            group = l_samples[s_index][0]
            if group == "A":
                group = "Carries"
            elif group == "H":
                group = "Health"
            abun = d_abun[tax_name][s_index]
            prt_line = str(abun) + "\t" + group + "\t" + tax_name + "\n"
            O_tax_filterd_profile.write(prt_line)


if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 1: sys.exit(sys.modules[__name__].__doc__)

    f_tax_profile = sys.argv.pop(0)
    # f_tax_profile = '5.abundance.rename_header.st_0.8'
    o_filtered_profile = f_tax_profile + ".top10"
    o_vio = f_tax_profile + ".vio.pdf"
    filter_abun(f_tax_profile, o_filtered_profile)
    # Draw

    tips = pd.read_csv(o_filtered_profile, sep='\t')
    sns.set(style="ticks", palette="pastel", color_codes=True)
    plt.subplots(figsize=(12, 6))
    sns.violinplot(y="tax", x="Relative abundance", hue="Group", scale="width", data=tips, split=True, inner="quart", palette={"Health": sns.xkcd_rgb["peach"], "Carries": sns.xkcd_rgb["baby blue"]})
    sns.despine()
    plt.savefig(o_vio)

