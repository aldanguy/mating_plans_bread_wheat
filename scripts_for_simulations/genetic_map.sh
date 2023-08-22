#!/bin/bash


# Goal : prepare matrix of variance covariance of progeny genotypes, based on a genetic map and a subset of markers


# input files
# markers.txt, genotyping_matrix_imputed.txt from prepare.sh
# supplementary_file_3_recombination_maps.txt from Danguy des Déserts et al.

# output files
# markers.txt (modified)
# genotyping_matrix_imputed (modified)
# genetic_map.txt 
# v_cov_progeny_genotypes.txt

base=${1}

source ${base}





#############################
# Subset one marker every cM (can be adjusted)

# Inputs
# titre_markers=${r}markers.txt # from interpolation_genetic_positions.R
cM=1
titre_genotyping_matrix_filtered_imputed=${r_amont}genotyping_matrix_filtered_imputed.txt # from prepare.sh


# Outputs
titre_markers_filtered_subset=${r}markers_filtered_subset.txt
titre_genotyping_matrix_filtered_imputed_subset=${r}genotyping_matrix_filtered_imputed_subset.txt


# Variables
v1=${titre_markers_filtered_subset} # from interpolation_genetic_positions.R
v2=${cM}
v3=${titre_genotyping_matrix_filtered_imputed_subset}


Rscript ${r_scripts}subset_markers.R ${v1} ${v2} ${v3}



