library("grid") ### use the server to get the figure, or it takes too much time
library("VennDiagram")
oral=as.character(unlist(read.table("oral.names.id")))
#Saliva=as.character(unlist(read.table("saliva.id")))
#sub=as.character(unlist(read.table("sub.id")))
#sup=as.character(unlist(read.table("sup.id")))
throat=as.character(unlist(read.table("throat.names.id")))
LC=as.character(unlist(read.table("stool.names.id")))
venn.diagram(list(Oral=oral,Stool=LC,Throat=throat),fill=c("red","yellow","green"),"stool.tiff")
