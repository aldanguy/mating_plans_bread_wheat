#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'



base=${1}


type=${2}
population_variance=${3}
c=${4}

source ${base}



####### Compute variance of crosses for this chr


if [ $(echo ${type} | grep "simTRUE" | grep "_h" | wc -l) -eq 1 ] || [ $(echo ${type} | grep "simFALSE" | wc -l ) -eq 1 ]
    then
    titre_markers_input=${r_value_crosses_markers}markers_estimated_${type}_${population_variance}.txt
    if [ $(echo ${type} | grep "_h1.0_" | wc -l) -eq 1 ] 
        then
        type2=$(echo ${type} | sed "s/_h1.0_/_/g" | sed "s/_g.*$//g")
        titre_lines_input=${r_value_crosses_lines}lines_tbv_${type2}.txt
    else
        titre_lines_input=${r_value_crosses_lines}lines_gebv_${type}.txt
    fi
elif [ $(echo ${type} | grep "simTRUE" | grep "_h" -v | wc -l) -eq 1 ]
    then
    titre_markers_input=${r_value_crosses_markers}markers_real_${type}_${population_variance}.txt
    titre_lines_input=${r_value_crosses_lines}lines_tbv_${type}.txt
fi

    


# Inputs
# chr=${3}
titre_genotyping_input=${r_prepare}genotyping.txt
titre_function_calcul_index_variance_crosses=${r_scripts}calcul_index_variance_crosses.R
# nbcores=${2}


# outputs
titre_variance_crosses_chr_output=${r_value_crosses_crosses}variance_crosses_chr_${type}_${population_variance}_${c}.txt
r_big_files_variance=${r_value_crosses_crosses}


# variables
v1=${c}
v2=${titre_markers_input}
v3=${titre_genotyping_input}
v4=${titre_lines_input}
v5=${titre_function_calcul_index_variance_crosses}
v6=${nbcores}
v7=${titre_variance_crosses_chr_output}
v8=${r_big_files_variance}
v9=${type}
v10=${population_variance}


Rscript ${r_scripts}variance_crosses_chr.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10}
    
date +'%Y-%m-%d-%T'
