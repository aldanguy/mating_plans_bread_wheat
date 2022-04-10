#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
export LC_COLLATE=C
export LC_ALL=C
ulimit -s unlimited
export OMP_STACKSIZE=64M









base=${1}





source ${base}


file_jobs=${r0_log_jobs}accuracy.txt

r=${r_big_files}article/accuracy/
r_log=${r0_log}accuracy/

mkdir -p ${r}
mkdir -p ${r_log}

populations=(selected unselected)

for population in ${populations[*]}
do

    for population_ID in $(seq 1 ${nb_simulations})
    do
    
  


            job_out=${r_log}accuracy2_${population}${population_ID}.out


            job_name=${population}${population_ID}
            
            


                v1=${base}
                v2=${population}
                v3=${population_ID}
                v4=${r}
                v5=${r_log}



            job=$(sbatch -o ${job_out} -J ${job_name} --mem=3G --parsable ${r_scripts}accuracy2.sh ${v1} ${v2} ${v3} ${v4} ${v5} )

            echo "${job_out} =" >> ${file_jobs}
            echo "${job}" >> ${file_jobs}
            
            
         
          


    
    
        done
done

echo "end"


jobs_all=${r0}all_jobs.txt
cat ${r0_log_jobs}* > ${jobs_all}




sed -i '/^$/d' ${jobs_all}
while (( $(squeue -u adanguy | grep -f ${jobs_all} | wc -l) >= 1 )) 
do    
    sleep 1m
    cat ${r0_log_jobs}* > ${jobs_all}
    sed -i '/^$/d' ${jobs_all}
    echo ${wait}
done
            
            
k=0

for f in ${r}accuracy_sd_*
do

    echo ${f}


    if [ ${k} -eq 0 ]
    then
    
    cat ${f} > ${r}accuracy_sd.txt
    
    else
    
    tail -n+2 ${f} >> ${r}accuracy_sd.txt
    
    
    fi
    
    k=$((${k}+1))
        #rm ${f}

    
done



k=0

for f in ${r}ratio_*
do

    echo ${f}


    if [ ${k} -eq 0 ]
    then
    
    cat ${f} > ${r}ratio.txt
    
    else
    
    tail -n+2 ${f} >> ${r}ratio.txt

    
    fi
    
    k=$((${k}+1))
        #rm ${f}

    
done


k=0

for f in ${r}correlations_*
do
    
    echo ${f}

    if [ ${k} -eq 0 ]
    then
    
    cat ${f} > ${r}correlations.txt
    
    else
    
    tail -n+2 ${f} >> ${r}correlations.txt

    
    fi
    
    k=$((${k}+1))
        #rm ${f}

    
done

titre_ratio=${r}ratio.txt

titre_accuracy=${r}accuracy_sd.txt
titre_bias_output=${r_results}bias.txt
titre_ratio_output=${r_results}ratio.txt
titre_correlations_input=${r}correlations.txt
titre_correlations_output=${r_results}correlations.txt



v1=${titre_ratio}
v2=${titre_accuracy}
v3=${titre_bias_output}
v4=${titre_ratio_output}
v5=${titre_correlations_input}
v6=${titre_correlations_output}
Rscript ${r_scripts}average_ratio_accuracy.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6}


rm ${r}ratio.txt
rm ${r}accuracy_sd.txt
rm ${r}correlations.txt

date +'%Y-%m-%d-%T'

