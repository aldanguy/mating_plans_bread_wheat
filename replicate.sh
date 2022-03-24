#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
export LC_COLLATE=C
export LC_ALL=C
ulimit -s unlimited
export OMP_STACKSIZE=64M









base=${1}

source ${base}



echo ${base}



file_jobs=${r0_log_jobs}jobs_replicate.txt


r_replicate=${r_big_files}article/replicate/
r_log=${r0_log}replicate/


mkdir -p ${r_replicate}
mkdir -p ${r_log}




constraints=CONSTRAINTS
nbcores=2
set_phi_file=false
set_starting_pop=true
qtls=300rand
genetic_map=WE



simulation=TRUE
qtls_info=TRUE
heritability=NA
genomic=NA
population=unselected


for population_ID in $(seq 1 3)
do

ID=s${simulation}_i${qtls_info}_q${qtls}_h${heritability}_g${genomic}_p${population}_n${population_ID}_m${genetic_map}_${constraints}
titre_criteria_base=${r_big_files}article/criteria/criteria_${ID}

for seed in $(seq 2 3)
do

r_replicate_seed=${r_big_files}article/replicate/seed${seed}/
r_log_replicate=${r0_log}replicate/seed${seed}/

mkdir -p ${r_replicate_seed}
mkdir -p ${r_log_replicate}

titre_mating_plan_base=${r_replicate_seed}mating_plan_${ID}_seed${seed}_


cp ${r_scripts}param_GA_default.sh ${r_scripts}param_GA_seed${seed}.sh
sed -i "s/seed=1/seed=${seed}/g" ${r_scripts}param_GA_seed${seed}.sh
param_GA=seed${seed}
                       
             



for criterion in ${criteria[*]}
do



v1=${base}
v2=${r_replicate_seed}
v3=${r_log_replicate}
v4=${ID}
v5=${constraints}
v6=${criterion}
v7=${titre_criteria_base}
v8=${titre_mating_plan_base}
v9=${nbcores}
v10=${param_GA}
v11=${set_phi_file}
v12=${set_starting_pop}





job_out=${r_log}replicate_${ID}_${criterion}_seed${seed}.out


job_name=rep${criterion}${ID}



job_opti=$(sbatch -o ${job_out} -J ${job_name} --mem=3G --parsable ${r_scripts}optimization.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16} ${v17} ${v18} ${v19} ${v20} ${v21})

echo "${job_out} =" >> ${file_jobs}
echo "${job_opti}" >> ${file_jobs}

done

done

done

k=0

for population_ID in $(seq 1 3)
do

for criterion in ${criteria[*]}
do

ID=s${simulation}_i${qtls_info}_q${qtls}_h${heritability}_g${genomic}_p${population}_n${population_ID}_m${genetic_map}_${constraints}



titre_seed1=${r_big_files}article/optimization/mating_plan_${ID}_${criterion}.txt

awk -v var=seed1  'NR==1{$(NF+1)="rep"} NR>1{$(NF+1)=var}1' ${titre_seed1} > ${r_replicate}temp.txt


if [ ${k} -eq 0 ]
then


cat ${r_replicate}temp.txt > ${r_replicate}mating_plan_replicate.txt

else

tail -n+2 ${r_replicate}temp.txt >> ${r_replicate}mating_plan_replicate.txt

fi





titre_seed1=${r_big_files}article/perf_${ID}_${criterion}*



if [ ${k} -eq 0 ]
then


cat ${r_replicate}temp.txt > ${r_replicate}perf.txt

else

tail -n+2 ${r_replicate}temp.txt >> ${r_replicate}perf.txt

fi

k=$((${k}+1))
done

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

for seed in $(seq 2 3)
do



for f in ${r_big_files}article/replicate/seed${seed}/mating_plan_*seed${seed}_*
do
    
    echo ${f}
    
    awk -v var=${seed}  'NR==1{$(NF+1)="rep"} NR>1{$(NF+1)=var}1' ${f} > ${r_replicate}temp.txt
    
    tail -n+2 ${r_replicate}temp.txt >> ${r_replicate}mating_plan_replicate.txt

done



for f in ${r_big_files}article/replicate/seed${seed}/perf_*
do


    
    echo ${f}
    
    awk -v var=${seed}  'NR==1{$(NF+1)="rep"} NR>1{$(NF+1)=var}1' ${f} > ${r_replicate}temp.txt


   
    
    tail -n+2 ${r_replicate}temp.txt >> ${r_replicate}perf.txt
    

done


done

rm ${r_replicate}temp.txt




titre_mating_plans_input=${r_replicate}mating_plan_replicate.txt
titre_shared_output${r_results}replicate.txt



v1=${titre_mating_plans_input}
v2=${titre_shared_output}


Rscript ${r_scripts}analyse_replicate.R ${v1} ${v2}


date +'%Y-%m-%d-%T'

