#!/bin/bash

base=${1}

source ${base}


titre_crosses_WE=${r_results}crosses_WE.txt
titre_markers=${r_value_crosses}markers_estimated.txt
titre_lines=${r_results}lines_g2.txt
titre_ped=${r_results}pedigree_g2.txt
titre_best_crosses=${r_results}best_crosses.txt
titre_lines_pred=${r_sd_predictions}lines_g1_simFALSE_allcm_WE_sd_prediction_prefWE_pvarWE.txt
titre_pedigree_pred=${r_sd_predictions}pedigree_g1_simFALSE_allcm_WE_sd_prediction_prefWE_pvarWE.txt
titre_lines_parents=${r_value_crosses}lines_estimated.txt
script=${r_scripts}analyses_120321.Rmd
output_dir=${r}figures_alldata

v1=${titre_crosses_WE}
v2=${titre_markers}
v3=${titre_lines}
v4=${titre_ped}
v5=${titre_best_crosses}
v6=${titre_lines_pred}
v7=${titre_pedigree_pred}
v8=${titre_lines_parents}
v9=${script}
v10=${output_dir}

Rscript ${r_scripts}analyses_rmd.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10}
