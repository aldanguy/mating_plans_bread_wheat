#!/bin/bash
#SBATCH -o /work/adanguy/these/croisements/scripts/pipeline_cr.out
#SBATCH -J first
#SBATCH --time=00:10:00


################################# Etape 1 : repositories


base=/work/adanguy/these/croisements/scripts/base_cr_090221.sh

source ${base}

# rm -rf ${r}
# rm -rf ${r_big_files}

source ${base}



################################# Etape 2 : sources files
nbcores=5
keep_all=FALSE
cM=FALSE
simulation=FALSE


job_out=${r_log}prepare.out
job_name=prepare
# job1=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}prepare.sh ${base} ${nbcores} ${keep_all})


job_out=${r_log_value_crosses}value_crosses.out
job_name=value
# job3=$(sbatch -o ${job_out} -J ${job_name} --mem=50G --dependency=afterok:${job1} --parsable ${r_scripts}value_crosses.sh ${base} ${nbcores} ${cM} ${simulation})

################################# Etape 3 : training on real data

generation=1
job_out=${r_log_best_crosses}best_crosses.out
job_name=best
# job4=$(sbatch -o ${job_out} -J ${job_name} --mem=50G --dependency=afterok:${job3} --parsable ${r_scripts}best_crosses.sh ${base} ${nbcores} ${generation})







nbcores=10

job_out=${r_log_sd_predictions}sd_predictions.out
job_name=sd
# job5=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G  --dependency=afterok:${job3} --parsable ${r_scripts}sd_predictions.sh ${base} ${nbcores})
job5=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}sd_predictions.sh ${base} ${nbcores})





