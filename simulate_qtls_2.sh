#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'




base=${1}
source ${base}

type=${2}





titre_markers_input=${r_prepare}markers.txt
titre_lines_input=${r_value_crosses_lines}lines_gebv_simFALSE_gbasic.txt
titre_genotyping_input=${r_prepare}genotyping.txt
# nb_run=30
titre_fonction_simulate_qtls=${r_scripts}simulate_qtls_3.R
titre_markers_output=${r_value_crosses_markers}markers_real_${type}.txt
titre_lines_output=${r_value_crosses_lines}lines_${type}.txt

v1=${titre_markers_input}
v2=${titre_genotyping_input}
v3=${titre_lines_input}
v4=${population_ref}
v5=${type}
v6=${titre_fonction_simulate_qtls}
v7=${titre_markers_output}
v8=${titre_lines_output}

Rscript ${r_scripts}simulate_qtls_2.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9}



populations=$(cut -f5 ${r_prepare}markers.txt | sort | uniq | grep -v "population")

for p in ${populations[*]}
    do
    head -n1 ${titre_markers_output} > ${r_value_crosses_markers}markers_real_${type}_${p}.txt
    grep ${p} ${titre_markers_output} >> ${r_value_crosses_markers}markers_real_${type}_${p}.txt
done

rm ${titre_markers_output}



head -n1 ${titre_lines_output} > ${r_value_crosses_lines}lines_pheno_${type}.txt
grep "pheno" ${titre_lines_output} >> ${r_value_crosses_lines}lines_pheno_${type}.txt



type2=$(echo ${type} | sed "s/_h.*_/_/g")
head -n1 ${titre_lines_output} > ${r_value_crosses_lines}lines_tbv_${type}.txt
grep "tbv" ${titre_lines_output} >> ${r_value_crosses_lines}lines_tbv_${type}.txt


rm ${titre_lines_output}



date +'%Y-%m-%d-%T'

