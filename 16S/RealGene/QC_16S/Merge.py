from __future__ import division
import os
import re
import sys
import random
import threading
from Bio import SeqIO
from settings import rename,parse_sam_all


class MergePerCompact(object):
    def __init__(self,compact_path,data_type,needed_reads):
        self.id = {}
        self.path = compact_path
        self.data_type = data_type
        self.needed_reads = needed_reads
        self.handle = open('%s/%s.together.fna'%(self.path,self.data_type),'w')

    def merge(self):
        for sample in os.listdir(self.path):
            sample_dir = '%s/%s'%(self.path,sample)
            if not os.path.isdir(sample_dir):
                continue
            hq_file = '%s/%s/high_quality.fq'%(self.path,sample)
            sample,lib_method = re.search('(\S+)_(\S+)',sample).groups()
            data_needed = self.get_needed_data(self.needed_reads[sample])
            sample = rename(sample,self.data_type)
            if sample not in self.id:
                self.id[sample] = 1
            hq_handle = open(hq_file)
            for record in SeqIO.parse(hq_handle,'fastq'):
                self.handle.write('>%s_%s\n%s\n'%(sample,self.id[sample],str(record.seq)))
                self.id[sample] += 1
                if self.id[sample] > data_needed:
                    break
            hq_handle.close()
            
    @staticmethod 
    def get_needed_data(n):
        r = random.randrange(-10,10,1) / 100
        return int( n * (1.2 + r) )

    def release(self):
        sys.stderr.write('Merge complete!\t%s\n'%self.path)
        self.handle.close()

class Merge(object):
    def __init__(self,work_path,concurrency):
        self.concurrency = concurrency
        self.path = {}
        self.path['QC'] = '%s/QC'%work_path
        self.path['split'] =  '%s/Split'%work_path
        self.get_info()
        self.active_threads = set()

    def get_compacts(self):
        for compact,data_type in self.compact_data_type.iteritems():
            compact_path = '%s/%s'%(self.path['QC'],compact)
            needed_reads = self.needed_reads[compact]
            yield compact_path,data_type,needed_reads

    def get_info(self):
        self.compact_data_type = {}
        self.needed_reads = {}
        sam_barcode_file = '%s/sam_barcode.all'%self.path['split']
        for (compact,sample_name,barcode_info,data_type,lib_method,data_needed) in parse_sam_all(sam_barcode_file):
            compact_path = '%s/%s'%(self.path['QC'],compact)
            if compact not in self.compact_data_type:
                self.compact_data_type[compact] = data_type
                self.needed_reads[compact] = {}
            elif self.compact_data_type[compact] != data_type:
                sys.stderr.write('The compact %s has two diffrent data_type!'%compact)

            self.needed_reads[compact][sample_name] = int( data_needed )

    @staticmethod
    def worker(job):
        job.merge()
        job.release()

    def merge(self):
        for compact_path,data_type,needed_reads in self.get_compacts():
            job = MergePerCompact(compact_path,data_type,needed_reads)
            t = threading.Thread(target=self.worker,args=(job,))
            self.active_threads.add(t)
            t.start()
            while True:
                if threading.activeCount() < self.concurrency:
                    break
        for t in threading.enumerate():
            if t in self.active_threads:
                t.join()
    



