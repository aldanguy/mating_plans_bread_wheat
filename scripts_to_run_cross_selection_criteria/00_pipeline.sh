#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
ulimit -s unlimited
export OMP_STACKSIZE=64M
export LC_COLLATE=C
export LC_ALL=C



####################### Parameters

# specify type of progeny (RILs or DHs)
progeny=RILsF5 
# Fx specify the number of generations. If progeny are DHs, type DHsF1 (chromosome doubling from F1 gametes) or DHsF2 (doubling from F2 gametes)...





D=3300 # total number of progenies
Dmax=60 # max progenies per cross
Dmin=5 # min progeny per cross. If not interested, set it to Dmax
Kmin=200 # min number of cross. If not interested, set to Kmax or 0
Kmax=300 # max number of cross
Cmax=250 # max progenies per parent. If not interested, set to D
Pmin=100 # min number of parent. If not interested set to Pmin or 0
Pmax=132 # max number of parents.




modele_name=expected_progeny
# can choose between:
# PM: expected_progeny = optimize mating plan to maximize expected mean of progeny
# PROBA: superior_to_treshold = optimize mating plan to maximize the expected number of progeny of w=genetic value superior to a treshold
# EMBV = optimize mating plan by allocating more progeny to crosses showing higest best possible progeny
# UC1: uc = optimize mating plan by allocating more progeny to crosses with higest expected mean of their q% best progeny
# UC2: uc_extreme = similar, but focus on more extreme progeny
# UC3: expected_q_best_progeny = optimize mating plan to maximize expected mean of the q% best progeny of the whole mating plan


within_family_selection_rate=0.07 # to compute UC = expected mean of q% best progeny per family


within_family_selection_rate_extreme=0.0001 # to compute UC extreme


q=${within_family_selection_rate} # to maximise expected mean of q% of best progeny of the whole mating mating

nb_generations_ga=20000 # should vary to check that genetic algorithm reach optimum

optimization_software=genetic_algorithm
# can choose between genetic_algorithm or linear_programming
# genetic algorithm is available for all models, but linear_programming is not available for EMBV and expected_q_best_progeny




####################### Directories





# main directory
r=/home/enter_your_path/

# directory where sources files must be stored
r_amont=${r}amont/
# repository "amont" is included in repository "r". 


# directory where results files will be stored
r_results=${r}results/
mkdir -p ${r_results}
mkdir -p ${r_results}big_files/


# directory where scripts must be stored
r_scripts=${r}scripts/
# repository "scripts" is included in repository "r".
# Should contain all scripts (from 00 to 13) + general.cfg + config_optimization_softwares.cfg


# directory where raw genetic algorithm results will be stored
r_genetic_algorithm=${r}genetic_algorithm/user/
# repository "genetic_algorithm" is included in repository "r".
# Should contain genetic_algorithm (including a subfolder named user)











cd ${r_results}


############### STEP 1 : provide files for computation of usefulness criterias



### Description of output files
# These files are needed to launch STEP 2.
# Examples are given in the input_files_examples folder

# 1 : genotyping data of parents
# description of file :
# overall : one row = one parental line, one column = genotype at one marker
# col n°1 : header = "ID" , value = name of parental line (string, ex: AO07403_XXX00000000000000000)
# col n°2-end : headers = name of markers (ex: "AX-89695177"), value = allelic dosage of alternativ allele (integer, 0, 1, 2). 
# rows should be sorted according ID column
# columns 2-end should be sorted by chromosome order and then following genetic map order. This is very important.
# All parental lines present in this file should also be in correspondance_ID data
# Dimensions without headers : nrows = nb parental lines * ncols =  (nb markers +1)
# A small exemple of data is given in the file genotypingf.txt 
# No missing value

# 2 : markers data
# description of file :
# overall : one row = description of one marker
# col n°1 : header = "chr" , value = number of chr (string, ex: 1A)
# col n°2 : header = "marker", value = name of markers (string, ex: "AX-89695177")
# col n°3 : header = "dcum", value = position on genetic map, in cumulated centimorgans (numeric, mainly comprised between 0 and 300).
# col n°4 : header = "value", value = allelic subsitution effect on phenotype (numeric) after genomic prediction model
# rows should be sorted by chromosome order and then following genetic map order. This is very important.
# Dimensions : nb markers * 4
# A small exemple of data is given in the file markersf.txt
# No missing value

