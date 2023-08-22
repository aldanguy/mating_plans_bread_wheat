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



#rm -rf ${r_best_crosses}
#rm -rf ${r_log_best_crosses}


source ${base}



################################# Etape 2 : sources files
nbcores=2
job_out=${r_log_prepare}prepare.out
job_name=prepare
#job1_1=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}prepare.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_1}" >> ${file_jobs}





job_out=${r_log_value_crosses}value_crosses.out
job_name=value
# job1_2=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job1_1} --parsable ${r_scripts}value_crosses.sh ${base})
job1_2=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}value_crosses.sh ${base})

echo "${job_out} =" >> ${file_jobs}
echo "${job1_2}" >> ${file_jobs}



################################# Etape 3 : training on real data
job_out=${r_log_best_crosses}best_crosses.out
job_name=best
#job1_3=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job1_2} --parsable ${r_scripts}best_crosses.sh ${base})
job1_3=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}best_crosses.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_3}" >> ${file_jobs}



nbcores=20
type=simFALSE_gbasic
population_profile=${population_ref}
population_variance=${population_ref}
progeny=RILsF5
job_out=${r_log_sd_predictions}sd_predictions_${population_variance}_${population_profile}_${type}_${progeny}.out
job_name=sd_${population_profile}_${population_variance}_${progeny}
#job1_4=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --dependency=afterok:${job1_2} --parsable ${r_scripts}sd_predictions.sh ${base} ${type} ${population_ref2} ${population_variance} ${progeny})
job1_4=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}sd_predictions.sh ${base} ${type} ${population_profile} ${population_variance} ${progeny})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_4}" >> ${file_jobs}


nbcores=20
type=simFALSE_gbasic
population_profile=${population_ref}
population_variance=${population_ref}
progeny=HDs
job_out=${r_log_sd_predictions}sd_predictions_${population_variance}_${population_profile}_${type}_${progeny}.out
job_name=sd_${population_profile}_${population_variance}_${progeny}
#job1_4=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --dependency=afterok:${job1_2} --parsable ${r_scripts}sd_predictions.sh ${base} ${type} ${population_ref2} ${population_variance} ${progeny})
job1_4=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}sd_predictions.sh ${base} ${type} ${population_profile} ${population_variance} ${progeny})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_4}" >> ${file_jobs}







job_out=${r_log}results.out
job_name=results
#job1_5=$(sbatch -o ${job_out} -J ${job_name} --mem-per-cpu=100G --dependency=afterok:${job1_3}:${job1_4} --parsable ${r_scripts}analyses_rmd.sh ${base})
job1_5=$(sbatch -o ${job_out} -J ${job_name} --mem-per-cpu=100G --parsable ${r_scripts}results.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_5}" >> ${file_jobs}







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




