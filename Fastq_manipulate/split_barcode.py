"""
Author: xujm@realbio.cn
Ver:

"""
# -*- coding: utf-8 -*- \#

import os, re, sys
import argparse
import logging
from Bio import SeqIO
import gzip
import re
import fuzzysearch
import setting

parser = argparse.ArgumentParser(description="Split samples from Illumina sequencing")
parser.add_argument('-a', '--fq1', type=str, dest='fq1', help='Read1 fastq file', required=True)
parser.add_argument('-b', '--fq2', type=str, dest='fq2', help='Read2 fastq file', required=True)
parser.add_argument('-s', '--sampleConfig', type=str, dest='sample_config', help='Sample barcode configuration info')
parser.add_argument('-v', '--verbose', action='store_true', dest='verbose', help='Enable debug info')


class RawFastqPairInfo():
    def __init__(self, ob_read1, ob_read2, out_barcode):
        self.ob_read1 = ob_read1
        self.ob_read2 = ob_read2
        self.out_barcode = out_barcode

    def get_barcode_pair(self):
        fq1_seq = str(self.ob_read1.seq)
        fq2_seq = str(self.ob_read2.seq)
        fq1_bar = fq1_seq[:6]
        fq2_bar = fq2_seq[:6]
        return [fq1_bar, fq2_bar]

    def is_need_out_barcode(self):
        """
        Judge out barcode in each reads pair
        Args:
        Returns: True or False

        """
        if fuzzysearch.find_near_matches(self.out_barcode, self.ob_read1.description, 1, 0, 0, 1) \
                and fuzzysearch.find_near_matches(self.out_barcode, self.ob_read2.description, 1, 0, 0, 1):
            return True
        else:
            return False


class Sample():
    def __init__(self, sam_barcode):
        self.sam_barcode = sam_barcode

    def make_dir(self):



if __name__ == '__main__':
    args = parser.parse_args()
    if args.verbose:
        logging.basicConfig(
            level=logging.DEBUG,
            format="[%(asctime)s]%(name)s:%(levelname)s:%(message)s"
        )
    logging.debug("Start running")

    fq1 = args.fq1
    fq2 = args.fq2
    sam_barcode = args.sample_config
    out_barcode = setting.SeqIndex.out_barcode['Test']

    with open(sam_barcode) as f:
        for line in f:


    # uncompress fastq.gz
    if re.findall(r'gz', fq1):
        fq1 = gzip.open(fq1)
    if re.findall(r'gz', fq2):
        fq2 = gzip.open(fq2)

    fq1_iter = SeqIO.parse(fq1, "fastq")
    fq2_iter = SeqIO.parse(fq2, "fastq")

    i = 1
    while i:
        try:
            record_fq1 = next(fq1_iter)
            record_fq2 = next(fq2_iter)
            class_fastq_pair = RawFastqPairInfo(record_fq1, record_fq2, out_barcode)
            if class_fastq_pair.is_need_out_barcode():
                logging.debug("get")
        except StopIteration:
            i = 0

    logging.debug('End running')
