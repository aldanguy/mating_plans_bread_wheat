#!/bin/bash
RANDOM=1




base=${1}
nbcores=${2}


type=${3}

population=${4}


source ${base}


output_variance=${r_value_crosses}variance_crosses/${type}/${population}/variance_crosses_${type}_${population}.txt
output_crosses=${r_value_crosses}crosses/crosses_${type}_${population}.txt

rm ${output_variance}
rm ${output_crosses}



for c in ${chr[*]}
    do
    
    
    r_log=${r_log_value_crosses_variance_crosses}${type}/${population}/${c}/
    r_save=${r_value_crosses}variance_crosses/${type}/${population}/${c}/
    mkdir -p ${r_log}
    mkdir -p ${r_save}


    ID=${type}_${population}_${c}
    
    echo ${ID}
  
    job_out=${r_log}variance_crosses_chr_${ID}.out
    
    job_name=${ID}
	    
    job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --time=00:30:00 --parsable ${r_scripts}variance_crosses_chr_3.sh ${base} ${nbcores} ${type} ${population} ${c} ${r_save}) 
    
    echo "${job_out} =" >> ${r_log_value_crosses_variance_crosses}jobs_variance_crosses_chr_${ID}.txt
    echo "${job}" >> ${r_log_value_crosses_variance_crosses}jobs_variance_crosses_chr_${ID}.txt


done


while (( $(squeue -u adanguy | grep -f ${r_log_value_crosses_variance_crosses}jobs_variance_crosses_chr_${ID}.txt | wc -l) >= 1 )) 
do    
    sleep 1s
done

k=0


for c in ${chr[*]}
    do
    
    r_save=${r_value_crosses}variance_crosses/${type}/${population}/${c}/
    ID=${type}_${population}_${chr}

    
    if [ ${k} -eq 0 ]
        then
            
        cat ${r_save}variance_crosses_chr_${ID}.txt > ${output_variance}
            
    else 
        tail -n+2 ${r_save}variance_crosses_chr_${ID}.txt >> ${output_variance}

            
    fi
        
    k=$((k+1))
done


# Inputs
titre_variance_crosses=${output_variance}
titre_lines=${r_value_crosses}lines_filtered_estimated.txt
titre_selection_intensity=${r_prepare}selection_intensity.txt
titre_function_calcul_index_variance_crosses=${r_scripts}calcul_index_variance_crosses.R


motif=$(echo ${type} | sed "s/marker_//g")
grep ${motif} ${titre_lines} | cut -f10 | sort -n | tail -n1
selection_treshold=$(grep ${motif} ${titre_lines} | cut -f10 | sort -n | tail -n1) # best gebv
selection_rate=0.07

# Output
titre_crosses=${output_crosses}


v1=${titre_variance_crosses}
v2=${titre_lines}
v3=${titre_selection_intensity}
v4=${titre_function_calcul_index_variance_crosses}
v5=${selection_treshold}
v6=${selection_rate}
v7=${titre_crosses}

Rscript ${r_scripts}variance_crosses_chr_2.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7}


