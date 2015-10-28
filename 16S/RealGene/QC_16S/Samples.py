import re
import sys

class Reads(object):
    def __init__(self,file1,file2):
        self.file1 = file1
        self.file2 = file2
        self.get_file_type()
    
    def get_file_type(self):
        read1_gz = self.file1.strip().endswith('gz')
        read2_gz = self.file2.strip().endswith('gz')
        if ( read1_gz != read2_gz ) :
            sys.stderr.write('Two Reads type and not mathched!  %s,%s\n'%(self.file1,self.file2))
        elif read1_gz and read2_gz:
            self.file_type = 'gz'
        elif not read1_gz and not read2_gz:
            self.file_type = 'text'


