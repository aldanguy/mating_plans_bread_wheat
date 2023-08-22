#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'



base=${1}

source ${base}

type=${2}
population_profile=${3}
population_variance=${4}
progeny=${5}




critere=sd_prediction
programme=NA
rr=1




short=$(echo ${type}_${population_variance}_${critere}_${population_profile}_${progeny}| sed "s|_||g")


r_save=${r_sd_predictions}${type}_${population_variance}_${critere}_${population_profile}_${progeny}/
mkdir -p ${r_save}
cd ${r_save}



titre_crosses=${r_value_crosses}crosses/crosses_${type}_${population_variance}.txt
nbcrosses=200
nbprogeny=1000
titre_best_crosses_output=${r_sd_predictions}subset_crosses_${type}_${population_variance}_${critere}.txt


v1=${titre_crosses}
v2=${nbcrosses}
v3=${nbprogeny}
v4=${titre_best_crosses_output}
v5=${progeny}

Rscript ${r_scripts}subset_crosses_sd_predictions.R ${v1} ${v2} ${v3} ${v4} ${v5}




   cp ${r_prepare}genotyping.txt ${r_save}genotypes_${type}_${population_variance}_${critere}_${population_profile}.txt
    titre_genotyping_input=${r_save}genotypes_${type}_${population_variance}_${critere}_${population_profile}.txt
    titre_best_crosses_input=${titre_best_crosses_output}
    titre_haplotypes_output=${r_save}haplotypes_${type}_${population_variance}_${critere}_${population_profile}.txt

    v1=${titre_genotyping_input}
    v2=${titre_best_crosses_input}
    v3=${titre_haplotypes_output}

    Rscript ${r_scripts}convert_geno_to_haplo.R ${v1} ${v2} ${v3}




if [ $(echo ${type} | grep -e "_h" | grep -e "TRUE" | wc -l) -eq 1 ]
    then

    titre_markers_input=${r_value_crosses_markers}markers_estimated_${type}_${population_profile}.txt
elif [ $(echo ${type} | grep -e "FALSE" | wc -l) -eq 1 ]
    then
    titre_markers_input=${r_value_crosses_markers}markers_estimated_${type}_${population_profile}.txt
elif [ $(echo ${type} | grep -e "_h" -v | grep -e "TRUE" | wc -l) -eq 1 ]
    then
    titre_markers_input=${r_value_crosses_markers}markers_real_${type}_${population_profile}.txt
fi






# inputs
titre_best_crosses_input=${titre_best_crosses_output}
titre_haplo_input=${titre_haplotypes_output}
# titre_best_crosses=${r}best_crosses_${critere}.txt
# Dmax=60
# generation=1
#run=1
# nb_run=10
# nbcores=5
titre_function_sort_genotyping_matrix=${r_scripts}sort_genotyping_matrix.R

# output
titre_genotypes_blupf90_progeny=${short}.txt
titre_genotypes_progeny=${r_save}genotypes_${type}_${population_variance}_${critere}_${population_profile}_${progeny}.txt
titre_pedigree_progeny=${r_save}pedigree_${type}_${population_variance}_${critere}_${population_profile}_${progeny}.txt




v1=${titre_markers_input}
v2=${titre_best_crosses_input}
v3=${titre_haplo_input}
v4=${titre_function_sort_genotyping_matrix}
v5=${titre_genotypes_blupf90_progeny}
v6=${titre_genotypes_progeny}
v7=${titre_pedigree_progeny}
v8=${nbcores}
v9=${type}
v10=${critere}
v11=${programme}
v12=${rr}
v13=${population_variance}
v14=${population_profile}
v15=${progeny}



Rscript ${r_scripts}progenies.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15}




if [ $(echo ${type} | grep "_h" | wc -l) -eq 1 ] || [ $(echo ${type} | grep "FALSE" | wc -l) -eq 1 ]
then

cp ${r_value_crosses_gblup}${type}/snp_pred_${type}.txt ${r_save}snp_pred
cp ${r_blupf90}predf90 ${r_save}
echo ${titre_genotypes_blupf90_progeny} | ${r_save}predf90


cp ${r_save}SNP_predictions ${r_save}SNP_predictions_${type}_${population_variance}_${critere}_${population_profile}_${progeny}.txt



titre_predictions=${r_save}SNP_predictions_${type}_${population_variance}_${critere}_${population_profile}_${progeny}.txt
titre_lines_output=${r_sd_predictions}lines_gebv_${type}_${population_variance}_${critere}_${population_profile}_${progeny}.txt


v1=${titre_predictions}
v2=${titre_pedigree_progeny}
v3=${type}
v4=${population_variance}
v5=${population_profile}
v6=${critere}
v7=${programme}
v8=${rr}
v9=${titre_lines_output}
v10=${progeny}

Rscript ${r_scripts}after_blupf90_2.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10}


fi 


if [ $(echo ${type} | grep "simTRUE" | wc -l) -eq 1 ]
then

titre_lines_output=${r_sd_predictions}lines_tbv_${type}_${population_variance}_${critere}_${population_profile}_${progeny}.txt


v1=${titre_genotypes_progeny}
v2=${titre_markers_input}
v3=${titre_pedigree_progeny}
v4=${type}
v5=${critere}
v6=${programme}
v7=${rr}
v8=${population_variance}
v9=${population_profile}
v10=${titre_lines_output}
v11=${progeny}


Rscript ${r_scripts}tbv_progenies.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11}


fi


rm -rf ${r_save}


date +'%Y-%m-%d-%T'

