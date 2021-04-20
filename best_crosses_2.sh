#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'



base=${1}

source ${base}



generation=${2}
type=${3}
population_ref2=${4}
critere=${5}
affixe=${6}
rr=${7}

next_generation=$((${generation} +1))
population_variance=${population_ref2}
source ${r_scripts}param_cr_${affixe}.sh



source ${r_scripts}param_cr_${affixe}.sh
motif=$(echo ${type} | sed "s/marker_//g")
ID1=g${next_generation}_${motif}_${population_ref2}
ID2=${critere}_${affixe}
ID3=rr${rr}

ID1old=g${generation}_${motif}_${population_ref2}


r_temp=${r_best_crosses}${ID1}_${ID2}_${ID3}/temp/
mkdir -p ${r_temp}
cd ${r_temp}










titre_haplo_input=${r_best_crosses_haplotypes}haplotypes_${ID1old}_${ID2}.txt
titre_markers_input=${r_value_crosses}markers_estimated_${motif}_${population_ref2}.txt
titre_best_crosses_input=${r_best_crosses}best_crosses_${ID1old}_${ID2}.txt
titre_snp_effects_input=${r_value_crosses}${motif}/snp_sol_${motif}.txt
titre_function_sort_genotyping_matrix=${r_scripts}sort_genotyping_matrix.R
titre_genotypes_blupf90_output=${r_temp}g.txt
titre_genotypes_output=${r_best_crosses_genotypes}genotypes_${ID1}_${ID2}_${ID3}.txt
titre_pedigree_output=${r_best_crosses_pedigree}pedigree_${ID1}_${ID2}_${ID3}.txt

v1=${titre_markers_input}
v2=${titre_best_crosses_input}
v3=${titre_haplo_input}
v4=${titre_snp_effects_input}
v5=${titre_function_sort_genotyping_matrix}
v6=${nbcores}
v7=${D}
v8=${next_generation}
v9=${type}
v10=${population_ref2}
v11=${critere}
v12=${affixe}
v13=${rr}
v14=${titre_genotypes_blupf90_output}
v15=${titre_genotypes_output}
v16=${titre_pedigree_output}
v17=${population_variance}

Rscript ${r_scripts}progenies.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16} ${v17}



titre_lines_output=${r_best_crosses_lines}lines_${ID1}_${ID2}_${ID3}.txt

if [ $(echo ${type} | grep "_h" | wc -l) -eq 1 ] || [ $(echo ${type} | grep "FALSE" | wc -l) -eq 1 ]
then

cp ${r_value_crosses}${motif}/snp_pred_${motif}.txt ${r_temp}snp_pred
cp ${r_blupf90}predf90 ${r_temp}
echo "g.txt" | ${r_temp}predf90


cp ${r_temp}SNP_predictions ${r_temp}SNP_predictions_${ID1}_${ID2}_${ID3}.txt



titre_predictions_input=${r_temp}SNP_predictions_${ID1}_${ID2}_${ID3}.txt


v1=${titre_lines_output}
v2=${titre_predictions_input}
v3=${next_generation}
v4=${type}
v5=${population_ref2}
v6=${critere}
v7=${affixe}
v8=${rr}


Rscript ${r_scripts}after_blupf90_2.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8}


cd ${r_best_crosses}${ID1}_${ID2}_${ID3}/
rm -rf ${r_temp}

else 




v1=${titre_genotypes_output}
v2=${titre_markers_input}
v3=${next_generation}
v4=${type}
v5=${population_ref2}
v6=${critere}
v7=${affixe}
v8=${rr}
v9=${titre_lines_output}


Rscript ${r_scripts}tbv_progenies.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9}


fi




