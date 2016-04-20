"""
Author: xujm@realbio.cn
Ver:

"""
# -*- coding: utf-8 -*- \#

import os, re, sys
import argparse
import logging
from collections import defaultdict
import json
import numpy as np

parser = argparse.ArgumentParser(description="Get top 20 relative abundance")
parser.add_argument('-r', '--relative', dest='relative', help='Relative abundance csv file', required=True)
parser.add_argument('-v', '--verbose', action='store_true', dest='verbose', help='Enable debug info')


def tree():
    return defaultdict(tree)


def cal_ave(d_abun):
    for (day, v1) in d_abun.iteritems():
        for (qual, v2) in d_abun[day].iteritems():
            for (tax, v3) in d_abun[day][qual].iteritems():
                d_abun[day][qual][tax] = np.average(v3)
    return d_abun


def sort_output(d_abun):
    sort_day_abun = sorted(d_abun.iteritems(), key=lambda d: d[0])
    print "Day\tQual\tTax\tAbun"
    for (day, v1) in sort_day_abun:
        sort_good_abun = sorted(v1['good'].iteritems(), key=lambda d: d[1], reverse=True)
        sort_inter_abun = sorted(v1['intermediate'].iteritems(), key=lambda d: d[1], reverse=True)
        sort_poor_abun = sorted(v1['poor'].iteritems(), key=lambda d:d[1], reverse=True)
        for (tax, v2) in sort_good_abun:
            print"%d\tgood\t%s\t%s" % (day, tax, str(format(v2, '.2e')))
        for (tax, v2) in sort_inter_abun:
            print"%d\tintermediate\t%s\t%s" % (day, tax, str(format(v2, '.2e')))
        for (tax, v2) in sort_poor_abun:
            print"%d\tpoor\t%s\t%s" % (day, tax, str(format(v2, '.2e')))


if __name__ == '__main__':
    args = parser.parse_args()
    if args.verbose:
        logging.basicConfig(
            level=logging.DEBUG,
            format="[%(asctime)s]%(name)s:%(levelname)s:%(message)s",
            filename='debug.log'
        )
    else:
        logging.basicConfig(
            level=logging.INFO,
            format="[%(asctime)s]%(name)s:%(levelname)s:%(message)s",
            filename='info.log'
        )

    F_abun = open(args.relative)

    header = F_abun.readline()
    l_header = re.split(',', header.strip())
    l_tax = []
    for (i, tax_name) in enumerate(l_header[3:]):
        l_tax.append(tax_name)
    logging.debug(l_tax)

    abun = tree()
    for line in F_abun:
        l_line = re.split(',', line.strip())
        s_qual = l_line[0]
        s_day = int(l_line[1])
        for (i, v) in enumerate(l_line[3:]):
            # logging.debug(l_tax[i])
            if abun[s_day][s_qual].get(l_tax[i]):
                abun[s_day][s_qual][l_tax[i]].append(float(v))
            else:
                abun[s_day][s_qual][l_tax[i]] = [float(v)]

    logging.debug(json.dumps(abun))
    sort_output(cal_ave(abun))
    logging.debug(json.dumps(abun))
