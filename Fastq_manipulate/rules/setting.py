"""
Author: xujm@realbio.cn
Ver:20160317

"""


class SeqIndex():
    def __init__(self):
        pass

    out_barcode = {
        'hiseq': 'ATCTCG',
        'XTen': '',
        'Test': 'AGACAA'
    }

    primer = {
        'hiseq': {
          '16S': {
              'forward': 'GGACTACVVGGGTATCTAATC',
              'reverse': 'CCTACGGGRSGCAGCAG',
          },
        },
    }

    barcode = {
        'hiseq': ['ATCACG', 'CGATGT', 'TTAGGC', 'TGACCA', 'ACAGTG', 'GCCAAT', 'CAGATC', 'ACTTGA', 'GATCAG', 'TAGCTT',
                  'GGCTAC', 'CTTGTA', 'AGTCAA', 'AGTTCC', 'ATGTCA', 'CCGTCC', 'GTAGAG', 'GTCCGC', 'GTGAAA', 'GTGGCC',
                  'GTTTCG', 'CGTACG', 'GAGTGG', 'GGTAGC', 'ACTGAT', 'ATGAGC', 'ATTCCT', 'CAAAAG', 'CAACTA', 'CACCGG']
    }
