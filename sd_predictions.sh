#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'



base=${1}

source ${base}

type=${2}
population_ref2=${3}
population_variance=${4}




generation=1
critere=sd_prediction
affixe=sd_prediction
next_generation=$((${generation} +1))
rr=1


r_temp=${r_sd_predictions}${ID1}_${ID2}/temp/
mkdir -p ${r_temp}
cd ${r_temp}



motif=$(echo ${type} | sed "s/marker_//g")
ID1=g${generation}_${motif}_${population_ref2}
ID2=sd_prediction_pref${population_ref2}_pvar${population_variance}


titre_crosses=${r_value_crosses}crosses/crosses_${ID1}.txt
nbcrosses=200
nbprogeny=1000
titre_best_crosses_output=${r_sd_predictions}subset_crosses_${ID1}.txt

v1=${titre_crosses}
v2=${nbcrosses}
v3=${nbprogeny}
v4=${titre_best_crosses_output}

Rscript ${r_scripts}subset_crosses_sd_predictions.R ${v1} ${v2} ${v3} ${v4}




   cp ${r_prepare}genotyping.txt ${r_sd_predictions}genotypes_${ID1}_${ID2}.txt
    titre_genotyping_input=${r_sd_predictions}genotypes_${ID1}_${ID2}.txt
    titre_best_crosses_input=${titre_best_crosses_output}
    titre_haplotypes_output=${r_sd_predictions}haplotypes_${ID1}_${ID2}.txt

    v1=${titre_genotyping_input}
    v2=${titre_best_crosses_input}
    v3=${titre_haplotypes_output}

    Rscript ${r_scripts}convert_geno_to_haplo.R ${v1} ${v2} ${v3}







titre_haplo_input=${titre_haplotypes_output}
titre_markers_input=${r_value_crosses}markers_estimated_${motif}_${population_ref2}.txt
titre_best_crosses_input=${titre_best_crosses_output}
titre_snp_effects_input=${r_value_crosses}${motif}/snp_sol_${motif}.txt
titre_function_sort_genotyping_matrix=${r_scripts}sort_genotyping_matrix.R
titre_genotypes_blupf90_output=${r_temp}g.txt
titre_genotypes_output=${r_sd_predictions}genotypes_${ID1}_${ID2}.txt
titre_pedigree_output=${r_sd_predictions}pedigree_${ID1}_${ID2}.txt

v1=${titre_markers_input}
v2=${titre_best_crosses_input}
v3=${titre_haplo_input}
v4=${titre_snp_effects_input}
v5=${titre_function_sort_genotyping_matrix}
v6=${nbcores}
v7=$((${nbcrosses} * ${nbprogeny}))
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



titre_lines_output=${r_sd_predictions}lines_${ID1}_${ID2}.txt

if [ $(echo ${type} | grep "_h" | wc -l) -eq 1 ] || [ $(echo ${type} | grep "FALSE" | wc -l) -eq 1 ]
then

cp ${r_value_crosses}${motif}/snp_pred_${motif}.txt ${r_temp}snp_pred
cp ${r_blupf90}predf90 ${r_temp}
echo "g.txt" | ${r_temp}predf90


cp ${r_temp}SNP_predictions ${r_temp}SNP_predictions_${ID1}_${ID2}.txt



titre_predictions_input=${r_temp}SNP_predictions_${ID1}_${ID2}.txt


v1=${titre_lines_output}
v2=${titre_predictions_input}
v3=${next_generation}
v4=${type}
v5=${population_ref2}
v6=${critere}
v7=${affixe}
v8=${rr}


Rscript ${r_scripts}after_blupf90_2.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8}


cd ${r_sd_predictions}
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



date +'%Y-%m-%d-%T'

