# $1: profile file : reduced_LF_1000.profile
# $2: health sample prefix : A for A[0-9]*
# $3: patient sample prefix : H for H[0-9]*
args <- commandArgs("T")
library(qvalue)
if(length(args)!=6){
  stop("argument number error: $0 <profile file> <health sample prefix> <patient sample prefix> <q_value|BH> <one-tail|two-tail> <outprefix>")
}
cutoff_vector=c(0.05,0.06,0.07,0.075,0.08,0.09,0.1)
profile_name=args[1]
profile_table=read.table(profile_name,header=TRUE)

sample_names=colnames(profile_table)
HD_sample_number=unlist(grep(paste(args[2],"[0-9]*", sep=""), sample_names))
LD_sample_number=unlist(grep(paste(args[3],"[0-9]*", sep=""), sample_names))
if(args[5]=="one-tail"){
	p_values1=apply(profile_table, 1, function(x,y=HD_sample_number, z=LD_sample_number) wilcox.test(unlist(x[y]),unlist(x[z]),alternative="greater")$p.value )
	p_values2=apply(profile_table, 1, function(x,y=HD_sample_number, z=LD_sample_number) wilcox.test(unlist(x[y]),unlist(x[z]),alternative="less")$p.value )
	if (args[4]=="q_value"){
		qobj1=qvalue(p_values1,pi0.meth="bootstrap")
		qobj2=qvalue(p_values2,pi0.meth="bootstrap")
		fdr1=qobj1$qvalues
		fdr2=qobj2$qvalues
	}else{
		fdr1=p.adjust(p_values1,method="fdr")
		fdr2=p.adjust(p_values2,method="fdr")
	}
	p_value_table=cbind(p_values1,fdr1,p_values2,fdr2)
	rownames(p_value_table)=rownames(profile_table)
	colnames(p_value_table)=c("p_value1","fdr1","p_value2","fdr2")
	write.table(p_value_table,paste(args[6],"fdr",sep="."), col.names=T,row.names=T, sep="\t",quote=F)
	p.value_method_result=matrix(0, nrow=length(cutoff_vector), ncol=5)
	colnames(p.value_method_result)=c("threshold", "p.value1","fdr1","p.value2","fdr2")
	for(cutoff in cutoff_vector){
		p1_num=length(which(p_values1<cutoff))
		fdr1_num=length(which(fdr1<cutoff))
		p2_num=length(which(p_values2<cutoff))
		fdr2_num=length(which(fdr2<cutoff))
		p.value_method_result[which(cutoff_vector == cutoff),]=c(cutoff,p1_num,fdr1_num,p2_num,fdr2_num)
	}
	write.table(p.value_method_result, paste(args[6],"num",sep="."), col.names=T,sep="\t", quote=F)
}
if (args[5]=="two-tail"){
	p_values=apply(profile_table, 1, function(x,y=HD_sample_number, z=LD_sample_number) wilcox.test(unlist(x[y]),unlist(x[z]))$p.value )
	if(args[4]=="q_value"){
		qobj=qvalue(p_values,pi0.meth="smoother")
		fdr=qobj$qvalues
	}else{
		fdr=p.adjust(p_values,method="fdr")
	}
	p_value_table=cbind(p_values,fdr)
	rownames(p_value_table)=rownames(profile_table)
	colnames(p_value_table)=c("p_value","fdr")
	write.table(p_value_table,paste(args[6],"fdr",sep="."), col.names=T,row.names=T, sep="\t",quote=F)
	p.value_method_result=matrix(0, nrow=length(cutoff_vector), ncol=5)
	colnames(p.value_method_result)=c("threshold", "p.value","fdr",args[2],args[3])
	for(cutoff in cutoff_vector){
		p_num=length(which(p_values<cutoff))
		fdr_num=length(which(fdr<cutoff))
		reduced_profile=profile_table[which(fdr< cutoff),]
		reduced_vector_1=apply(reduced_profile[,HD_sample_number], 1, median)
		reduced_vector_2=apply(reduced_profile[,LD_sample_number], 1, median)
		reduced_profile_1=reduced_profile[which(reduced_vector_1 > reduced_vector_2),]
		reduced_profile_2=reduced_profile[which(reduced_vector_1 < reduced_vector_2),]
		num1=nrow(reduced_profile_1)
		num2=nrow(reduced_profile_2)
		p.value_method_result[which(cutoff_vector == cutoff),]=c(cutoff,p_num,fdr_num,num1,num2)
		
	}
	write.table(p.value_method_result, paste(args[6],"num",sep="."), col.names=T,sep="\t", quote=F)
	
}


