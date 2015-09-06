# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
alias today="date +%F"
alias rd1="cd /data_center_01/DNA_Data/data1/original_data/raw_reads/";
alias rd4="cd /data_center_04/DNA_Data";
alias soft="cd /data_center_01/soft";
alias ibd="cd /var/www/html/ibiome_dev/xujm/ibiome"
alias ib="cd /var/www/html/ibiome/"
alias ll="ls -l -h  --time-style="long-iso" "
alias le="less -S"
alias grep='egrep --color=auto'
alias df='df -h'
alias du='du -h --max-depth=1'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ym='lftp -u Realbio_LYQ,REALBIO8o9y%lyq sftp://genomics.wuxiapptec.com.cn'

PS1="\[\e[1;32m\][\u@\h:\[\e[1;31m\] \# \[\e[1;36m\]\W]$\[\e[m\]"
export PS1
#export PERL5LIB=$PERL5LIB:/share/apps/Programe/perl-5.20.0/lib/site_perl/5.20.0/:/share/apps/Virus_pipline/Perl_lib/lib/site_perl/5.20.0/:/share/nas3/liangzebin/bin/MOCAT/MOCAT/src/:/data_center_01/home/NEOLINE/wuchunyan/software/PERL/lib

#export PYTHONPATH=/home/snowflake/local/lib:/home/snowflake/softwares/qiime/PyCogent-1.5.3
#export RDP_JAR_PATH=/home/snowflake/softwares/qiime/rdp_classifier_2.2/rdp_classifier-2.2.jar
#export PATH=$PATH:/home/snowflake/softwares/qiime/microbiomeutil-r20110519/ChimeraSlayer:/home/snowflake/softwares/qiime/AmpliconNoiseV1.27/Scripts:/home/snowflake/softwares/qiime/AmpliconNoiseV1.27/bin:/home/snowflake/local/bin
#export PYRO_LOOKUP_FILE=/home/snowflake/softwares/qiime/AmpliconNoiseV1.27/Data/LookUp_E123.dat
#export SEQ_LOOKUP_FILE=/home/snowflake/softwares/qiime/AmpliconNoiseV1.27/Data/Tran.dat
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/data_center_01/soft/lib64
#export LIBRARY_PATH=$LIBRARY_PATH:/home/snowflake/local/lib
#export C_INCLUDE_PATH=$C_INCLUDE_PATH:/home/snowflake/local/include
#export PYTHONPATH=/home/snowflake/local/lib/python2.7:/home/snowflake/softwares/qiime/biom-format-1.3.1:/home/snowflake/local/lib/python2.7/site-packages:/home/snowflake/local/bin:/home/snowflake/softwares/qiime/PyCogent-1.5.3:/home/snowflake/softwares/qiime/pyqi-master:$PYTHONPATH;
