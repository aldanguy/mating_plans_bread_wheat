#!/bin/bash




base=${1}


source ${base}



# Inputs
titre_variance_crosses=${r_value_crosses}variance_crosses.txt
titre_lines=${r_prepare}lines.txt
titre_selection_intensity=${r_prepare}selection_intensity.txt
titre_function_calcul_index_variance_crosses=${r_scripts}calcul_index_variance_crosses.R
selection_treshold=$(cut -f5 ${r_prepare}lines.txt | tail -n+2 | sort -n | tail -n1) # best gebv
selection_rate=0.07

# Output
titre_crosses=${r_value_crosses}crosses.txt

