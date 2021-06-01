#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'


base=${1}


simulation=${2}





source ${base}


jobs_gblup=${r_log_value_crosses_jobs}jobs_gblup.txt



if [ ${simulation} == "FALSE" ]
    then



    cp ${r_prepare}lines.txt ${r_value_crosses_lines}lines_pheno_simFALSE.txt

    




        
    method="basic"
        
            

            type=simFALSE_g${method}
            typeshort=$(echo ${type} | sed "s/_/./g")
            echo ${type}
            

            
   




        
        
            job_out=${r_log_value_crosses_gblup}gblup_${type}.out
            job_name=${typeshort}
                    job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}gblup_2.sh ${base} ${type})
            
            echo "${job_out} =" >> ${jobs_gblup}
            echo "${job}" >> ${jobs_gblup}
    

    
    
    sed -i '/^$/d' ${jobs_gblup}
    while (( $(squeue -u adanguy | grep -f ${jobs_gblup} | wc -l) >= 1 )) 
        do    
        sleep 1s
    done
    

    

elif [ ${simulation} == "TRUE" ]
    then

    method="basic"
        


        for subset in ${qtls[*]}
            do
        
            for h in ${heritability[*]}
                do
    
                for r in $(seq 1 ${nb_run})
                    do
    

                    while (( $(squeue -u adanguy | wc -l) >= ${nb_jobs_allowed} ))
                        do    
                        sleep 1s
                    done
                    # variables

                    type=sim${simulation}_${subset}_h${h}_r${r}_g${method}
                    echo ${type}
                    
                 


                    typeshort=$(echo ${type} | sed "s/_/./g")
                    job_out=${r_log_value_crosses_gblup}gblup_${type}.out
                    job_name=${typeshort}
                    job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}gblup_2.sh ${base} ${type})
                    echo "${job_out} =" >> ${jobs_gblup}
                    echo "${job}" >> ${jobs_gblup}


    
                done
            
            done

    
    done
    
    
    sed -i '/^$/d' ${jobs_gblup}
    while (( $(squeue -u adanguy | grep -f ${jobs_gblup} | wc -l) >= 1 )) 
        do    
        sleep 1s
    done
    
    

   
                
                
                
   
   
    
 


    
fi
date +'%Y-%m-%d-%T'



