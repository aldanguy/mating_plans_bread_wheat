#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'

base=${1}

source ${base}


r_ref=${2}
ID=${3}
criterion=${4}
constraints=${5}
nbcores=${6}
titre_mating_plan_base=${7}
titre_criteria_base=${8}
titre_criteria_prepared=${9}
param_GA=${10}
set_phi_file=${11}
r_log=${12}
set_starting_pop=${13}




echo ${base}
echo ${r_ref}
echo ${ID}
echo ${criterion}
echo ${constraints}
echo ${nbcores}
echo ${titre_mating_plan_base}
echo ${titre_criteria_base}
echo ${titre_criteria_prepared}
echo ${param_GA}
echo ${set_phi_file}
echo ${r_log}
echo ${set_starting_pop}

nbcores=2


titre_fitness_graph=${r0_graphs}fitness_GA_${ID}_${criterion}_${param_GA}.png




r_analysis=${r_ref}${ID}_${criterion}_GA/
output_dir=${ID}_${criterion}
config_file=config_${ID}_${criterion}.cfg
log_GA=${r_log}GA_${ID}_${criterion}.out



source ${r_scripts}param_${constraints}.sh
source ${r_scripts}param_GA_${param_GA}_${criterion}.sh

if [ ${constraints} == "CONSTRAINTS" ] || [ ${criterion} == "UC3" ]
then



titre_criteria_prepared_for_opti=$(echo ${titre_criteria_prepared} | sed "s|^.*/||g")

    

if [ ${criterion} == "PM" ]
then
model_number=1
elif [ ${criterion} == "PROBA" ]
then
model_number=2
elif [ ${criterion} == "EMBV" ]
then
model_number=3
elif [ ${criterion} == "UC1" ]
then
model_number=4
elif [ ${criterion} == "UC3" ]
then
model_number=7
elif [ ${criterion} == "UC2" ]
then
model_number=9
fi


if [ ${sharing_used} == "TRUE" ]
then
sharing=0.9
elif [ ${sharing_used} == "FALSE" ]
then
sharing=0
fi




if [ -d "${r_analysis}" ]
then
    rm -rf ${r_analysis}
fi
mkdir -p ${r_analysis}

cd ${r_analysis}

cp ${r_genetic_algorithm_0} ${r_analysis}

unzip ${r_analysis}GA.zip

cd ${r_analysis}genetic_algorithm/


make

cd ${r_analysis}genetic_algorithm/DANGUY/

make


cp ${titre_criteria_prepared} ${r_analysis}genetic_algorithm/DANGUY/${titre_criteria_prepared_for_opti}
cp ${titre_selection_intensity} ${r_analysis}genetic_algorithm/DANGUY/tab3_selection_intensity.txt
cp ${titre_best_order_statistic} ${r_analysis}genetic_algorithm/DANGUY/tab2_expected_best_order_statistic.txt


cp ${r_scripts}config_optimization_softwares.cfg ${r_analysis}genetic_algorithm/DANGUY/${config_file}
sed -i "s|set_model|${model_number}|g" ${config_file}
sed -i "s|set_Dtot|${D}|g" ${config_file}
sed -i "s|set_Dmax|${Dmax}|g" ${config_file}
sed -i "s|set_Dmin|${Dmin}|g" ${config_file}
sed -i "s|set_Kmin|${Kmin}|g" ${config_file}
sed -i "s|set_Kmax|${Kmax}|g" ${config_file}
sed -i "s|set_Cmax|${Cmax}|g" ${config_file}
sed -i "s|set_Pmin|${Pmin}|g" ${config_file}
sed -i "s|set_Pmax|${Pmax}|g" ${config_file}
sed -i "s|selection_rate_UC3|${selection_rate_for_UC3}|g" ${config_file}
sed -i "s|set_file|${titre_criteria_prepared_for_opti}|g" ${config_file}
sed -i "s|set_outputdir|${output_dir}|g" ${config_file}
sed -i "s|set_phi_constraints|${set_phi_constraints}|g" ${config_file}
sed -i "s|set_phi_file|${set_phi_file}|g" ${config_file}
sed -i "s|set_starting_pop_true|${set_starting_pop}|g" ${config_file}
sed -i "s|set_starting_pop_file|example_file.txt|g" ${config_file}
sed -i "s|set_phimax|${phimax}|g" ${config_file}




