import os
import re
from string import Template

class settings(object):
    primer = {
        'HXT': {
            '16S':{
                'forward':'CCTACGGGNGGCWGCAG',
                'reverse':'GACTACHVGGGTATCTAATCC',
            },
            'ITS':{
                'forward':'GCATCGATGAAGAACGCAGC',
                'reverse':'TCCTCCGCTTATTGATATGC',
            },
        },
        'Self': {
            '16S':{
                'forward':'GGACTACHVGGGTWTCTAAT',
                'reverse':'ACTCCTACGGGAGGCAGCAG',
            },
            'ITS':{
                'forward':'TCCTCCGCTTATTGATATGC',
                'reverse':'GCATCGATGAAGAACGCAGC',
            },
        },
        'Pair':{
            'ITS':{
                'forward':'AWCGATGAAGARCRYAGC',
                'reverse':'GCTTAAGTTCAGCGGGTA',
            },
            '16S':{
                'forward':'CCTACGGGNGGCWGCAG',
                'reverse':'GACTACHVGGGTATCTAATCC',
            },
        },
        'ZJM':{
            '16S':{
                'forward':'CCTACGGGNGGCWGCAG',
                'reverse':'GACTACHVGGGTATCTAATCC',
            },
        },
        'Macrogen':{
            '16S':{
                'forward':'GTGCCAGCMGCCGCGGTAA',
                'reverse':'GGACTACHVGGGTWTCTAAT',
            },
        },
        'Self2':{
            '16S':{
                'forward':'GGACTACVVGGGTATCTAATC',
                'reverse':'CCTACGGGRSGCAGCAG',
            },
        },
        'Self3':{
            '16S':{
                'forward':'GGACTACVVGGGTATCTAATC',
                'reverse':'CCCTACGGGGYGCASCAG',
            },
        },
        'Self4':{
            '16S':{
                'forward':'GGACTACVVGGGTATCTAATC',
                'reverse':'CCTACGGGRSGCAGCAG',
            },
            'ITS':{
                'forward':'TCCTCCGCTTATTGATATGC',
                'reverse':'GCATCGATGAAGAACGCAGC',
            },
            'ARCH':{
                'forward':'GGACTACVVGGGTATCTAATC',
                'reverse':'CCTACGGGGYGCASCAG',
            },
        },
    }

    barcode = {
        'HXT':{
            'forward':[None,'ATCACG','CGATGT','TTAGGC','TGACCA','ACAGTG','GCCAAT','CAGATC','ACTTGA','GATCAG','TAGCTT','GGCTAC','CTTGTA'],
            'reverse':[None,'ATCACG','CGATGT','TTAGGC','TGACCA','ACAGTG','GCCAAT','CAGATC','ACTTGA','GATCAG','TAGCTT','GGCTAC','CTTGTA'],
        },
        'Self':{
            'reverse':[None,'CCTAAACTACGG','TGCAGATCCAAC','CCATCACATAGG','GTGGTATGGGAG','ACTTTAAGGGTG','GAGCAACATCCT',
                            'TGTTGCGTTTCT','ATGTCCGACCAA','AGGTACGCAATT','GTTACGTGGTTG','TACCGCCTCGGA','CGTAAGATGCCT',
                            'ACAGCCACCCAT','TGTCTCGCAAGC','GAGGAGTAAAGC','TACCGGCTTGCA','ATCTAGTGGCAA','CCAGGGACTTCT',
                            'CACCTTACCTTA','ATAGTTAGGGCT','GCACTTCATTTC','TTAACTGGAAGC','CGCGGTTACTAA','GAGACTATATGC',],
            'forward':[None,'CCTAAACTACGG','TGCAGATCCAAC','CCATCACATAGG','GTGGTATGGGAG','ACTTTAAGGGTG','GAGCAACATCCT',
                            'TGTTGCGTTTCT','ATGTCCGACCAA','AGGTACGCAATT','GTTACGTGGTTG','TACCGCCTCGGA','CGTAAGATGCCT',
                            'ACAGCCACCCAT','TGTCTCGCAAGC','GAGGAGTAAAGC','TACCGGCTTGCA','ATCTAGTGGCAA','CCAGGGACTTCT',
                            'CACCTTACCTTA','ATAGTTAGGGCT','GCACTTCATTTC','TTAACTGGAAGC','CGCGGTTACTAA','GAGACTATATGC',],
        },
    }


