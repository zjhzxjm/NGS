"""
Author: xujm@realbio.cn
Ver:

"""
# -*- coding: utf-8 -*- \#

import os, re, sys
import argparse
import logging

parser = argparse.ArgumentParser(description="Get top 20 relative abundance")
parser.add_argument('-r', '--relative', dest='relative', help='Relative abundance csv file')
parser.add_argument('-v', '--verbose', action='store_true', dest='verbose', help='Enable debug info')


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
        l_tax[i] = tax_name

    d_all = {}
    for line in F_abun:
        l_line = re.split(',', line.strip())
        s_qual = l_line[0]
        s_day = l_line[1]

        d_abun = {}
        for (i, abun) in enumerate(l_line[3:]):
            d_abun[l_tax[i]] = abun

        try:
            d_all =

