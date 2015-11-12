"""
boxplot script
Author: xujm@realbio.cn
Ver:20151112

$ ./boxplot.py data_file
data_file:
Sam_name Num_Vel N50_Vel N90_Vel Num_Soap N50_Soap N90_Soap
"""

from matplotlib.pyplot import *

if __name__ == '__main__':
    sys.argv.pop(0)
    if len(sys.argv) < 1: sys.exit(sys.modules[__name__].__doc__)

    IN_data = open(sys.argv.pop(0))
    num_vel, num_soa, N50_vel, N50_soa, N90_vel, N90_soa = [], [], [], [], [], []

    for line in IN_data:
        line = line.strip().split()
        num_vel.append(int(line[1]))
        num_soa.append(int(line[4]))

        N50_vel.append(int(line[2]))
        N50_soa.append(int(line[5]))

        N90_vel.append(int(line[3]))
        N90_soa.append(int(line[6]))

    header = ['Soap','MetaVelvetSL']

    num = [num_vel, num_soa]
    N50 = [N50_vel, N50_soa]
    N90 = [N90_vel, N90_soa]

    x = [1,2,3,4]
    y = [5,4,3,2]

    figure()

    subplot(131)
    boxplot(num, labels=header)
    title('Total number')

    subplot(132)
    boxplot(N50, labels=header)
    title('N50 length')

    subplot(133)
    boxplot(N90, labels=header)
    title('N90 length')

    show()
