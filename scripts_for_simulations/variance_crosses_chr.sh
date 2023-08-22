#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'


base=${1}
source ${base}
titre_markers_input=${2}
titre_genotypes_parents=${3}
nbcores=${4}
chr=${5}
progeny=${6}
r_big_files=${7}
titre_variance_crosses_chr_output=${8}
titre_lines_parents=${9}
titre_genetic_map_used=${10}



echo ${base}
echo ${titre_markers_input}
echo ${titre_genotypes_parents}
echo ${nbcores}
echo ${chr}
echo ${progeny}
echo ${r_big_files}
echo ${titre_variance_crosses_chr_output}
echo ${titre_lines_parents}
echo ${titre_genetic_map_used}


titre_function_calcul_index_variance_crosses=${r_scripts}calcul_index_variance_crosses.R


# variables
v1=${titre_markers_input}
v2=${titre_genotypes_parents}
v3=${nbcores}
v4=${chr}
v5=${progeny}
v6=${titre_function_calcul_index_variance_crosses}
v7=${r_big_files}
v8=${titre_variance_crosses_chr_output}
v9=${titre_lines_parents}
v10=${titre_genetic_map_used}


Rscript ${r_scripts}variance_crosses_chr.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10}
    
date +'%Y-%m-%d-%T'
