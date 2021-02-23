#!/bin/bash
RANDOM=1


base=${1}

generation=${2}

simulation=${3}





# base=/work/adanguy/these/croisements/scripts/base_cr_031120.sh
source ${base}

k=0
file_jobs=${r_log_value_crosses_gblup}jobs_gblup_sim${simulation}.txt
rm ${file_jobs}


if [ ${simulation} == "FALSE" ]
    then

    output_markers=${r_value_crosses}markers_estimated.txt
    output_lines=${r_value_crosses}lines_estimated.txt
    run=0


    
    for subset in ${cm[*]}
        do


        r_log=${r_log_value_crosses_gblup}${subset}cm/sim${simulation}/
        r_save=${r_value_crosses}blupf90/${subset}cm/sim${simulation}/

        mkdir -p ${r_log}
        mkdir -p ${r_save}


        ID=${subset}cm_sim${simulation}
        IDshort=${subset}${simulation}
        echo ${ID}

  
        job_out=${r_log}gblup_${ID}.out
    
        job_name=${IDshort}
	    
        job=$(sbatch -o ${job_out} -J ${job_name} --mem=10G --parsable ${r_scripts}gblup_2.sh ${base} ${subset} ${simulation})
    
        echo "${job_out} =" >> ${file_jobs}
        echo "${job}" >> ${file_jobs}
    
    
    

        while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
            do    
            sleep 1s
        done


    
    

    
    



        file_marker=${r_save}markers_${ID}.txt
        file_lines=${r_save}lines_${ID}.txt
        file_temp1=${r_save}temp1_${ID}.txt
        file_temp2=${r_save}temp2_${ID}.txt

        if ((k==0 ))
        
            then 
        
            cat ${file_marker} > ${output_markers}
        
        
            cat ${file_lines} > ${output_lines}
        
        
        else
    
    
            motif_gebv=gebv_qb_${subset}cm
            motif_qb=qb_${subset}cm
        
            already_present_gebv=$(head -n1 ${output_lines} | sed "s/\t/\n/g" | grep -n ${motif_gebv} | wc -l )
            already_present_qb=$(head -n1 ${output_markers} | sed "s/\t/\n/g" | grep -n ${motif_qb} | wc -l )
        
            
            if [ ${already_present_gebv} -eq 0 ]
                then
        
                echo "add gebv"

                range_inf=$(head -n1 ${file_lines} | sed "s/\t/\n/g" | grep -n ${motif_gebv} | cut -f1 -d":" | sort | head -n1)
                range_sup=$(head -n1 ${file_lines} | sed "s/\t/\n/g" | grep -n ${motif_gebv} | cut -f1 -d":" | sort | tail -n1)
                cut ${file_lines} -f${range_inf}-${range_sup} > ${file_temp1}
                paste -d'\t' ${output_lines} ${file_temp1} > ${file_temp2}
                cp ${file_temp2} ${output_lines}
    
                rm ${file_temp1}
                rm ${file_temp2}
                
            if [ ${already_present_qb} -eq 0 ]
                then
                
                echo "add qr"

        
                range_inf=$(head -n1 ${file_markers} | sed "s/\t/\n/g" | grep -n ${motif_qb} | cut -f1 -d":" | sort | head -n1)
                range_sup=$(head -n1 ${file_markers} | sed "s/\t/\n/g" | grep -n ${motif_qb} | cut -f1 -d":" | sort | tail -n1)
                cut ${file_markers} -f${range_inf}-${range_sup} > ${file_temp1}
                paste -d'\t' ${output_markers} ${file_temp1} > ${file_temp2}
                cp ${file_temp2} ${output_markers}
            
              
                rm ${file_temp1}
                rm ${file_temp2}
    
    

    
        fi


    
        k=$((k +1))

    
    done
    

