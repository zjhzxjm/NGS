"""
Author: xujm@realbio.cn
Ver:

"""
# -*- coding: utf-8 -*- \#

import os, re, sys
import argparse
import logging
from Bio import SeqIO
from numpy import mean

parser = argparse.ArgumentParser(description="")
parser.add_argument('-i', '--input', type=str, dest='input', help='fastq file', required=True)
parser.add_argument('-o', '--output', type=str, dest='output', help='filtered fastq out', required=True)
parser.add_argument('-q', '--qmin', type=int, dest='qmin', help='min quality score, default is 30')
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

if __name__ == '__main__':
    args = parser.parse_args()
    fq = args.input
    out = args.output
    if args.qmin:
        qmin = args.qmin
    else:
        qmin = 30

    sample_name = " " + out.split("/")[-2]
    fq_iter = SeqIO.parse(open(fq), "fastq")
    O_fq = open(out, "w")
    while True:
        try:
            record = next(fq_iter)
            logging.debug(type(mean(record.letter_annotations["phred_quality"])))
            if qmin > mean(record.letter_annotations["phred_quality"]):
                continue
            record.description += sample_name
            O_fq.write(record.format("fastq"))
        except StopIteration:
            break
    O_fq.close()
