#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'


base=${1}


simulation=${2}





source ${base}


jobs_gblup=${r_log_value_crosses_jobs}jobs_gblup.txt
folder_list_gblup=${r_log_value_crosses_gblup}folder_list_gblup.txt
k=0
output_markers=${r_value_crosses}markers_estimated.txt
output_lines=${r_value_crosses}lines_estimated.txt



if [ ${simulation} == "FALSE" ]
    then



    rm -f ${folder_list_gblup}
    echo "${r_prepare}" > ${folder_list_gblup}

    




        
        for method in ${genomic[*]}
        
            do

            type=marker_simFALSE_allcm_g${method}
            typeshort=$(echo ${type} | sed "s/_/./g")
            r_save=${r_value_crosses_gblup}${type}/
            echo ${type}
            

            
   




        
        
            job_out=${r_log_value_crosses_gblup}gblup_${type}.out
            job_name=${typeshort}
            job=$(sbatch -o ${job_out} -J ${job_name} --time=00:20:00 --parsable ${r_scripts}gblup_2_weights_ldak.sh ${base} ${simulation} ${method} ${type})
            
            echo "${job_out} =" >> ${jobs_gblup}
            echo "${job}" >> ${jobs_gblup}
            echo "${r_save}" >> ${folder_list_gblup}
    

    
    done
    
    sed -i '/^$/d' ${jobs_gblup}
    while (( $(squeue -u adanguy | grep -f ${jobs_gblup} | wc -l) >= 1 )) 
        do    
        sleep 1s
    done
    
        cat ${folder_list_gblup} | while read folder 
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

    for method in ${genomic[*]}
        do


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

                    type=marker_sim${simulation}_${subset}cm_h${h}_r${r}_g${method}
                    echo ${type}
                    r_save=${r_value_crosses_gblup}${type}/
                    
                 


                    typeshort=$(echo ${type} | sed "s/_/./g")
                    job_out=${r_log_value_crosses_gblup}gblup_${type}.out
                    job_name=${typeshort}
            job=$(sbatch -o ${job_out} -J ${job_name} --time=00:20:00 --parsable ${r_scripts}gblup_2_weights_ldak.sh ${base} ${simulation} ${method} ${type})
                    echo "${job_out} =" >> ${jobs_gblup}
                    echo "${job}" >> ${jobs_gblup}
                    echo "${r_save}" >> ${folder_list_gblup}


    
                done
            
            done

        done
    done
    
    
    sed -i '/^$/d' ${jobs_gblup}
    while (( $(squeue -u adanguy | grep -f ${jobs_gblup} | wc -l) >= 1 )) 
        do    
        sleep 1s
    done
    
    

    cat ${folder_list_gblup} | while read folder 
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
    
    <<COMMENTS
    
    titre_markers=${output_markers}
    titre_lines=${output_lines}
    
    v1=${titre_markers}
    v2=${titre_lines}
    
    #Rscript ${r_scripts}after_qtls_simulations.R ${v1} ${v2}
    
    
    
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

COMMENTS

titre=${output_lines}

v1=${titre}


Rscript ${r_scripts}evaluate_gmodel.R ${v1}
    


    
fi
date +'%Y-%m-%d-%T'



