#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'




base=${1}



source ${base}

file_jobs=${r_log_value_crosses_jobs}jobs_simulate_qtls.txt

for h in ${heritability[*]}
    do
    for subset in ${qtls[*]}
        do
        
        for r in $(seq 1 ${nb_run})
            do


            while (( $(squeue -u adanguy | wc -l) >= ${nb_jobs_allowed} ))
                do    
                sleep 1s
            done

            type=simTRUE_${subset}_h${h}_r${r}
        
        
        

        
            typeshort=$(echo ${type} | sed "s/_/./g")
            echo ${type}
            job_out=${r_log_value_crosses_simulate_qtls}simulate_qtls_${type}.out
            job_name=${typeshort}
            job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}simulate_qtls_2.sh ${base} ${type})
            echo "${job_out} =" >> ${file_jobs}
            echo "${job}" >> ${file_jobs}


            
        done
    
    done
done    

sed -i '/^$/d' ${file_jobs}
while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
    do    
    sleep 1s
done




   k=0
   
   for h in ${heritability[*]}
        do
        if [ ${k} -eq 0 ]
            then
            k=1
            for f in $(ls ${r_value_crosses_markers} | grep "real")
                do 
                echo ${f}
                    if [ $(echo ${f} | grep "h${h}" | wc -l ) -eq 1 ]
                        then
                        new_title=$(echo ${f} | sed "s|_h.*_r|_r|g")
                        echo ${new_title}
                        cp ${r_value_crosses_markers}${f} ${r_value_crosses_markers}${new_title}
                        rm ${r_value_crosses_markers}${f}
                    else
                        rm ${r_value_crosses_markers}${f}
                    fi
            done
        fi
    done
    
    k=0
    
       for h in ${heritability[*]}
        do
        if [ ${k} -eq 0 ]
            then
            k=1
            for f in $(ls ${r_value_crosses_lines} | grep "tbv")
                do 
                    if [ $(echo ${f} | grep "h${h}" | wc -l ) -eq 1 ]
                        then
                        new_title=$(echo ${f} | sed "s|_h.*_r|_r|g")
                        cp ${r_value_crosses_lines}${f} ${r_value_crosses_lines}${new_title}
                        rm ${r_value_crosses_lines}${f}
                    else
                        rm ${r_value_crosses_lines}${f}
                    fi
            done
        fi
    done
    
   
                        
date +'%Y-%m-%d-%T'

      
