#!/bin/bash
RANDOM=1



# General


r_amont=/work/adanguy/these/croisements/amont/

r_scripts=/work/adanguy/these/croisements/scripts/





# Main repository

date=200421

first=${r_scripts}first_cr_${date}.sh


r=/work/adanguy/these/croisements/${date}/
mkdir -p ${r}


r_big_files=/work2/genphyse/dynagen/adanguy/croisements/${date}/
mkdir -p ${r_big_files}




cd ${r}




r_log=${r}log/
mkdir -p ${r_log}

# prepare.sh
r_prepare=${r_big_files}prepare/
mkdir -p ${r_prepare}

r_log_prepare=${r}log/prepare/
mkdir -p ${r_log_prepare}


# value_crosses.sh




r_value_crosses=${r_big_files}value_crosses/
r_value_crosses_variance_crosses=${r_value_crosses}variance_crosses/
r_value_crosses_simulate_qtls=${r_value_crosses}simulate_qtls/
r_value_crosses_crosses=${r_value_crosses}crosses/
r_value_crosses_gblup=${r_value_crosses}gblup/


mkdir -p ${r_value_crosses}
mkdir -p ${r_value_crosses_variance_crosses}
mkdir -p ${r_value_crosses_crosses}
mkdir -p ${r_value_crosses_simulate_qtls}
mkdir -p ${r_value_crosses_gblup}



r_log_value_crosses=${r}log/value_crosses/
r_log_value_crosses_gblup=${r_log_value_crosses}gblup/
r_log_value_crosses_variance_crosses=${r_log_value_crosses}variance_crosses/
r_log_value_crosses_simulate_qtls=${r_log_value_crosses}simulate_qtls/
r_log_value_crosses_crosses=${r_log_value_crosses}crosses/
r_log_value_crosses_jobs=${r_log_value_crosses}jobs/

mkdir -p ${r_log_value_crosses}
mkdir -p ${r_log_value_crosses_gblup}
mkdir -p ${r_log_value_crosses_simulate_qtls}
mkdir -p ${r_log_value_crosses_crosses}
mkdir -p ${r_log_value_crosses_jobs}



# best_crosses.sh

r_best_crosses=${r_big_files}best_crosses/



r_best_crosses_genotypes=${r_best_crosses}genotypes/
r_best_crosses_lines=${r_best_crosses}lines/
r_best_crosses_pedigree=${r_best_crosses}pedigree/
r_best_crosses_best_crosses=${r_best_crosses}best_crosses/
r_best_crosses_crosses=${r_best_crosses}crosses/
r_best_crosses_haplotypes=${r_best_crosses}haplotypes/


mkdir -p ${r_best_crosses_genotypes}
mkdir -p ${r_best_crosses_lines}
mkdir -p ${r_best_crosses_pedigree}
mkdir -p ${r_best_crosses_best_crosses}
mkdir -p ${r_best_crosses_crosses}
mkdir -p ${r_best_crosses_haplotypes}



r_log_best_crosses=${r_log}best_crosses/
r_log_best_crosses_jobs=${r_log_best_crosses}jobs/



mkdir -p ${r_log_best_crosses}
mkdir -p ${r_log_best_crosses_jobs}

# sd_predictions.sh

r_sd_predictions=${r_big_files}sd_predictions/
mkdir -p ${r_sd_predictions}

r_log_sd_predictions=${r}log/sd_predictions/
mkdir -p ${r_log_sd_predictions}


#crossval


r_crossval=${r}crossval/
mkdir -p ${r_crossval}
r_log_crossval=${r_log}crossval/
mkdir -p ${r_log_crossval}


# graphs


r_graphs=${r}graphs/
mkdir -p ${r_graphs}


# resultst

r_results=${r_big_files}results/
mkdir -p ${r_results}


# BLUF90


r_blupf90=/work/adanguy/blupf90/ # should already exist, with blupf90, renumf90, postGSf0, predf90 and airemlf90 activated


r_blupf90_pheno=${r_blupf90}pheno/
mkdir -p ${r_blupf90_pheno}


r_blupf90_snp=${r_blupf90}snp/
mkdir -p ${r_blupf90_snp}


r_blupf90_map=${r_blupf90}map/
mkdir -p ${r_blupf90_map}


r_blupf90_weights=${r_blupf90}weights/
mkdir -p ${r_blupf90_weights}










chr=(1A 1B 1D 2A 2B 2D 3A 3B 3D 4A 4B 4D 5A 5B 5D 6A 6B 6D 7A 7B 7D)

# R

module purge
module load system/R-3.6.2
module load system/Python-3.6.3
module load system/pandoc-2.1.3
module load bioinfo/tabix-0.2.5



titre_path_cplex="/work/degivry/CPLEX_Studio128/cplex/python/3.6/x86-64_linux/cplex/__init__.py"

D=10000

nb_run=10

cm=(all 20 chr)

heritability=(0.8 0.4)

nbcores=2


keep_all=FALSE

population_ref=WE


criteres=(gebv uc logw uc_extreme)

genomic=(basic ldak)

affixes=(simple real)

nb_jobs_allowed=300


populations=(WE EE WA EA CsRe)
# should belong to ${r_amont}supplementary_file_3_recombination_maps.txt


