#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
export LC_COLLATE=C
export LC_ALL=C
ulimit -s unlimited
export OMP_STACKSIZE=64M









base=${1}

source ${base}

file_jobs=${r0_log_jobs}decrease_variance.txt

r=${r_big_files}article/decrease_variance/

mkdir -p ${r}





    
    for population_ID in $(seq 1 ${nb_simulations})
    do
    
    
    
    titre_parents_unselected=${r_big_files}article/parents/TBV_first_generation_sTRUE_iTRUE_q300rand_hNA_gNA_pselected_n${population_ID}_mWE_CONSTRAINTS.txt
    titre_parents_selected=${r_big_files}article/parents/TBV_last_generation_sTRUE_iTRUE_q300rand_hNA_gNA_pselected_n${population_ID}_mWE_CONSTRAINTS.txt
    titre_output=${r}decrease_variance_n${population_ID}.txt
    
    

v1=${titre_parents_unselected}
v2=${titre_parents_selected}
v3=${titre_output}


Rscript ${r_scripts}decrease_variance1.R ${v1} ${v2} ${v3}








           
            
            
            
            done
            
            
            
      


           
k=0

for f in ${r}decrease_variance_*
do

    if [ ${k} -eq 0 ]
    then
    
    cat ${f} > ${r}decrease_variance.txt
    
    else
    
    tail -n+2 ${f} >> ${r}decrease_variance.txt
    
    
    fi
    
    k=$((${k}+1))
        #rm ${f}

    
done

     


titre_input=${r}decrease_variance.txt

titre_output=${r_results}decrease_variance.txt


v1=${titre_input}
v2=${titre_output}


Rscript ${r_scripts}decrease_variance2.R ${v1} ${v2}


rm ${r}decrease_variance.txt



date +'%Y-%m-%d-%T'

