#!/bin/bash



base=${1}
# base=/work/adanguy/these/croisements/scripts/base_cr_031120.sh
source ${base}



rm ${r_log_value_crosses_gblup}jobs_gblup.txt

for subset in ${cm[*]}
do



    echo ${subset}
  
	job_out=${r_log_value_crosses_gblup}gblup_${subset}cm.out
    
    job_name=${subset}cm_gblup
	    
    job=$(sbatch -o ${job_out} -J ${job_name} --mem=10G --parsable ${r_scripts}gblup_2.sh ${base} ${subset}) 
    
    echo "${job_out} =" >> ${r_log_value_crosses_gblup}jobs_gblup.txt
    echo "${job}" >> ${r_log_value_crosses_gblup}jobs_gblup.txt
    
    
    

    while (( $(squeue -u adanguy | grep -f ${r_log_value_crosses_gblup}jobs_gblup.txt | wc -l) >= 1 )) 
    do    
        sleep 1s
    done


done
