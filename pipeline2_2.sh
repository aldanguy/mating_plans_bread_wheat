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


criterion=UC3
job_criteria=1

 if [ ! -f "${titre_mating_plan_base}${criterion}.txt" ] && [ ! ${ID} == "sTRUE_iTRUE_q300rand_hNA_gNA_pselected_n8_mWE_CONSTRAINTS" ] && [ ! ${ID} == "sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n10_mWE_CONSTRAINTS" ] && [ ! ${ID} == "sTRUE_iTRUE_q300rand_hNA_gNA_punselected_n21_mWE_CONSTRAINTS" ]
then
echo ${criterion}
    
   


v1=${base}
v2=${r}
v3=${r_log}
v4=${ID}
v5=${constraints}
v6=${criterion}
v7=${titre_criteria_base}
v8=${titre_mating_plan_base}
v9=${nbcores}
v10=${param_GA}
v11=${set_phi_file}
v12=${set_starting_pop}


job_criteria=1


job_out=${r_log}optimization_${ID}_${criterion}.out


job_name=opti${criterion}${ID}



job_opti=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job_criteria} --mem=3G --parsable ${r_scripts}optimization.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16} ${v17} ${v18} ${v19} ${v20} ${v21})



echo "${job_out} =" >> ${file_jobs}
echo "${job_opti}" >> ${file_jobs}

 fi

   
   
   
criterion=EMBV



 if [ ! -f "${titre_mating_plan_base}${criterion}.txt" ] && [ ! ${ID} == "sTRUE_iTRUE_q300rand_hNA_gNA_pselected_n8_mWE_CONSTRAINTS" ] && [ ! ${ID} == "sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_pselected_n10_mWE_CONSTRAINTS" ] && [ ! ${ID} == "sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_pselected_n11_mWE_CONSTRAINTS" ] && [ ! ${ID} == "sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_pselected_n24_mWE_CONSTRAINTS" ] && [ ! ${ID} == "sTRUE_iTRUE_q300rand_hNA_gNA_pselected_n17_mWE_CONSTRAINTS_EMBV" ]
then
echo ${criterion}
    
   


v1=${base}
v2=${r}
v3=${r_log}
v4=${ID}
v5=${constraints}
v6=${criterion}
v7=${titre_criteria_base}
v8=${titre_mating_plan_base}
v9=${nbcores}
v10=${param_GA}
v11=${set_phi_file}
v12=${set_starting_pop}


job_criteria=1


job_out=${r_log}optimization_${ID}_${criterion}.out


job_name=opti${criterion}${ID}



job_opti=$(sbatch -o ${job_out} -J ${job_name} --dependency=afterok:${job_criteria} --mem=3G --parsable ${r_scripts}optimization.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16} ${v17} ${v18} ${v19} ${v20} ${v21})



echo "${job_out} =" >> ${file_jobs}
echo "${job_opti}" >> ${file_jobs}

 fi

   
   
date +'%Y-%m-%d-%T'

