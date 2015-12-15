tb<-read.table("result.txt.st",header=TRUE)
for (i in seq(1:44)){
	pdf(paste(i,"pdf",sep="."))
	hist(tb[,i],breaks=1000)
	#print (tb[,1])
	dev.off()
}

