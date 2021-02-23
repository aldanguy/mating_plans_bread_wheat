#!/bin/bash
RANDOM=1



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


# source ${base}

nbcores=${2}

nbcores=5
base=/work/adanguy/these/croisements/scripts/base_cr_150221.sh
source ${base}


file_jobs=${r_log_value_crosses}jobs_values_crosses.txt
rm ${file_jobs}


rm -rf ${r_log_value_crosses}
rm -rf ${r_value_crosses}
source ${base}


simulation=FALSE


job_out=${r_log_value_crosses_gblup}gblup_1_sim${simulation}.out
job_name=gblup
job1=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}gblup_1.sh ${base} ${simulation})
echo "${job_out} =" >> ${file_jobs}
echo "${job1}" >> ${file_jobs}
    



job_out=${r_log_value_crosses_simulate_qtls}simulate_qtls_1.out
job_name=qtls
job2=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job1} --parsable ${r_scripts}simulate_qtls_1.sh ${base})
# job2=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}simulate_qtls_1.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job2}" >> ${file_jobs}
    

simulation=TRUE
job_out=${r_log_value_crosses_gblup}gblup_1_sim${simulation}.out
job_name=gblup
job3=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job2} --parsable ${r_scripts}gblup_1.sh ${base} ${simulation})
echo "${job_out} =" >> ${file_jobs}
echo "${job3}" >> ${file_jobs}
    



job_out=${r_log_value_crosses_variance_crosses_chr}variance_crosses_chr_1.out
job_name=v
job4=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job3} --parsable ${r_scripts}variance_crosses_chr_1.sh ${base} ${nbcores})
job4=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}variance_crosses_chr_1.sh ${base} ${nbcores})

echo "${job_out} =" >> ${file_jobs}
echo "${job4}" >> ${file_jobs}
    




job_out=${r_log_value_crosses_crosses}crosses.out
job_name=crosses
job4=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job2} --mem=10G --parsable ${r_scripts}variance_crosses_chr_1.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job4}" >> ${file_jobs}
    


