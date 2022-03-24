#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
export LC_COLLATE=C
export LC_ALL=C
ulimit -s unlimited
export OMP_STACKSIZE=64M






base=/work/adanguy/these/croisements/scripts/01_base_cr_250222.sh

source ${base}
file_jobs=${r0}jobs_pipeline1_UC3.txt
job_name=p1
job_out=${r0}p1.out


populations=(selected)
constraintsall=(CONSTRAINTS NO_CONSTRAINTS)



genetic_map=WE
proportion_of_crosses_used=0.1
progeny=RILsF5
param_GA=default
set_phi_file=false
nbcores=2
set_starting_pop=true
file_jobs=${r0}jobs_pipeline1_UC3.txt

#rm ${file_jobs}














job_out=${r0_log_pipeline2}basic_files.out
job_name=basic
# job_prepare=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}basic_files.sh ${base})
echo "${job_out} =" >> ${file_jobs}
echo "${job_prepare}" >> ${file_jobs}




while [ ! -f "${titre_haplotypes_parents0}" ] 
do

echo "Waiting for basic files  ${titre_haplotypes_parents0}"

sleep 1m

done






ID=real_data
r=${r_big_files}real_data/
r_log=${r0_log}real_data/

simulation=FALSE
qtls_info=ESTIMATED
qtls=NA
heritability=NA
genomic=GBLUP
constraints=CONSTRAINTS
population=selected
population_ID=real_data

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



    echo ${ID}


job_out=${r0_log_pipeline2}pipeline2_${ID}.out


job_name=${ID}



# job=$(sbatch -o ${job_out} -J ${job_name} -p unlimitq --parsable ${r_scripts}pipeline2.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16} ${v17} ${v18} ${v19} ${v20} ${v21} ${v22} ${v23} ${v24} ${v25} ${v26} ${v27} ${v28} ${v29})

echo "${job_out} =" >> ${file_jobs}
echo "${job}" >> ${file_jobs}








while [ ! -f "${titre_GEBV_parents0}" ] 
do

echo "Waiting for GEBV of real data  ${titre_GEBV_parents0}"

sleep 1m

done







r=${r_big_files}article/
simulation=TRUE




for constraints in ${constraintsall[*]}
do


for population in ${populations[*]}
do
    
    for population_ID in $(seq 1 ${nb_simulations})
    do



qtls_info=ESTIMATED
heritability=0.4
qtls=300rand
genomic=GBLUP

ID=s${simulation}_i${qtls_info}_q${qtls}_h${heritability}_g${genomic}_p${population}_n${population_ID}_m${genetic_map}_${constraints}
r_log=${r0_log}article/${ID}/


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


job_out=${r0_log_pipeline2}pipeline2_${ID}.out


job_name=${heritability}${population}${population_ID}

job=$(sbatch -o ${job_out} -J ${job_name} -p workq --parsable ${r_scripts}pipeline2.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16} ${v17} ${v18} ${v19} ${v20} ${v21} ${v22} ${v23} ${v24} ${v25} ${v26} ${v27} ${v28} ${v29})

echo "${job_out} =" >> ${file_jobs}
echo "${job}" >> ${file_jobs}



qtls_info=TRUE
heritability=NA
qtls=300rand
genomic=NA


ID=s${simulation}_i${qtls_info}_q${qtls}_h${heritability}_g${genomic}_p${population}_n${population_ID}_m${genetic_map}_${constraints}
r_log=${r0_log}article/${ID}/


# echo ${ID}


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


job_out=${r0_log_pipeline2}pipeline2_${ID}.out


job_name=${heritability}${population}${population_ID}

# job=$(sbatch -o ${job_out} -J ${job_name} -p workq --parsable ${r_scripts}pipeline2.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16} ${v17} ${v18} ${v19} ${v20} ${v21} ${v22} ${v23} ${v24} ${v25} ${v26} ${v27} ${v28} ${v29})

# echo "${job_out} =" >> ${file_jobs}
# echo "${job}" >> ${file_jobs}



sed -i '/^$/d' ${file_jobs}
while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 50 )) 
do    
    sleep 1s

done




while (( $(squeue -u adanguy  | wc -l) >=  ${nb_jobs_allowed})) 
do    
sleep 1m
done

done

done



done



echo "end"

jobs_all=${r0}all_jobs.txt
cat ${r0_log_jobs}* > ${jobs_all}




sed -i '/^$/d' ${jobs_all}
while (( $(squeue -u adanguy | grep -f ${jobs_all} | wc -l) >= 1 )) 
do    
    sleep 1h
    cat ${r0_log_jobs}* > ${jobs_all}
    sed -i '/^$/d' ${jobs_all}
done




v1=${base}


job_out=${r0_log_pipeline2}analyse_results.out


job_name=results

#job=$(sbatch -o ${job_out} -J ${job_name} -p workq --parsable ${r_scripts}analyse_results.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16} ${v17} ${v18} ${v19} ${v20} ${v21} ${v22} ${v23} ${v24} ${v25} ${v26} ${v27} ${v28} ${v29})






################## when everything is over





v1=${base}



job_out=${r0_log_pipeline2}check.out


job_name=check

#job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}progeny1_check_sd.sh ${v1} )
echo "${job_out} =" >> ${file_jobs}
echo "${job}" >> ${file_jobs}


cat ${r0_log_jobs}* > ${jobs_all}
sed -i '/^$/d' ${jobs_all}
while (( $(squeue -u adanguy | grep -f ${jobs_all} | wc -l) >= 1 )) 
do    
    sleep 1m
    cat ${r0_log_jobs}* > ${jobs_all}
    sed -i '/^$/d' ${jobs_all}
done



job_out=${r0_log_pipeline2}replicate.out


job_name=replicate

#job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}replicate.sh ${v1} )
echo "${job_out} =" >> ${file_jobs}
echo "${job}" >> ${file_jobs}

cat ${r0_log_jobs}* > ${jobs_all}
sed -i '/^$/d' ${jobs_all}
while (( $(squeue -u adanguy | grep -f ${jobs_all} | wc -l) >= 1 )) 
do    
    sleep 1m
    cat ${r0_log_jobs}* > ${jobs_all}
    sed -i '/^$/d' ${jobs_all}
done


job_out=${r0_log_pipeline2}all_crosses.out


job_name=all

#job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}all_crosses1.sh ${v1} )
echo "${job_out} =" >> ${file_jobs}
echo "${job}" >> ${file_jobs}

job_out=${r0_log_pipeline2}accuracy.out


job_name=ac

# job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}accuracy1.sh ${v1} )
echo "${job_out} =" >> ${file_jobs}
echo "${job}" >> ${file_jobs}



job_out=${r0_log_pipeline2}similarity.out


job_name=s

# job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}similarity_mating_plans1.sh ${v1} )
echo "${job_out} =" >> ${file_jobs}
echo "${job}" >> ${file_jobs}







date +'%Y-%m-%d-%T'




