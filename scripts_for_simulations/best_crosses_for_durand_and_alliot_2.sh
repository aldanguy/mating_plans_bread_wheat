#!/bin/bash



base=${1}

source ${base}


critere=${3}
nbcores=${2}



generation=1
run=NA

# path of input
titre_variance_crosses=/work/adanguy/these/croisements/031120/tab1_variance_crosses_filtered.txt
# path of cplex programm
# titre_path_cplex="/work/degivry/CPLEX_Studio128/cplex/python/3.6/x86-64_linux/cplex/__init__.py"
# variables



echo ${critere}

<<COMMENTS
nb_parents=800
titre_function_calcul=${r_scripts}calcul_index_compute_variance_crosses.R
titre_sortie=${r}crosses.txt

v1=${nb_parents}
v2=${titre_function_calcul}
v3=${titre_sortie}

Rscript ${r_scripts}simulate_crosses_file.R ${v1} ${v2} ${v3}
COMMENTS


if [ ${critere} == "gebv" ]
then
    colonne=3;
elif [ ${critere} == "logw" ]
then
    colonne=5
elif [ ${critere} == "uc" ]
then
    colonne=6
fi



# numero of column in input (3 = u, 5= log_w, 6=UC)
# path of output
titre_best_crosses_cplex=/work/adanguy/these/croisements/031120/best_crosses_durand_alliot_${critere}_raw.txt




v1=${colonne}
v2=${titre_best_crosses_cplex}
v3=${titre_variance_crosses}
v4=${titre_path_cplex}

D=3300
Dmax=60
Dmin=1
Pmax=132
Pmin=100
Kmax=300
Kmin=200
Cmax=250

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

python ${r_scripts}choose_crosses_update.py ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14}



# titre_best_crosses_cplex=${r}best_crosses_${critere}_raw.txt
titre_best_crosses=/work/adanguy/these/croisements/031120/best_crosses_durand_alliot_${critere}.txt

v1=${titre_best_crosses_cplex}
v2=${titre_best_crosses}
v3=${generation}
v4=${run}

Rscript ${r_scripts}after_cplex.R ${v1} ${v2} ${v3} ${v4}

