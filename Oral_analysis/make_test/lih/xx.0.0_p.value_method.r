args <- commandArgs("T")
if(length(args)!=3){
  stop("argument number error: $0 <profile file> <health sample prefix> <patient sample prefix>")
}

cutoff_vector=c(1e-1,0.05,seq(from=0.01, to=0.001, length = 10),seq(from=0.0009, to=0.0001, length = 9),seq(from=0.00009, to=0.00001, length = 9),1e-6,1e-7,1e-8,1e-9, 1e-10,1e-11)

profile_name=args[1]
profile_table=read.table(profile_name)

sample_names=colnames(profile_table)
HD_sample_number=unlist(grep(paste(args[2],"[0-9]*", sep=""), sample_names))
LD_sample_number=unlist(grep(paste(args[3],"[0-9]*", sep=""), sample_names))

p_values=apply(profile_table, 1, function(x,y=HD_sample_number, z=LD_sample_number) wilcox.test(unlist(x[y]),unlist(x[z]))$p.value )
fdr_p=p.adjust(p_values,method="fdr")
max_p_value = max(p_values[which(fdr_p<0.001)])
profile_table = profile_table[which(p_values<=max_p_value)]

reduced_vector_1=apply(profile_table[,HD_sample_number], 1, mean)
reduced_vector_2=apply(profile_table[,LD_sample_number], 1, mean)

reduced_profile_1=profile_table[which(reduced_vector_1 > reduced_vector_2),]
reduced_profile_2=profile_table[which(reduced_vector_1 < reduced_vector_2),]

write.table(reduced_profile_1, paste(args[2], ".profile",sep=""), col.names=T,sep="\t", quote=F)
write.table(reduced_profile_2, paste(args[3], ".profile",sep=""), col.names=T,sep="\t", quote=F)
