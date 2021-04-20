#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'



##### Step 1 : Readme


## Description of input data

# 1 : genotyping data of parents
# description of file :
# overall : one row = one parental line, one column = genotype at one marker
# col n°1 : header = "ID" , value = name of parental line (string, ex: AO07403_XXX00000000000000000)
# col n°2-end : headers = name of markers (ex: "AX-89695177"), value = allelic dosage of alternativ allele (integer, 0, 1, 2). No missing value. 
# rows should be sorted accordind ID column
# columns 2-end should be sorted by chromosome order and then following genetic map order. This is very important.
# All parental lines present in this file should also be in crosses data, but no more.
# Dimensions without headers : nrows = nb parental lines * ncols =  (nb markers +1)
# A small exemple of data is given in the file FD_genotyping.txt


# 2 : markers data
# description of file :
# overall : one row = description of one marker
# col n°1 : header = "chr" , value = number of chr (string, ex: 1A)
# col n°2 : header = "marker", value = name of markers (string, ex: "AX-89695177")
# col n°3 : header = "dcum", value = position on genetic map, in cumulated centimorgans (numeric, mainly comprised between 0 and 300).
# col n°4 : header = "value", value = allelic subsitution effect on phenotype (numeric)
# rows should be sorted by chromosome order and then following genetic map order. This is very important.
# Dimensions : nb markers * 4
# A small exemple of data is given in the file FD_markers.txt

# 3 : crosses data 
# description of file : 
# overall : one row = one cross to study
# col n°1 : header = "P1", value = name of first parental line involve in the cross (string, ex: AO07403_XXX00000000000000000)
# col n°2 : header = "P2", value = name of second parental line (string, ex: AO12017_XXX00000000000000000)
# col n°3 : header = "gebv", value = average of parental line gebv (numeric). Gives expected mean of progeny of a cross
# All parental lines present in this file should also be in genotyping data.
# P1 alphabetical order should always be lower than P2 alphabetical number (ex: P1 = AO07403_XXX00000000000000000, P2 = AO12017_XXX00000000000000000)
# Dimensions : nb crosses * 3
# A small exemple of data is given in the file FD_crosses.txt


# All files should have tab separator between columns, points to indicate float (ex : 1.2), headers, but no row numbers and no quotes


## Description of output data

# The file "titre_crosses_output" in script 02
# description of file :
# overall : one row give caracteristics of a cross
# col n°1-3 : same as crosses data
# col n°4 : header = "sd", value = expected standard deviation of progeny derived from the cross P1*P2 (numeric)
# col n°5 : header = "logw", value = log10 probability for a cross to produce a progeny with lower value than the value of best parental line (numeric) 
# col n°6 : header = "uc", value = xpected mean of top q% progeny of a cross (numeric)
# col n°7 : header = "uc_extreme", value = expected mean of the top 0.01% progeny of a cross (numeric)
# should have as many rows as crosses data.
# Dimensions : nb crosses * 7
# A small exemple of data is given in the file FD_crosses2.txt
# tab separator between columns, points to indicate float (ex : 1.2), headers, but no row numbers and no quotes


## Parameters

# specify type of progeny (RILs or HDs)
progeny=RILs

# specifiy number of selfing generation (if RILs, k=1 -> F2 ; k=2 -> F3 ... ; in HDs k=1 -> F1 gamete doubled ; k=2 -> F2 gamete doubled ...)
k=4 # for RILs F5

# specify value of best parental line to exceed in progeny (warning, should be estimated from the same genomic analysis than the one producing parental gebv).
best_parental_line=24.82689

# specify selection intensity correspond to superior progeny value of each cross (expected mean of top q% of progeny)
sel_intensity=1.91 # for q = 7%


## Directories


# directory where examples files will be stored
source_directory=/home/adanguydesd/Documents/These_Alice/croisements/temp/

# directory where results files will be stored
results_directory=/home/adanguydesd/Documents/These_Alice/croisements/temp/

# directory where scripts are stored
scripts_directory=/home/adanguydesd/Documents/These_Alice/croisements/scripts/



##### Step 1 : compute caracteristics of each cross

# The script compute variance of crosses, and the value of 4 criteria : gebv (1), logw (2), uc (3) and uc_extreme (4)
# Should be quite long and intensiv if number or parents and/or number of markers is high

# Input
titre_markers_input=${source_directory}FD_markers.txt
titre_genotyping_input=${source_directory}FD_genotyping.txt
titre_crosses_input=${source_directory}FD_crosses.txt
# progeny=RILs
# k=1
# sel_intensity=1.91
# best_parental_line=24.82689

# Output
r_big_files=${results_directory} # warning, in case of many crosses and many markers to study, files stored here would be very big
titre_crosses_output=${results_directory}FD_crosses_estimated.txt

# Variables
v1=${titre_markers_input}
v2=${titre_genotyping_input}
v3=${titre_crosses_input}
v4=${r_big_files}
v5=${progeny}
v6=${k}
v7=${sel_intensity}
v8=${best_parental_line}
v9=${titre_crosses_output}


Rscript ${scripts_directory}02_pipeline_for_FD_variance_crosses.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9}

##### Step 2 : optimize mating plan

# PLE or genetic algorithm


##### Step 3 : simulate progenies

# number of rep, and compute gebv
