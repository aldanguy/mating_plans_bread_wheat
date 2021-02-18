#!/bin/bash



base=${1}

source ${base}
critere=${2}
generation=${3}
idrun=${4}
nbcores=${5}
affixe=${6}

source ${r_scripts}param_cr_${affixe}.sh




if [ ${critere} = "gebv" ] || [ ${critere} = "uc" ] || [ ${critere} = "logw" ] || [ ${critere} = "random" ] ; 
then 
titre_best_crosses=${r_best_crosses}${critere}/best_crosses_${critere}_g${generation}_${affixe}.txt

fi


# inputs
titre_markers_filtered_subset_estimated=${r_value_crosses}markers_filtered_subset_estimated.txt
titre_haplotypes_critere=${r_best_crosses}${critere}/haplotypes_${critere}_g${generation}_r${idrun}_${affixe}.txt
# titre_best_crosses=${r}best_crosses_${critere}.txt
# Dmax=60
# generation=1
#run=1
# nb_run=10
# nbcores=5
titre_genotyping_matrix_filtered_imputed_subset=${r_value_crosses}genotyping_matrix_filtered_imputed_subset.txt
titre_pedigree=${r_prepare}pedigree.txt
titre_function_sort_genotyping_matrix=${r_scripts}sort_genotyping_matrix.R
population=WE

# output
titre_genotypes_blupf90_critere=${r_blupf90_snp}${critere}_g${generation}_r${idrun}_${affixe}.txt
titre_genotypes_critere=${r_best_crosses}${critere}/genotyping_${critere}_g${generation}_r${idrun}_${affixe}.txt
titre_pedigree_critere=${r_best_crosses}${critere}/pedigree_${critere}_g${generation}_r${idrun}_${affixe}.txt



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
v13=${population}
v14=${critere}
v15=${titre_genotyping_matrix_filtered_imputed_subset}
v16=${titre_pedigree}


Rscript ${r_scripts}progenies.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16}


mkdir -p ${r_best_crosses}${critere}/${generation}/${affixe}/${idrun}/

cd ${r_best_crosses}${critere}/${generation}/${affixe}/${idrun}/

cp ${r_value_crosses}snp_pred ${r_best_crosses}${critere}/${generation}/${affixe}/${idrun}/

echo ${titre_genotypes_blupf90_critere} | ${r_blupf90}predf90 > ${r_log_best_crosses}${critere}/predf90_${critere}_g${generation}_r${idrun}_${affixe}.out


cp ${r_best_crosses}${critere}/${generation}/${affixe}/${idrun}/SNP_predictions ${r_best_crosses}${critere}/SNP_predictions_${critere}_g${generation}_r${idrun}_${affixe}.txt






################################### 
# input
titre_lines_critere=${r_best_crosses}${critere}/lines_${critere}_g${generation}_r${idrun}_${affixe}.txt # also output
titre_predictions=${r_best_crosses}${critere}/SNP_predictions_${critere}_g${generation}_r${idrun}_${affixe}.txt
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


rm -rf ${r_best_crosses}${critere}/${generation}/${affixe}/${idrun}/

rm ${titre_genotypes_blupf90_critere}
rm ${titre_haplotypes_critere}
rm ${titre_predictions}
rm ${titre_genotypes_critere}
