#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'

base=${1}

source ${base}


 base=${1}

source ${base}


r_ref=${2}
ID=${3}
criterion=${4}
constraints=${5}
nbcores=${6}
titre_mating_plan_base=${7}
titre_criteria_base=${8}
r_log=${9}
param_GA=${10}




echo ${base}
echo ${r_ref}
echo ${ID}
echo ${criterion}
echo ${constraints}
echo ${nbcores}
echo ${titre_mating_plan_base}
echo ${titre_criteria_base}
echo ${r_log}
echo ${param_GA}



titre_mating_plan_raw=${r_ref}mating_plan_raw_${ID}_${criterion}_CPLEX.txt

titre_criteria=${titre_criteria_base}.txt

source ${r_scripts}param_GA_${param_GA}.sh

source ${r_scripts}param_${constraints}.sh

if [ ${constraints} == "CONSTRAINTS" ]
then


if [ ${criterion} == "PM" ]
    then
    colonne=$(head ${titre_criteria} -n1 | sed "s/\t/\n/g" | grep -n "PM" | sed "s/:.*//g")
elif  [ ${criterion} == "UC1" ]
    then 
    colonne=$(head ${titre_criteria} -n1 | sed "s/\t/\n/g" | grep -n "UC1" | sed "s/:.*//g")
elif  [ ${criterion} == "PROBA" ]
    then 
    colonne=$(head ${titre_criteria} -n1 | sed "s/\t/\n/g" | grep -n "PROBA" | sed "s/:.*//g")
elif  [ ${criterion} == "UC2" ]
    then 
    colonne=$(head ${titre_criteria} -n1 | sed "s/\t/\n/g" | grep -n "UC2" | sed "s/:.*//g")
elif  [ ${criterion} == "OHV" ]
    then 
    colonne=$(head ${titre_criteria} -n1 | sed "s/\t/\n/g" | grep -n "OHV" | sed "s/:.*//g")
fi
    
  
    
    titre_mating_plan_raw=${titre_mating_plan_raw}
    titre_criteria=${titre_criteria}
    titre_path_cplex="/work/degivry/CPLEX_Studio128/cplex/python/3.6/x86-64_linux/cplex/__init__.py"
    #nbcores=1


    v1=${colonne}
    v2=${titre_mating_plan_raw}
    v3=${titre_criteria}
    v4=${titre_path_cplex}
    v5=${D}
    v6=${Dmax}
    v7=${Dmin}
    v8=${Pmax}
    v9=${Pmin}
    v10=${Kmax}
    v11=${Kmin}
    v12=${Cmax}
    v13=${nbcores}
    v14=${criterion}

    SECONDS=0
    python ${r_scripts}CPLEX.py ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} > ${r_log}CPLEX_screen_${ID}_${criterion}.txt
    time=${SECONDS}

   

    v1=${titre_mating_plan_raw}
    v2=${titre_criteria}
    v3=${criterion}
    v4=${titre_mating_plan_base}${criterion}.txt
    


    Rscript ${r_scripts}after_CPLEX.R ${v1} ${v2} ${v3} ${v4} 
    
    
    ligne=$(cat ${r_log}CPLEX_screen_${ID}_${criterion}.txt | grep -n "fitness value" | sed "s/:.*//g")
    ligne2=$(( ${ligne} +1 ))
    fitness=$(head -n${ligne2} ${r_log}CPLEX_screen_${ID}_${criterion}.txt| tail -n1)
    titre_output=${r_ref}perf_${ID}_${criterion}_CPLEX.txt
    
    nb_crosses=$( cat ${titre_criteria} | wc -l )
    nb_crosses_tot=$( cat ${titre_criteria_base}_no_filter.txt | wc -l )
    
    

     v1=CPLEX
    v2=${ID}
    v3=${fitness}
    v4=${titre_output}
    v5=${criterion}
    v6=${constraints}
    v7=${time}
    v8=${seed}
    v9=${nb_crosses}
    v10=${nb_crosses_tot}





    Rscript ${r_scripts}perf.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10}
    
    
    

rm ${titre_mating_plan_raw}


elif [ ${constraints} == "NO_CONSTRAINTS" ]
then


titre_criteria_input=${titre_criteria_base}.txt
titre_mating_plan_output=${titre_mating_plan_base}${criterion}.txt


v1=${titre_criteria_input}
v2=${criterion}
v3=${D}
v4=${Dmax}
v5=${titre_mating_plan_output}

    Rscript ${r_scripts}mating_plan_NO_CONSTRAINTS.R ${v1} ${v2} ${v3} ${v4} ${v5} 


fi



date +'%Y-%m-%d-%T'
