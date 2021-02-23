#!/bin/bash
RANDOM=1



base=${1}
source ${base}


subset=${2}

h=${3}

ID=${subset}cm_h${h}


titre_markers=${r_value_crosses}markers_estimated.txt
titre_genotyping_matrix=${r_prepare}genotyping_matrix_filtered_imputed.txt
titre_lines=${r_value_crosses}lines_estimated.txt
population=WE
# nb_run=30
titre_markers_estimated_qtls=${r_value_crosses}markers_estimated_qtls_${ID}.txt
titre_lines_estimated_qtls=${r_value_crosses}lines_estimated_qtls_${ID}.txt

v1=${titre_markers}
v2=${titre_genotyping_matrix}
v3=${titre_lines}
v4=${population}
v5=${nb_run}
v6=${subset}
v7=${titre_markers_estimated_qtls}
v8=${titre_lines_estimated_qtls}
v9=${h}

Rscript ${r_scripts}simulate_qtls_2.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9}




