#!/bin/bash
RANDOM=1



base=${1}

source ${base}
nbcores=${2}
generation=${3}
type=${4}
population=${5}
critere=${6}
affixe=${7}
rr=${8}


next_generation=$((${generation} +1))

source ${r_scripts}param_cr_${affixe}.sh




motif=$(echo ${type} | sed "s/marker_//g")

ID1=g${generation}_${motif}_${population}
path1=g${generation}_${motif}_${population}/

output_crosses=${r_value_crosses}variance_crosses/${path1}crosses_${ID1}.txt

ID2=g${generation}_${motif}_${population}_${critere}_${affixe}
path2=g${generation}_${motif}_${population}_${critere}_${affixe}/

ID3=g${next_generation}_${motif}_${population}_${critere}_${affixe}_rr${rr}
path3=g${next_generation}_${motif}_${population}_${critere}_${affixe}_rr${rr}/

r_save=${r_best_crosses}${path3}
mkdir -p ${r_save}



cd ${r_save}

titre_best_crosses=${r_best_crosses}${path2}best_crosses_${ID2}.txt


# inputs
titre_markers=${r_value_crosses}markers_filtered_estimated.txt
titre_haplotypes_critere=${r_save}haplotypes_${ID3}.txt
# titre_best_crosses=${r}best_crosses_${critere}.txt
# Dmax=60
# generation=1
#run=1
# nb_run=10
# nbcores=5
titre_genotyping_matrix=${r_prepare}genotyping_matrix_filtered_imputed.txt
titre_pedigree=${r_prepare}pedigree.txt
titre_function_sort_genotyping_matrix=${r_scripts}sort_genotyping_matrix.R

# output
titre_genotypes_blupf90_critere=g.txt
titre_genotypes_critere=${r_save}genotypes_${ID3}.txt
titre_pedigree_critere=${r_save}pedigree_${ID3}.txt
titre_snp_sol=${r_value_crosses}blupf90/${motif}/snp_sol_${motif}.txt



v1=${titre_markers}
v2=${titre_best_crosses}
v3=${titre_haplotypes_critere}
v4=${D}
v5=${titre_genotypes_blupf90_critere}
v6=${titre_genotypes_critere}
v7=${titre_pedigree_critere}
v8=${titre_function_sort_genotyping_matrix}
v9=${nbcores}
v10=${next_generation}
v11=${type}
v12=${population}
v13=${critere}
v14=${affixe}
v15=${rr}
v16=${titre_genotyping_matrix}
v17=${titre_pedigree}
v18=${titre_snp_sol}


Rscript ${r_scripts}progenies.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16} ${v17} ${v18}



titre_lines_output=${r_best_crosses_lines}lines_${ID3}.txt

if [ $(echo ${type} | grep "_h" | wc -l) -eq 1 ] || [ $(echo ${type} | grep "FALSE" | wc -l) -eq 1 ]
then

cp ${r_value_crosses}blupf90/${motif}/snp_pred_${motif}.txt ${r_save}snp_pred
cp ${r_blupf90}predf90 ${r_save}
echo ${titre_genotypes_blupf90_critere} | ${r_save}predf90


cp ${r_save}SNP_predictions ${r_save}SNP_predictions_${ID3}.txt



titre_predictions=${r_save}SNP_predictions_${ID3}.txt
generation=${next_generation}


v1=${titre_lines_output}
v2=${titre_predictions}
v3=${generation}
v4=${type}
v5=${population}
v6=${critere}
v7=${affixe}
v8=${rr}


Rscript ${r_scripts}after_blupf90_2.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8}



rm ${titre_genotypes_blupf90_critere}
rm ${r_save}SNP_predictions*

else 

titre_geno=${r_save}genotypes_${ID3}.txt



v1=${titre_geno}
v2=${titre_markers}
v3=${next_generation}
v4=${type}
v5=${population}
v6=${critere}
v7=${affixe}
v8=${rr}
v9=${titre_lines_output}


Rscript ${r_scripts}tbv_progenies.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9}


fi




titre_crosses=${output_crosses}
titre_best_crosses_output=${r_save}best_crosses_${ID3}.txt
titre_crosses_output=${r_save}best_crosses_${ID3}.txt
titre_geno_parents=${r_prepare}genotyping_matrix_filtered_imputed.txt
titre_geno_progeny=${titre_genotypes_critere}
titre_lines_parents=${r_prepare}lines.txt
titre_lines_progeny=${titre_lines_output}
titre_ped_parents=${r_prepare}pedigree.txt
titre_ped_progeny=${titre_pedigree_critere}
titre_geno_output=${r_best_crosses_genotypes}genotypes_${ID3}.txt
titre_lines_output=${r_best_crosses_lines}lines_${ID3}.txt
titre_ped_output=${r_best_crosses_pedigree}ped_${ID3}.txt

v1=${titre_best_crosses}
v2=${output_crosses}
v3=${titre_best_crosses_output}
v4=${titre_crosses_output}
v5=${next_generation}
v6=${type}
v7=${population}
v8=${critere}
v9=${affixe}
v10=${rr}
v11=${titre_geno_parents}
v12=${titre_geno_progeny}
v13=${titre_lines_parents}
v14=${titre_lines_progeny}
v15=${titre_ped_parents}
v16=${titre_ped_progeny}
v17=${titre_geno_output}
v18=${titre_lines_output}
v19=${titre_ped_output}



Rscript ${r_scripts}prepare_for_next_generations.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} ${v15} ${v16} ${v17} ${v18} ${v19}


if [ ${generation} -gt 1 ]
then

previous_gen=$((${generation} -1 ))

previous_ID=g${previous_gen}_${motif}_${population}_${critere}_${affixe}_rr${rr}


cat ${r_best_crosses_genotypes}genotypes_${previous_ID}.txt > ${r_save}temp.txt
tail -n+2 ${titre_genotypes_critere} >> ${r_save}temp.txt
cp ${r_save}temp.txt ${r_best_crosses_genotypes}genotypes_${ID3}.txt

cat ${r_best_crosses_pedigree}ped_${previous_ID}.txt > ${r_save}temp.txt
tail -n+2 ${titre_pedigree_critere} >> ${r_save}temp.txt
cp ${r_save}temp.txt ${r_best_crosses_pedigree}ped_${ID3}.txt

cat ${r_best_crosses_lines}lines_${previous_ID}.txt > ${r_save}temp.txt
tail -n+2 ${titre_lines_output} >> ${r_save}temp.txt
cp ${r_save}temp.txt ${r_best_crosses_lines}lines_${ID3}.txt

rm ${r_save}temp.txt


fi



