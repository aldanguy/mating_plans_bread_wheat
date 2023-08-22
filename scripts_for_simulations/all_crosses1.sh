#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
export LC_COLLATE=C
export LC_ALL=C
ulimit -s unlimited
export OMP_STACKSIZE=64M









base=${1}

source ${base}


r=${r_big_files}article/

file_jobs=${r0_log_jobs}jobs_all_crosses.txt



r_log=${r0_log}all_crosses/

mkdir -p ${r_log}
mkdir -p ${r}


population=unselected



genetic_map=WE
proportion_of_crosses_used=1
progeny=RILsF5
param_GA=default
set_phi_file=false
nbcores=1
set_starting_pop=true
simulation=TRUE
qtls_info=TRUE
heritability=NA
qtls=300rand
genomic=NA
constraints=CONSTRAINTS

    
    for population_ID in $(seq 1 3)
    do



ID=s${simulation}_i${qtls_info}_q${qtls}_h${heritability}_g${genomic}_p${population}_n${population_ID}_m${genetic_map}_${constraints}


echo ${ID}


v1=${base}
v2=${r}
v3=${r_log}
v4=${simulation}
v5=${qtls_info}
v6=${qtls}
v7=${heritability}
v8=${genomic}
v9=${population}
v10=${population_ID}
v11=${constraints}
v12=${progeny}
v13=${genetic_map}
v14=${proportion_of_crosses_used}
v15=${param_GA}
v16=${set_phi_file}
v17=${nbcores}
v18=${ID}
v19=${set_starting_pop}


job_out=${r_log}all_crosses_${ID}.out


job_name=${ID}

job=$(sbatch -o ${job_out} -J ${job_name} -p workq --parsable ${r_scripts}all_crosses2.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16} ${v17} ${v18} ${v19} ${v20} ${v21} ${v22} ${v23} ${v24} ${v25} ${v26} ${v27} ${v28} ${v29})

echo "${job_out} =" >> ${file_jobs}
echo "${job}" >> ${file_jobs}


done

echo "end"


jobs_all=${r0}all_jobs.txt
cat ${r0_log_jobs}* > ${jobs_all}




sed -i '/^$/d' ${jobs_all}
while (( $(squeue -u adanguy | grep -f ${jobs_all} | wc -l) >= 1 )) 
do    
    sleep 1m
    cat ${r0_log_jobs}* > ${jobs_all}
    sed -i '/^$/d' ${jobs_all}
    echo "wait"
done





date +'%Y-%m-%d-%T'

