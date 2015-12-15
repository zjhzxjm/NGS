args <- commandArgs("T")
#print(args[1])
profile=read.table(args[1])
sum(profile[,1])
sum2=apply(profile, 2, sum)

#uniform=profile/sum2
for (i in 1:ncol(profile)){
  profile[,i]=profile[,i]/sum2[i]  
}

write.table(profile, paste( args[1],"st",sep="."))
