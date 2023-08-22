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

cM=${3}

simulation=${4}




if [ ${cM} != FALSE ] ; 
then 

#############################
# Subset one marker every cM (can be adjusted)

# Inputs
titre_markers_filtered=${r_prepare}markers_filtered.txt 
titre_genotyping_matrix_filtered_imputed=${r_prepare}genotyping_matrix_filtered_imputed.txt # from prepare.sh
titre_function_sort_genotyping_matrix=${r_scripts}sort_genotyping_matrix.R


# Outputs
titre_markers_filtered_subset=${r_value_crosses}markers_filtered_subset.txt
titre_genotyping_matrix_filtered_imputed_subset=${r_value_crosses}genotyping_matrix_filtered_imputed_subset.txt


# Variables
v1=${titre_markers_filtered}
v2=${titre_genotyping_matrix_filtered_imputed}
v3=${cM}
v4=${titre_genotyping_matrix_filtered_imputed_subset}
v5=${titre_markers_filtered_subset}
v6=${titre_function_sort_genotyping_matrix}

Rscript ${r_scripts}subset_markers.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6}

else

cp ${r_prepare}genotyping_matrix_filtered_imputed.txt ${r_value_crosses}genotyping_matrix_filtered_imputed_subset.txt
cp ${r_prepare}markers_filtered.txt ${r_value_crosses}markers_filtered_subset.txt

fi



if [ ${simulation} != "TRUE" ] ; 
then 



job_out=${r_log_calcul_gblup}gblup.out
job_name=gblup
job=$(sbatch -o ${job_out} -J ${job_name} --time=00:30:00 --mem=10G --parsable ${r_scripts}gblup.sh ${base})


elif [ ${simulation} == "TRUE" ] ; 
then


job_out=${r_log}simulated_marker_effects.out
job_name=simul_mke
# job=$(sbatch -o ${job_out} -J ${job_name} --time=00:30:00 --mem=10G --parsable ${r_scripts}simulated_marker_effects.sh ${base})

fi



while (( $(squeue -u adanguy | grep ${job} | wc -l) >= 1 )) 
do    
    sleep 1s
done





job_out=${r_log_calcul_variance_crosses_chr}variance_crosses_chr.out
job_name=chr
job=$(sbatch -o ${job_out} -J ${job_name} --parsable ${r_scripts}variance_crosses_chr_1.sh ${base} ${nbcores})
echo "${job}" >> ${r_log_value_crosses_variance_crosses_chr}jobs_variance_crosses_chr.txt



while (( $(squeue -u adanguy | grep -f ${r_log_value_crosses_variance_crosses_chr}jobs_variance_crosses_chr.txt | wc -l) >= 1 )) 
do    
    sleep 1s
done



k=0
for f in ${r_value_crosses_variance_crosses_chr}variance_crosses_*.txt
do 


    if ((k==0 ))
        
    then 
        
        cat ${f} > ${r_value_crosses}variance_crosses.txt
            # rm ${f}
        
    else
        
        tail -n+2 ${f} >> ${r_value_crosses}variance_crosses.txt
            # rm ${f}

    fi
        
    k=$((k +1))
        
done

# Inputs
titre_variance_crosses=${r_value_crosses}variance_crosses.txt
titre_lines=${r_prepare}lines.txt
titre_selection_intensity=${r_selection_intensity}tab3_selection_intensity.txt
titre_function_calcul_index_variance_crosses=${r_scripts}calcul_index_variance_crosses.R
selection_treshold=$(cut -f5 ${r}lines.txt | tail -n+2 | sort -n | tail -n1) # best gebv
selection_rate=0.07

# Output
titre_crosses=${r_value_crosses}crosses.txt





# Variables
v1=${titre_variance_crosses}
v2=${titre_lines}
v3=${titre_selection_intensity}

v4=${titre_function_calcul_index_variance_crosses}
v5=${selection_treshold}
v6=${selection_rate}
v7=${titre_crosses}



Rscript ${r_scripts}crosses.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7}
