args=c("final_group_members_profile_A.profile", "final_group_members_profile_H.profile", "final_group_mean_A.profile","final_group_mean_H.profile", 15, "hochberg")
patient_member=read.table(args[1])
#control_member=read.table(args[2])
patient_mean=read.table(args[3])
#control_mean=read.table(args[4])
most_group_number=as.numeric(args[5])

get_type <- function(file_name){
  type_profile=unlist(strsplit(file_name,"_"))
  type_profile=type_profile[length(type_profile)]
  type=unlist(strsplit(type_profile,"[.]"))[1]
  type
}

type_p=get_type(args[1])
#type_c=get_type(args[2])

row.names(patient_mean)=paste(type_p, 1:nrow(patient_mean), sep="_")
#row.names(control_mean)=paste(type_c, 1:nrow(control_mean), sep="_")
#profile_mean=as.matrix(rbind(patient_mean, control_mean))
profile_mean=as.matrix(rbind(patient_mean))



profile=as.matrix(rbind(patient_member))
#profile=as.matrix(rbind(patient_member, control_member))

interval=range(profile)
profile=(profile-interval[1])/(interval[2]-interval[1])
#profile[1:15, 1:5]=1
#profile[315:320, 115:120]=1
#c("whitesmoke","palegreen3","royalblue1","khaki","orangeRed","firebrick" )
#c( "firebrick" "whitesmoke","khaki", "orangeRed" )
colfunc <- colorRampPalette(c("white","green","yellow","orange","red","blue","black"),bias=4)

#profile[(nrow(profile)-5):nrow(profile), (ncol(profile)-5):ncol(profile)]=1
#profile[1:5, (ncol(profile)-5):ncol(profile)]=1

par(mfcol=c(1,1),mar=c(3,3,3,5) )
image(1:ncol(profile),1:nrow(profile),z=t(profile), col=colfunc(1000), axe=F,xlab="", ylab="")
box()
#after the image function, the corres
y=most_group_number
while(y < nrow(profile)){
  abline(y, 0)
  y=y+most_group_number
}
cnames=colnames(profile)


#HD_sample_number=unlist(grep(paste(type_c,"[0-9]*", sep=""), colnames(profile)))
LD_sample_number=unlist(grep(paste(type_p,"[0-9]*", sep=""), colnames(profile)))
#abline(v=length(LD_sample_number)+0.5, lwd=3)
#a=t(profile)


p_values=apply(profile_mean, 1, function(x,y=HD_sample_number, z=LD_sample_number) wilcox.test(unlist(x[y]),unlist(x[z]))$p.value )
q_values=p.adjust(p_values, method=args[6]) #p_values=rev(p_values)
q_values=signif(q_values, digits=3)
at_vector=seq(0, nrow(profile)-as.numeric(args[5]), as.numeric(args[5])) + as.numeric(args[5])/2
axis(2, at=at_vector, labels=names(q_values), las=1)
axis(4, at=at_vector, labels=q_values, las=1)
