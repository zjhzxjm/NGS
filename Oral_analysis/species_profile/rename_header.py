"""
Author: Junming Xu
Contact: xujm@realbio.cn / zjhzxjm@gmail.com
This script rename the header by giving a relalation ship file

$ ./rename_header.py rela.list table > out file
rela.list
new name \s+ old name
"""

import sys, os, re

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 2: sys.exit(sys.modules[__name__].__doc__)

    fi_rela = sys.argv.pop(0)
    fi_table = sys.argv.pop(0)
    fo_table = fi_table + '.header_rename'
    ob_fi_rela = open(fi_rela.rstrip())
    ob_fi_table = open(fi_table.rstrip())

    dict_rela = {}

    for line in ob_fi_rela:
        row = re.split("\s+", line.rstrip())
        dict_rela[row[1]] = row[0]

    line_num = 0
    for line in ob_fi_table:
        line_num += 1
        if line_num == 1:
            sys.stdout.write('\t')
            row = re.split("\s+", line.rstrip())
            #print([i for i in row if i])
            sys.stdout.write('\t'.join([dict_rela[i] for i in row if i]))
            sys.stdout.write('\n')
        else:
            print(line.rstrip())