elif [ ${simulation} == "TRUE" ]
    then
    
    output_markers=${r_value_crosses}markers_estimated_qtls_estimated.txt
    output_lines=${r_value_crosses}lines_estimated_qtls_estimated.txt

    for subset in ${cm[*]}
        do
        
        for h in ${heritability[*]}
            do
    
            for idrun in $(seq 1 ${nb_run})
                do

                r_log=${r_log_value_crosses_gblup}${subset}cm/sim${simulation}/g${generation}/r${idrun}/h${h}/
                r_save=${r_value_crosses}blupf90/${subset}cm/sim${simulation}/g${generation}/r${idrun}/h${h}/

                mkdir -p ${r_log}
                mkdir -p ${r_save}


                ID=${subset}cm_sim${simulation}_g${generation}_r${idrun}_h${h}
                IDshort=${subset}${simulation}${generation}${idrun}.${h}
                echo ${ID}

  
                job_out=${r_log}gblup_${ID}.out
    
                job_name=${IDshort}
	    
                job=$(sbatch -o ${job_out} -J ${job_name} --mem=10G --parsable ${r_scripts}gblup_2.sh ${base} ${subset} ${simulation} ${generation} ${idrun} ${h})
    
                echo "${job_out} =" >> ${file_jobs}
                echo "${job}" >> ${file_jobs}
    
    

                while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
                    do    
                    sleep 1s
                done



                file_marker=${r_save}markers_${ID}.txt
                file_lines=${r_save}lines_${ID}.txt
                file_temp1=${r_save}temp1_${ID}.txt
                file_temp2=${r_save}temp2_${ID}.txt

                if ((k==0 ))
        
                    then 
        
                    cat ${file_marker} > ${output_markers}
        
        
                    cat ${file_lines} > ${output_lines}
        
        
                            
                else
    
    
                    motif_gebv=gebv_qr_${subset}cm_h${h}_r${idrun}
                    motif_qe=qe_${subset}cm_h${h}_r${idrun}
        
                    already_present_gebv=$(head -n1 ${output_lines} | sed "s/\t/\n/g" | grep -n ${motif_gebv} | wc -l )
                    already_present_qe=$(head -n1 ${output_markers} | sed "s/\t/\n/g" | grep -n ${motif_qe} | wc -l )
        
            
                    if [ ${already_present_gebv} -eq 0 ]
                        then
        
                        echo "add gebv"

                        range_inf=$(head -n1 ${file_lines} | sed "s/\t/\n/g" | grep -n ${motif_gebv} | cut -f1 -d":" | sort | head -n1)
                        range_sup=$(head -n1 ${file_lines} | sed "s/\t/\n/g" | grep -n ${motif_gebv} | cut -f1 -d":" | sort | tail -n1)
                        cut ${file_lines} -f${range_inf}-${range_sup} > ${file_temp1}
                        paste -d'\t' ${output_lines} ${file_temp1} > ${file_temp2}
                        cp ${file_temp2} ${output_lines}
    
                        rm ${file_temp1}
                        rm ${file_temp2}
                
                    if [ ${already_present_qe} -eq 0 ]
                        then
                
                        echo "add qe"

        
                        range_inf=$(head -n1 ${file_markers} | sed "s/\t/\n/g" | grep -n ${motif_qe} | cut -f1 -d":" | sort | head -n1)
                        range_sup=$(head -n1 ${file_markers} | sed "s/\t/\n/g" | grep -n ${motif_qe} | cut -f1 -d":" | sort | tail -n1)
                        cut ${file_markers} -f${range_inf}-${range_sup} > ${file_temp1}
                        paste -d'\t' ${output_markers} ${file_temp1} > ${file_temp2}
                        cp ${file_temp2} ${output_markers}
            
              
                        rm ${file_temp1}
                        rm ${file_temp2}
    
    

    
                    fi
  
    

    
                fi
    
                #rm ${file_marker}
                #rm ${file_lines}

    
                k=$((k +1))

    
            done
            
        done

    done
    
fi




