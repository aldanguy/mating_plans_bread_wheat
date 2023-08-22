#!/bin/bash
#SBATCH -o /work/adanguy/these/croisements/scripts/pipeline_cr_maize.out
#SBATCH -J first
#SBATCH --time=00:10:00
RANDOM=1
date +'%Y-%m-%d-%T'




################################# Etape 1 : repositories


base=/work/adanguy/these/croisements/scripts/base_cr_290421_maize.sh

source ${base}

#rm -rf ${r}
# rm -rf ${r_big_files}

source ${base}

file_jobs=${r_log}first_jobs.txt



################################# Etape 2 : sources files
job_out=${r_log_prepare}prepare.out
job_name=prepare
job1_1=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}prepare_maize.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job1_1}" >> ${file_jobs}