cp ${r_scripts}general.cfg ${r_analysis}genetic_algorithm/DANGUY/
sed -i "s|nb_generations_ga|${nb_generations_ga}|g" ${r_analysis}genetic_algorithm/DANGUY/general.cfg
sed -i "s|set_seed|${seed}|g" ${r_analysis}genetic_algorithm/DANGUY/general.cfg
sed -i "s|set_sharing|${sharing}|g" ${r_analysis}genetic_algorithm/DANGUY/general.cfg



if [ ${set_starting_pop} == "true" ]
then

    if [ ${criterion} == "UC3" ]
    then

    set_starting_pop_file=${titre_mating_plan_base}PROBA.txt
    
    elif [ ${criterion} == "EMBV" ]
    then

    set_starting_pop_file=${titre_mating_plan_base}UC1.txt
    
    fi


    while [ ! -f "${set_starting_pop_file}" ] 
    do
    
    echo "Waiting for starting pop file  ${set_starting_pop_file}"

    sleep 1m
    
    done
    
    echo -e "P1\tP2\tdij" >  ${r_analysis}genetic_algorithm/DANGUY/example_file.txt
    
    if [ ${constraints} == "CONSTRAINTS" ]
    then

    colonne_P1=$(head ${set_starting_pop_file} -n1 | sed "s/\t/\n/g" | grep -n "P1" | sed "s/:.*//g")
    colonne_P2=$(head ${set_starting_pop_file} -n1 | sed "s/\t/\n/g" | grep -n "P2" | sed "s/:.*//g")
    colonne_nbprogeny=$(head ${set_starting_pop_file} -n1 | sed "s/\t/\n/g" | grep -n "nbprogeny" | sed "s/:.*//g")
    cut -f${colonne_P1},${colonne_P2},${colonne_nbprogeny} ${set_starting_pop_file} | tail -n+2 >> ${r_analysis}genetic_algorithm/DANGUY/example_file.txt
    
    elif [ ${constraints} == "NO_CONSTRAINTS" ]
    then
    
     colonne_P1=$(head ${set_starting_pop_file} -n1 | sed "s/ /\n/g" | grep -n "P1" | sed "s/:.*//g")
    colonne_P2=$(head ${set_starting_pop_file} -n1 | sed "s/ /\n/g" | grep -n "P2" | sed "s/:.*//g")
    colonne_nbprogeny=$(head ${set_starting_pop_file} -n1 | sed "s/ /\n/g" | grep -n "nbprogeny" | sed "s/:.*//g")
    cut -f${colonne_P1},${colonne_P2},${colonne_nbprogeny} ${set_starting_pop_file} -d" " | tail -n+2 >> ${r_analysis}genetic_algorithm/DANGUY/example_file.txt
    fi
    

fi


    SECONDS=0

${r_analysis}genetic_algorithm/DANGUY/test.opt -c ${config_file} >${log_GA}
    time=${SECONDS}



titre_mating_plan_ga_input=${r_analysis}genetic_algorithm/DANGUY/${output_dir}/resag${model_number}.csv
titre_fitness_evolution_ga_input=${r_analysis}genetic_algorithm/DANGUY/${output_dir}/evolution${model_number}.csv
titre_criteria_input=${titre_criteria_base}.txt
titre_mating_plan_output=${titre_mating_plan_base}${criterion}.txt
titre_fitness_graph_output=${titre_fitness_graph}



v1=${titre_mating_plan_ga_input}
v2=${titre_fitness_evolution_ga_input}
v3=${titre_criteria_input}
v4=${criterion}
v5=${titre_mating_plan_output}
v6=${titre_fitness_graph_output}
v7=${model_number}

Rscript ${r_scripts}after_genetic_algorithm.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} 


colonne=$(( ${model_number} +1 ))
fitness=$(tail -n1 ${r_analysis}genetic_algorithm/DANGUY/${output_dir}/evolution${model_number}.csv | cut -f${colonne} -d",")
titre_output=${r_ref}perf_${ID}_${criterion}_GA.txt
    
    
   nb_crosses=$( cat ${titre_criteria_base}.txt | wc -l )
    nb_crosses_tot=$( cat ${titre_criteria_base}_no_filter.txt | wc -l )
    
    
  
    
     v1=GA
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
    
    


cd ${r0}


rm -rf ${r_analysis}



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
