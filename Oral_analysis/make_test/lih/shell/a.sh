#perl ../../trans.pl result.txt xx
#Rscript Rscript/uniform_table.r result.txt.trans
#Rscript Rscript/0.0_remove_zero_lines.r result.txt.trans.st H A
Rscript Rscript/0.0_p.value_method.r result.txt.trans.st.reduce80 H A
#Rscript /data_center_03/Project/Oral_Zhejiang_University/gene_profile/new/Rscript/1.0_get_sub_profile.r /data_center_03/Project/Oral_Zhejiang_University/gene_profile/new/result.txt.trans.st.reduce80 0.07 fdr H A xx
#Rscript /data_center_03/Project/Oral_Zhejiang_University/gene_profile/new/Rscript/1.0_get_sub_profile.r /data_center_03/Project/Oral_Zhejiang_University/gene_profile/new/result.txt.trans.st.reduce80 0.075 fdr H A yy
#Rscript /data_center_03/Project/Oral_Zhejiang_University/gene_profile/new/Rscript/2.0_4.0_fast_2_markers_groups.r xx.H.diff 0.7 complete & 
#Rscript /data_center_03/Project/Oral_Zhejiang_University/gene_profile/new/Rscript/2.0_4.0_fast_2_markers_groups.r xx.A.diff 0.7 complete 
#Rscript /data_center_03/Project/Oral_Zhejiang_University/gene_profile/new/Rscript/3.0_get_average_groups.r group_xx.H.diff xx.H.diff 24 20 &
#Rscript /data_center_03/Project/Oral_Zhejiang_University/gene_profile/new/Rscript/3.0_get_average_groups.r group_xx.A.diff xx.A.diff 76 20
#Rscript /data_center_03/Project/Oral_Zhejiang_University/gene_profile/new/Rscript/2.0_4.0_fast_2_markers_groups.r group_mean_xx.H.diff 0.8 complete 
#Rscript /data_center_03/Project/Oral_Zhejiang_University/gene_profile/new/Rscript/2.0_4.0_fast_2_markers_groups.r group_mean_xx.A.diff 0.8 complete &
