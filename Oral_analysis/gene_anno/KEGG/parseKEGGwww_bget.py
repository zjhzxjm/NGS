"""
Parse KEGG www_bget file from Entry name list file

$ ./parseKEGGwww_bget.py gene_entry_name.list > out_file
"""

import sys, re, requests

def getOtherDB(entry):
    url = "http://www.kegg.jp/dbget-bin/www_bget?" + entry
    resp = requests.get(url)
    if resp.status_code != 200:
        sys.stderr.write(entry + "html cant be got\n")
    match = re.search(r'NCBI-GI:.*>(?P<GI>\d+)</a>.*NCBI-GeneID:.*>(?P<GeneID>\d+)</a>',resp.text)
    return match

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 1: sys.exit(sys.modules[__name__].__doc__)

    fi_gene_entry_name_list = sys.argv.pop(0)
    IN_list = open(fi_gene_entry_name_list)
    for line in IN_list:
        m = getOtherDB(line.rstrip())
        sys.stdout.write( line.rstrip() + "\t" + m.group('GI') + "\t" + m.group('GeneID') + "\n" )
