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


source ${base}

cd ${r_prepare}



#############################
# compute expected mean of higher quantiles

# Input
# D=3300

# Output
titre_selection_intensity_output=${titre_selection_intensity}

# Variables
v1=${D}
v2=${titre_selection_intensity_output}

# Script
Rscript ${r_scripts}02_01_selection_intensity.R ${v1} ${v2}


#############################
# compute expected mean of higher statistics 

# Inputs
# D=3300
titre_selection_intensity_input=${titre_selection_intensity_output}

# Output
titre_expected_best_order_statistic_output=${titre_best_order_statistic}

# Variables
v1=${D}
v2=${titre_selection_intensity_input}
v3=${titre_expected_best_order_statistic_output}

# Script
Rscript ${r_scripts}02_02_order_statistics.R ${v1} ${v2} ${v3}

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
Rscript ${r_scripts}02_03_ID.R ${v1} ${v2} ${v3} ${v4}


#############################
# Step 2 : estimation of blues, require ASREML-r (skipped)
# Data saved in r_amont/lines.txt


#module purge
#module load system/R-3.4.3_bis

# Inputs
# titre_phenotypes_input=${r_amont}Traitees_IS.txt
#titre_lines_input=${titre_lines_output}

# Output
#titre_lines_output=${r_prepare}lines_2.txt

# Variables
#v1=${titre_phenotypes_input}
#v2=${titre_lines_input}
#v3=${titre_lines_output}

# Script
# Rscript ${r_scripts}02_04_blues.R ${v1} ${v2} ${v3} # use of asreml



#############################
# Step 3 : filter genotyping matrix
source ${base}

# Inputs
# titre_genotyping_input=${r_amont}matrix_nonimput_withoutOTV_names.txt
# titre_lines_input=${r_prepare}lines_2.txt # from blues.R require asreml
titre_lines_input=${r_prepare}lines_1.txt # no asreml required, adjusted phenotypes are given in r_amont/lines.txt

#keep_all=${3}

# outputs
# titre_lines=${r}lines.txt
titre_genotyping_output=${r_prepare}genotyping_1.txt
#titre_lines_output=${titre_phenotypes_parents0}


# Variables
v1=${titre_genotyping_input}
v2=${titre_lines_input}
v3=${keep_all}
v4=${titre_genotyping_output}
#v5=${titre_lines_output}

# Script
#Rscript ${r_scripts}02_05_filtering_genotyping_matrix.R ${v1} ${v2} ${v3} ${v4} ${v5}
Rscript ${r_scripts}02_05_filtering_genotyping_matrix.R ${v1} ${v2} ${v3} ${v4}

cp ${r_amont}phenotypes_real_data.txt ${titre_phenotypes_parents0}



#############################
# Step 4 : physical position of markers (skipped)

# Inputs
#titre_physical_position_markers_input=${r_amont}Vraies_positions_marqueurs.txt # private data
#titre_correspondance_chr_input=${r_amont}Codes_chr.txt
#titre_chr_regions_input=${r_amont}Decoupage_chr_ble.tab
# titre_genotyping_matrix_raw=${r_amont}matrix_nonimput_withoutOTV_names.txt

# Output
#titre_markers_ouput=${r_prepare}markers_1.txt # no longer include private data
#titre_genotyping_input=${titre_genotyping_output}

# Variables
#v1=${titre_physical_position_markers_input}
#v2=${titre_correspondance_chr_input}
#v3=${titre_chr_regions_input}
#v4=${titre_genotyping_input}
#v5=${titre_markers_ouput}

# Script
#Rscript ${r_scripts}02_06_markers.R ${v1} ${v2} ${v3} ${v4} ${v5}

cp ${r_amont}markers_${genetic_map_ref}.txt ${r_prepare}markers_1.txt


#############################
# choose a genetic map

# Input
titre_genetic_maps_input=${r_amont}supplementary_file_S4_recombination_maps.txt # from Danguy des Déserts et al.

# Output
titre_genetic_map_temp_output=${r_prepare}genetic_map

# Variables
v1=${titre_genetic_maps_input}
v2=${titre_genetic_map_temp_output}

# Script
Rscript ${r_scripts}02_07_prepare_genetic_map.R ${v1} ${v2}

#############################
# estimation of genetic position of a set of markers based on a genetic map

# Inputs

