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
optimization=${7}
test_fitness=${8}


echo ${type}
echo ${population_variance}
echo ${critere}
echo ${programme}
echo ${progeny}
echo ${optimization}
echo ${test_fitness}

population_profile=${population_ref}


source ${r_scripts}param_cr_${programme}.sh


file_jobs=${r_log_best_crosses_jobs}jobs_best_crosses_2_${type}_${population_variance}_${critere}_${programme}.txt




                                    






titre_crosses=${r_value_crosses_crosses}crosses_${type}_${population_variance}.txt

# Pmax=${Pmax}
# Kmax=${Kmax}
# Cmax=${Cmax}
# Kmin=${Kmin}
# critere=${critere}
titre_crosses_filtered=${r_best_crosses}crosses_filtered_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.txt




v1=${titre_crosses}
v2=${Pmax}
v2=50000000
v3=${Kmax}
v3=50000000
v4=${Cmax}
v4=50000000
v5=${Kmin}
v5=50000000
v6=${critere}
v7=${titre_crosses_filtered}
v8=${progeny}


Rscript ${r_scripts}pre_filter_crosses.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8}



if [ ${critere} == "gebv" ]
    then
    model=1
elif [ ${critere} == "logw" ]
    then
    model=2
elif [ ${critere} == "embv" ]
    then
    model=3
elif [ ${critere} == "uc" ]
    then
    model=4
elif [ ${critere} == "topq" ]
    then
    model=7
elif [ ${critere} == "uc_extreme" ]
    then
    model=9
fi



cp ${r_scripts}config.cfg ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.cfg

q=0.07



sed -i "s|precise_file|${titre_crosses_filtered}|g" ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.cfg
sed -i "s|precise_model|${model}|g" ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.cfg
sed -i "s|precise_Dtot|${D}|g" ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.cfg
sed -i "s|precise_Dmax|${Dmax}|g" ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.cfg
sed -i "s|precise_Dmin|${Dmin}|g" ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.cfg
sed -i "s|precise_Kmin|${Kmin}|g" ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.cfg
sed -i "s|precise_Kmax|${Kmax}|g" ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.cfg
sed -i "s|precise_Cmax|${Cmax}|g" ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.cfg
sed -i "s|precise_Pmin|${Pmin}|g" ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.cfg
sed -i "s|precise_Pmax|${Pmax}|g" ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.cfg
sed -i "s|precise_qtop|${q}|g" ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.cfg
sed -i "s|precise_outputdir|${r_best_crosses}${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}/AG_results/|g" ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.cfg


rm -rf ${r_best_crosses}${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}/AG_results/
mkdir -p ${r_best_crosses}${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}/AG_results/

cp -r /work/adanguy/AG/ ${r_best_crosses}${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}

cd ${r_best_crosses}${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}/AG/DANGUY/


cp ${titre_crosses_filtered} .




if [ ${critere} == "gebv" ] || [ ${critere} == "uc" ] || [ ${critere} == "uc_extreme" ] || [ ${critere} == "logw" ] && [ ${optimization} == "PLE" ] 


then
echo "CPLEX"


<<COMMENTS

./lpcreate -c ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}.cfg

date +'%Y-%m-%d-%T'
lp_solve alice.lp > ${r_best_crosses}${type}_${population_variance}_${critere}_${programme}_${progeny}/AG/DANGUY/results.txt
date +'%Y-%m-%d-%T'

grep "x" ${r_best_crosses}${type}_${population_variance}_${critere}_${programme}_${progeny}/AG/DANGUY/results.txt | sed "s/ /;/g" | sed "s/^.*;//g" > ${r_best_crosses}${type}_${population_variance}_${critere}_${programme}_${progeny}/AG/DANGUY/best_crosses.txt



titre_best_crosses_lpsolve_input=${r_best_crosses}${type}_${population_variance}_${critere}_${programme}_${progeny}/AG/DANGUY/best_crosses.txt
titre_best_crosses_output=${r_best_crosses}best_crosses_${type}_${population_variance}_${critere}_${programme}_${progeny}.txt


v1=${titre_best_crosses_lpsolve_input}
v2=${titre_crosses_filtered}
v3=${type}
v4=${population_variance}
v5=${critere}
v6=${programme}
v7=${titre_best_crosses_output}
v8=${progeny}

Rscript ${r_scripts}after_lpsolve.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8}


rm ${titre_crosses_filtered}
rm ${titre_best_crosses_lpsolve_input}

COMMENTS



# numero of column in input (3 = u, 5= log_w, 6=UC)
# path of output
titre_best_crosses_cplex=${r_best_crosses}crosses_filtered_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}_raw.txt

# path of input

# path of cplex programm
# titre_path_cplex="/work/degivry/CPLEX_Studio128/cplex/python/3.6/x86-64_linux/cplex/__init__.py"
# variables


if [ ${critere} != "uc" ]
then

    colonne=$(head ${titre_crosses_filtered} -n1 | sed "s/\t/\n/g" | grep -n ${critere} | sed "s/:.*//g")
