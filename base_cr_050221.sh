#!/bin/bash



# General


r_amont=/work/adanguy/these/croisements/amont/

r_scripts=/work/adanguy/these/croisements/scripts/





# Main repository

date=050221

first=${r_scripts}first_cr_${date}.sh


r=/work/adanguy/these/croisements/${date}/
mkdir -p ${r}


r_big_files=/work2/genphyse/dynagen/adanguy/croisements/${date}/
mkdir -p ${r_big_files}


r_big_matrix=${r_big_files}big_matrix/
mkdir -p ${r_big_matrix}


r_best_crosses=${r}best_crosses/
# r_best_crosses=${r}best_crosses/
mkdir -p ${r_best_crosses}



r_sd_predictions=${r}sd_predictions/
mkdir -p ${r_sd_predictions}


r_variance_crosses_chr=${r}variance_crosses_chr/
mkdir -p ${r_variance_crosses_chr}


cd ${r}

log=${r}log/


# Log


r_log=${r}log/
mkdir -p ${r_log}

r_log_jobs=${r}log/jobs/
mkdir -p ${r_log_jobs}

r_log_crossval=${r}log/crossval/
mkdir -p ${r_log_crossval}


r_log_gblup=${r}log/gblup/
mkdir -p ${r_log_gblup}


r_log_calcul=${r}log/calcul/
mkdir -p ${r_log_calcul}


r_log_calcul_gblup=${r}log/calcul/gblup/
mkdir -p ${r_log_calcul_gblup}

r_log_calcul_variance_crosses_chr=${r}log/calcul/variance_crosses_chr/
mkdir -p ${r_log_calcul_variance_crosses_chr}


r_log_sd_predictions=${r}log/sd_predictions/
mkdir -p ${r_log_sd_predictions}


r_log_variance_crosses_chr=${r}log/variance_crosses_chr/
mkdir -p ${r_log_variance_crosses_chr}

r_log_best_crosses=${r}log/best_crosses/
mkdir -p ${r_log_best_crosses}

r_log_best_crosses_gebv=${r}log/best_crosses/gebv/
mkdir -p ${r_log_best_crosses_gebv}

r_log_best_crosses_logw=${r}log/best_crosses/logw/
mkdir -p ${r_log_best_crosses_logw}

r_log_best_crosses_uc=${r}log/best_crosses/uc/
mkdir -p ${r_log_best_crosses_uc}

r_log_best_crosses_random=${r}log/best_crosses/random/
mkdir -p ${r_log_best_crosses_random}



r_graphs=${r}graphs/
mkdir -p ${r_graphs}






# BLUF90


r_blupf90=/work/adanguy/blupf90/ # should already exist, with blupf90, renumf90, postGSf0, predf90 and airemlf90 activated


r_blupf90_blues=/work/adanguy/blupf90/blues/
mkdir -p ${r_blupf90_blues}


r_blupf90_snp=/work/adanguy/blupf90/snp/
mkdir -p ${r_blupf90_snp}


r_blupf90_map=/work/adanguy/blupf90/map/
mkdir -p ${r_blupf90_map}


r_blupf90_weights=/work/adanguy/blupf90/weights/
mkdir -p ${r_blupf90_weights}


r_blupf90_crossval_snp=/work/adanguy/blupf90/crossval/snp/
mkdir -p ${r_blupf90_crossval_snp}


r_blupf90_crossval_blues=/work/adanguy/blupf90/crossval/blues/
mkdir -p ${r_blupf90_crossval_blues}


r_blupf90_crossval_new=/work/adanguy/blupf90/crossval/new/
mkdir -p ${r_blupf90_crossval_new}


r_blupf90_crossval_ebv=/work/adanguy/blupf90/crossval/ebv/
mkdir -p ${r_blupf90_crossval_ebv}

chr=(1A 1B 1D 2A 2B 2D 3A 3B 3D 4A 4B 4D 5A 5B 5D 6A 6B 6D 7A 7B 7D)

# R

module purge
module load system/R-3.6.2
module load system/Python-3.6.3


titre_path_cplex="/work/degivry/CPLEX_Studio128/cplex/python/3.6/x86-64_linux/cplex/__init__.py"

D=3300
D=10000

Dmax=60 # Kmax*Dmax >=D
Dmax=1000

Dmin=1
Dmin=0

Pmax=132 # Pmax*(Pmax-1)/2 >= Kmax
Pmax=100000

Pmin=100 #Pmin*2 <= Kmax
Pmin=0

Kmax=300 #kmax*Dmin

Kmin=200 # Pmin(Pmin-1)/2 >= Kmin 
Kmin=0

Cmax=250
Cmax=10000

nb_run=10


