#!/bin/bash
RANDOM=1




base=${1}
nbcores=${2}


source ${base}


types=$(cat ${r_value_crosses}markers_filtered_estimated.txt | cut -f7 | sort | uniq | grep -v "type" )

for type in ${types[*]}
do

    for population in ${populations[*]}
        do



        r_log=${r_log_value_crosses_variance_crosses_chr}${type}/${population}/
        mkdir -p ${r_log}
        
        ID=${type}_${population}

        echo ${ID}
  
        job_out=${r_log}variance_crosses_chr_${ID}.out
    
        job_name=${ID}
	    
        job=$(sbatch -o ${job_out} -J ${job_name} --mem=10G --parsable ${r_scripts}crosses_2.sh ${base} ${nbcores} ${type} ${population}) 
    
        echo "${job_out} =" >> ${r_log_value_crosses_crosses}jobs_crosses.txt
        echo "${job}" >> ${r_log_value_crosses_crosses}jobs_crosses.txt
    
    done
	
done




while (( $(squeue -u adanguy | grep -f ${r_log_value_crosses_crosses}jobs_crosses.txt | wc -l) >= 1 )) 
do    
    sleep 1s
done






