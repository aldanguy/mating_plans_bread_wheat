#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'



base=${1}

source ${base}




titre_genotyping=${r_amont}GSE50558_CFD_matrix_GEO.txt
titre_map=${r_amont}Complete-map-3133142.txt
titre_correspondance_ID=${r_amont}GPL17677-31783.txt
titre_pheno=${r_amont}PhenotypicDataDent.csv
titre_function_sort_genotyping_matrix=${r_scripts}sort_genotyping_matrix.R
#nbcores=2
titre_genotyping_output=${r_prepare}genotyping.txt
titre_markers_output=${r_prepare}markers.txt
titre_pheno_output=${r_prepare}lines.txt

v1=${titre_genotyping}
v2=${titre_map}
v3=${titre_correspondance_ID}
v4=${titre_pheno}
v5=${titre_function_sort_genotyping_matrix}
v6=${nbcores}
v7=${titre_genotyping_output}
v8=${titre_markers_output}
v9=${titre_pheno_output}

Rscript ${r_scripts}prepare_maize.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9}



