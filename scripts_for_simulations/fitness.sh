#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'


base=${1}

source ${base}











file_jobs=${r_log_best_crosses_jobs}jobs_fitness.txt

method="basic"
population_variance=${population_ref}
simulations=(FALSE TRUE)
datas=(real estimated)
progeny=RILsF5
optimization=PLE
test_fitness=TRUE
for simulation in ${simulations[*]}
    do
    
    if [ ${simulation} == "FALSE" ]
        then
        
        for critere in ${criteres[*]}
            do
            for programme in ${programmes[*]}
                do
                
                
                                    
                                    
                random=$(shuf -i1-20 -n1)
                
                if [ ${critere} == "gebv" ] || [ ${critere} == "logw" ] || [ ${critere} == "uc" ] || [ ${critere} == "uc_extreme" ] && [ ${random} -eq 1 ]

                    then

                    
                
                
                
                
                    
        
                    type=simFALSE_g${method}
                    typeshort=$(echo ${type} | sed "s/_/./g")
                    echo ${type}_${population_variance}_${critere}_${programme}_${progeny}
                    job_out=${r_log_best_crosses}best_crosses_1_${type}_${population_variance}_${critere}_${programme}_${progeny}_PLE.out
                    job_name=${typeshort}${population_variance}${critere}${programme}${progeny}
                    job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}best_crosses_1.sh ${base} ${type} ${population_variance} ${critere} ${programme} ${progeny} ${optimization} ${test_fitness}) 
                    echo "${job_out} =" >> ${file_jobs}
                    echo "${job}" >> ${file_jobs}
                
                
                fi
                
               
                
                
            done
        done
                        



        
    elif [ ${simulation} == "TRUE" ]
        then
        
        for data in ${datas[*]}
            do
        
        
            for subset in ${qtls[*]}
                do
            
                for r in $(seq 1 ${nb_run})
                    do
                    
                    
                    for critere in ${criteres[*]}
                    do
                        
                        for programme in ${programmes[*]}
                            do
                    
            
                            if [ ${data} == "real" ]
                                then
                                
                                                
                                    random=$(shuf -i1-20 -n1)
                
                
                                if [ ${critere} == "gebv" ] || [ ${critere} == "logw" ] || [ ${critere} == "uc" ] || [ ${critere} == "uc_extreme" ] && [ ${random} -eq 1 ]
                                    then
                                
                                
                                
                                
                                
                                    type=simTRUE_${subset}_r${r}
                                    typeshort=$(echo ${type} | sed "s/_/./g")
                                    echo ${type}_${population_variance}_${critere}_${programme}_${progeny}
                                    job_out=${r_log_best_crosses}best_crosses_1_${type}_${population_variance}_${critere}_${programme}_${progeny}_PLE.out
                                    job_name=${typeshort}${population_variance}${critere}${programme}${progeny}
                                    job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}best_crosses_1.sh ${base} ${type} ${population_variance} ${critere} ${programme} ${progeny} ${optimization} ${test_fitness}) 
                                    echo "${job_out} =" >> ${file_jobs}
                                    echo "${job}" >> ${file_jobs}
                                
                                 
                                
                              
                        
                                fi
            
                            elif [ ${data} == "estimated" ]
                                then
                
        
        
                                for h in ${heritability[*]}
                                    do
                                    random=$(shuf -i1-20 -n1)

                                
                                
                                        if [ ${critere} == "gebv" ] || [ ${critere} == "logw" ] || [ ${critere} == "uc" ] || [ ${critere} == "uc_extreme" ] && [ ${random} -eq 1 ]

                                        then
                                
                              
    

                    
                                        type=simTRUE_${subset}_h${h}_r${r}_g${method}
                                        typeshort=$(echo ${type} | sed "s/_/./g")
                                        echo ${type}_${population_variance}_${critere}_${programme}_${progeny}
                                        job_out=${r_log_best_crosses}best_crosses_1_${type}_${population_variance}_${critere}_${programme}_${progeny}_PLE.out
                                        job_name=${typeshort}${population_variance}${progeny}
                                        job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}best_crosses_1.sh ${base} ${type} ${population_variance} ${critere} ${programme} ${progeny} ${optimization} ${test_fitness}) 
                                        echo "${job_out} =" >> ${file_jobs}
                                        echo "${job}" >> ${file_jobs}
                                    
                                    fi
                                  
                                done
                            
                            fi
                        
                        done
                    done
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
