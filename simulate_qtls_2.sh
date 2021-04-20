#!/bin/bash
RANDOM=1



base=${1}
source ${base}

type=${2}

r_save=${3}



titre_markers_input=${r_prepare}markers.txt
titre_lines_input=${r_value_crosses}lines_estimated.txt
titre_genotyping_input=${r_prepare}genotyping.txt
# nb_run=30
titre_fonction_simulate_qtls=${r_scripts}simulate_qtls_3.R
titre_markers_output=${r_save}markers_${type}.txt
titre_lines_output=${r_save}lines_${type}.txt

v1=${titre_markers_input}
v2=${titre_genotyping_input}
v3=${titre_lines_input}
v4=${population_ref}
v5=${type}
v6=${titre_fonction_simulate_qtls}
v7=${titre_markers_output}
v8=${titre_lines_output}

Rscript ${r_scripts}simulate_qtls_2.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9}

