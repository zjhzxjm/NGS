# $1: profile file : reduced_LF_1000.profile
# $2: cutoff : 0.05
# $3: adjusting method : hochberg
# $4: health sample name prefix : H
# $5: patient sample name prefix : A
args <- commandArgs("T")
library(qvalue)
if(length(args)!=7){
  stop("argument number error: $0 <profile file> <cutoff> <q_value|BH> <health sample name prefix> <patient sample name prefix> <one-tail|two-tail> <out prefix >")
}
methods=c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none","q_value")
if(!(args[3]%in%methods)){
  stop("adjusting method corresponding to argument 3 does not exist, choose one of the following: \"holm\", \"hochberg\", \"hommel\", \"bonferroni\", \"BH\", \"BY\", \"fdr\", \"none\"")
}
profile_name=args[1]
cutoff=as.numeric(args[2]) #c(0.05,1e-1,1e-2,1e-3,1e-4,1e-5,1e-6,1e-7,1e-8,1e-9,1e-10,1e-11)
adjust_method=args[3]  # "hochberg" "fdr" "bonferroni"

profile_table=read.table(profile_name)

sample_names=colnames(profile_table)
HD_sample_number=unlist(grep(paste(args[4],"[0-9]*", sep=""), sample_names))
LD_sample_number=unlist(grep(paste(args[5],"[0-9]*", sep=""), sample_names))

if(args[6]=="one-tail"){
	p_values1=apply(profile_table, 1, function(x,y=HD_sample_number, z=LD_sample_number) wilcox.test(unlist(x[y]),unlist(x[z]),alternative="greater")$p.value )
	p_values2=apply(profile_table, 1, function(x,y=HD_sample_number, z=LD_sample_number) wilcox.test(unlist(x[y]),unlist(x[z]),alternative="less")$p.value )
	if (args[3]=="q_value"){
		qobj1=qvalue(p_values1,pi0.meth="bootstrap")
		qobj2=qvalue(p_values2,pi0.meth="bootstrap")
		fdr1=qobj1$qvalues
		fdr2=qobj2$qvalues
	}else{
		fdr1=p.adjust(p_values1,method="fdr")
		fdr2=p.adjust(p_values2,method="fdr")
	}
	reduced_profile1=profile_table[which(fdr1< cutoff),]
	reduced_profile2=profile_table[which(fdr2< cutoff),]
	write.table(reduced_profile_1, paste(args[7],args[4], ".profile",sep=""), col.names=T,sep="\t", quote=F)
	write.table(reduced_profile_2, paste(args[7],args[5], ".profile",sep=""), col.names=T,sep="\t", quote=F)
}
if(args[6]=="two-tail"){	
	p_values=apply(profile_table, 1, function(x,y=HD_sample_number, z=LD_sample_number) wilcox.test(unlist(x[y]),unlist(x[z]))$p.value )
	if (args[3]=="q_value"){
		qobj=qvalue(p_values,pi0.meth="smoother")
		fdr=qobj$qvalues
	}else{
		fdr=p.adjust(p_values,method="fdr")
	}
	reduced_profile=profile_table[which(fdr< cutoff),]
	reduced_vector_1=apply(reduced_profile[,HD_sample_number], 1, median)
	reduced_vector_2=apply(reduced_profile[,LD_sample_number], 1, median)
	reduced_profile_1=reduced_profile[which(reduced_vector_1 > reduced_vector_2),]
	reduced_profile_2=reduced_profile[which(reduced_vector_1 < reduced_vector_2),]
	write.table(reduced_profile_1, paste(args[4], ".profile",sep=""), col.names=T,sep="\t", quote=F)
	write.table(reduced_profile_2, paste(args[5], ".profile",sep=""), col.names=T,sep="\t", quote=F)
}

