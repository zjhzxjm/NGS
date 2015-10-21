"""
This script is create group bars from a list file which contains pep.path.class

the list file format:
pep.path.class file dirname\tgroup name

$ ./histKEGG.py pep.path.class.list
"""

import sys
import re
import rpy2.robjects as robjects
import rpy2.robjects.lib.ggplot2 as ggplot2
from rpy2.robjects.functions import SignatureTranslatedFunction

def mergePepClass(fi_class_list):
    fo_group = fi_class_list + ".group"
    LIST = open(fi_class_list, 'rt')
    OT = open(fo_group, 'wt')
    OT.write('Group\tCLASS\tPathway\tNum\tPercent\n')
    fi_class_rows = re.split('\n', LIST.read().strip())
    LIST.close()
    for fi_class_row in fi_class_rows:
        fi_classes = re.split('\t', fi_class_row.strip())
        IN = open(fi_classes[0], 'rt')
        IN.readline()
        for row in IN:
            #row_v = re.split('\t', row.strip())
            OT.write(fi_classes[1] + "\t" + row)
    OT.close()

def groupBar(fi_data):
    dev_off = robjects.r('dev.off')
    read_delim = robjects.r('read.delim')
    #print(fi_data)
    class_data = read_delim(fi_data, header=True, stringsAsFactors=False)
    robjects.r.assign('class.data', class_data)
    robjects.r.pdf(fi_data + ".Bar.pdf")
    robjects.r('class_data <- class.data')
    class_data = robjects.r('class_data')
    ggplot2.theme = SignatureTranslatedFunction(ggplot2.theme, init_prm_translate={'axis_text_x': 'axis.text.x', 'axis_text_y': 'axis.text.y', 'axis_text_fill': 'axis.text.fill'})
    bar = ggplot2.ggplot(class_data) + ggplot2.geom_bar(stat='identity', position='dodge') + ggplot2.aes_string(x='Pathway',y='Percent',fill='Group') + ggplot2.theme(axis_text_x=ggplot2.element_text(angle=90, hjust=1))
    bar.plot()
    dev_off()



if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 1: sys.exit(sys.modules[__name__].__doc__)

    fi_class_list = sys.argv.pop(0)
    mergePepClass(fi_class_list)
    fi_data = fi_class_list + '.group'
    groupBar(fi_data)
