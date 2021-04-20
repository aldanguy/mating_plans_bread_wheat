#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'




base=${1}
generation=${2}


source ${base}
    

types=$(cat ${r_value_crosses}markers_estimated.txt | cut -f7 | sort | uniq | grep -v "type" )
echo ${types[*]}
file_jobs=${r_log_value_crosses_jobs}jobs_crosses_2.txt




for type in ${types[*]}
do



    
    
    subset=$(echo ${type} | grep -e "chrcm" | wc -l) # means that dealing with one QTL per chr. In this cas, genetic map doesnt matter, and only one pop is studied
    
    if [ ${subset} -eq 0 ]
        then 
        populations2=${populations[*]}
    else
        populations2=(WE)
    fi

    
    for population in ${populations2[*]} # to replace by populations2
    do





        while (( $(squeue -u adanguy | wc -l) >= ${nb_jobs_allowed} ))
            do    
                sleep 1s
        done





        motif=$(echo ${type} | sed "s/marker_//g")
        ID1=g${generation}_${motif}_${population}

        echo ${ID1}
  
        job_out=${r_log_value_crosses_crosses}crosses_2_${ID1}.out
    
        job_name=${motif}${population}
        
 
            job_name=${motif}${population}

            job=$(sbatch -o ${job_out} -J ${job_name} --mem=3G --parsable ${r_scripts}crosses_2.sh ${base} ${generation} ${type} ${population}) 

    
    
        echo "${job_out} =" >> ${file_jobs}
        echo "${job}" >> ${file_jobs}
        
        sed -i '/^$/d' ${file_jobs}
        while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 10 )) 
            do    
            sleep 1s
        done
        
    done
	
done


sed -i '/^$/d' ${file_jobs}
while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
do    
    sleep 1s
done



date +'%Y-%m-%d-%T'



