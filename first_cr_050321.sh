#!/bin/bash
#SBATCH -o /work/adanguy/these/croisements/scripts/pipeline_cr.out
#SBATCH -J first
#SBATCH --time=00:10:00
RANDOM=1
date +'%Y-%m-%d-%T'


################################# Etape 1 : repositories


base=/work/adanguy/these/croisements/scripts/base_cr_200421.sh

source ${base}

#rm -rf ${r}
# rm -rf ${r_big_files}

source ${base}

file_jobs=${r_log}first_jobs.txt



################################# Etape 2 : sources files
nbcores=2
job_out=${r_log_prepare}prepare.out
job_name=prepare
#job1_1=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}prepare.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_1}" >> ${file_jobs}





generation=1
job_out=${r_log_value_crosses}value_crosses_g${generation}.out
job_name=value
# job1_2=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job1_1} --parsable ${r_scripts}value_crosses.sh ${base} ${generation})
job1_2=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}value_crosses.sh ${base} ${generation})

echo "${job_out} =" >> ${file_jobs}
echo "${job1_2}" >> ${file_jobs}



################################# Etape 3 : training on real data
job_out=${r_log_best_crosses}best_crosses_g${generation}.out
job_name=best
#job1_3=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job1_2} --parsable ${r_scripts}best_crosses.sh ${base} ${generation})

job1_3=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}best_crosses.sh ${base} ${generation})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_3}" >> ${file_jobs}




nbcores=20
type=marker_simTRUE_allcm_r2
population_ref2=${population_ref}
population_variance=${population_ref2}
job_out=${r_log_sd_predictions}sd_predictions_${population_ref2}_${population_variance}_${type}.out
job_name=sd_${population_ref2}_${population_variance}
#job1_4=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --dependency=afterok:${job1_2} --parsable ${r_scripts}sd_predictions.sh ${base} ${type} ${population_ref2} ${population_variance})
job1_4=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}sd_predictions.sh ${base} ${type} ${population_ref2} ${population_variance})

echo "${job_out} =" >> ${file_jobs}
echo "${job1_4}" >> ${file_jobs}


job_out=${r_log}figures_all.out
job_name=figure
#job1_5=$(sbatch -o ${job_out} -J ${job_name} --mem-per-cpu=100G --dependency=afterok:${job1_3}:${job1_4} --parsable ${r_scripts}analyses_rmd.sh ${base})
job1_5=$(sbatch -o ${job_out} -J ${job_name} --mem-per-cpu=50G --parsable ${r_scripts}analyses_rmd.sh ${base})

echo "${job_out} =" >> ${file_jobs}
echo "${job1_5}" >> ${file_jobs}


job_out=${r_log}crossval.out
job_name=c
#job1_6=$(sbatch -o ${job_out} -J ${job_name} --mem-per-cpu=50G --dependency=afterok:${job1_3} --parsable ${r_scripts}pipeline_for_LDAK.sh ${base})
job1_6=$(sbatch -o ${job_out} -J ${job_name} --mem-per-cpu=50G --parsable ${r_scripts}pipeline_for_LDAK.sh ${base})

echo "${job_out} =" >> ${file_jobs}
echo "${job1_6}" >> ${file_jobs}


cp ${r_scripts}pipeline_cr.out ${r_log}




