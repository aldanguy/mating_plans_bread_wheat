#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
export LC_COLLATE=C
export LC_ALL=C
ulimit -s unlimited
export OMP_STACKSIZE=64M









base=${1}

source ${base}


ID=${2}
population=${3}

echo ${base}
echo ${ID}
echo ${population}



if [ ${population} == "unselected" ]
then

    titre_ldak_used=${titre_LDAK0}

elif [ ${population} == "selected" ]
then

    titre_ldak_used=${r_big_files}article/parents/LDAK_${ID}.txt
fi


for criterion1 in ${criteria[*]}
do

    for criterion2 in ${criteria[*]}
    do


titre_LDAK_input=${titre_ldak_used}
titre_mating_plan1_input=${r_big_files}article/optimization/mating_plan_${ID}_${criterion1}.txt
titre_mating_plan2_input=${r_big_files}article/optimization/mating_plan_${ID}_${criterion2}.txt
titre_similarity_output=${r_big_files}article/similarity_mating_plans/similarity_${ID}_${criterion1}_${criterion2}.txt



v1=${titre_LDAK_input}
v2=${titre_mating_plan1_input}
v3=${titre_mating_plan2_input}
v4=${criterion1}
v5=${criterion2}
v6=${titre_similarity_output}


Rscript ${r_scripts}similarity_mating_plans.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6}


done

done




date +'%Y-%m-%d-%T'

