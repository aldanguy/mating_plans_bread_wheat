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



echo ${base}
echo ${r_ref}
echo ${ID}
echo ${criterion}
echo ${constraints}
echo ${nbcores}
echo ${titre_mating_plan_base}
echo ${titre_criteria_base}
echo ${titre_criteria_prepared}



r_analysis=${r_ref}${ID}_${criterion}/
output_dir=${ID}_${criterion}
config_file=config_${ID}_${criterion}.cfg
titre_mating_plan_raw=${r_ref}mating_plan_raw_${ID}_${criterion}_lpsolve.txt



source ${r_scripts}param_${constraints}.sh

titre_criteria_prepared_for_opti=$(echo ${titre_criteria_prepared} | sed "s|^.*/||g")


set_phi_constraints=NA
set_phi_file=NA
set_starting_pop=NA
set_starting_pop_file=NA

    

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


cd ${r}

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
sed -i "s|set_phimax|0|g" ${config_file}





${r_analysis}genetic_algorithm/DANGUY/lpcreate -c ${config_file} # create alice.lp in ${r_genetic_algorithm}

lp_solve alice.lp > ${titre_mating_plan_raw}

titre_mating_plan_lpsolve_input=${titre_mating_plan_raw}
titre_criteria_input=${titre_criteria_base}.txt
#model_name=${model_name}
titre_mating_plan_output=${titre_mating_plan_base}${criterion}.txt






v1=${titre_mating_plan_lpsolve_input}
v2=${titre_criteria_input}
v3=${criterion}
v4=${titre_mating_plan_output}


Rscript ${r_scripts}after_lp_solve.R ${v1} ${v2} ${v3} ${v4} 



cd ${r0}

rm -rf ${r_analysis}
trm -rf ${ritre_mating_plan_raw}





date +'%Y-%m-%d-%T'
