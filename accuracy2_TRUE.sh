#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
export LC_COLLATE=C
export LC_ALL=C
ulimit -s unlimited
export OMP_STACKSIZE=64M









base=${1}
source ${base}

population=${2}
population_ID=${3}
r=${4}
r_log=${5}


echo ${base}
echo ${population}
echo ${population_ID}
echo ${r}
echo ${r_log}


constraints=CONSTRAINTS
proportion_of_crosses_used=1
progeny=RILsF5
titre_genetic_map_used=${r_results}markers_WE.txt
genetic_map=WE
file_jobs=${r0_log_jobs}accuracy.txt



ID0=sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_p${population}_n${population_ID}_mWE_CONSTRAINTS
ID1=sTRUE_iTRUE_q300rand_hNA_gNA_p${population}_n${population_ID}_mWE_CONSTRAINTS
info="population_predict_population"


criteria_estimated=${r_big_files}article/true_GBLUP/criteria/criteria_${ID0}_no_filter.txt
criteria_true=${r_big_files}article/criteria/criteria_${ID1}_no_filter.txt



titre_criteria_estimated=${criteria_estimated}
titre_criteria_true=${criteria_true}
titre_output=${r}accuracy_sd_p${population}_n${population_ID}_${info}.txt
titre_PROBA=${r}PROBA_p${population}_n${population_ID}.txt


v1=${titre_criteria_estimated}
v2=${titre_criteria_true}
v3=${titre_output}
v4=${info}
v5=${titre_PROBA}


Rscript ${r_scripts}accuracy_sd_TRUE.R ${v1} ${v2} ${v3} ${v4} ${v5}






<<COMMENTS


r_progeny_temp=${r}p${population}_n${population_ID}/
mkdir -p ${r_progeny_temp}
titre_markers_used_blupf90=${r_big_files}article/markers/markers_QTLs_${ID0}.txt


if [ ${population} == "unselected" ]
then

titre_genotypes_used=${titre_genotypes_parents0}
titre_genetic_values_first=${r_big_files}article/parents/phenotypes_first_generation_${ID0}.txt
ID=selected_predict_unselected_n${population_ID}
titre_LDAK_used=${titre_LDAK0}
titre_snp_sol=${r_big_files}article/gblup/raw/snp_sol_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_pselected_n${population_ID}_mWE_CONSTRAINTS.txt
titre_snp_pred=${r_big_files}article/gblup/raw/snp_pred_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_pselected_n${population_ID}_mWE_CONSTRAINTS.txt








elif [ ${population} == "selected" ]

then

titre_genotypes_used=${r_big_files}article/parents/genotypes_last_generation_${ID0}.txt
titre_genetic_values_first=${r_big_files}article/parents/phenotypes_last_generation_${ID0}.txt
ID=unselected_predict_selected_n${population_ID}
titre_LDAK_used=${r_big_files}article/parents/LDAK_${ID0}.txt
titre_snp_sol=${r_big_files}article/gblup/raw/snp_sol_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n${population_ID}_mWE_CONSTRAINTS.txt
titre_snp_pred=${r_big_files}article/gblup/raw/snp_pred_sTRUE_iESTIMATED_q300rand_h0.4_gGBLUP_punselected_n${population_ID}_mWE_CONSTRAINTS.txt








fi

titre_markers_used=${r}markers_${ID}.txt
titre_genetic_values_used=${r}genetic_values_${ID}.txt
titre_criteria_base=${r}criteria_${ID}



titre_phenotyping_blupf90=${r_progeny_temp}p.txt
titre_markers_blupf90=${r_progeny_temp}m.txt
titre_genotyping_blupf90=${r_progeny_temp}s.txt
titre_weights_blupf90=${r_progeny_temp}w.txt
titre_genotypes_used=${titre_genotypes_used}
titre_phenotypes_progeny=${titre_genetic_values_first}



v1=${titre_phenotypes_progeny} # completely disconnected from analysis
v2=${titre_markers_used_blupf90}
v3=${titre_genotypes_used}
v4=${titre_phenotyping_blupf90}
v5=${titre_markers_blupf90}
v6=${titre_genotyping_blupf90}
v7=${titre_weights_blupf90}

echo "STEP 2.1 : prepare_for_BLUPf90"

Rscript ${r_scripts}prepare_for_BLUPf90.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7}


cd ${r_progeny_temp}

cp ${titre_snp_pred} ${r_progeny_temp}snp_pred
cp ${r_blupf90}predf90 ${r_progeny_temp}
echo s.txt | ${r_progeny_temp}predf90







echo "STEP 2.2 : after_BLUPf90.R"


titre_GEBV_input=${r_progeny_temp}SNP_predictions
titre_snp_effects_input=${titre_snp_sol}
titre_lines_input=${titre_genetic_values_first}
titre_markers_input=${titre_markers0}
titre_markers_output=${titre_markers_used}
titre_lines_output=${titre_genetic_values_used}




v1=${titre_GEBV_input}
v2=${titre_snp_effects_input}
v3=${titre_lines_input}
v4=${titre_markers_input}
v5=${titre_markers_output}
v6=${titre_lines_output}


Rscript ${r_scripts}after_BLUPf90.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6}



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





job_out=${r_log}criteria_${ID}.out


job_name=criteria${ID}

COMMENTS

#job_criteria=$(sbatch -o ${job_out} -J ${job_name} --mem=3G --parsable ${r_scripts}criteria.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16} ${v17} ${v18} ${v19} ${v20} ${v21})

<<COMMENTS
echo "${job_out} =" >> ${file_jobs}
echo "${job_criteria}" >> ${file_jobs}


while (( $(squeue -u adanguy | grep ${job_criteria} | wc -l) >= 1 )) 
do    
sleep 1m
echo "wait"
done

ID2=${ID0}
ID0=${ID}
info="cross_validation"


titre_criteria_estimated1=${titre_criteria_base}_no_filter.txt
titre_criteria_estimated2=${r_big_files}article/criteria/criteria_${ID2}_no_filter.txt
titre_output=${r}criteria_${ID0}_no_filter.txt



v1=${titre_criteria_estimated1}
v2=${titre_criteria_estimated2}
v3=${titre_output}

Rscript ${r_scripts}filter.R ${v1} ${v2} ${v3} 




criteria_estimated=${r}criteria_${ID0}_no_filter.txt
criteria_true=${r_big_files}article/criteria/criteria_${ID1}_no_filter.txt



titre_criteria_estimated=${criteria_estimated}
titre_criteria_true=${criteria_true}
titre_output=${r}accuracy_sd_p${population}_n${population_ID}_${info}.txt



v1=${titre_criteria_estimated}
v2=${titre_criteria_true}
v3=${titre_output}
v4=${info}

Rscript ${r_scripts}accuracy_sd.R ${v1} ${v2} ${v3} ${v4}

rm -rf ${r_progeny_temp}
cd ${r0}



COMMENTS





date +'%Y-%m-%d-%T'

