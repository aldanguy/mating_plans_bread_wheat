#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
export LC_COLLATE=C
export LC_ALL=C
ulimit -s unlimited
export OMP_STACKSIZE=64M


# change gblup to GBLUP


base=${1}

source ${base}

r=${2}
r_log=${3}
ID=${4}
constraints=${5}
criterion=${6}
titre_criteria_base=${7}
titre_mating_plan_base=${8}
nbcores=${9}
param_GA=${10}
set_phi_file=${11}
set_starting_pop=${12}



echo ${base}
echo ${r}
echo ${r_log}
echo ${ID}
echo ${constraints}
echo ${criterion}
echo ${titre_criteria_base}
echo ${titre_mating_plan_base}
echo ${nbcores}
echo ${param_GA}
echo ${set_phi_file}
echo ${set_starting_pop}

nbcores=2


# Directories

r_optimization_temp=${r}optimization/

mkdir -p ${r_optimization_temp}


cd ${r}

file_jobs=${r0_log_jobs}jobs_${ID}.txt





if [ ${criterion} == "UC3" ] || [ ${criterion} == "EMBV" ] || [ ${PLE} == "lp_solve" ]
then

titre_criteria_prepared=${r_optimization_temp}crosses_${ID}_${constraints}_${criterion}_high_PM_prepared.txt


titre_criteria_input=${titre_criteria_base}.txt
titre_criteria_output=${titre_criteria_prepared}



v1=${titre_criteria_input}
v2=${titre_criteria_output}

Rscript ${r_scripts}prepare_for_optimization_softwares.R ${v1} ${v2} 

fi






    if [ ${optimization_software} == "genetic_algorithm" ] || [ ${criterion} == "UC3" ] || [ ${criterion} == "EMBV" ]
        then
        
        

file_jobs=${r0_log_jobs}jobs_${ID}.txt

        


       # variables
        v1=${base}
        v2=${r}
        v3=${ID}
        v4=${criterion}
        v5=${constraints}
        v6=${nbcores}
        v7=${titre_mating_plan_base}
        v8=${titre_criteria_base}
        v9=${titre_criteria_prepared}
        v10=${param_GA}
        v11=${set_phi_file}
        v12=${r_log}
        v13=${set_starting_pop}

        
     


   
    
   

        echo ${criterion}
        echo "genetic algorithm"

        
        job_out=${r_log}genetic_algorithm_${ID}_${criterion}.out
        
        
        job_name=${criterion}${ID}
        
        
        
        if [ ${criterion} == "UC3" ]
        then
            
        job=$(sbatch -p unlimitq -o ${job_out} -J ${job_name} -c ${nbcores} --mem=10G --parsable ${r_scripts}genetic_algorithm.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13})
        
        else 
        
                job=$(sbatch -p workq -o ${job_out} -J ${job_name} -c ${nbcores} --mem=10G --parsable ${r_scripts}genetic_algorithm.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13})

        fi
        
        echo "${job_out} =" >> ${file_jobs}
        echo "${job}" >> ${file_jobs}

















elif [ ${optimization_software} == "linear_programming" ] && ( [ ${criterion} == "UC1" ] || [ ${criterion} == "UC2" ] || [ ${criterion} == "PROBA" ] || [ ${criterion} == "OHV" ] || [ ${criterion} == "PM" ] )
    then


    
    if [ ${PLE} == "lp_solve" ]
    then



       # variables
         v1=${base}
        v2=${r}
        v3=${ID}
        v4=${criterion}
        v5=${constraints}
        v6=${nbcores}
        v7=${titre_mating_plan_base}
        v8=${titre_criteria_base}

        
     

        echo ${criterion}
        echo "lp solve"

        
        job_out=${r_log}lp_solve_${ID}_${criterion}.out
        
        
        job_name=${criterion}${ID}
        

            
        job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem=10G --parsable ${r_scripts}lp_solve.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9})
        
        echo "${job_out} =" >> ${file_jobs}
        echo "${job}" >> ${file_jobs}


    
    elif [ ${PLE} == "CPLEX" ]
    then
    
    # variables
         v1=${base}
        v2=${r}
        v3=${ID}
        v4=${criterion}
        v5=${constraints}
        v6=${nbcores}
        v7=${titre_mating_plan_base}
        v8=${titre_criteria_base}
        v9=${r_log}
                v10=${param_GA}



        
        

       

        echo ${criterion}
        echo "CPLEX"

        
        job_out=${r_log}CPLEX_${ID}_${criterion}.out
        
        
        job_name=${criterion}${ID}
        

            
        job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem=10G --parsable ${r_scripts}CPLEX.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10})
        
        echo "${job_out} =" >> ${file_jobs}
        echo "${job}" >> ${file_jobs}


    
    
    
    
    fi
    
    fi







date +'%Y-%m-%d-%T'

