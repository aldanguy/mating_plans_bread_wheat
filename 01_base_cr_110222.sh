#!/bin/bash
RANDOM=1



# General


r_amont=/work/adanguy/these/croisements/amont/

r_scripts=/work/adanguy/these/croisements/scripts/





# Main repositories

date=110222

first=${r_scripts}00_first_cr_${date}.sh


r0=/work/adanguy/these/croisements/${date}/
mkdir -p ${r0}


r_big_files=/work2/genphyse/dynagen/adanguy/croisements/${date}/
mkdir -p ${r_big_files}


r0_log=${r0}log/
mkdir -p ${r0_log}

r0_log_article=${r0_log}article/
mkdir -p ${r0_log_article}

r0_log_prepare=${r0_log}prepare/
mkdir -p ${r0_log_prepare}

r0_log_real_data=${r0_log}real_data/
mkdir -p ${r0_log_real_data}

r0_log_jobs=${r0_log}jobs/
mkdir -p ${r0_log_jobs}


cd ${r0}






# prepare.sh
r_prepare=${r_big_files}prepare/
mkdir -p ${r_prepare}



# graphs


r0_graphs=${r0}graphs/
mkdir -p ${r0_graphs}


# resultst

r_results=${r0}results/
mkdir -p ${r_results}


# BLUF90


r_blupf90=/work/adanguy/blupf90/ # should already exist, with blupf90, renumf90, postGSf0, predf90 and airemlf90 activated




r_genetic_algorithm_0=/work/adanguy/GA.zip






chromosomes=(1A 1B 1D 2A 2B 2D 3A 3B 3D 4A 4B 4D 5A 5B 5D 6A 6B 6D 7A 7B 7D)

# R

module purge
module load system/R-3.6.2
module load system/Python-3.6.3
module load system/pandoc-2.1.3
module load bioinfo/tabix-0.2.5



titre_path_cplex="/work/degivry/CPLEX_Studio128/cplex/python/3.6/x86-64_linux/cplex/__init__.py"

D=10000

nb_simulations=30

nb_mendelian_simulations=10

#qtls=(all 20cm chr 20mb 100rand)
qtls_tested=(300rand)

heritability_tested=(1.0 0.4)



keep_all=FALSE

genetic_map_ref=WE
genetic_maps_raw=(WE EE WA EA CsRe)

criteria=(UC1 PM UC2 PROBA OHV EMBV UC3)


constraintes_tested=(CONSTRAINTS NO_CONSTRAINTS)

nb_jobs_allowed=300


genetic_maps=(WE EE WA EA mapx3 nolinkagegroup genasphy)




titre_markers0=${r_results}markers_${genetic_map_ref}.txt
titre_genotypes_parents0=${r_results}genotypes_real_data.txt
titre_phenotypes_parents0=${r_results}phenotypes_real_data.txt
titre_GEBV_parents0=${r_results}GEBV_real_data.txt
titre_haplotypes_parents0=${r_results}haplotypes_real_data.txt
titre_LDAK0=${r_results}LDAK_real_data.txt
titre_selection_intensity=${r_results}selection_intensity.txt
titre_best_order_statistic=${r_results}expected_best_order_statistic.txt 

within_family_selection_rate_UC1=0.07
within_family_selection_rate_UC2=0.0001
selection_rate_for_UC3=0.07

optimization_software=linear_programming
PLE=CPLEX
