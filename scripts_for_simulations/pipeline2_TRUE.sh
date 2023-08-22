#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
export LC_COLLATE=C
export LC_ALL=C
ulimit -s unlimited
export OMP_STACKSIZE=64M









base=${1}

source ${base}

r=${2}
r_log=${3}
simulation=${4}
qtls_info=${5}
qtls=${6}
heritability=${7}
genomic=${8}
population=${9}
population_ID=${10}
constraints=${11}
progeny=${12}
genetic_map=${13}
proportion_of_crosses_used=${14}
param_GA=${15}
set_phi_file=${16}
nbcores=${17}
ID=${18}
set_starting_pop=${19}





echo ${base}
echo ${r}
echo ${r_log}
echo ${simulation}
echo ${qtls_info}
echo ${qtls}
echo ${heritability}
echo ${genomic}
echo ${population}
echo ${population_ID}
echo ${constraints}
echo ${progeny}
echo ${genetic_map}
echo ${proportion_of_crosses_used}
echo ${param_GA}
echo ${set_phi_file}
echo ${nbcores}
echo ${ID}
echo ${set_starting_pop}


           
                        
             


r_parents=${r}parents/
r_markers=${r}markers/
r_gblup=${r}gblup/
r_gblup_raw=${r_gblup}raw/
r_gblup_param=${r_log}GBLUP_param/
r_LDAK=${r}LDAK/
r_criteria=${r}criteria/
r_optimization=${r}optimization/
r_progeny=${r}progeny/


mkdir -p ${r_log}
mkdir -p ${r}
mkdir -p ${r_LDAK}
mkdir -p ${r_parents}
mkdir -p ${r_markers}
mkdir -p ${r_gblup_raw}
mkdir -p ${r_gblup_param}
mkdir -p ${r_criteria}
mkdir -p ${r_optimization}
mkdir -p ${r_progeny}




titre_criteria_base=${r_criteria}criteria_${ID}
titre_mating_plan_base=${r_optimization}mating_plan_${ID}_
titre_TBV_progeny_base=${r_progeny}TBV_progeny_${ID}_
titre_markers_for_TBV_progeny=${r_markers}markers_QTLs_${ID}.txt
titre_genetic_map_used=${r_results}markers_${genetic_map}.txt
file_jobs=${r0_log_jobs}jobs_${ID}.txt

if [ ${simulation} == "TRUE" ]
then



if [ ${qtls_info} == "TRUE" ] && [ ${population} == "unselected" ]
then

titre_genetic_values_used=${r_parents}TBV_first_generation_${ID}.txt
titre_markers_used=${r_markers}markers_QTLs_${ID}.txt
titre_genotypes_used=${titre_genotypes_parents0}
titre_LDAK_used=${titre_LDAK0}
titre_haplotypes_used=${titre_haplotypes_parents0}

titre_TBV_parents=${r_parents}TBV_first_generation_${ID}.txt

elif [ ${qtls_info} == "TRUE" ] && [ ${population} == "selected" ]
then

titre_genetic_values_used=${r_parents}TBV_last_generation_${ID}.txt
titre_markers_used=${r_markers}markers_QTLs_${ID}.txt
titre_genotypes_used=${r_parents}genotypes_last_generation_${ID}.txt
titre_LDAK_used=${r_parents}LDAK_${ID}.txt
titre_haplotypes_used=${r_parents}haplotypes_last_generation_${ID}.txt
titre_TBV_parents=${r_parents}TBV_last_generation_${ID}.txt


elif [ ${qtls_info} == "ESTIMATED" ] && [ ${population} == "unselected" ]
then

titre_genetic_values_used=${r_parents}GEBV_parents_${ID}.txt
titre_markers_used=${r_markers}markers_estimated_${ID}.txt
titre_genotypes_used=${titre_genotypes_parents0}
titre_LDAK_used=${titre_LDAK0}
titre_haplotypes_used=${titre_haplotypes_parents0}


titre_TBV_parents=${r_parents}TBV_first_generation_${ID}.txt



elif [ ${qtls_info} == "ESTIMATED" ] && [ ${population} == "selected" ]
then

titre_genetic_values_used=${r_parents}GEBV_parents_${ID}.txt
titre_markers_used=${r_markers}markers_estimated_${ID}.txt
titre_genotypes_used=${r_parents}genotypes_last_generation_${ID}.txt
titre_LDAK_used=${r_parents}LDAK_${ID}.txt
titre_haplotypes_used=${r_parents}haplotypes_last_generation_${ID}.txt

titre_TBV_parents=${r_parents}TBV_last_generation_${ID}.txt




fi



elif [ ${simulation} == "FALSE" ]
then

titre_genetic_values_used=${titre_GEBV_parents0}
titre_markers_used=${r_markers}markers_estimated_${ID}.txt
titre_genotypes_used=${titre_genotypes_parents0}
titre_LDAK_used=${titre_LDAK0}
titre_haplotypes_used=${titre_haplotypes_parents0}



fi






v1=${base}
v2=${r}
v3=${r_log}
v4=${ID}
v5=${simulation}
v6=${qtls_info}
v7=${qtls}
v8=${heritability}
v9=${genomic}
v10=${population}
v11=${population_ID}
v12=${titre_genetic_values_used}
v13=${titre_markers_used}
v14=${titre_genotypes_used}
v15=${titre_LDAK_used}
v16=${titre_haplotypes_used}





job_out=${r_log}parents_and_markers_${ID}_TRUE.out


job_name=parents${ID}



job_parents=$(sbatch -o ${job_out} -J ${job_name} --mem=10G --parsable ${r_scripts}parents_and_markers_TRUE.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16} ${v17} ${v18} ${v19} ${v20} ${v21})

echo "${job_out} =" >> ${file_jobs}
echo "${job_parents}" >> ${file_jobs}



while (( $(squeue -u jelsen  | wc -l) >=  ${nb_jobs_allowed})) 
do    
sleep 1m
done




sed -i '/^$/d' ${file_jobs}
while (( $(squeue -u jelsen | grep -f ${file_jobs} | wc -l) >= 1 )) 
do    
    sleep 1m
    sed -i '/^$/d' ${file_jobs}
done


v1=${base}
v2=${r}
v3=${r_log}
v4=${ID}
v5=${constraints}
v6=${proportion_of_crosses_used}
v7=${progeny}
v8=${titre_genetic_values_used}
v9=${titre_genetic_map_used}
v10=${titre_genotypes_used}
v11=${titre_LDAK_used}
v12=${titre_markers_used}
v13=${titre_criteria_base}
v14=${genetic_map}



file_jobs=${r0_log_jobs}jobs_${ID}.txt




job_out=${r_log}criteria_${ID}_TRUE.out


job_name=criteria${ID}



job_criteria=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job_parents} --mem=3G --parsable ${r_scripts}criteria.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16} ${v17} ${v18} ${v19} ${v20} ${v21})

echo "${job_out} =" >> ${file_jobs}
echo "${job_criteria}" >> ${file_jobs}







date +'%Y-%m-%d-%T'

