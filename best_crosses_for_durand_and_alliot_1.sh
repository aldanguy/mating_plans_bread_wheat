#!/bin/bash



base=${1}


base=/work/adanguy/these/croisements/scripts/base_cr_031120.sh

source ${base}

nbcores=1



critere=gebv


job_out=/work/adanguy/these/croisements/031120/log/best_crosses_for_durand_and_alliot_${critere}_constraint_on_parents.out
job_name=${critere}
job=$(sbatch -o ${job_out} -J ${job_name} --parsable --mem=10G ${r_scripts}best_crosses_for_durand_and_alliot_2.sh ${base} ${nbcores} ${critere})



critere=uc


job_out=/work/adanguy/these/croisements/031120/log/best_crosses_for_durand_and_alliot_${critere}_constraint_on_parents.out
job_name=${critere}
job=$(sbatch -o ${job_out} -J ${job_name} --parsable --mem=10G ${r_scripts}best_crosses_for_durand_and_alliot_2.sh ${base} ${nbcores} ${critere})



critere=logw


job_out=/work/adanguy/these/croisements/031120/log/best_crosses_for_durand_and_alliot_${critere}_constraint_on_parents.out
job_name=${critere}
job=$(sbatch -o ${job_out} -J ${job_name} --parsable --mem=10G ${r_scripts}best_crosses_for_durand_and_alliot_2.sh ${base} ${nbcores} ${critere})



