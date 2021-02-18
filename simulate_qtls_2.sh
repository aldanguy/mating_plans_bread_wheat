#!/bin/bash



base=${1}
source ${base}


subset=${2}


titre_markers=${r_prepare}markers_filtered.txt
titre_genotyping_matrix=${r_prepare}genotyping_matrix_filtered_imputed.txt
titre_lines=${r_prepare}lines.txt
population=WE
# nb_run=30
titre_markers_filtered_qtls=${r_value_crosses}markers_filtered_qtls_${subset}cm.txt
titre_lines_qtls=${r_value_crosses}lines_qtls_${subset}cm.txt


v1=${titre_markers}
v2=${titre_genotyping_matrix}
v3=${titre_lines}
v4=${population}
v5=${nb_run}
v6=${subset}
v7=${titre_markers_filtered_qtls}
v8=${titre_lines_qtls}

Rscript ${r_scripts}simulate_qtls_2.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8}




