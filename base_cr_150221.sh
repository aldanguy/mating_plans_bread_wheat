#!/bin/bash



# General


r_amont=/work/adanguy/these/croisements/amont/

r_scripts=/work/adanguy/these/croisements/scripts/





# Main repository

date=150221

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


# value_crosses.sh




r_value_crosses=${r_big_files}value_crosses/
r_value_crosses_variance_crosses_chr=${r_value_crosses}variance_crosses_chr/
r_value_crosses_variance_crosses_chr_big_matrix=${r_value_crosses_variance_crosses_chr}big_matrix/

mkdir -p ${r_value_crosses}
mkdir -p ${r_value_crosses_variance_crosses_chr}
mkdir -p ${r_value_crosses_variance_crosses_chr_big_matrix}



r_log_value_crosses=${r}log/value_crosses/
r_log_value_crosses_gblup=${r_log_value_crosses}gblup/
r_log_value_crosses_variance_crosses_chr=${r_log_value_crosses}variance_crosses_chr/
r_log_value_crosses_simulate_qtls=${r_log_value_crosses}simulate_qtls/
r_log_value_crosses_crosses=${r_log_value_crosses}crosses/

mkdir -p ${r_log_value_crosses}
mkdir -p ${r_log_value_crosses_gblup}
mkdir -p ${r_log_value_crosses_variance_crosses_chr}
mkdir -p ${r_log_value_crosses_simulate_qtls}
mkdir -p ${r_log_value_crosses_crosses}



# best_crosses.sh

r_best_crosses=${r_big_files}best_crosses/


r_best_crosses_gebv=${r_best_crosses}gebv/
r_best_crosses_uc=${r_best_crosses}uc/
r_best_crosses_logw=${r_best_crosses}logw/
r_best_crosses_random=${r_best_crosses}random/

mkdir -p ${r_best_crosses}
mkdir -p ${r_best_crosses_gebv}
mkdir -p ${r_best_crosses_uc}
mkdir -p ${r_best_crosses_logw}
mkdir -p ${r_best_crosses_random}




r_log_best_crosses=${r_log}best_crosses/
r_log_best_crosses_gebv=${r_log_best_crosses}gebv/
r_log_best_crosses_uc=${r_log_best_crosses}uc/
r_log_best_crosses_logw=${r_log_best_crosses}logw/
r_log_best_crosses_random=${r_log_best_crosses}random/

mkdir -p ${r_log_best_crosses}
mkdir -p ${r_log_best_crosses_gebv}
mkdir -p ${r_log_best_crosses_uc}
mkdir -p ${r_log_best_crosses_logw}
mkdir -p ${r_log_best_crosses_random}

# sd_predictions.sh

r_sd_predictions=${r_big_files}sd_predictions/
mkdir -p ${r_sd_predictions}

r_log_sd_predictions=${r}log/sd_predictions/
mkdir -p ${r_log_sd_predictions}


# graphs


r_graphs=${r}graphs/
mkdir -p ${r_graphs}



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

nb_run=3

cm=(all 0.1 1 10)
