#!/bin/bash



base=${1}

source ${base}

nbcores=${2}

population_map_to_simulate_progeny=${3}

critere=sd_predictions
generation=1
idrun=1


titre_crosses=${r_value_crosses}crosses.txt
nbcrosses=200
nbprogeny=400
titre_best_crosses=${r_sd_predictions}subset_crosses.txt


v1=${titre_crosses}
v2=${nbcrosses}
v3=${nbprogeny}
v4=${titre_best_crosses}

Rscript ${r_scripts}subset_crosses_sd_predictions.R ${v1} ${v2} ${v3} ${v4}






# inputs
titre_markers_filtered_subset_estimated=${r_value_crosses}markers_filtered_subset_estimated.txt
titre_haplotypes_critere=${r_sd_predictions}haplotypes_${critere}_${population_map_to_simulate_progeny}.txt
# titre_best_crosses=${r}best_crosses_${critere}.txt
D=${nbprogeny}
# generation=1
#run=1
# nb_run=10
# nbcores=5
titre_genotyping_matrix_filtered_imputed_subset=${r_value_crosses}genotyping_matrix_filtered_imputed_subset.txt
titre_pedigree=${r_prepare}pedigree.txt
titre_function_sort_genotyping_matrix=${r_scripts}sort_genotyping_matrix.R
population=WE

# output
titre_genotypes_blupf90_critere=${r_blupf90_snp}${critere}_${population_map_to_simulate_progeny}.txt
titre_genotypes_critere=${r_sd_predictions}genotyping_${critere}_${population_map_to_simulate_progeny}.txt
titre_pedigree_critere=${r_sd_predictions}pedigree_${critere}_${population_map_to_simulate_progeny}.txt



v1=${titre_markers_filtered_subset_estimated}
v2=${titre_best_crosses}
v3=${titre_haplotypes_critere}
v4=${D}
v5=${generation}
v6=${idrun}
v7=${nb_run}
v8=${titre_genotypes_blupf90_critere}
v9=${titre_genotypes_critere}
v10=${titre_pedigree_critere}
v11=${titre_function_sort_genotyping_matrix}
v12=${nbcores}
v13=${population_map_to_simulate_progeny}
v14=${critere}
v15=${titre_genotyping_matrix_filtered_imputed_subset}
v16=${titre_pedigree}

Rscript ${r_scripts}progenies.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16}


mkdir -p ${r_sd_predictions}${population_map_to_simulate_progeny}/



cd ${r_sd_predictions}${population_map_to_simulate_progeny}/

cp ${r_value_crosses}snp_pred ${r_sd_predictions}${population_map_to_simulate_progeny}/

echo ${titre_genotypes_blupf90_critere} | ${r_blupf90}predf90 > ${r_log_sd_predictions}predf90_${critere}_${population_map_to_simulate_progeny}.out


cp ${r_sd_predictions}${population_map_to_simulate_progeny}/SNP_predictions ${r_sd_predictions}/SNP_predictions_${critere}_${population_map_to_simulate_progeny}.txt




################################### 
# input
titre_lines_critere=${r_sd_predictions}lines_${critere}_${population_map_to_simulate_progeny}.txt # also output
titre_predictions=${r_sd_predictions}SNP_predictions_${critere}_${population_map_to_simulate_progeny}.txt
titre_lines=${r_prepare}lines.txt
#generation=1
#critere=gebv

v1=${titre_lines_critere}
v2=${titre_predictions}
v3=${generation}
v4=${critere}
v5=${idrun}
v6=${titre_lines}

Rscript ${r_scripts}after_blupf90_2.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6}


rm -rf ${r_sd_predictions}${population_map_to_simulate_progeny}/

rm ${titre_genotypes_critere}
rm ${titre_genotypes_blupf90_critere}
rm ${titre_haplotypes_critere}
rm ${titre_predictions}
