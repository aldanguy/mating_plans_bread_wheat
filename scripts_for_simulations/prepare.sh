#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'


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

base=/work/adanguy/these/croisements/scripts/base_cr_050321.sh

source ${base}



#############################
# compute expected mean of higher quantiles

# Input
# D=3300

# Output
titre_selection_intensity_output=${r_prepare}selection_intensity.txt # output

# Variables
v1=${D}
v2=${titre_selection_intensity_output}

# Script
Rscript ${r_scripts}selection_intensity.R ${v1} ${v2}


#############################
# compute expected mean of higher statistics 

# Inputs
# D=3300
titre_selection_intensity_input=${titre_selection_intensity_output}

# Output
titre_expected_best_order_statistic_output=${r_prepare}expected_best_order_statistic.txt 

# Variables
v1=${D}
v2=${titre_selection_intensity_input}
v3=${titre_expected_best_order_statistic_output}

# Script
Rscript ${r_scripts}order_statistics.R ${v1} ${v2} ${v3}

#############################
# Step 1 : ID of lines

# Inputs
titre_phenotypes_input=${r_amont}Traitees_IS.txt
titre_genotyping_input=${r_amont}matrix_nonimput_withoutOTV_names.txt

# Output
titre_lines_output=${r_prepare}lines_1.txt
titre_pedigree_output=${r_prepare}pedigree.txt

# Variables
v1=${titre_phenotypes_input}
v2=${titre_genotyping_input}
v3=${titre_lines_output}
v4=${titre_pedigree_output}


# Script
Rscript ${r_scripts}ID.R ${v1} ${v2} ${v3} ${v4}


#############################
# Step 2 : estimation of blues
module purge
module load system/R-3.4.3_bis

# Inputs
# titre_phenotypes_input=${r_amont}Traitees_IS.txt
titre_lines_input=${titre_lines_output}

# Output
titre_lines_output=${r_prepare}lines_2.txt

# Variables
v1=${titre_phenotypes_input}
v2=${titre_lines_input}
v3=${titre_lines_output}

# Script
Rscript ${r_scripts}blues.R ${v1} ${v2} ${v3} # use of asreml




#############################
# Step 3 : filter genotyping matrix
source ${base}

# Inputs
# titre_genotyping_input=${r_amont}matrix_nonimput_withoutOTV_names.txt
titre_lines_input=${r_prepare}lines_2.txt # from blues.R
#keep_all=${3}

# outputs
# titre_lines=${r}lines.txt
titre_genotyping_output=${r_prepare}genotyping_1.txt
titre_lines_output=${r_prepare}lines.txt 


# Variables
v1=${titre_genotyping_input}
v2=${titre_lines_input}
v3=${keep_all}
v4=${titre_genotyping_output}
v5=${titre_lines_output}

# Script
Rscript ${r_scripts}filtering_genotyping_matrix.R ${v1} ${v2} ${v3} ${v4} ${v5}

#############################
# Step 4 : physical position of markers (skipped)

# Inputs
titre_physical_position_markers_input=${r_amont}Vraies_positions_marqueurs.txt # private data
titre_correspondance_chr_input=${r_amont}Codes_chr.txt
titre_chr_regions_input=${r_amont}Decoupage_chr_ble.tab
# titre_genotyping_matrix_raw=${r_amont}matrix_nonimput_withoutOTV_names.txt

# Output
titre_markers_ouput=${r_prepare}markers_1.txt # no longer include private data
titre_genotyping_input=${titre_genotyping_output}

# Variables
v1=${titre_physical_position_markers_input}
v2=${titre_correspondance_chr_input}
v3=${titre_chr_regions_input}
v4=${titre_genotyping_input}
v5=${titre_markers_ouput}

# Script
Rscript ${r_scripts}markers.R ${v1} ${v2} ${v3} ${v4} ${v5}




#############################
# choose a genetic map

# Input
titre_genetic_maps_input=${r_amont}supplementary_file_3_recombination_maps.txt # from Danguy des Déserts et al.

# Output
titre_genetic_map_temp_output=${r_prepare}genetic_map

# Variables
v1=${titre_genetic_maps_input}
v2=${titre_genetic_map_temp_output}

# Script
Rscript ${r_scripts}prepare_genetic_map.R ${v1} ${v2}

#############################
# estimation of genetic position of a set of markers based on a genetic map

# Inputs

k=0
for population in ${populations[*]}
    do

    # input
    titre_genetic_map_input=${titre_genetic_map_temp_output}_${population}.txt
    titre_markers_input=${titre_markers_ouput}
    
    # output
    titre_markers_output=${r_prepare}markers_2_${population}.txt

    v1=${titre_genetic_map_input}
    v2=${titre_markers_input}
    v3=${population}
    v4=${titre_markers_output}

    # Script
    Rscript ${r_scripts}interpolation_genetic_positions.R ${v1} ${v2} ${v3} ${v4}

    if [ ${k} -eq 0 ]
        then

        cat ${titre_markers_output} > ${r_prepare}markers_2.txt
        cat ${titre_genetic_map_temp_output}_${population}.txt > ${r_prepare}genetic_map.txt
    else 
        tail -n+2 ${titre_markers_output} >> ${r_prepare}markers_2.txt
        tail -n+2 ${titre_genetic_map_temp_output}_${population}.txt >> ${r_prepare}genetic_map.txt

    fi

    
    k=$((${k} +1))


done



#############################
# Step 5 : imputation of missing values

# Inputs
titre_genotyping_input=${r_prepare}genotyping_1.txt
titre_markers_input=${r_prepare}markers_2.txt
titre_function_sort_genotyping_matrix=${r_scripts}sort_genotyping_matrix.R


# Output
titre_genotyping_output=${r_prepare}genotyping.txt
titre_markers_output=${r_prepare}markers.txt

# Variables
v1=${titre_genotyping_input}
v2=${titre_markers_input}
v3=${nbcores}
v4=${titre_function_sort_genotyping_matrix}
v5=${titre_genotyping_output}
v6=${titre_markers_output}

# Script
Rscript ${r_scripts}imputation.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6}



# At the end, should provide
# a filtered genotyping matrix with no missing data
# the physical and genetic positions of markers


rm ${r_prepare}lines_*.txt
rm ${r_prepare}markers_*.txt
rm ${r_prepare}genotyping_*.txt
rm ${r_prepare}genetic_map_*.txt

populations=$(cut -f5 ${r_prepare}markers.txt | sort | uniq | grep -v "population")

for p in ${populations[*]}
    do
    head -n1 ${r_prepare}markers.txt > ${r_prepare}markers_${p}.txt
    grep ${p} ${r_prepare}markers.txt >> ${r_prepare}markers_${p}.txt
done




date +'%Y-%m-%d-%T'

