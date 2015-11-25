"""
Author: Junming Xu
Contact: xujm@realbio.cn / zjhzxjm@gmail.com
This script produce name list for ven.r script from cdhit clstr file
This version can only stat three list file in 'stat_set' sub function

$ python2.6 ./pro_ven_id_from_clstr.py fna.clstr A.gene.list,B.gene.list...
"""

import sys, os, itertools, re, time
def stat_set(fi_gene_list):
    fi_gene_list, dict_sets, fo_stat = re.split(',', fi_gene_list), {}, open('ven.stat', 'w')

    for file in fi_gene_list:
        file = file.rstrip()
        gene_id_file = open('{0}.id'.format(file))

        dict_sets[re.split('/', file)[-1]] = []
        for gene_id in gene_id_file:
            dict_sets[re.split('/', file)[-1]].append(gene_id.rstrip())

    file1 = fi_gene_list[0]
    file2 = fi_gene_list[1]
    file3 = fi_gene_list[2]

    num_file1 = len(set(dict_sets[re.split('/', file1)[-1]]))
    num_file2 = len(set(dict_sets[re.split('/', file2)[-1]]))
    num_file3 = len(set(dict_sets[re.split('/', file3)[-1]]))

    num = len(set(dict_sets[re.split('/', file1)[-1]]) & set(dict_sets[re.split('/', file2)[-1]]))
    name = re.split('/',file1)[-1] + ' and ' + re.split('/',file2)[-1]
    rate_1 = '{0:5.2f}%'.format(num*100.0/num_file1)
    rate_2 = '{0:5.2f}%'.format(num*100.0/num_file2)
    fo_stat.write(name + ':' + str(num) + '\t' + str(rate_1) + '(' + str(num_file1)  + ')' + '\t' + str(rate_2) + '(' + str(num_file2)  + ')\n')

    num = len(set(dict_sets[re.split('/', file1)[-1]]) & set(dict_sets[re.split('/', file3)[-1]]))
    name = re.split('/',file1)[-1] + ' and ' + re.split('/',file3)[-1]
    rate_1 = '{0:5.2f}%'.format(num*100.0/num_file1)
    rate_2 = '{0:5.2f}%'.format(num*100.0/num_file3)
    fo_stat.write(name + ':' + str(num) + '\t' + str(rate_1) + '(' + str(num_file1)  + ')' + '\t'  + str(rate_2) + '(' + str(num_file3)  + ')\n')

    num = len(set(dict_sets[re.split('/', file2)[-1]]) & set(dict_sets[re.split('/', file3)[-1]]))
    name = re.split('/',file2)[-1] + ' and ' + re.split('/',file3)[-1]
    rate_1 = '{0:5.2f}%'.format(num*100.0/num_file2)
    rate_2 = '{0:5.2f}%'.format(num*100.0/num_file3)
    fo_stat.write(name + ':' + str(num) + '\t' + str(rate_1) + '(' + str(num_file2)  + ')' + '\t'  + str(rate_2) + '(' + str(num_file3)  + ')\n')

    num = len(set(dict_sets[re.split('/', file1)[-1]]) & set(dict_sets[re.split('/', file2)[-1]]) & set(dict_sets[re.split('/', file3)[-1]]))
    name = re.split('/',file1)[-1] + ' and ' + re.split('/',file2)[-1] + ' and ' + re.split('/',file3)[-1]
    rate_1 = '{0:5.2f}%'.format(num*100.0/num_file1)
    rate_2 = '{0:5.2f}%'.format(num*100.0/num_file2)
    rate_3 = '{0:5.2f}%'.format(num*100.0/num_file3)
    fo_stat.write(name + ':' + str(num) + '\t' + str(rate_1) + '(' + str(num_file1)  + ')' + '\t' + str(rate_2) + '(' + str(num_file2)  + ')' + '\t' + str(rate_3) + '(' + str(num_file3)  + ')\n')


def get_file_line_num(file):
    wc_out = os.popen('wc -l {0}'.format(file)).read().strip()
    line_num = int(re.search('^(\d+)',wc_out).group(1))
    return line_num

def prt_process(cur_num, total_num):
    cur_num = float(cur_num)
    total_num = float(total_num)
    rate = '{0:5.2f}%'.format(cur_num/total_num*100)
    my_time = time.ctime(time.time())
    sys.stderr.write('Number of lines processed: ' + str(int(cur_num)) + '/' + str(int(total_num)) + " " + str(rate) + " " + my_time + "\n")

def cluster_dic(fi_clstr):
    cluster_file, cluster_dic = open(fi_clstr.rstrip()), {}

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
    gene_file, cluster_dic, repeat_dic = open(fi_gene.rstrip()), cluster_dic, {}
    gene_id_file = open('{0}.id'.format(fi_gene), 'w')

    line_num  = get_file_line_num(fi_gene)
    cur_line = 0
    prt_process(cur_line, line_num)
    for line in gene_file:
        cur_line = cur_line + 1
        if cur_line%1000000 == 0: prt_process(cur_line, line_num)
        gene_name = line.rstrip()
        repeat_dic[gene_name] = 1
        if cluster_dic.get(gene_name):
            if repeat_dic.get(cluster_dic[gene_name]):
                #sys.stderr.write(fi_gene + " repeat gene:" + gene_name + "/n")
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
    list = sys.argv.pop(0)
    fi_gene_list = re.split(',', list)

    sys.stderr.write('Start at ' + time.ctime(time.time()) + '\n')

    cluster_dic = cluster_dic(fi_clstr)
    for file in fi_gene_list:
        sys.stderr.write(file)
        file = file.rstrip()
        tran_name(file, cluster_dic)

    stat_set(list)
    sys.stderr.write('End at ' + time.ctime(time.time()) + '\n')
