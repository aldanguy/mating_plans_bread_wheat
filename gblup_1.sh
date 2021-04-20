#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'


base=${1}


simulation=${2}





source ${base}


file_jobs=${r_log_value_crosses_jobs}jobs_gblup.txt
folder_list=${r_log_value_crosses_gblup}folder_list_estimated.txt
k=0
output_markers=${r_value_crosses}markers_estimated.txt
output_lines=${r_value_crosses}lines_estimated.txt



if [ ${simulation} == "FALSE" ]
    then



    rm -f ${folder_list}
    echo "${r_prepare}" > ${folder_list}
    subset=all

    



        while (( $(squeue -u adanguy | wc -l) >= ${nb_jobs_allowed} ))
            do    
            sleep 1s
        done

        # variables
        type=sim${simulation}_${subset}cm
        echo ${type}
        r_log=${r_log_value_crosses_gblup}${type}/
        r_save=${r_value_crosses}${type}/





        
        
        mkdir -p ${r_log}
        typeshort=$(echo ${type} | sed "s/_/./g")
        job_out=${r_log}gblup_${type}.out
        job_name=${typeshort}
        job=$(sbatch -o ${job_out} -J ${job_name} --time=00:20:00 --parsable ${r_scripts}gblup_2.sh ${base} ${type} ${r_log} ${r_save} ${simulation})
        echo "${job_out} =" >> ${file_jobs}
        echo "${job}" >> ${file_jobs}
        echo "${r_save}" >> ${folder_list}
    

    

    
    sed -i '/^$/d' ${file_jobs}
    while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
        do    
        sleep 1s
    done
    
        cat ${folder_list} | while read folder 
        do
    
        if [ ${k} -eq 0 ]
            then
            
            cat ${folder}lines.txt > ${output_lines}
            cat ${folder}markers.txt > ${output_markers}
            
        else 
            tail -n+2 ${folder}lines* >> ${output_lines}
            tail -n+2 ${folder}markers* >> ${output_markers}
        fi
        
        k=$((k+1))
    done
    

elif [ ${simulation} == "TRUE" ]
    then
    


    for subset in ${cm[*]}
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

                type=sim${simulation}_${subset}cm_h${h}_r${r}
                echo ${type}
                r_log=${r_log_value_crosses_gblup}${type}/
                r_save=${r_value_crosses}${type}/



                mkdir -p ${r_log}
                typeshort=$(echo ${type} | sed "s/_/./g")
                job_out=${r_log}gblup_${type}.out
                job_name=${typeshort}
                job=$(sbatch -o ${job_out} -J ${job_name} --time=00:20:00 --parsable ${r_scripts}gblup_2.sh ${base} ${type} ${r_log} ${r_save} ${simulation})
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
    
    

    cat ${folder_list} | while read folder 
        do
    
        if [ ${k} -eq 0 ]
            then
            
            cat ${folder}lines.txt > ${output_lines}
            
        elif [ ${k} -eq 1 ]
            then
            tail -n+2 ${folder}lines* >> ${output_lines}
            cat ${folder}markers* > ${output_markers}
            #rm ${folder}lines*
            #rm ${folder}markers*
            
        else 
            tail -n+2 ${folder}lines* >> ${output_lines}
            tail -n+2 ${folder}markers* >> ${output_markers}
            #rm ${folder}lines*
            #rm ${folder}markers*
        fi
        
        k=$((k+1))
    done
    
    # rm ${folder_list1}
    
    titre_markers=${output_markers}
    titre_lines=${output_lines}
    
    v1=${titre_markers}
    v2=${titre_lines}
    
    Rscript ${r_scripts}after_qtls_simulations.R ${v1} ${v2}
    
    
    
    types=$(cat ${r_value_crosses}markers_estimated.txt | cut -f7 | sort | uniq | grep -v "type" )
    echo ${types[*]}
    populations=$(cat ${r_value_crosses}markers_estimated.txt | cut -f5 | sort | uniq | grep -v "population" )
    echo ${populations[*]}

    for type in ${types[*]}
        do
        motif=$(echo ${type} | sed "s/marker_//g")
        
        head -n1 ${output_lines} > ${r_value_crosses}lines_estimated_${motif}.txt
        grep -P "${motif}\t" ${output_lines} | grep -v "pheno"  >> ${r_value_crosses}lines_estimated_${motif}.txt

        
        for population in ${populations[*]}
            do
            
            head -n1 ${output_markers} > ${r_value_crosses}markers_estimated_${motif}_${population}.txt
            grep -P "${type}\t" ${output_markers} | grep ${population} >> ${r_value_crosses}markers_estimated_${motif}_${population}.txt
            
        done
    done


    


    
fi
date +'%Y-%m-%d-%T'



