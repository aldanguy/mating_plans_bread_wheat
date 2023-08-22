#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'


base=${1}

source ${base}











file_jobs=${r_log_best_crosses_jobs}jobs_best_crosses_1.txt

method="basic"
population_variance=${population_ref}
simulations=(FALSE TRUE)
datas=(real estimated)
progeny=RILsF5
optimization=PLE
test_fitness=FALSE
population_profile=WE

for simulation in ${simulations[*]}
    do
    
    if [ ${simulation} == "FALSE" ]
        then
        
        for critere in ${criteres[*]}
            do
            for programme in ${programmes[*]}
                do
                    
        
                type=simFALSE_g${method}
                
                
                                                #if [ $(ls ${r_best_crosses_lines} | grep ${type} | grep ${critere}_real_RILsF5 | wc -l) -eq 0 ] ##
                            #    then ##
                
                

                
                    typeshort=$(echo ${type} | sed "s/_/./g")
                    #echo ${type}_${population_variance}_${critere}_${programme}_${progeny}
                    job_out=${r_log_best_crosses}best_crosses_1_${type}_${population_variance}_${critere}_${programme}_${progeny}.out
                    job_name=${typeshort}${population_variance}${critere}${programme}${progeny}
                    #job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}best_crosses_1.sh ${base} ${type} ${population_variance} ${critere} ${programme} ${progeny} ${optimization} ${test_fitness}) 
                    #echo "${job_out} =" >> ${file_jobs}
                    #echo "${job}" >> ${file_jobs}
                    
                    
                   # fi ##
                
                
                
                if [ ${critere} == "gebv" ] || [ ${critere} == "logw" ] || [ ${critere} == "uc" ] || [ ${critere} == "uc_extreme" ] || [ ${critere} == "embv" ]
                
                
                    then
                    
                                                #    if [ $(ls ${r_best_crosses_lines} | grep ${type} | grep ${critere}_real_top_RILsF5 | wc -l) -eq 0 ] ##
                               # then ##
                    

                
                        #echo ${type}_${population_variance}_${critere}_${programme}_${progeny}_top
                        job_out=${r_log_best_crosses}best_crosses_1_${type}_${population_variance}_${critere}_${programme}_${progeny}_top.out
                        job_name=${typeshort}${population_variance}${critere}${programme}${progeny}top
                        #job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}best_crosses_4.sh ${base} ${type} ${population_variance} ${critere} ${programme} ${progeny}) 
                        #echo "${job_out} =" >> ${file_jobs}
                        #echo "${job}" >> ${file_jobs}
                        
                        
                      #  fi ##
                    
                fi
                
                
                
                
                
                
                
                
                while (( $(squeue -u adanguy | wc -l) >= ${nb_jobs_allowed} ))
                    do    
                    sleep 1s
                done
                sed -i '/^$/d' ${file_jobs}
                while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 100 )) 
                    do    
                    sleep 1s
                done
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
                                type=simTRUE_${subset}_r${r}
                                
                                
                                
                            if [ $(grep ${type} ${r_log}fails.txt | grep ${critere} wc -l) -eq 1 ]
                            then
                               
                               
                               
                            
                                

                                
                                
                                    typeshort=$(echo ${type} | sed "s/_/./g")
                                    echo ${type}_${population_variance}_${critere}_${programme}_${progeny}
                                    job_out=${r_log_best_crosses}best_crosses_1_${type}_${population_variance}_${critere}_${programme}_${progeny}.out
                                    job_name=${typeshort}${population_variance}${critere}${programme}${progeny}
                                    job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}best_crosses_1.sh ${base} ${type} ${population_variance} ${critere} ${programme} ${progeny} ${optimization} ${test_fitness}) 
                                    echo "${job_out} =" >> ${file_jobs}
                                    echo "${job}" >> ${file_jobs}
                                    
                               fi ##
                                    
                                    
                                
                                
                                if [ ${critere} == "gebv" ] || [ ${critere} == "logw" ] || [ ${critere} == "uc" ] || [ ${critere} == "uc_extreme" ] || [ ${critere} == "embv" ] 
                                 
                                    then
                                    
                              if [ $(ls ${r_best_crosses_lines} | grep lines_tbv_${type}_${population_variance}_${critere}_${programme}_top_RILsF5 | wc -l) -eq 0 ] ##
                               then ##
                                    
                                
                                
                                                
                                        echo ${type}_${population_variance}_${critere}_${programme}_${progeny}_top
                                        job_out=${r_log_best_crosses}best_crosses_1_${type}_${population_variance}_${critere}_${programme}_${progeny}_top.out
                                        job_name=${typeshort}${population_variance}${critere}${programme}${progeny}top
                                        job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}best_crosses_4.sh ${base} ${type} ${population_variance} ${critere} ${programme} ${progeny}) 
                                        echo "${job_out} =" >> ${file_jobs}
                                        echo "${job}" >> ${file_jobs}
                                        
                                        
                                fi ##
                                    
                                fi
                                
                                
                                while (( $(squeue -u adanguy | wc -l) >= ${nb_jobs_allowed} ))
                                    do    
                                    sleep 1s
                                done
                                sed -i '/^$/d' ${file_jobs}
                                while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 100 )) 
                                    do    
                                    sleep 1s
                                done
                        
                        
                        
            
                        elif [ ${data} == "estimated" ]
                            then
                
        
        
                                for h in ${heritability[*]}
                                do
    

                    
                                    type=simTRUE_${subset}_h${h}_r${r}_g${method}
                                    
                                    
                            if [ $(grep ${type} ${r_log}fails.txt | grep ${critere} wc -l) -eq 1 ]
                               then ##
                                    
                                        
                                                        



                                        typeshort=$(echo ${type} | sed "s/_/./g")
                                        echo ${type}_${population_variance}_${critere}_${programme}_${progeny}
                                        job_out=${r_log_best_crosses}best_crosses_1_${type}_${population_variance}_${critere}_${programme}_${progeny}.out
                                        job_name=${typeshort}${population_variance}${progeny}
                                        job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}best_crosses_1.sh ${base} ${type} ${population_variance} ${critere} ${programme} ${progeny} ${optimization} ${test_fitness}) 
                                        echo "${job_out} =" >> ${file_jobs}
                                        echo "${job}" >> ${file_jobs}
                                        
                                        
                                    fi ##
                                    
                                        
                                    if [ ${critere} == "gebv" ] || [ ${critere} == "logw" ] || [ ${critere} == "uc" ] || [ ${critere} == "uc_extreme" ] || [ ${critere} == "embv" ] 
                                     
                                        then
                                        
                                        
                              if [ $(ls ${r_best_crosses_lines} | grep lines_tbv_${type}_${population_variance}_${critere}_${programme}_top_RILsF5 | wc -l) -eq 0 ] ##
                               then ##
                                    
                                        
                                            
                                    
                                    
                                            echo ${type}_${population_variance}_${critere}_${programme}_${progeny}_top
                                            job_out=${r_log_best_crosses}best_crosses_1_${type}_${population_variance}_${critere}_${programme}_${progeny}_top.out
                                            job_name=${typeshort}${population_variance}${critere}${programme}${progeny}top
                                            job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}best_crosses_4.sh ${base} ${type} ${population_variance} ${critere} ${programme} ${progeny}) 
                                            echo "${job_out} =" >> ${file_jobs}
                                            echo "${job}" >> ${file_jobs}
                                            
                                   
                                   fi ##
                                        
                                    fi
                                    
                                    while (( $(squeue -u adanguy | wc -l) >= ${nb_jobs_allowed} ))
                                        do    
                                        sleep 1s
                                    done     
                                    sed -i '/^$/d' ${file_jobs}
                                    while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 100 )) 
                                        do    
                                        sleep 1s
                                    done
                                done
                            
                            fi
                        
                        done
                    done
                done
            done
        done
    fi
done
                        
                
                
                





date +'%Y-%m-%d-%T'
