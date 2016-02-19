data = read.table("AS_LC-H_gene.path.class.stat",head=TRUE,sep="\t");
#格式
#	组1	组2
#功能1	个数	个数
#功能2	个数	个数
#
#
name = data[,1]
data = data[,(2:3)]
col=c("lightblue","pink");
pdf("num.pdf",height=7,width=15);
par(mar=c(10,5,1,1))
barplot(t(data),col=col,beside=TRUE,ylab="Number in each Category");
legend("topright",legend=c("Ankylosing spondylitis","Healthy"),col=col,pch=15);
text(labels=name,x=3*(1:nrow(data))-1,y=rep(-2000,nrow(data)),srt=45,xpd=TRUE,adj=1,cex=0.7);
dev.off();
data[,1] = data[,1]/sum(data[,1]);
data[,2] = data[,2]/sum(data[,2]);
pdf("per.pdf",height=7,width=15)
par(mar=c(10,5,1,1))
barplot(t(data),col=col,beside=TRUE,ylab="Percentage in each Category");
legend("topright",legend=c("Ankylosing spondylitis","Healthy"),col=col,pch=15);
text(labels=name,x=3*(1:nrow(data))-1,y=rep(-0.003,nrow(data)),srt=45,xpd=TRUE,adj=1,cex=0.7);
dev.off();
