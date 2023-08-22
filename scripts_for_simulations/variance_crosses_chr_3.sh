#!/bin/bash
RANDOM=1



base=${1}

source ${base}

nbcores=${2}

chr=${5}

type=${3}

population=${4}

r_save=${5}


ID=${type}_${population}_${chr}



####### Compute variance of crosses for this chr


# Inputs
# chr=${3}
titre_markers=${r_value_crosses}markers_filtered_estimated.txt
titre_genotyping_matrix_filtered_imputed_subset=${r_prepare}genotyping_matrix_filtered_imputed.txt
titre_lines=${r_prepare}lines.txt
titre_function_calcul_index_variance_crosses=${r_scripts}calcul_index_variance_crosses.R
# nbcores=${2}


# outputs
titre_variance_crosses_chr=${r_save}variance_crosses_chr_${ID}.txt
r_value_crosses_variance_crosses_chr_big_matrix=${r_save}

# variables
v1=${chr}
v2=${titre_markers}
v3=${titre_genotyping_matrix_filtered_imputed_subset}
v4=${titre_lines}
v5=${titre_function_calcul_index_variance_crosses}
v6=${nbcores}
v7=${titre_variance_crosses_chr}
v8=${r_value_crosses_variance_crosses_chr_big_matrix}
v9=${population}
v10=${type}

rm ${r_save}big_matrix*

Rscript ${r_scripts}variance_crosses_chr_3.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10}
    
rm ${r_save}big_matrix*