def get_lib_method(file):
    if not os.path.isfile(file):
        return None
    file = os.path.basename(file.strip())
    if re.match('^sam_barcode.l$',file):
        lib_method = 'Self'
    elif re.match('^sam_barcode.s\d+$',file):
        out_barcode = re.match('^sam_barcode.s(\d+)$',file).group(1)
        lib_method = 'HXT%s'%out_barcode
    elif re.match('^sam_barcode.p$',file):
        lib_method = 'Pair'
    elif re.match('^sam_barcode.n$',file):
        lib_method = 'Small'
    elif re.match('^sam_barcode.o$',file):
        lib_method = 'Other'
    elif re.match('^sam_barcode.z$',file):
        lib_method = 'ZJM'
    elif re.match('^sam_barcode.m$',file):
        lib_method = 'Macrogen'
    elif re.match('^sam_barcode.l2$',file):
        lib_method = 'Self2'
    elif re.match('^sam_barcode.l3$',file):
        lib_method = 'Self3'
    elif re.match('^sam_barcode.l4$',file):
        lib_method = 'Self4'
    else:
        lib_method = None
    return lib_method

def get_primer(lib_method,data_type):
    primer = settings.primer
    if lib_method not in primer:
        return ('','')
    if data_type not in primer[lib_method]:
        return ('','')
    if lib_method.find('HXT') == 0:
        lib_method = 'HXT'
    return (primer[lib_method][data_type]['forward'],primer[lib_method][data_type]['reverse'])

def get_reads(raw_path,lib_method):
    read1,read2 = map( lambda s:s.strip(), os.popen('ls %s/*'%raw_path).readlines() )
    return read1,read2

def get_unaligned(path):
    ret = []
    for file in os.popen('ls %s/*unalign*'%path):
        file_name = re.search('(\S+)R\d.fastq',os.path.basename(file.strip())).group(1)
        if file_name in ret:
            continue
        ret.append(file_name)
        file2 = re.sub('R1.fastq','R2.fastq',file)
        yield file_name,file,file2

def rename(sample,data_type):
    sample = re.sub('[-_]','.',sample)
    if data_type == '16S':
        sample = 'S%s'%sample
    if data_type == 'ITS':
        sample = 'ITS%s'%sample
    if data_type == 'ARCH':
        sample = 'ARCH%s'%sample
    return sample

def parse_sam_all(file):
    handle = open(file)
    for line in handle:
        if re.search('^#',line):
            continue
        ( compact,sample_name,barcode_info,data_type,lib_method,needed_reads )  = re.split('\s+',line.strip())
        yield  compact,sample_name,barcode_info,data_type,lib_method,needed_reads
    handle.close()

class MyTemplate(Template):
    delimiter = '$'
    def get(self,d):
        return self.safe_substitute(d)

def get_pandaseq_cmd(d):
    if d['lib_method'] == 'Small':
        t = MyTemplate('/data_center_01/home/NEOLINE/liangzebin/soft/pandaseq_rebuild/bin/pandaseq -F -f ${read1} -r ${read2} -w ${out_file} -g ${log_file} -l 0 -L 600 -o 20')
        pandaseq_cmd = t.get(d)
    elif d['lib_method'] == 'Other':
        t = MyTemplate('/data_center_01/home/NEOLINE/liangzebin/soft/pandaseq_rebuild/bin/pandaseq -F -f ${read1} -r ${read2} -w ${out_file} -g ${log_file} -l 220 -L 500')
        pandaseq_cmd = t.get(d)
    else:
        t = MyTemplate('/data_center_01/home/NEOLINE/liangzebin/soft/pandaseq_rebuild/bin/pandaseq -F -f ${read1} -r ${read2} -w ${out_file} -p ${f_primer} -q ${r_primer} -g ${log_file} -l 220 -L 500')
        pandaseq_cmd = t.get(d)
    return pandaseq_cmd

