#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'

base=${1}




source ${base}


type=${2}
population_variance=${3}
critere=${4}
programme=${5}
progeny=${6}

echo ${type}
echo ${population_variance}
echo ${critere}
echo ${programme}
echo ${progeny}


population_profile=${population_ref}
file_jobs=${r_log_best_crosses_jobs}jobs_best_crosses_2_${type}_${population_variance}_${critere}_${programme}_${progeny}_top.txt


source ${r_scripts}param_cr_${programme}.sh

programme=${programme}_top
test_fitness=FALSE




titre_crosses=${r_value_crosses_crosses}crosses_${type}_${population_variance}.txt
colonne=${critere}
titre_best_crosses_output=${r_best_crosses}best_crosses_${type}_${population_variance}_${critere}_${programme}_${progeny}.txt
titre_best_order_stat=${r_prepare}expected_best_order_statistic.txt


v1=${titre_crosses}
v2=${D}
v3=${Dmax}
v4=${colonne}
v5=${type}
v6=${population_variance}
v7=${programme}
v8=${titre_best_crosses_output}
v9=${progeny}
v10=${titre_best_order_stat}

Rscript ${r_scripts}top_crosses.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10}



cp ${r_prepare}genotyping.txt ${r_best_crosses_genotypes}genotypes_${type}_${population_variance}_${critere}_${programme}_${progeny}.txt
titre_genotyping_input=${r_best_crosses_genotypes}genotypes_${type}_${population_variance}_${critere}_${programme}_${progeny}.txt
titre_best_crosses_input=${r_best_crosses}best_crosses_${type}_${population_variance}_${critere}_${programme}_${progeny}.txt
titre_haplotypes_output=${r_best_crosses_haplotypes}haplotypes_${type}_${population_variance}_${critere}_${programme}_${progeny}.txt

v1=${titre_genotyping_input}
v2=${titre_best_crosses_input}
v3=${titre_haplotypes_output}

Rscript ${r_scripts}convert_geno_to_haplo.R ${v1} ${v2} ${v3}







for rr in $(seq 1 ${nb_run})
do






   
    echo ${rr}
  
    
    job_out=${r_log_best_crosses}best_crosses_2_${type}_${population_variance}_${critere}_${programme}_${progeny}_rr${rr}_${population_profile}.out
    job_name=${rr}
    job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --time=20:00:00 --mem-per-cpu=10G --parsable ${r_scripts}best_crosses_2.sh ${base} ${type} ${population_variance} ${population_profile} ${critere} ${programme} ${rr} ${progeny} )
    echo "${job_out} =" >> ${file_jobs}
    echo "${job}" >> ${file_jobs}





done





date +'%Y-%m-%d-%T'
