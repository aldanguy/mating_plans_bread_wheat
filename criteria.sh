#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
export LC_COLLATE=C
export LC_ALL=C
ulimit -s unlimited
export OMP_STACKSIZE=64M


# change gblup to GBLUP


base=${1}





source ${base}

r=${2}
r_log=${3}
ID=${4}
constraints=${5}
proportion_of_crosses_used=${6}
progeny=${7}
titre_genetic_values_used=${8}
titre_genetic_map_used=${9}
titre_genotypes_used=${10}
titre_LDAK_used=${11}
titre_markers_used=${12}
titre_criteria_base=${13}
genetic_map=${14}





echo ${base}
echo ${r}
echo ${r_log}
echo ${ID}
echo ${constraints}
echo ${proportion_of_crosses_used}
echo ${progeny}
echo ${titre_genetic_values_used}
echo ${titre_genetic_map_used}
echo ${titre_genotypes_used}
echo ${titre_LDAK_used}
echo ${titre_markers_used}
echo ${titre_criteria_base}
echo ${genetic_map}



source ${r_scripts}param_${constraints}.sh







# Directories



r_criteria=${r}criteria/
r_criteria_temp=${r_criteria}temp/${ID}/

mkdir -p ${r_criteria_temp}

titre_function_calcul_index_variance_crosses=${r_scripts}calcul_index_variance_crosses.R


cd ${r}

# files specific of unselected scripts


########################################## PART 1 : Generate files


# Step 1 : names of files and some variables
# not of all of them will be used, this depends on the scenario







file_jobs=${r0_log_jobs}jobs_variance_${ID}.txt
titre_variance_crosses_chr=${r_criteria_temp}variance_crosses_${ID}_
titre_variances_crosses=${r_criteria_temp}variance_crosses_${ID}.txt
titre_crosses_temp=${r_criteria_temp}crosses_temp_${ID}.txt






chr=1A

for chr in ${chromosomes[*]}
    do
    

    
    

        

    r_big_files=${r_criteria_temp}
    titre_variance_crosses_chr_output=${titre_variance_crosses_chr}${chr}.txt

        

      
    # variables
    v1=${base}
    v2=${titre_markers_used}
    v3=${titre_genotypes_used}
    v4=${nbcores}
    v5=${chr}
    v6=${progeny}
    v7=${r_big_files}
    v8=${titre_variance_crosses_chr_output}
    v9=${titre_genetic_values_used}
    v10=${titre_genetic_map_used}




    echo ${chr}
    
    
    job_out=${r_log}variance_crosses_${ID}_${chr}.out
    
    
    job_name=${chr}
    

	    
    job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem=3G --time=00:30:00 --parsable ${r_scripts}variance_crosses_chr.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11})
    
    echo "${job_out} =" >> ${file_jobs}
    echo "${job}" >> ${file_jobs}
    
    while (( $(squeue -u adanguy  | wc -l) >=  ${nb_jobs_allowed})) 
    do    
    sleep 1m
    done

done

sed -i '/^$/d' ${file_jobs}
while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
do    
    sleep 1s
    sed -i '/^$/d' ${file_jobs}
done



k=0

for chr in ${chromosomes[*]}
    do
    
    if [ ${k} -eq 0 ]
        then
            
        cat ${titre_variance_crosses_chr}${chr}.txt > ${titre_variances_crosses}
            
    else 
        tail -n+2 ${titre_variance_crosses_chr}${chr}.txt >> ${titre_variances_crosses}

            
    fi
    
    k=$((k+1))
    
done

if [ ! -f "${titre_variances_crosses}" ] 
then
    echo "no variance file"
else

    head ${titre_variances_crosses}
fi
echo "STEP 3.2 : criteria"


colonne_PROBA=$(head ${titre_genetic_values_used} -n1 | sed "s/\t/\n/g" | grep -n "value" | sed "s/:.*//g")
selection_treshold_PROBA=$( cut -f${colonne_PROBA} ${titre_genetic_values_used} | tail -n+2 | sort -g | tail -n1) # best GEBV
titre_crosses_output=${titre_crosses_temp}



# Output

v1=${titre_variances_crosses}
v2=${titre_genetic_values_used}
v3=${titre_selection_intensity}
v4=${titre_best_order_statistic}
v5=${selection_treshold_PROBA}
v6=${within_family_selection_rate_UC1}
v7=${within_family_selection_rate_UC2}
v8=${Dmax_EMBV}
v9=${titre_function_calcul_index_variance_crosses}
v10=${titre_crosses_output}






Rscript ${r_scripts}crosses.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} 


echo "STEP 3.2 : OHV"



#titre_genotypes_parents=${titre_genotypes_parents}
titre_markers_value_input=${titre_markers_used}
titre_crosses_input=${titre_crosses_temp}
#titre_function_calcul_index_variance_crosses
titre_crosses_output=${titre_criteria_base}_no_filter.txt



v1=${titre_genotypes_used}
v2=${titre_markers_value_input}
v3=${titre_crosses_input}
v4=${titre_function_calcul_index_variance_crosses}
v5=${titre_crosses_output}


Rscript ${r_scripts}OHV.R ${v1} ${v2} ${v3} ${v4} ${v5} 

########################################## STEP 4 : filter crosses

echo "STEP 4 : filter crosses "


echo "STEP 4.x : crosses_CONSTRAINTS.R "

titre_LDAK_input=${titre_LDAK_used}
titre_crosses_input=${titre_criteria_base}_no_filter.txt
#most_related_crosses_removed
titre_crosses_output=${titre_criteria_base}.txt



v1=${titre_LDAK_input}
v2=${titre_crosses_input}
v3=${most_related_crosses_removed}
v4=${titre_crosses_output}



Rscript ${r_scripts}crosses_CONSTRAINTS.R ${v1} ${v2} ${v3} ${v4} 


echo "STEP 4.x+1 : keep_crosses_with_high_PM.R "

titre_criteria_input=${titre_criteria_base}.txt
#proportion_of_crosses_used
titre_criteria_output=${titre_criteria_base}.txt


v1=${titre_criteria_input}
v2=${proportion_of_crosses_used}
v3=${titre_criteria_output}


Rscript ${r_scripts}keep_crosses_with_high_PM.R ${v1} ${v2} ${v3} 


rm -rf ${r_criteria_temp}

date +'%Y-%m-%d-%T'
