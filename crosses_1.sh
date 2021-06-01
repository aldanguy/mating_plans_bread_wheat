#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'




base=${1}


source ${base}
    
file_jobs=${r_log_value_crosses_jobs}jobs_crosses_2.txt

method="basic"
population_variance=${population_ref}

simulations=(FALSE TRUE)
datas=(real estimated)
for simulation in ${simulations[*]}
    do
    
    if [ ${simulation} == "FALSE" ]
        then
        
        type=simFALSE_g${method}
        typeshort=$(echo ${type} | sed "s/_/./g")
        echo ${type}_${population_variance}
        job_out=${r_log_value_crosses_crosses}crosses_2_${type}_${population_variance}.out
        job_name=${typeshort}${population_variance}
         job=$(sbatch -o ${job_out} -J ${job_name} --mem=3G --parsable ${r_scripts}crosses_2.sh ${base} ${type} ${population_variance}) 
        echo "${job_out} =" >> ${file_jobs}
        echo "${job}" >> ${file_jobs}
        while (( $(squeue -u adanguy | wc -l) >= ${nb_jobs_allowed} ))
            do    
            sleep 1s
        done
        sed -i '/^$/d' ${file_jobs}
        while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 10 )) 
            do    
            sleep 1s
        done
                        



        
    elif [ ${simulation} == "TRUE" ]
        then
        
        for data in ${datas[*]}
            do
        
        
            for subset in ${qtls[*]}
                do
            
                for r in $(seq 1 ${nb_run})
                    do
                    
            
                    if [ ${data} == "real" ]
                        then
                        
                        
                        
                        type=simTRUE_${subset}_r${r}

                        
                        
                        typeshort=$(echo ${type} | sed "s/_/./g")
                        echo ${type}_${population_variance}
                        job_out=${r_log_value_crosses_crosses}crosses_2_${type}_${population_variance}.out
                        job_name=${typeshort}${population_variance}
                        job=$(sbatch -o ${job_out} -J ${job_name} --mem=3G --parsable ${r_scripts}crosses_2.sh ${base} ${type} ${population_variance}) 
                        echo "${job_out} =" >> ${file_jobs}
                        echo "${job}" >> ${file_jobs}
                        while (( $(squeue -u adanguy | wc -l) >= ${nb_jobs_allowed} ))
                            do    
                            sleep 1s
                        done
                         sed -i '/^$/d' ${file_jobs}
                        while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 10 )) 
                            do    
                            sleep 1s
                        done
                        
                        
                        
            
                    elif [ ${data} == "estimated" ]
                        then
                
        
        
                        for h in ${heritability[*]}
                            do
    

                    
                            type=simTRUE_${subset}_h${h}_r${r}_g${method}
                            

                        
                            typeshort=$(echo ${type} | sed "s/_/./g")
                            echo ${type}_${population_variance}
                            job_out=${r_log_value_crosses_crosses}crosses_2_${type}_${population_variance}.out
                            job_name=${typeshort}${population_variance}
                            job=$(sbatch -o ${job_out} -J ${job_name} --mem=3G --parsable ${r_scripts}crosses_2.sh ${base} ${type} ${population_variance}) 
                            echo "${job_out} =" >> ${file_jobs}
                            echo "${job}" >> ${file_jobs}
                            while (( $(squeue -u adanguy | wc -l) >= ${nb_jobs_allowed} ))
                                do    
                                sleep 1s
                            done     
                            sed -i '/^$/d' ${file_jobs}
                            while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 10 )) 
                                do    
                                sleep 1s
                            done

                        done
                    fi
                done
            done
        done
    fi
done
                        
                
                
                



sed -i '/^$/d' ${file_jobs}
while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
do    
    sleep 1s
done



date +'%Y-%m-%d-%T'



