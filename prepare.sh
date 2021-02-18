#!/bin/bash



# Goal: prepare base files for next scripts: rename lines with an equal size ID, estimate BLUE of lines, clean and impute genotyping matrix

# inputs files
# Traitees_IS.txt, matrix_nonimput_withoutOTV_names.txt from Sarah Ben-Sadoun
# Vraies_positions_marqueurs.txt, Codes_chr.txt, Decoupage_chr_ble.tab from Sophie Bouchet


# Output files
# genotyping_matrix_imputed.txt from imputation.R
# genotyping_matrix_updated.txt from order.R
# lines.txt from filtering_genotyping_matrix.R
# markers.txt from order.R


base=${1}


source ${base}

nbcores=${2}

keep_all=${3}



#############################
# compute expected mean of higher quantiles

# Input
# D=3300

# Output
titre_selection_intensity=${r_prepare}selection_intensity.txt # output

# Variables
v1=${D}
v2=${titre_selection_intensity}

# Script
Rscript ${r_scripts}selection_intensity.R ${v1} ${v2}


#############################
# compute expected mean of higher statistics 

# Inputs
# d=3300
# titre_selection_intensity=${r}tab3_selection_intensity.txt # from selection_intensity.R

# Output
titre_expected_best_order_statistic=${r_prepare}expected_best_order_statistic.txt 

# Variables
v1=${D}
v2=${titre_selection_intensity}
v3=${titre_expected_best_order_statistic}

# Script
Rscript ${r_scripts}order_statistics.R ${v1} ${v2} ${v3}

#############################
# Step 1 : ID of lines

# Inputs
titre_phenotypes=${r_amont}Traitees_IS.txt
titre_genotyping_matrix_raw=${r_amont}matrix_nonimput_withoutOTV_names.txt

# Output
titre_lines=${r_prepare}lines.txt
titre_pedigree=${r_prepare}pedigree.txt

# Variables
v1=${titre_phenotypes}
v2=${titre_genotyping_matrix_raw}
v3=${titre_lines}
v4=${titre_pedigree}

# Script
Rscript ${r_scripts}ID.R ${v1} ${v2} ${v3} ${v4}


#############################
# Step 2 : estimation of blues
module purge
module load system/R-3.4.3_bis

# Inputs
# titre_phenotypes=${r_amont}Traitees_IS.txt
# titre_lines=${r}lines.txt from ID.R

# Output
# titre_lines=${r}lines.txt

# Variables
v1=${titre_phenotypes}
v2=${titre_lines}

# Script
Rscript ${r_scripts}blues.R ${v1} ${v2} # use of asreml

#############################
# Step 3 : filter genotyping matrix
source ${base}

# Inputs
# titre_genotyping_matrix_raw=${r_amont}matrix_nonimput_withoutOTV_names.txt
# titre_lines=${r}lines.txt # from blues.R
# keep_all=${3}

# outputs
# titre_lines=${r}lines.txt
titre_genotyping_matrix_filtered=${r_prepare}genotyping_matrix_filtered.txt

# Variables
v1=${titre_genotyping_matrix_raw}
v2=${titre_lines}
v3=${titre_genotyping_matrix_filtered}
v4=${keep_all}

# Script
Rscript ${r_scripts}filtering_genotyping_matrix.R ${v1} ${v2} ${v3} ${v4}

#############################
# Step 4 : physical position of markers (skipped)

# Inputs
titre_physical_position_markers=${r_amont}Vraies_positions_marqueurs.txt # private data
titre_correspondance_chr=${r_amont}Codes_chr.txt
titre_chr_regions=${r_amont}Decoupage_chr_ble.tab
# titre_genotyping_matrix_raw=${r_amont}matrix_nonimput_withoutOTV_names.txt

# Output
titre_markers_filtered=${r_prepare}markers_filtered.txt # no longer include private data

# Variables
v1=${titre_physical_position_markers}
v2=${titre_correspondance_chr}
v3=${titre_chr_regions}
v4=${titre_genotyping_matrix_filtered}
v5=${titre_markers_filtered}

# Script
Rscript ${r_scripts}markers.R ${v1} ${v2} ${v3} ${v4} ${v5}


#############################
# choose a genetic map

# Input
titre_genetic_maps_initial=${r_amont}supplementary_file_3_recombination_maps.txt # from Danguy des Déserts et al.

# Output
titre_genetic_map=${r_prepare}genetic_map

# Variables
v1=${titre_genetic_maps_initial}
v2=${titre_genetic_map}

# Script
Rscript ${r_scripts}prepare_genetic_map.R ${v1} ${v2}


#############################
# estimation of genetic position of a set of markers based on a genetic map

# Inputs

titre_genetic_map_WE=${r_prepare}genetic_map_WE.txt
titre_genetic_map_EE=${r_prepare}genetic_map_EE.txt
titre_genetic_map_WA=${r_prepare}genetic_map_WA.txt
titre_genetic_map_EA=${r_prepare}genetic_map_EA.txt
titre_genetic_map_CsRe=${r_prepare}genetic_map_CsRe.txt
# titre_markers=${r_prepare}markers_filtered.txt

v1=${titre_genetic_map_WE}
v2=${titre_genetic_map_EE}
v3=${titre_genetic_map_WA}
v4=${titre_genetic_map_EA}
v5=${titre_genetic_map_CsRe}
v6=${titre_markers_filtered}

# Script
Rscript ${r_scripts}interpolation_genetic_positions.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6}



#############################
# Step 5 : imputation of missing values

# Inputs
# titre_genotyping_matrix_updated=${r}genotyping_matrix_updated # from filtering_genotyping_matrix.R 
# titre_markers=${r}markers.txt from order.R 
# nbcores=${2}
titre_function_sort_genotyping_matrix=${r_scripts}sort_genotyping_matrix.R


# Output
titre_genotyping_matrix_filtered_imputed=${r_prepare}genotyping_matrix_filtered_imputed.txt

# Variables
v1=${titre_genotyping_matrix_filtered}
v2=${titre_markers_filtered}
v3=${titre_genotyping_matrix_filtered_imputed}
v4=${nbcores}
v5=${titre_function_sort_genotyping_matrix}

# Script
Rscript ${r_scripts}imputation.R ${v1} ${v2} ${v3} ${v4} ${v5}






# At the end, should provide
# a filtered genotyping matrix with no missing data
# the physical and genetic positions of markers