# 3 : parental breeding value data 
# description of file : 
# overall : one row = one parental line
# col n°1 : header = "ID", value = name of the parental line (string, ex: AO07403_XXX00000000000000000)
# col n°2 : header = "value", value = parental breeding value estimate (numeric).
# All parental lines present in this file should also be in genotyping data (same order).
# Dimensions : nb crosses * 2
# A small exemple of data is given in the file breeding_values.txt
# No missing value


# All files should have tab separator between columns, points to indicate float (ex : 1.2), headers, but no row numbers and no quotes.



############### STEP 2 : compute usefulness criteria

### Output file: computation of usefulness criteria for each cross
# description of file : 
# overall : one row = one cross
# col n°1 : header = "P1", value = name of the first parental line of the cross (string, ex: AO07403_XXX00000000000000000)
# col n°2 : header = "P2", value = name of the second parental line of the cross (string). Alphabetical order of P1 < P2
# col n°3 : header = "sd_progeny", value = predicted sd of breeding values of progeny (numeric, >= 0). Depends on the type of progeny (RILs, DH) and the number of selfing generations
# col n°4 : header = "expcted_progeny", value = expected value of progeny breeding value (numeric)
# col n°5 : header = "proba_lower_treshold", value = log10 of the probability to produce a progeny of genetic value <= a treshold (numeric, <=0)
# col n°6 : header = "uc", value = expected value of the "within_family_selection_rate" best progeny per family (numeric)
# col n°7 : header = "uc_extreme", value = expected value of the "within_family_selection_rate_extreme" best progeny per family (numeric)
# Dimensions : nb crosses * 7
# A small exemple of data is given in the file criteria.txt
# No missing value

### computation of progeny sd


titre_markers_input=${r_results}markersf.txt
titre_genotype_input=${r_results}genotypingf.txt
titre_function_calcul_index_variance_crosses=${r_scripts}08_index_lines_to_keep.R
#progeny=${progeny}
titre_variance_crosses_output=${r_results}variance_progeny.txt
r_big_files=${r_results}big_files/


v1=${titre_markers_input}
v2=${titre_genotype_input}
v3=${titre_function_calcul_index_variance_crosses}
v4=${progeny}
v5=${titre_variance_crosses_output}
v6=${r_big_files}



Rscript ${r_scripts}07_variance_progeny.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} 




### computation of criteria


within_family_selection_treshold=$(cut -f2 ${r_results}breeding_values.txt | tail -n+2 | sort | tail -n1)
# can be change for the treshold you want


titre_variance_progeny_input=${r_results}variance_progeny.txt
titre_breeding_values_input=${r_results}breeding_values.txt
titre_selection_intensity_table_input=${r_amont}selection_intensity_table.txt
#within_family_selection_rate=${within_family_selection_rate}
#within_family_selection_rate_extreme=${within_family_selection_rate_extreme}
#within_family_selection_treshold=${within_family_selection_treshold}
# titre_function_calcul_index_variance_crosses=${r_scripts}08_index_lines_to_keep.R
titre_criteria_output=${r_results}criteria.txt
# titre_function_calcul_index_variance_crosses=${r_scripts}08_index_lines_to_keep.R


v1=${titre_variance_progeny_input}
v2=${titre_breeding_values_input}
v3=${titre_selection_intensity_table_input}
v4=${within_family_selection_rate}
v5=${within_family_selection_rate_extreme}
v6=${within_family_selection_treshold}
v7=${titre_criteria_output}
v8=${titre_function_calcul_index_variance_crosses}

Rscript ${r_scripts}09_criteria.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8}






############### STEP 3 : optimization



### Output file: mating plan for one criteria
# description of file : 
# overall : one row = one cross
# col n°1 : header = "P1", value = name of the first parental line of the cross (string, ex: AO07403_XXX00000000000000000)
# col n°2 : header = "P2", value = name of the second parental line of the cross (string). Alphabetical order of P1 < P2
# col n°3 : header = "nbprogeny", value = number of progeny allocated (integer)
# Dimensions : Kmin <= nb rows <= Kmax, 3 columns 
# A small exemple of data is given in the file mating_plan.txt

### reduction of data based on expected progeny value
# To reduce computation time, only best crosses are kept


titre_criteria_input=${r_results}criteria.txt
proportion_of_best_crosses_used=0.1 # means the 10% best crosses (based on expected progeny value). Set the value you want. 1 means you keep every crosses. Allow to reduce computation time
titre_criteria_output=${r_results}criteriaf.txt




v1=${titre_criteria_input}
v2=${proportion_of_best_crosses_used}
v3=${titre_criteria_output}

Rscript ${r_scripts}10_keep_crosses_with_high_expected_progeny.R ${v1} ${v2} ${v3}

### preparation for optimization software


