#!/bin/bash
RANDOM=1




base=${1}
nbcores=${2}


source ${base}

rm ${r_log_value_crosses_variance_crosses_chr}jobs_variance_crosses_chr.txt

for c in ${chr[*]}
do


    echo ${c}
  
	job_out=${r_log_value_crosses_variance_crosses_chr}variance_crosses_chr_${c}.out
    
    job_name=${c}
	    
    job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --time=10:00:00  --mem-per-cpu=10G --parsable ${r_scripts}variance_crosses_chr.sh ${base} ${nbcores} ${c}) 
    
    echo "${job_out} =" >> ${r_log_value_crosses_variance_crosses_chr}jobs_variance_crosses_chr.txt
    echo "${job}" >> ${r_log_value_crosses_variance_crosses_chr}jobs_variance_crosses_chr.txt

	
done


while (( $(squeue -u adanguy | grep -f ${r_log_value_crosses_variance_crosses_chr}jobs_variance_crosses_chr.txt | wc -l) >= 1 )) 
do    
    sleep 1s
done


rm ${r_value_crosses}variance_crosses.txt
k=0
for f in ${r_value_crosses_variance_crosses_chr}variance_crosses_*.txt
do 


    if ((k==0 ))
        
    then 
        
        cat ${f} > ${r_value_crosses}variance_crosses.txt
            rm ${f}
        
    else
        
        tail -n+2 ${f} >> ${r_value_crosses}variance_crosses.txt
            rm ${f}

    fi
        
    k=$((k +1))
        
done





