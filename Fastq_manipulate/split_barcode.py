"""
Author: xujm@realbio.cn
Ver:

"""
# -*- coding: utf-8 -*- \#
import argparse
import logging
from Bio import SeqIO
import gzip
import re
import fuzzysearch
import setting
import subprocess

parser = argparse.ArgumentParser(description="Split samples from Illumina sequencing")
parser.add_argument('-a', '--fq1', type=str, dest='fq1', help='Read1 fastq file', required=True)
parser.add_argument('-b', '--fq2', type=str, dest='fq2', help='Read2 fastq file', required=True)
parser.add_argument('-s', '--sampleConfig', type=str, dest='sample_config', help='Sample barcode configuration info',
                    required=True)
parser.add_argument('-v', '--verbose', action='store_true', dest='verbose', help='Enable debug info')


class RawFastqPairInfo:
    def __init__(self, ob_read1, ob_read2, outbarcode, barcode_type='hiseq'):
        self.ob_read1 = ob_read1
        self.ob_read2 = ob_read2
        self.out_barcode = outbarcode
        self.barcode_type = barcode_type

    def get_barcode_pair(self):
        fq1_seq = str(self.ob_read1.seq)
        fq2_seq = str(self.ob_read2.seq)
        fq1_bar = fq1_seq[:6]
        fq2_bar = fq2_seq[:6]

        try:
            f_barcode = "F" + str(setting.SeqIndex.barcode[self.barcode_type].index(fq1_bar) + 1)
        except ValueError:
            f_barcode = ''

        try:
            r_barcode = "R" + str(setting.SeqIndex.barcode[self.barcode_type].index(fq2_bar) + 1)
        except ValueError:
            r_barcode = ''

        if f_barcode and r_barcode:
            return f_barcode + "+" + r_barcode

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


class Sample:
    def __init__(self, sam_barcode):
        d_dir = {}
        with open(sam_barcode) as f:
            for line in f:
                (project, sample, barcode) = line.strip().split()[:3]
                code = subprocess.call(['mkdir', '-p', project+"/"+sample])
                if code:
                    logging.error("Can't make filefoder: %s/%s" % (project, sample))
                d_dir[barcode] = project + "/" + sample
        logging.debug(d_dir)
        self.d_dir = d_dir


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
    logging.info("Start running")

    fq1 = args.fq1
    fq2 = args.fq2
    class_sample = Sample(args.sample_config)
    out_barcode = setting.SeqIndex.out_barcode['hiseq']

    if re.findall(r'gz', fq1):
        F_fq1 = gzip.open(fq1)
    else:
        F_fq1 = open(fq1)
    if re.findall(r'gz', fq2):
        F_fq2 = gzip.open(fq2)
    else:
        F_fq2 = open(fq2)

    O_fq1 = {}
    O_fq2 = {}
    for (k, v) in class_sample.d_dir.items():
        O_fq1[k] = open(v + "/R1.fastq_filterd", "w")
        O_fq2[k] = open(v + "/R2.fastq_filterd", "w")

    fq1_iter = SeqIO.parse(F_fq1, "fastq")
    fq2_iter = SeqIO.parse(F_fq2, "fastq")

    d_count = {'total': 0, 'out_total': 0}
    while True:
        try:
            record_fq1 = next(fq1_iter)
            record_fq2 = next(fq2_iter)
            class_fastq_pair = RawFastqPairInfo(record_fq1, record_fq2, out_barcode)

            d_count['total'] += 1
            if class_fastq_pair.is_need_out_barcode():
                # Fetch our out barcode
                d_count['out_total'] += 1
                barcode_pair = class_fastq_pair.get_barcode_pair()
                if barcode_pair:
                    try:
                        if class_sample.d_dir[barcode_pair]:
                            logging.debug("Our seq %s" % class_sample.d_dir[barcode_pair])
                            O_fq1[barcode_pair].write(record_fq1.format("fastq"))
                            O_fq2[barcode_pair].write(record_fq2.format("fastq"))
                            logging.debug(record_fq1.format("fastq"))
                            try:
                                d_count[class_sample.d_dir[barcode_pair]] += 1
                            except KeyError:
                                d_count[class_sample.d_dir[barcode_pair]] = 1
                    except KeyError:
                        try:
                            d_count[barcode_pair] += 1
                        except KeyError:
                            d_count[barcode_pair] = 1
                else:

        except StopIteration:
            break

    for k in class_sample.d_dir.iterkeys():
        O_fq1[k].close()
        O_fq2[k].close()

    for (k, v) in d_count.items():
        if k == "total":
            logging.info("The total reads number: %d" % v)
        elif k == "out_total":
            logging.info("Total reads number with our out barcode: %d" % v)
        else:
            logging.info("%s: %d" % (k, v))

    logging.info('End running')