for genetic_map in ${genetic_maps_raw[*]}
    do

    # input
    titre_genetic_map_input=${titre_genetic_map_temp_output}_${genetic_map}.txt
    titre_markers_input=${r_prepare}markers_1.txt
    
    # output
    titre_markers_output=${r_results}markers_${genetic_map}.txt

    v1=${titre_genetic_map_input}
    v2=${titre_markers_input}
    v3=${genetic_map}
    v4=${titre_markers_output}

    # Script
    Rscript ${r_scripts}02_08_interpolation_genetic_positions.R ${v1} ${v2} ${v3} ${v4}

  


done




#############################
# Step 5 : imputation of missing values

# Inputs
titre_genotyping_input=${r_prepare}genotyping_1.txt
titre_markers_input=${titre_markers0}


# Output
titre_genotyping_output=${titre_genotypes_parents0}
titre_markers_output=${r_prepare}markers.txt

# Variables
v1=${titre_genotyping_input}
v2=${titre_markers_input}
v3=${nbcores}
v4=${titre_genotyping_output}
v5=${titre_markers_output}

# Script
Rscript ${r_scripts}02_10_imputation.R ${v1} ${v2} ${v3} ${v4} ${v5}



# At the end, should provide
# a filtered genotyping matrix with no missing data
# the physical and genetic positions of markers




titre_genetic_map_input=${titre_markers0}
titre_nolinkagegroup=${r_results}markers_nolinkagegroup.txt
titre_mapx3=${r_results}markers_mapx3.txt
titre_genasphy=${r_results}markers_nogenpos.txt

v1=${titre_genetic_map_input}
v2=${titre_nolinkagegroup}
v3=${titre_mapx3}
v4=${titre_genasphy}

Rscript ${r_scripts}02_11_strange_genetic_maps.R ${v1} ${v2} ${v3} ${v4}




echo "STEP 3 : filter crosses "


titre_genotypes_parents_input=${titre_genotypes_parents0}
titre_markers_input=${titre_markers0}
titre_markers_output=${r_prepare}LDAK_real_data.map
titre_genotyping_output=${r_prepare}LDAK_real_data.ped




v1=${titre_genotypes_parents_input}
v2=${titre_markers_input}
v3=${titre_markers_output}
v4=${titre_genotyping_output}

echo "STEP 3.1 : prepare_for_LDAK.R "


Rscript ${r_scripts}prepare_for_LDAK.R ${v1} ${v2} ${v3} ${v4} 




plink --file ${r_prepare}LDAK_real_data --recode --noweb --out ${r_prepare}LDAK_2_real_data
plink --file ${r_prepare}LDAK_2_real_data --noweb --make-bed --out ${r_prepare}LDAK_3_real_data

r_LDAK_temp=${r_prepare}LDAK/temp/

if [ -d "${r_LDAK_temp}" ]
then
    rm -rf ${r_LDAK_temp}
fi
mkdir -p ${r_LDAK_temp}
cd ${r_LDAK_temp}
cp ${r_prepare}LDAK_3_real_data* ${r_LDAK_temp}


/work/adanguy/ldak5.1.linux --cut-weights sections --bfile ${r_LDAK_temp}LDAK_3_real_data --window-cm 1 --section-cm 1 --buffer-cm 1 --no-thin YES > ${r0_log_prepare}LDAK_step1_prepare_real_data.out
/work/adanguy/ldak5.1.linux --calc-weights-all sections --bfile ${r_LDAK_temp}LDAK_3_real_data > ${r0_log_prepare}LDAK_step2_prepare_real_data.out
/work/adanguy/ldak5.1.linux --calc-kins-direct LDAK-Thin --bfile ${r_LDAK_temp}LDAK_3_real_data --weights ${r_LDAK_temp}sections/weights.all --power -1 --kinship-raw YES > ${r0_log_prepare}LDAK_step3_prepare_real_data.out

echo "STEP 3.2 : convert_LDAK_matrix.R "


titre_g_raw=${r_LDAK_temp}LDAK-Thin.grm.raw
titre_ibs_output=${titre_LDAK0}
titre_lines=${titre_phenotypes_parents0}

v1=${titre_g_raw}
v2=${titre_ibs_output}
v3=${titre_lines}




Rscript ${r_scripts}convert_LDAK_matrix.R ${v1} ${v2} ${v3} 

cd ${r0}




titre_genotyping_input=${titre_genotypes_parents0}
titre_markers_input=${titre_markers0}
titre_haplotypes_output=${titre_haplotypes_parents0}

v1=${titre_genotyping_input}
v2=${titre_markers_input}
v3=${titre_haplotypes_output}

Rscript ${r_scripts}convert_geno_to_haplo.R ${v1} ${v2} ${v3} 




#rm ${r_prepare}*
# rm -rf ${r_LDAK_temp}

date +'%Y-%m-%d-%T'

