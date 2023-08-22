#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
export LC_COLLATE=C
export LC_ALL=C
ulimit -s unlimited
export OMP_STACKSIZE=64M




base=${1}
source ${base}

r=${2}
ID=${3}
criterion=${4}
titre_mating_plan_base=${5}
titre_TBV_progeny_base=${6}
titre_markers_used=${7}
titre_haplotypes_used=${8}
num_simulation=${9}




echo ${base}
echo ${r}
echo ${ID}
echo ${criterion}
echo ${titre_mating_plan_base}
echo ${titre_TBV_progeny_base}
echo ${titre_markers_used}
echo ${titre_haplotypes_used}
echo ${num_simulation}




ID3=${ID}_${criterion}_${num_simulation}




r_progeny_temp=${r}progeny/temp/${ID3}/


titre_genotypes_progeny=${r_progeny_temp}genotypes_progeny_${ID3}.txt
titre_pedigree_progeny_temp=${r_progeny_temp}pedigree_progeny_temp_${ID3}.txt
titre_pedigree_progeny=${r}progeny/pedigree_progeny_${ID3}.txt

titre_TBV_progeny=${titre_TBV_progeny_base}${criterion}_${num_simulation}.txt
titre_TBV_progeny_gain=${titre_TBV_progeny_base}${criterion}_${num_simulation}_gain.txt
titre_TBV_progeny_diversity=${titre_TBV_progeny_base}${criterion}_${num_simulation}_diversity.txt
titre_TBV_progeny_selection_rate=${titre_TBV_progeny_base}${criterion}_${num_simulation}_sel.txt

if [ -d "${r_progeny_temp}" ]
then
rm -rf ${r_progeny_temp}
fi
mkdir -p ${r_progeny_temp}
cd ${r_progeny_temp}




titre_markers_input=${titre_markers_used}
titre_mating_plan_base_input=${titre_mating_plan_base}${criterion}.txt
titre_haplo_input=${titre_haplotypes_used}
#num_simulation
titre_genotypes_output=${titre_genotypes_progeny}
titre_progeny_pedigree_output=${titre_pedigree_progeny_temp}


v1=${titre_markers_input}
v2=${titre_mating_plan_base_input}
v3=${titre_haplo_input}
v4=${num_simulation}
v5=${titre_genotypes_output}
v6=${titre_progeny_pedigree_output}


Rscript ${r_scripts}progeny.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6}



titre_genotypes_input=${titre_genotypes_progeny}

titre_qtls_input=${titre_markers_used}
titre_tbv_output=${titre_TBV_progeny}



v1=${titre_genotypes_input}
v2=${titre_qtls_input}
v3=${titre_tbv_output}


Rscript ${r_scripts}compute_tbv.R ${v1} ${v2} ${v3}


titre_lines_input=${titre_TBV_progeny}
titre_gain_output=${titre_TBV_progeny_gain}
titre_selection_rate_output=${titre_TBV_progeny_selection_rate}

v1=${titre_lines_input}
v2=${selection_rate_for_UC3}
v3=${titre_gain_output}
v4=${titre_selection_rate_output}


Rscript ${r_scripts}progeny_gain.R ${v1} ${v2} ${v3} ${v4}

titre_genotypes_input=${titre_genotypes_progeny}
titre_markers_input=${titre_markers_used}
titre_lines_input=${titre_TBV_progeny}
titre_pedigree_input=${titre_pedigree_progeny_temp}
#selection_rate_for_UC3
titre_diversity_output=${titre_TBV_progeny_diversity}


v1=${titre_genotypes_input}
v2=${titre_markers_input}
v3=${titre_lines_input}
v4=${titre_pedigree_input}
v5=${selection_rate_for_UC3}
v6=${titre_diversity_output}


Rscript ${r_scripts}progeny_diversity.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6}







colonne_value=$(head ${titre_pedigree_progeny_temp} -n1 | sed "s/\t/\n/g" | grep -n "^value$" | sed "s/:.*//g")

cut --complement -f${colonne_value} ${titre_pedigree_progeny_temp} > ${titre_pedigree_progeny}






cd ${r0}

rm -rf ${r_progeny_temp}


date +'%Y-%m-%d-%T'