titre_criteria_input=${r_results}criteriaf.txt
titre_criteria_output=${r_results}criteriaf.txt



v1=${titre_criteria_input}
v2=${titre_criteria_output}

Rscript ${r_scripts}11_prepare_for_optimizaton_softwares.R ${v1} ${v2}

### optimization




if [ ${modele_name} == "expected_progeny" ]
then
modele_number=1
else if [ ${modele_name} == "superior_to_treshold" ]
then
modele_number=2
else if [ ${modele_name} == "EMBV" ]
then
modele_number=3
else if [ ${modele_name} == "uc" ]
then
modele_number=4
else if [ ${modele_name} == "expected_q_best_progeny" ]
then
modele_number=7
else if [ ${modele_name} == "uc_extreme" ]
modele_number=9
then
fi



cd ${r_genetic_algorithm}


cp ${r_scripts}config_optimization_softwares.cfg ${r_genetic_algorithm}config_optimization_softwares_model${modele_number}.cfg

config_file=${r_genetic_algorithm}config_optimization_softwares_model${modele_number}.cfg

sed -i "s|precise_model|${model}|g" ${config_file}
sed -i "s|precise_Dtot|${D}|g" ${config_file}
sed -i "s|precise_Dmax|${Dmax}|g" ${config_file}
sed -i "s|precise_Dmin|${Dmin}|g" ${config_file}
sed -i "s|precise_Kmin|${Kmin}|g" ${config_file}
sed -i "s|precise_Kmax|${Kmax}|g" ${config_file}
sed -i "s|precise_Cmax|${Cmax}|g" ${config_file}
sed -i "s|precise_Pmin|${Pmin}|g" ${config_file}
sed -i "s|precise_Pmax|${Pmax}|g" ${config_file}
sed -i "s|precise_qtop|${q}|g" ${config_file}


cp ${r_scripts}general.cfg ${r_genetic_algorithm}
sed -i "s|nb_generations_ga|${nb_generations_ga}|g" ${r_genetic_algorithm}general.cfg


if [ ${optimization_software} == "genetic_algorithm" ]
    then

    cp ${r_results}criteriaf.txt ${r_genetic_algorithm}criteria_for_ga_modele${modele_number}.txt

    sed -i "s|precise_file|criteria_for_ga_modele${modele_number}.txt|g" ${config_file}
    sed -i "s|precise_outputdir|after_ga_modele${modele_number}|g" ${config_file}


    ${r_genetic_algorithm}test.opt -c ${config_file}

    ### provide clean mating plan


    titre_mating_plan_ga_input=${r_genetic_algorithm}after_ga_modele${modele_number}/resag${modele_number}.csv
    titre_fitness_evolution_ga_input=${r_genetic_algorithm}after_ga_modele${modele_number}/evolution${modele_number}.csv
    #modele_name=${modele_name}
    #modele_number=${modele_number}
    titre_mating_plan_output=${r_results}mating_plan_${modele_name}.txt
    titre_fitness_graph_output=${r_results}fitness_${modele_name}.png



    v1=${titre_mating_plan_ga_input}
    v2=${titre_fitness_evolution_ga_input}
    v3=${modele_name}
    v4=${modele_number}
    v5=${titre_mating_plan_output}
    v6=${titre_fitness_graph_output}

    Rscript ${r_scripts}12_after_genetic_algorithm.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6}


else if [ ${optimization_software} == "linear_programming" ]
    then



    cp ${r_results}criteriaf.txt ${r_genetic_algorithm}criteria_for_PLE_modele${modele_number}.txt

    sed -i "s|precise_file|criteria_for_PLE_modele${modele_number}.txt|g" ${config_file}
    sed -i "s|precise_outputdir|after_PLE_modele${modele_number}|g" ${config_file}


    ${r_genetic_algorithm}lpcreate -c ${config_file}

    lp_solve alice.lp > ${r_genetic_algorithm}PLE_outputs_modele${modele_number}.txt

    ### provide clean mating plan

    titre_mating_plan_lpsolve_input=${r_genetic_algorithm}PLE_outputs_modele${modele_number}.txt
    titre_criteria_input=${r_genetic_algorithm}criteria_for_PLE_modele${modele_number}.txt
    #model_name=${model_name}
    titre_mating_plan_output=${r_results}mating_plan_${modele_name}.txt




    v1=${titre_mating_plan_lpsolve_input}
    v2=${titre_criteria_input}
    v3=${model_name}
    v4=${titre_mating_plan_output}


    Rscript ${r_scripts}13_after_linear_programming.R ${v1} ${v2} ${v3} ${v4}

fi

