#!/bin/bash
RANDOM=1


base=${1}


simulation=${2}





# base=/work/adanguy/these/croisements/scripts/base_cr_031120.sh
source ${base}


file_jobs=${r_log_value_crosses_gblup}jobs_gblup_sim${simulation}.txt
rm ${file_jobs}


if [ ${simulation} == "FALSE" ]
    then

    output_markers=${r_value_crosses}markers_estimated.txt
    output_lines=${r_value_crosses}lines_estimated.txt
    rm ${output_markers}
    rm ${output_lines}

    
    for subset in ${cm[*]}
        do


        r_log=${r_log_value_crosses_gblup}sim${simulation}/${subset}cm/
        r_save=${r_value_crosses}blupf90/sim${simulation}/${subset}cm/

        mkdir -p ${r_log}
        mkdir -p ${r_save}


        ID=sim${simulation}_${subset}cm
        IDshort=${simulation}.${subset}
        echo ${ID}

  
        job_out=${r_log}gblup_${ID}.out
    
        job_name=${IDshort}
	    
        job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}gblup_2.sh ${base} ${simulation} ${subset})
    
        echo "${job_out} =" >> ${file_jobs}
        echo "${job}" >> ${file_jobs}


    
    

        while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
            do    
            sleep 1s
        done


   
        file_markers=${r_save}markers_${ID}.txt
        file_lines=${r_save}lines_${ID}.txt
        motif_gebv=gebv_qb_${subset}cm
        motif_qb=qb_${subset}cm
   
        
        paste_columns "${motif_gebv}" "${file_lines}" "${output_lines}"
   
        paste_columns "${motif_qb}" "${file_markers}" "${output_markers}"


    
    done
    

elif [ ${simulation} == "TRUE" ]
    then
    
    output_markers=${r_value_crosses}markers_estimated_qtls_estimated.txt
    output_lines=${r_value_crosses}lines_estimated_qtls_estimated.txt
    rm ${output_markers}
    rm ${output_lines}

    for subset in ${cm[*]}
        do
        
        for h in ${heritability[*]}
            do
    
            for idrun in $(seq 1 ${nb_run})
                do

                r_log=${r_log_value_crosses_gblup}sim${simulation}/${subset}cm/h${h}/r${idrun}/
                r_save=${r_value_crosses}blupf90/sim${simulation}/${subset}cm/h${h}/r${idrun}/

                mkdir -p ${r_log}
                mkdir -p ${r_save}


                ID=sim${simulation}_${subset}cm_h${h}_r${idrun}
                IDshort=${simulation}.${subset}.${h}.${idrun}
                echo ${ID}

  
                job_out=${r_log}gblup_${ID}.out
    
                job_name=${IDshort}
	    
                job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}gblup_2.sh ${base} ${simulation} ${subset} ${h} ${idrun})
    
                echo "${job_out} =" >> ${file_jobs}
                echo "${job}" >> ${file_jobs}
    


                while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
                    do    
                    sleep 1s
                done



                file_markers=${r_save}markers_${ID}.txt
                file_lines=${r_save}lines_${ID}.txt
                motif_gebv=gebv_qr_${subset}cm_h${h}_r${idrun}
                motif_qe=qe_${subset}cm_h${h}_r${idrun}


                        
                paste_columns "${motif_gebv}" "${file_lines}" "${output_lines}"
   
                paste_columns "${motif_qe}" "${file_markers}" "${output_markers}"

    
            done
            
        done

    done
    
fi




