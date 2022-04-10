#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'



base=${1}
source ${base}


echo ${base}



k=0
for f in ${r_big_files}article/progeny/*_selection_rate_temp4.txt
do

echo ${f}

 if [ ${k} -eq 0 ]
 then

    cat ${f} > ${r_big_files}article/progeny/selection_rate_temp5.txt

 else
 
 tail -n+2 ${f} >> ${r_big_files}article/progeny/selection_rate_temp5.txt
 
 fi
 
 k=$((${k}+1))
#rm ${f}

done


k=0
for f in ${r_big_files}article/progeny/*_diversity_temp4.txt
do

echo ${f}

 if [ ${k} -eq 0 ]
 then

    cat ${f} > ${r_big_files}article/progeny/diversity_temp5.txt

 else
 
 tail -n+2 ${f} >> ${r_big_files}article/progeny/diversity_temp5.txt

 
 fi
 
 k=$((${k}+1))
#rm ${f}

done



k=0
for f in ${r_big_files}article/progeny/*_gain_temp4.txt
do

echo ${f}

 if [ ${k} -eq 0 ]
 then

    cat ${f} > ${r_big_files}article/progeny/gain_temp5.txt


 else
 
 tail -n+2 ${f} >> ${r_big_files}article/progeny/gain_temp5.txt
 
 fi
 
 k=$((${k}+1))
#rm ${f}

done




titre_sel_rate_input=${r_big_files}article/progeny/selection_rate_temp5.txt
titre_gain_input=${r_big_files}article/progeny/gain_temp5.txt
titre_diversity_input=${r_big_files}article/progeny/diversity_temp5.txt
titre_selection_rate_output=${r_results}selection_rate.txt
titre_diversity_output=${r_results}diversity.txt
titre_gain_output=${r_results}gain.txt
titre_impact_constraints_output=${r_results}impact_constraints.txt


v1=${titre_sel_rate_input}
v2=${titre_gain_input}
v3=${titre_diversity_input}
v4=${titre_selection_rate_output}
v5=${titre_diversity_output}
v6=${titre_gain_output}
v7=${titre_impact_constraints_output}

 Rscript ${r_scripts}analyse_gain3.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7}
 
 
rm ${r_big_files}article/progeny/selection_rate_temp5.txt
rm ${r_big_files}article/progeny/gain_temp5.txt
rm ${r_big_files}article/progeny/diversity_temp5.txt


date +'%Y-%m-%d-%T'