elif  [ ${critere} == "uc" ]
    then 
    colonne=$(head ${titre_crosses_filtered} -n1 | sed "s/\t/\n/g" | grep -v "extreme" | grep -n ${critere} | sed "s/:.*//g")
fi


v1=${colonne}
v2=${titre_best_crosses_cplex}
v3=${titre_crosses_filtered}
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
v14=${critere}

SECONDS=0
python ${r_scripts}choose_crosses_update.py ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14} >${r_log_best_crosses}crosses_${type}_${population_variance}_${critere}_${programme}_${progeny}_cplex_output.txt
time=${SECONDS}


ligne=$(cat ${r_log_best_crosses}crosses_${type}_${population_variance}_${critere}_${programme}_${progeny}_cplex_output.txt | grep -n "fitness value" | sed "s/:.*//g")
ligne2=$(( ${ligne} +1 ))


fitness=NA
fitness=$(head -n${ligne2} ${r_log_best_crosses}crosses_${type}_${population_variance}_${critere}_${programme}_${progeny}_cplex_output.txt | tail -n1)
optimization2=CPLEX
gen=NA




if [ ${test_fitness} == "FALSE" ]
then

# titre_best_crosses_cplex=${r}best_crosses_${critere}_raw.txt
titre_best_crosses_output=${r_best_crosses}best_crosses_${type}_${population_variance}_${critere}_${programme}_${progeny}.txt



v1=${titre_best_crosses_cplex}
v2=${titre_best_crosses_output}
v3=${type}
v4=${population_variance}
v5=${critere}
v6=${programme}
v7=${progeny}


Rscript ${r_scripts}after_cplex.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7}

rm ${titre_best_crosses_cplex}
#rm ${r_log_best_crosses}crosses_${type}_${population_variance}_${critere}_${programme}_${progeny}_cplex_output.txt

fi




# elif [ ${critere} == "embv" ] || [ ${critere} == "topq" ] || [ ${critere} == "gebv" ] || [ ${critere} == "logw" ] || [ ${critere} == "uc" ] || [ ${critere} == "uc_extreme" ]

# elif [ ${critere} == "embv" ] || [ ${critere} == "topq" ] || [ ${critere} == "logw" ] || [ ${optimization} == "GA" ]
elif [ ${critere} == "embv" ] || [ ${critere} == "topq" ] || [ ${optimization} == "GA" ]


then
echo "GA"





SECONDS=0
./test.opt -c ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.cfg > ${r_log_best_crosses}crosses_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}_AG_output.txt
time=${SECONDS}




fitness=NA

colonne=$(( ${model} +1 ))
fitness=$(tail -n1 ${r_best_crosses}${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}/AG_results/evolution${model}.csv | cut -f${colonne} -d",")
gen=$(tail -n1 ${r_best_crosses}${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}/AG_results/evolution${model}.csv | cut -f1 -d",")
optimization2=GA
echo ${gen}






if [ ${test_fitness} == "FALSE" ]
then

titre_best_crosses_AG=${r_best_crosses}${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}/AG_results/resag${model}.csv
titre_evolution=${r_best_crosses}${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}/AG_results/evolution${model}.csv
titre_best_crosses_output=${r_best_crosses}best_crosses_${type}_${population_variance}_${critere}_${programme}_${progeny}.txt
evolution_graph=${r_graphs}AG_${type}_${population_variance}_${critere}_${programme}_${progeny}.png

v1=${titre_best_crosses_AG}
v2=${titre_best_crosses_output}
v3=${type}
v4=${population_variance}
v5=${critere}
v6=${programme}
v7=${titre_evolution}
v8=${evolution_graph}
v9=${model}
v10=${progeny}




Rscript ${r_scripts}after_ga.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10}



fi

cd ${r_best_crosses}
rm -rf ${r_best_crosses}${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}/AG_results/
#rm ${r_log_best_crosses}crosses_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}_AG_output.txt

fi

cd ${r_best_crosses}
rm -rf ${r_best_crosses}${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}/
rm ${titre_crosses_filtered}
rm ${r_log_best_crosses}config_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization}.cfg




titre_output=${r_best_crosses_perf}perf_${type}_${population_variance}_${critere}_${programme}_${progeny}_${optimization2}.txt



v1=${type}
v2=${critere}
v3=${programme}
v4=${population_variance}
v5=${progeny}
v6=${optimization2}
v7=${fitness}
v8=${time}
v9=${gen}
v10=${titre_output}

Rscript ${r_scripts}perf.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10}


if [ ${test_fitness} == "FALSE" ]
then

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
    job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --time=20:00:00 --mem-per-cpu=10G --parsable ${r_scripts}best_crosses_2.sh ${base} ${type} ${population_variance} ${population_profile} ${critere} ${programme} ${rr} ${progeny})
    echo "${job_out} =" >> ${file_jobs}
    echo "${job}" >> ${file_jobs}





done


fi




date +'%Y-%m-%d-%T'
