#!/bin/bash
#SBATCH -o /work/adanguy/these/croisements/scripts/pipeline_cr.out
#SBATCH -J first
#SBATCH --time=00:10:00


################################# Etape 1 : repositories


base=/work/adanguy/these/croisements/scripts/base_cr_090221.sh

source ${base}

# rm -rf ${r}

source ${base}



################################# Etape 2 : sources files
nbcores=2
keep_all=FALSE
cM=FALSE
simulation=FALSE


job_out=${r_log}prepare.out
job_name=prepare
job1=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}prepare.sh ${base} ${nbcores} ${keep_all})

job_out=${r_log}selection_intensity.out
job_name=i
job2=$(sbatch -o ${job_out} -J ${job_name} --time=00:30:00 --parsable ${r_scripts}selection_intensity.sh ${base})


job_out=${r_log_calcul}calcul.out
job_name=calcul
job3=$(sbatch -o ${job_out} -J ${job_name} --mem=50G --dependency=afterok:${job1}:${job2} --parsable ${r_scripts}calcul.sh ${base} ${nbcores} ${cM} ${simulation})

################################# Etape 3 : training on real data

generation=1
job_out=${r_log_best_crosses}best_crosses.out
job_name=best
job4=$(sbatch -o ${job_out} -J ${job_name} --mem=50G --dependency=afterok:${job3} --parsable ${r_scripts}best_crosses.sh ${base} ${nbcores})









job_out=${r_log_sd_predictions}sd_predictions.out
job_name=sd
job5=$(sbatch -o ${job_out} -J ${job_name} --mem=50G --dependency=afterok:${job3} --parsable ${r_scripts}sd_predictions.sh ${base} ${nbcores})





