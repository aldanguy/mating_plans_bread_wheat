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
generation=${2}





source ${base}
rm -rf ${r_value_crosses_gblup}
rm -rf ${r_log_value_crosses_gblup}
source ${base}



file_jobs=${r_log_value_crosses_jobs}jobs_values_crosses.txt



simulation=FALSE
job_out=${r_log_value_crosses_gblup}gblup_1_sim${simulation}.out
job_name=gblup${simulation}
job2_1=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}gblup_1_g_ldak.sh ${base} ${simulation})
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
job2_1=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job2_2}:${job2_1} --parsable ${r_scripts}gblup_1_g_ldak.sh ${base} ${simulation})
echo "${job_out} =" >> ${file_jobs}
echo "${job2_3}" >> ${file_jobs}
    
