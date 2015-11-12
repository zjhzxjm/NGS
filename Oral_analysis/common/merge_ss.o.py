"""
This script merge all stat result from ss.o script
Author:xujm@realbio.cn
Ver:20151112

$ ./merge_ss.o.py stat_list > outfile
stat_list:
.../sample_name/kmer_num/*.stat
"""

import sys, re

def getInfo(file):
    fi_file, d_info = open(file), {}
    for line in fi_file:
        if re.search('\S+',line.rstrip()):
            line = line.rstrip().split("\t")
            if re.search("Total number", line[1]):
                d_info['num'] = line[2].split()[5]
            elif re.search("N50", line[1]):
                d_info['N50'] = line[2].split()[5]
            elif re.search("N90", line[1]):
                d_info['N90'] = line[2].split()[5]
    return d_info

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 1: sys.exit(sys.modules[__name__].__doc__)

    fi_stat_list = sys.argv.pop(0)
    IN_list = open(fi_stat_list)
    for line in IN_list:
        d = getInfo(line.rstrip())
        sam = line.rstrip().split("/")[-3]
        kmer = line.rstrip().split("/")[-2]
        sys.stdout.write(sam +"\t"+ kmer +"\t"+ d['num'] +"\t"+ d['N50'] +"\t"+ d['N90'] +"\n")
