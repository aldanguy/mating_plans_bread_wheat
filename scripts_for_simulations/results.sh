#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'



base=${1}



source ${base}


for f in ${r_best_crosses_perf}*.txt
do 

    cat ${f} >> ${r_results}all_perf.txt
done




for f in ${r_best_crosses_lines}*_tbv_*.txt
do 

    cat ${f} >> ${r_results}all_progenies_tbv.txt
done




for f in ${r_best_crosses_lines}lines_tbv_simTRUE_300rand_r1_*gebv*_real_RILsF5*.txt
do 

    cat ${f} >> ${r_results}sample_progenies_tbv.txt
done







k=0
for f in ${r_value_crosses_lines}*tbv*.txt
do 

    if [ ${k} -eq 0 ]
    then

        cat ${f} > ${r_results}parental_lines_tbv.txt
    else
        tail -n+2 ${f} >> ${r_results}parental_lines_tbv.txt
    fi
    
    k=$((${k} +1 ))
    
done







k=0
for f in ${r_best_crosses}best_crosses*.txt
do 

    if [ ${k} -eq 0 ]
    then

        cat ${f} > ${r_results}best_crosses.txt
    else
        tail -n+2 ${f} >> ${r_results}best_crosses.txt
    fi
    
    k=$((${k} +1 ))
    
done





k=0
for f in ${r_value_crosses_crosses}crosses_simTRUE_300rand_r*.txt
do 

    if [ ${k} -eq 0 ]
    then

        cat ${f} > ${r_results}all_crosses.txt
    else
        tail -n+2 ${f} >> ${r_results}all_crosses.txt
    fi
    
    k=$((${k} +1 ))
    
done




titre_progenies_tbv_input=${r_results}all_progenies_tbv.txt
titre_best_progenies_tbv_output=${r_results}best_progenies_tbv.txt
titre_superior_progenies_tbv_output=${r_results}superior_progenies.txt
titre_mean_progenies_tbv_output=${r_results}mean_progenies.txt
titre_parental_lines_tbv_input=${r_results}parental_lines_tbv.txt
titre_best_parental_lines_tbv_output=${r_results}best_parental_lines_tbv.txt
titre_perf_input=${r_results}all_perf.txt
titre_perf_output=${r_results}all_perf2.txt
titre_best_crosses_input=${r_results}best_crosses.txt
titre_best_crosses_output=${r_results}best_crosses2.txt
q=0.07
titre_progenies_sup_best_parent_output=${r_results}progenies_sup_best_parent_tbv.txt
titre_crosses=${r_results}all_crosses.txt

v1=${titre_progenies_tbv_input}
v2=${titre_best_progenies_tbv_output}
v3=${titre_superior_progenies_tbv_output}
v4=${titre_mean_progenies_tbv_output}
v5=${titre_parental_lines_tbv_input}
v6=${titre_best_parental_lines_tbv_output}
v7=${titre_perf_input}
v8=${titre_perf_output}
v9=${titre_best_crosses_input}
v10=${titre_best_crosses_output}
v11=${q}
v12=${titre_progenies_sup_best_parent_output}
v13=${titre_crosses}

Rscript ${r_scripts}extract_results.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13}


rm ${titre_progenies_tbv_input}
rm ${titre_parental_lines_tbv_input}
rm ${titre_best_crosses_input}
rm ${titre_perf_input}




titre_genotyping=${r_prepare}genotyping.txt
titre_markers=${r_prepare}markers_WE.txt
titre_ibs_output=${r_results}IBS.txt

v1=${titre_genotyping}
v2=${titre_markers}
v3=${titre_ibs_output}


#Rscript ${r_scripts}IBS.R ${v1} ${v2} ${v3}



cat ${r_value_crosses_crosses}crosses_simTRUE_300rand_h0.4_r1_gbasic_WE.txt > ${r_results}crosses.txt
tail -n+2 ${r_value_crosses_crosses}crosses_simTRUE_300rand_h0.4_r2_gbasic_WE.txt >> ${r_results}crosses.txt
tail -n+2 ${r_value_crosses_crosses}crosses_simTRUE_300rand_h0.4_r3_gbasic_WE.txt >> ${r_results}crosses.txt
tail -n+2 ${r_value_crosses_crosses}crosses_simTRUE_300rand_r1_WE.txt >> ${r_results}crosses.txt
tail -n+2 ${r_value_crosses_crosses}crosses_simTRUE_300rand_r2_WE.txt >> ${r_results}crosses.txt
tail -n+2 ${r_value_crosses_crosses}crosses_simTRUE_300rand_r3_WE.txt >> ${r_results}crosses.txt



date +'%Y-%m-%d-%T'
