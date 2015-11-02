"""
Author: Junming Xu
Contact: xujm@realbio.cn / zjhzxjm@gmail.com
This script produce name list for ven.r script from cdhit clstr file

$ ./pro_ven_id_from_clstr.py fna.clstr A.gene.list,B.gene.list...
"""

import sys, os, itertools, re

def cluster_dic(fi_clstr):
    cluster_file, cluster_dic = open(fi_clstr), {}

    # parse through the cluster file and store the sequences + represent gene name in the dictionary
    cluster_groups = (x[1] for x in itertools.groupby(cluster_file, key=lambda line: line[0] == '>'))
    for cluster in cluster_groups:
        for seq in cluster_groups.next():
            num = seq.split()[0]
            if num == '0':
                rep_name = seq.split('>')[1].split('...')[0]
            else:
                cluster_dic[seq.split('>')[1].split('...')[0]] = rep_name
#        seqs = [seq.split('>')[1].split('...')[0] for seq in cluster_groups.next()]
#        cluster_dic[name] = seqs

    # return the cluster dictionary
    return cluster_dic

def tran_name(fi_gene, cluster_dic):
    gene_file, cluster_dic, repeat_dic = open(fi_gene), cluster_dic, {}
    gene_id_file = open('{0}.id'.format(fi_gene), 'w')

    for line in gene_file:
        gene_name = line.strip()
        repeat_dic[gene_name] = 1
        if gene_name in list(cluster_dic):
            if cluster_dic[gene_name] in list(repeat_dic):
                sys.stderr.write(fi_gene + " repeat gene:" + gene_name + "/n")
                continue
            gene_id_file.write('{0}\n'.format(cluster_dic[gene_name]))
            repeat_dic[cluster_dic[gene_name]] = 1
        else:
            gene_id_file.write('{0}\n'.format(gene_name))

    gene_id_file.close()

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 2: sys.exit(sys.modules[__name__].__doc__)

    fi_clstr = sys.argv.pop(0)
    fi_gene_list = re.split(',', sys.argv.pop(0))

    cluster_dic = cluster_dic(fi_clstr)
    for file in fi_gene_list:
        tran_name(file, cluster_dic)
