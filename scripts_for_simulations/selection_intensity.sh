#!/bin/bash



base=${1}
source ${base}


# Goal: Prepare reference files about properties of Normal distribution

# input files
# none

# output files
# tab3_selection_intensity.txt from selection_intensity.R
# tab2_expected_best_order_statistic.txt from order_statistics.R


#############################
# compute expected mean of higher quantiles

# Input
# D=3300

# Output
titre_selection_intensity=${r}tab3_selection_intensity.txt # output

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
titre_tab2_expected_best_order_statistic=${r}tab2_expected_best_order_statistic.txt 

# Variables
v1=${D}
v2=${titre_selection_intensity}
v3=${titre_tab2_expected_best_order_statistic}

# Script
Rscript ${r_scripts}order_statistics.R ${v1} ${v2} ${v3}
