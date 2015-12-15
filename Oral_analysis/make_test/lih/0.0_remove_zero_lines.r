# $1: profile file : LF_1000.profile
# $2: threshold of numbers of abundances greater than 0 in one line
args <- commandArgs("T")
profile=read.table(args[1]) #$1
sample_names=colnames(profile)
HD_sample_number=unlist(grep(paste(args[2],"[0-9]*", sep=""), sample_names))
LD_sample_number=unlist(grep(paste(args[3],"[0-9]*", sep=""), sample_names))
save_or_rm <- function(vector, cut){
zero=length(which(vector>0))
  if( zero >= as.numeric(cut)){ 
    T
  }else{
    F
  }
}
#check=apply(profile,1,save_or_rm,cut=20)
check1 = apply(profile[,HD_sample_number], 1, save_or_rm, cut = 16)
check2 = apply(profile[,LD_sample_number], 1, save_or_rm, cut = 20)
#profile_final1=profile[check,]
profile_final2=profile[(check1 | check2),]


#HD=apply(profile_final[,HD_sample_number], 1, mean)
#LD=apply(profile_final[,LD_sample_number], 1, mean)
#head(HD>0.0001)
#print("\n")
#head(LD>0.0001)
#print("\n")
#head(HD>0.0001 | LD >0.0001)

#profile_final=profile_final[which(HD>0.0001 | LD >0.0001),]
#heatmap(as.matrix(profile_final))

write.table(profile_final2, paste( args[1],"80",sep="."), quote=F)
#write.table(profile_final2, paste( args[1],"reduce90",sep="."), quote=F)

