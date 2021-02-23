#!/bin/bash
RANDOM=1



base=${1}




source ${base}

file_jobs=${r_log_value_crosses_simulate_qtls}jobs_simulate_qtls.txt
rm ${file_jobs}
output_markers=${r_value_crosses}markers_estimated_qtls.txt
output_lines=${r_value_crosses}lines_estimated_qtls.txt
rm ${output_markers}
rm ${output_lines}


for h in ${heritability[*]}
    do
    for subset in ${cm[*]}
        do


        ID=${subset}cm_h${h}
        IDshort=${subset}.${h}
        echo ${ID}
  
        job_out=${r_log_value_crosses_simulate_qtls}simulate_qtls_2_${ID}.out
    
        job_name=${IDshort}
	    
        job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}simulate_qtls_2.sh ${base} ${subset} ${h}) 
    
        echo "${job_out} =" >> ${file_jobs}
        echo "${job}" >> ${file_jobs}
    



        while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
            do    
            sleep 1s
        done

    


        ID=${subset}cm_h${h}

        file_lines=${r_value_crosses}lines_estimated_qtls_${ID}.txt
        file_markers=${r_value_crosses}markers_estimated_qtls_${ID}.txt
        motif_blue=blue_qr_${subset}cm_h${h}_r
        motif_tbv=tbv_qr_${subset}cm_r
        motif_qr=qr_${subset}cm_r



        motif=${motif_blue}
        file_input=${file_lines}
        file_output=${output_lines}
        paste_columns "${motif}" "${file_input}" "${file_output}"
   
   
   
        motif=${motif_tbv}
        file_input=${file_lines}
        file_output=${output_lines}
        paste_columns "${motif}" "${file_input}" "${file_output}"

   
        motif=${motif_qr}
        file_input=${file_markers}
        file_output=${output_markers}
        paste_columns "${motif_qr}" "${file_markers}" "${output_markers}"




               



    done
    
    
done
