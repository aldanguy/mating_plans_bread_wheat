#!/bin/bash
RANDOM=1



base=${1}



source ${base}

file_jobs=${r_log_value_crosses_jobs}jobs_simulate_qtls.txt
simulation=TRUE
output_markers=${r_value_crosses}markers_estimated.txt
output_lines=${r_value_crosses}lines_estimated.txt
folder_list=${r_log_value_crosses_gblup}folder_list_estimated.txt

for h in ${heritability[*]}
    do
    for subset in ${cm[*]}
        do
        
        for r in $(seq 1 ${nb_run})
            do


            while (( $(squeue -u adanguy | wc -l) >= ${nb_jobs_allowed} ))
                do    
                sleep 1s
            done

            type=sim${simulation}_${subset}cm_h${h}_r${r}
        
        
        

        
            typeshort=$(echo ${type} | sed "s/_/./g")
            echo ${type}
            r_save=${r_value_crosses_simulate_qtls}${type}/
            mkdir -p ${r_save}
            job_out=${r_log_value_crosses_simulate_qtls}simulate_qtls_${type}.out
            job_name=${typeshort}
            job=$(sbatch -o ${job_out} -J ${job_name} --time=00:10:00 --parsable ${r_scripts}simulate_qtls_2.sh ${base} ${type} ${r_save})
            echo "${job_out} =" >> ${file_jobs}
            echo "${job}" >> ${file_jobs}
            echo "${r_save}" >> ${folder_list}


            
        done
    
    done
done    

sed -i '/^$/d' ${file_jobs}
while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
    do    
    sleep 1s
done

k=0

cat ${folder_list} | while read folder 
        do
    
        if [ ${k} -eq 0 ]
            then
            
            cat ${folder}lines.txt > ${output_lines}
            
        elif [ ${k} -eq 1 ]
            then
            tail -n+2 ${folder}lines* >> ${output_lines}
            cat ${folder}markers* > ${output_markers}

            
        else 
            tail -n+2 ${folder}lines* >> ${output_lines}
            tail -n+2 ${folder}markers* >> ${output_markers}
        fi
        
        k=$((k+1))
done