titre_crosses_input=${r_value_crosses_crosses}crosses_${ID1old}.txt ### to modif
titre_best_crosses_output=${r_best_crosses_best_crosses}best_crosses_${ID1}_${ID2}_${ID3}.txt
titre_crosses_output=${r_best_crosses_crosses}crosses_${ID1}_${ID2}_${ID3}.txt
titre_crosses_filtered=${r_best_crosses}crosses_filtered_${ID1old}_${ID2}.txt
titre_geno_parents=${r_best_crosses_genotypes}genotypes_${ID1old}_${ID2}.txt
titre_geno_progeny=${titre_genotypes_output}
titre_lines_parents=${r_value_crosses}lines_estimated_${motif}.txt
titre_lines_progeny=${titre_lines_output}
titre_ped_parents=${r_prepare}pedigree.txt
titre_ped_progeny=${titre_pedigree_output}
titre_geno_output=${r_best_crosses_genotypes}genotypes_${ID1}_${ID2}_${ID3}.txt
titre_lines_output=${r_best_crosses_lines}lines_${ID1}_${ID2}_${ID3}.txt
titre_ped_output=${r_best_crosses_pedigree}pedigree_${ID1}_${ID2}_${ID3}.txt

v1=${titre_best_crosses_input}
v2=${titre_crosses_input}
v3=${titre_best_crosses_output}
v4=${titre_crosses_output}
v5=${titre_crosses_filtered}
v6=${next_generation}
v7=${type}
v8=${population_ref2}
v9=${critere}
v10=${affixe}
v11=${rr}
v12=${titre_geno_parents}
v13=${titre_geno_progeny}
v14=${titre_lines_parents}
v15=${titre_lines_progeny}
v16=${titre_ped_parents}
v17=${titre_ped_progeny}
v18=${titre_geno_output}
v19=${titre_lines_output}
v20=${titre_ped_output}



Rscript ${r_scripts}prepare_for_next_generations.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16} ${v17} ${v18} ${v19} ${v20}


if [ ${generation} -gt 1 ]
then

previous_gen=$((${generation} -1 ))



cat ${r_best_crosses_genotypes}genotypes_${ID1old}_${ID2}_${ID3}.txt > ${r_best_crosses}temp_${ID1}_${ID2}_${ID3}.txt
tail -n+2 ${titre_genotypes_output} >> ${r_best_crosses}temp_${ID1}_${ID2}_${ID3}.txt
cp ${r_best_crosses}temp_${ID1}_${ID2}_${ID3}.txt ${r_best_crosses_genotypes}genotypes_${ID1}_${ID2}_${ID3}.txt

cat ${r_best_crosses_pedigree}ped_${ID1old}_${ID2}_${ID3}.txt > ${r_best_crosses}temp_${ID1}_${ID2}_${ID3}.txt
tail -n+2 ${titre_pedigree_output} >> ${r_best_crosses}temp_${ID1}_${ID2}_${ID3}.txt
cp ${r_best_crosses}temp_${ID1}_${ID2}_${ID3}.txt ${r_best_crosses_pedigree}ped_${ID1old}_${ID2}_${ID3}.txt

cat ${r_best_crosses_lines}lines_${ID1old}_${ID2}_${ID3}.txt > ${r_best_crosses}temp_${ID1}_${ID2}_${ID3}.txt
tail -n+2 ${titre_lines_output} >> ${r_best_crosses}temp_${ID1}_${ID2}_${ID3}.txt
cp ${r_best_crosses}temp_${ID1}_${ID2}_${ID3}.txt ${r_best_crosses_lines}lines_${ID1old}_${ID2}_${ID3}.txt

rm ${r_best_crosses}temp_${ID1}_${ID2}_${ID3}.txt


fi



motif_tbv=$(echo ${type} | sed "s/cm_h.*_r/cm_r/g" | sed "s/marker_//g")


titre_genotyping_input=${titre_geno_output}
titre_markers_input=${r_value_crosses}markers_estimated_${motif_tbv}_${population_ref2}.txt
generation=${next_generation}
type=${type}
population=${population_ref2}
critere=${critere}
affixe=${affixe}
rr=${rr}
titre_lines_input=${titre_lines_output}
titre_lines_output=${r_best_crosses_lines}lines_${ID1}_${ID2}_${ID3}_for_analysis.txt

v1=${titre_genotypes_output}
v2=${titre_markers_input}
v3=${next_generation}
v4=${type}
v5=${population_ref2}
v6=${critere}
v7=${affixe}
v8=${rr}
v9=${titre_lines_input}
v10=${titre_lines_output}

Rscript ${r_scripts}tbv_progenies_2.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10}




date +'%Y-%m-%d-%T'
