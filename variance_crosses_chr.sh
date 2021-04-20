#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'



base=${1}

source ${base}

generation=${2}
type=${3}
population=${4}
c=${5}

motif=$(echo ${type} | sed "s/marker_//g")
ID1=g${generation}_${motif}_${population}
ID2=${c}




####### Compute variance of crosses for this chr


# Inputs
# chr=${3}
titre_markers_input=${r_value_crosses}markers_estimated_${motif}_${population}.txt
titre_genotyping_input=${r_prepare}genotyping.txt
titre_lines_input=${r_value_crosses}lines_estimated_${motif}.txt
titre_function_calcul_index_variance_crosses=${r_scripts}calcul_index_variance_crosses.R
# nbcores=${2}


# outputs
titre_variance_crosses_chr_output=${r_value_crosses_crosses}variance_crosses_chr_${ID1}_${ID2}.txt
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
v9=${population}
v10=${type}
v11=${generation}


Rscript ${r_scripts}variance_crosses_chr_3.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11}
    
date +'%Y-%m-%d-%T'
