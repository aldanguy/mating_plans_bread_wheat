#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'




base=${1}
generation=${2}
type=${3}
population=${4}


source ${base}

motif=$(echo ${type} | sed "s/marker_//g")
ID1=g${generation}_${motif}_${population}

output_variance=${r_value_crosses}crosses/variance_crosses_${ID1}.txt
output_crosses=${r_value_crosses}crosses/crosses_${ID1}.txt
file_jobs=${r_log_value_crosses_jobs}jobs_variance_crosses_chr_${ID1}.txt
nbcores=1

<<COMMENTS

for c in ${chr[*]}
    do
    

    
    
    ID2=${c}
    echo ${ID2}
    
    job_out=${r_log_value_crosses_crosses}variance_crosses_chr_${ID1}_${ID2}.out
    
    job_name=${c}${motif}${population}
	    
    # job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --time=00:20:00 --parsable ${r_scripts}variance_crosses_chr.sh ${base} ${generation} ${type} ${population} ${c}) 
    
    echo "${job_out} =" >> ${file_jobs}
    echo "${job}" >> ${file_jobs}

done


sed -i '/^$/d' ${file_jobs}
while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
do    
    sleep 1s
done

k=0

for c in ${chr[*]}
    do
    
    
    ID2=${c}


    
    if [ ${k} -eq 0 ]
        then
            
        cat ${r_value_crosses}crosses/variance_crosses_chr_${ID1}_${ID2}.txt > ${output_variance}
            
    else 
        tail -n+2 ${r_value_crosses}crosses/variance_crosses_chr_${ID1}_${ID2}.txt >> ${output_variance}

            
    fi
    
    #rm ${r_value_crosses}crosses/variance_crosses_chr_${ID1}_${ID2}.txt
    k=$((k+1))
done

COMMENTS
# Inputs
titre_variance_crosses_input=${output_variance}
titre_lines_input=${r_value_crosses}lines_estimated_${motif}.txt
titre_selection_intensity_input=${r_prepare}selection_intensity.txt
titre_function_calcul_index_variance_crosses=${r_scripts}calcul_index_variance_crosses.R


selection_treshold=$(grep ${motif} ${titre_lines_input} | grep -v "pheno" | cut -f7 | sort -n | tail -n1) # best gebv
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
v8=${generation}

Rscript ${r_scripts}crosses_2.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8}


# rm ${titre_variance_crosses_input}
date +'%Y-%m-%d-%T'
