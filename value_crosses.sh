#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'



# Goal: prepare base files for next scripts: rename lines with an equal size ID, estimate BLUE of lines, clean and impute genotyping matrix

# inputs files
# Traitees_IS.txt, matrix_nonimput_withoutOTV_names.txt from Sarah Ben-Sadoun
# Vraies_positions_marqueurs.txt, Codes_chr.txt, Decoupage_chr_ble.tab from Sophie Bouchet


# Output files
# genotyping_matrix_imputed.txt from imputation.R
# genotyping_matrix_updated.txt from order.R
# lines.txt from filtering_genotyping_matrix.R
# markers.txt from order.R


base=${1}





source ${base}



file_jobs=${r_log_value_crosses_jobs}jobs_values_crosses.txt
rm ${file_jobs}


simulation=FALSE
job_out=${r_log_value_crosses_gblup}gblup_1_sim${simulation}.out
job_name=gblup${simulation}
job2_1=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}gblup_1.sh ${base} ${simulation})
echo "${job_out} =" >> ${file_jobs}
echo "${job2_1}" >> ${file_jobs}
    



job_out=${r_log_value_crosses_simulate_qtls}simulate_qtls_1.out
job_name=qtls
job2_2=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job2_1} --parsable ${r_scripts}simulate_qtls_1.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job2_2}" >> ${file_jobs}
    

simulation=TRUE
job_out=${r_log_value_crosses_gblup}gblup_1_sim${simulation}.out
job_name=gblup${simulation}
job2_3=$(sbatch -o ${job_out} -J ${job_name} --mem=10G --dependency=afterok:${job2_2}:${job2_1} --parsable ${r_scripts}gblup_1.sh ${base} ${simulation})
echo "${job_out} =" >> ${file_jobs}
echo "${job2_3}" >> ${file_jobs}
    

job_out=${r_log_value_crosses_crosses}crosses_1.out
job_name=v
#job2_4=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job2_3} --parsable ${r_scripts}crosses_1.sh ${base})
job2_4=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}crosses_1.sh ${base})

echo "${job_out} =" >> ${file_jobs}
echo "${job2_4}" >> ${file_jobs}
    


sed -i '/^$/d' ${file_jobs}
while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
    do    
    sleep 1s
done
    


date +'%Y-%m-%d-%T'
