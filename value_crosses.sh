#!/bin/bash



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

nbcores=${2}



job_out=${r_log_value_crosses_gblup}gblup_1.out
job_name=gblup
job1=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}gblup_1.sh ${base})




job_out=${r_log_value_crosses_simulate_qtls}simulate_qtls_1.out
job_name=qtls
job2=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job2} --parsable ${r_scripts}simulate_qtls_1.sh ${base})





job_out=${r_log_value_crosses_variance_crosses_chr}variance_crosses_chr_1.out
job_name=v
job3=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job2} --mem=10G --parsable ${r_scripts}variance_crosses_chr_1.sh ${base} ${nbcores})





job_out=${r_log_value_crosses_crosses}crosses.out
job_name=crosses
job3=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job2} --mem=10G --parsable ${r_scripts}variance_crosses_chr_1.sh ${base})



