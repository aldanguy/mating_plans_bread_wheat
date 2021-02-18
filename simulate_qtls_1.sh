#!/bin/bash



base=${1}




source ${base}

rm ${r_log_value_crosses_simulate_qtls}jobs_simulate_qtls.txt

for subset in ${cm[*]}
do



    echo ${subset}
  
	job_out=${r_log_value_crosses_simulate_qtls}simulate_qtls_2_${subset}cm.out
    
    job_name=${subset}cm
	    
    job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}simulate_qtls_2.sh ${base} ${subset}) 
    
    echo "${job_out} =" >> ${r_log_value_crosses_simulate_qtls}jobs_simulate_qtls.txt
    echo "${job}" >> ${r_log_value_crosses_simulate_qtls}jobs_simulate_qtls.txt


done



while (( $(squeue -u adanguy | grep -f ${r_log_value_crosses_simulate_qtls}jobs_simulate_qtls.txt | wc -l) >= 1 )) 
do    
    sleep 1s
done


rm ${r_value_crosses}markers_filtered_qtls.txt
k=0
for subset in ${cm[*]}
do


 if ((k==0 ))
        
    then 
        
        cat ${r_value_crosses}markers_filtered_qtls_${subset}cm.txt > ${r_value_crosses}markers_filtered_qtls.txt
        #rm ${r_value_crosses}markers_filtered_qtls_${subset}cm.txt
        
        
        cat ${r_value_crosses}lines_qtls_${subset}cm.txt > ${r_value_crosses}lines_qtls.txt
        #rm ${r_value_crosses}lines_qtls_${subset}cm.txt
        
        
    else
    
    range_inf=$(head -n1 ${r_value_crosses}markers_filtered_qtls_${subset}cm.txt | sed "s/\t/\n/g" | grep -n "qs" | cut -f1 -d":" | sort | head -n1)
    range_sup=$(head -n1 ${r_value_crosses}markers_filtered_qtls_${subset}cm.txt | sed "s/\t/\n/g" | grep -n "qs" | cut -f1 -d":" | sort | tail -n1)
    cut ${r_value_crosses}markers_filtered_qtls_${subset}cm.txt -f${range_inf}-${range_sup} > ${r_value_crosses}temp_${subset}cm.txt
    paste -d'\t' ${r_value_crosses}markers_filtered_qtls.txt ${r_value_crosses}temp_${subset}cm.txt > ${r_value_crosses}temp2_${subset}cm.txt
    cp ${r_value_crosses}temp2_${subset}cm.txt ${r_value_crosses}markers_filtered_qtls.txt
    #rm ${r_value_crosses}markers_filtered_qtls_${subset}cm.txt
    
    
    range_inf=$(head -n1 ${r_value_crosses}lines_qtls_${subset}cm.txt | sed "s/\t/\n/g" | grep -n "qs" | cut -f1 -d":" | sort | head -n1)
    range_sup=$(head -n1 ${r_value_crosses}lines_qtls_${subset}cm.txt | sed "s/\t/\n/g" | grep -n "qs" | cut -f1 -d":" | sort | tail -n1)
    cut ${r_value_crosses}lines_qtls_${subset}cm.txt -f${range_inf}-${range_sup} > ${r_value_crosses}temp_${subset}cm.txt
    paste -d'\t' ${r_value_crosses}lines_qtls.txt ${r_value_crosses}temp_${subset}cm.txt > ${r_value_crosses}temp2_${subset}cm.txt
    cp ${r_value_crosses}temp2_${subset}cm.txt ${r_value_crosses}lines_qtls.txt
    #rm ${r_value_crosses}lines_qtls_${subset}cm.txt
  
    
    
    
    

    
    fi
    
        k=$((k +1))

    
done

rm ${r_value_crosses}temp_${subset}cm.txt
rm ${r_value_crosses}temp2_${subset}cm.txt
