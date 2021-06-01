#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'




base=${1}
type=${2}
population_variance=${3}


source ${base}


output_variance=${r_value_crosses}crosses/variance_crosses_${type}_${population_variance}.txt
output_crosses=${r_value_crosses}crosses/crosses_${type}_${population_variance}.txt
file_jobs=${r_log_value_crosses_jobs}jobs_variance_crosses_chr_${type}_${population_variance}.txt
typeshort=$(echo ${type} | sed "s/_/./g")
echo ${type}_${population_variance}

nbcores=1


for c in ${chr[*]}
    do
    

    
    
    echo ${c}

    
    job_out=${r_log_value_crosses_crosses}variance_crosses_chr_${type}_${population_variance}_${c}.out
    
    
    job_name=${c}${typeshort}${population_variance}
	    
    #job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem=3G --time=00:30:00 --parsable ${r_scripts}variance_crosses_chr.sh ${base} ${type} ${population_variance} ${c}) 
    
    #echo "${job_out} =" >> ${file_jobs}
    #echo "${job}" >> ${file_jobs}

done

sed -i '/^$/d' ${file_jobs}
while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
do    
    sleep 1s
done


k=0

for c in ${chr[*]}
    do
    
    


    
    if [ ${k} -eq 0 ]
        then
            
        cat ${r_value_crosses}crosses/variance_crosses_chr_${type}_${population_variance}_${c}.txt > ${output_variance}
            
    else 
        tail -n+2 ${r_value_crosses}crosses/variance_crosses_chr_${type}_${population_variance}_${c}.txt >> ${output_variance}

            
    fi
    
    #rm ${r_value_crosses}crosses/variance_crosses_chr_${ID1}_${ID2}.txt
    k=$((k+1))
done

if [ $(echo ${type} | grep "simTRUE" | grep "_h" | wc -l) -eq 1 ] || [ $(echo ${type} | grep "simFALSE" | wc -l ) -eq 1 ]
    then
    if [ $(echo ${type} | grep "_h1.0_" | wc -l) -eq 1 ] 
        then
        type2=$(echo ${type} | sed "s/_h1.0_/_/g" | sed "s/_g.*$//g")
        titre_lines_input=${r_value_crosses_lines}lines_tbv_${type2}.txt

        else

        titre_lines_input=${r_value_crosses_lines}lines_gebv_${type}.txt
    fi
elif [ $(echo ${type} | grep "simTRUE" | grep "_h" -v | wc -l) -eq 1 ]
    then
    titre_lines_input=${r_value_crosses_lines}lines_tbv_${type}.txt
fi



# Inputs
titre_variance_crosses_input=${output_variance}
titre_selection_intensity_input=${r_prepare}selection_intensity.txt
titre_function_calcul_index_variance_crosses=${r_scripts}calcul_index_variance_crosses.R

export LC_COLLATE=C
export LC_ALL=C
selection_treshold=$( cut -f2 ${titre_lines_input} | tail -n+2 | sort -g | tail -n1) # best gebv
selection_rate=0.07

# Output
titre_crosses_output=${output_crosses}


v1=${titre_variance_crosses_input}
v2=${titre_lines_input}
v3=${titre_selection_intensity_input}
v4=${titre_function_calcul_index_variance_crosses}
v5=${selection_treshold}
v6=${selection_rate}
v7=${titre_crosses_output}
v8=${type}
v9=${population_variance}


Rscript ${r_scripts}crosses_2.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9}


# rm ${titre_variance_crosses_input}
date +'%Y-%m-%d-%T'
