#!/bin/bash
#SBATCH -o /work/adanguy/these/croisements/scripts/00_pipeline.out
#SBATCH -J first
#SBATCH --time=00:10:00
RANDOM=1
date +'%Y-%m-%d-%T'


################################# Etape 1 : repositories


base=/work/adanguy/these/croisements/scripts/01_base_cr_110222.sh
####    base=/work/adanguy/these/croisements/scripts/01_base_cr_230821.sh

source ${base}

#rm -rf ${r}
#rm -rf ${r_big_files}

source ${base}

file_jobs=${r_log_jobs}00_first_jobs.txt



#rm -rf ${r_best_crosses}
#rm -rf ${r_log_best_crosses}


source ${base}



################################# Etape 2 : sources files
job_out=${r_log_prepare}01_prepare.out
job_name=prepare
job1_1=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}02_prepare.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_1}" >> ${file_jobs}

job1_1=1
job_out=${r_log_value_crosses}03_value_crosses.out
job_name=value
job1_2=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job1_1} --parsable ${r_scripts}03_value_crosses.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_2}" >> ${file_jobs}



job1_2=1
source $base
job_out=${r_log_filtering}05_filtering.out
job_name=f
job1_2=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job1_2} --parsable ${r_scripts}05_filtering.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_2}" >> ${file_jobs}


job1_2=1
job_out=${r_log_optimization}06_optimization.out
job_name=best
source $base
job1_3=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job1_2} --parsable ${r_scripts}06_01_optimization.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_3}" >> ${file_jobs}

job1_2=1
source $base
file_jobs=${r_log_jobs}00_first_jobs.txt
rm -rf ${r_log_sd_predictions}
rm -rf ${r_sd_predictions}
source $base
nbcores=10
type=simTRUE_300rand_r1
selected=selected
g=NA
population_profile=${population_ref}
population_variance=${population_ref}
progeny=RILsF5
job_out=${r_log_sd_predictions}sd_predictions_${population_variance}_${population_profile}_${type}_${selected}_${progeny}.out
job_name=sd_${population_profile}_${population_variance}_${progeny}
job1_4=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --dependency=afterok:${job1_2} --parsable ${r_scripts}07_sd_predictions.sh ${base} ${type} ${selected} ${g} ${population_variance} ${population_profile} ${progeny})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_4}" >> ${file_jobs}


job1_2=1
nbcores=10
type=simTRUE_300rand_r1
selected=unselected
g=NA
population_profile=${population_ref}
population_variance=${population_ref}
progeny=RILsF5
job_out=${r_log_sd_predictions}sd_predictions_${population_variance}_${population_profile}_${type}_${selected}_${progeny}.out
job_name=sd_${population_profile}_${population_variance}_${progeny}
job1_4=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --dependency=afterok:${job1_2} --parsable ${r_scripts}07_sd_predictions.sh ${base} ${type} ${selected} ${g} ${population_variance} ${population_profile} ${progeny})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_4}" >> ${file_jobs}

nbcores=10
job1_2=1
type=simTRUE_300rand_h0.4_r1
selected=selected
g=gblup
population_profile=${population_ref}
population_variance=${population_ref}
progeny=RILsF5
job_out=${r_log_sd_predictions}sd_predictions_${population_variance}_${population_profile}_${type}_${selected}_${progeny}.out
job_name=sd_${population_profile}_${population_variance}_${progeny}
job1_4=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --dependency=afterok:${job1_2} --parsable ${r_scripts}07_sd_predictions.sh ${base} ${type} ${selected} ${g} ${population_variance} ${population_profile} ${progeny})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_4}" >> ${file_jobs}



job1_2=1
type=simTRUE_300rand_h0.4_r1
selected=unselected
g=gblup
population_profile=${population_ref}
population_variance=${population_ref}
progeny=RILsF5
job_out=${r_log_sd_predictions}sd_predictions_${population_variance}_${population_profile}_${type}_${selected}_${progeny}.out
job_name=sd_${population_profile}_${population_variance}_${progeny}
job1_4=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --dependency=afterok:${job1_2} --parsable ${r_scripts}07_sd_predictions.sh ${base} ${type} ${selected} ${g} ${population_variance} ${population_profile} ${progeny})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_4}" >> ${file_jobs}



job_out=${r_log}results.out
job_name=results
#job1_5=$(sbatch -o ${job_out} -J ${job_name} --mem-per-cpu=100G --dependency=afterok:${job1_3}:${job1_4} --parsable ${r_scripts}analyses_rmd.sh ${base})
job1_5=$(sbatch -o ${job_out} -J ${job_name} --mem-per-cpu=100G --parsable ${r_scripts}results.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_5}" >> ${file_jobs}



job_out=${r_log}results_genetic_map.out
job_name=results_gm
job1_5=$(sbatch -o ${job_out} -J ${job_name} --mem-per-cpu=100G --parsable ${r_scripts}results_genetic_map.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_5}" >> ${file_jobs}



job_out=${r_log}results_uc.out
job_name=results_uc
job1_5=$(sbatch -o ${job_out} -J ${job_name} --mem-per-cpu=100G --parsable ${r_scripts}results_uc.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_5}" >> ${file_jobs}



job_out=${r_log}gain.out
job_name=gain
job1_5=$(sbatch -o ${job_out} -J ${job_name} --mem=20G --parsable ${r_scripts}gain.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_5}" >> ${file_jobs}



job_out=${r_log_ibs}ibs.out
job_name=ibs
job1_5=$(sbatch -o ${job_out} -J ${job_name} --mem=10G --parsable ${r_scripts}08_IBS.sh ${base})
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



job_out=${r_log}test_ag.out
job_name=c
#job1_6=$(sbatch -o ${job_out} -J ${job_name} --mem-per-cpu=50G --dependency=afterok:${job1_3} --parsable ${r_scripts}pipeline_for_LDAK.sh ${base})
job1_6=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}verification_ag.sh ${base})


cp ${r_scripts}pipeline_cr.out ${r_log}

