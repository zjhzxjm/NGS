import os
import sys
from QC_16S.Pipeline import Pipeline
from QC_16S.WorkStat import WorkStat
from QC_16S.Merge import Merge,MergePerCompact
from QC_16S.WorkPerSample import WorkPerSample

def main(work_path,concurrency):

    pipeline = Pipeline(work_path,concurrency)
    canceled = not pipeline.total()
    if canceled:
        return False

#    compact = 'RY2015F11B03-1-16S'
#    sample_name = 'MV15'
#    lib_method = 'Self'
#    data_type = '16S'
#    sample_work = WorkPerSample(work_path,compact,sample_name,lib_method,data_type)
#    sample_work.pandaseq()
#    sample_work.QC()

    stat = WorkStat(work_path,concurrency)
    stat.total()

    os.system('echo "stat finished" | mail -s "miseq report" xujm@realbio.cn')

    merge = Merge(work_path,concurrency)
    merge.merge()

#    compact_path = '/data_center_04/DNA_Data/MiSeq/20150814/s241g01022_LYQ_20150813_1sample/QC/RY2015D24C03-2'
#    data_type = 'ITS'
#    needed_reads = '100000'
#    merge_compact = MergePerCompact(compact_path,data_type,needed_reads)
#    merge_compact.merge()
#    merge_compact.release()

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 1:
        sys.stderr.write('Usage: python run_pipeline.py work_path [process_num] \n process_num default is cpu_count\n')
        sys.exit()
    work_path = sys.argv.pop(0)
    work_path = os.path.abspath(work_path)
    sys.stderr.write('Workdir is %s,pipeline begin\n'%work_path)
    if len(sys.argv) != 0:
        concurrency = int(sys.argv.pop(0))
    else:
        concurrency = cpu_count()

    main(work_path,concurrency)
