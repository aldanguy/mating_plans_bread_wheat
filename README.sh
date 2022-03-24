# README


# STEP1 = parents_and_markers.sh 
# Objective: generate files
# 1) file for markers, give markers ID, genetic positions, markers effects (either QTLs effects, either estimated marker effects)
# 2) file for genotypes, give lines ID and genotypes at marker
# 3) file for haplotypes, give lines ID and haplotypes
# 4) file for genetic values, give lines genetic values (either GEBV, either TBV)
# 5) file for genetic similarity, give pairiwise lines genetic similarity


# STEP2 = compute criteria and filter crosses
# can filter crosses based on the PM quantity 
# can remove too much related crosses 
# Objective : generate file of criteria


# STEP3 = optimization of mating plans
# Objective : generate mating plan

# STEP4 = simulation of TBV of progeny (QTLs effects are supposed known)
# Objective : genetic gain and genetic diversity



# Info on column names

# For all analysis (simulations or not)
# chr: Meaning = chromosome ID. Value = string = "1A"..."7D", 21 levels. Missing data = no. As much levels as chromosomes ID in the file
# region: Meaning = genomic regions of chromosomes. Value = string = "R1", "R2a", "C", "R2b" or "R3", 5 levels. Missing data = no. As much levels as chromosomic regions in the file
# marker: Meaning = ID of marker. Value = string, as much levels as markers ID in the file (this article ~ 16k levels). Missing data = n0. 
# pos: Meaning = physical position of marker. Value = interger, unit = pb. Missing data = no
# dcum: Meaning = cumulated genetic positon since chromosome start. Value = float, unit = CM. Missing data = no (see interpolation.R)
# ID: Meaning = lines ID. Value = string, as much levels as different candidate parents (this article = 835 levels). Missing data = no. Lines ID should have the same length (see ID.R)
# value: Meaning = either phenotypes, GEBV, TBV, marker effect or QTL effect depending of the file. Value = float. Missing data = no
# CONSTRAINTS: Meaning = name of the file of CONSTRAINTS. Value = string = "CONSTRAINTS" or "NO_CONSTRAINTS", one level. Missing data = no. Example of file of constraints: ${r_scripts}param_CONSTRAINTS.sh
# info: Meaning = info on the value quantity. Value = string, one level. Missing data = possible. Example: info = "QTLs_effects", "estimated_marker_effects", "phenotypes", "GEBV", "TBV" (one level per file)
# haplo: Meaning = haplotypes n°1 or n°2. Value = string = "haplo_1" or "haplo_2", 2 levels. Missing data = no

# simulation: Meaning = if population is simulated. Value = string = "TRUE" or "FALSE", one level. Missing data = no. 
# qtls: Meaning = number of QTLs used to simulate genetic architecture. Value = string, one level. Missing data = possible. Example: qtls = "300rand" (see Simulate_QTLs.R)
# qtls_info: Meaning = accuracy on QTLs effects. Value = string, one level. Missing data = possible. Example: qtls_info = "TRUE" means that QTLs effects are known ; tls_info = "ESTIMATED" means that QTLs effects are not known and should be estimated using a genomic prediction model
# genetic_map: Meaning = ID of the genetic map. Value = string, one level. Missing data = possible. Example: genetic_map = "WE" = genetic map of the Western European bread wheat population, Danguy des Déserts et al. 2021
# heritability: Meaning = heritability of the simulated phenotypes, Value = float. Missing data = possible. Example: heritability = 0.4 (see simulate_phenotypes.R)
# genomic: Meaning = genomic prediction model used to estimate GEBV and marker effects. Value = string, one level. Missing data = possible. Example: genomic = "GBLUP"
# population: Meaning = type of the studied population. Value = string, one level. Missing data = possible. Example: population = "unselected" or population = "selected" (see first_selection_cycles.R)
# population_ID: Meaning = ID of the population. Value = string, one level. Missing data = possible. Example populaion_ID = "real data" or population_ID = "1"
# P1: Meaning = ID of parent n°1. Value = string, as much levels as different candidate parents - 1, Missing data = no. ID sould matches ID
# P2: Meaning = ID of parent n°2. Value = string, as much levels as different candidate parents - 1, Missing data = no
# PM: Meaning = expected mean of the progeny genetic value of a cross between P1*P2, value = float, Missing data = no
# UC1: Meaning = expected mean of the [within_family_selection_rate_UC1]% best progeny genetic value of a cross between P1*P2, value = float, Missing data = no
# UC2: Meaning = expected mean of the [within_family_selection_rate_UC2]% best progeny genetic value of a cross between P1*P2, value = float, Missing data = no
# PROBA: Meaning = proportion of progeny superior to the genetic value of the best parent, value = float, Missing data = no
# OHV: Meaning = best theoritical progeny of P1*P2, value = float, Missing data = no
# EMBV: Meaning = best progeny considering family size of P1*P2, value = float, Missing data = no
# sd: Meaning = progeny standard deviation of P1*P2, value = float, Missing data = no
# progeny: Meaning = types of progeny used to compute criteria. Value = string, one level, Missing data = no. Example: progeny = "RILsF5"
# criterion: Meaning = criterion, value = string = "PM" or "UC1" or ..., one level, Missing data = no
# nbprogeny: Meaning = nb of progeny allocated to P1*P2, value = integer, Missing data = no
# num_simulation: Meaning = ID of the simulation of progeny derived from a mating plan. value = integer, Missing data = no
# genic_div: Meaning =  genic diversity of the [selection_rate_for_UC3]% best progeny of a mating plan, value = float, Missing data = no
# nparents: Meaning = number of parents that contribute to the [selection_rate_for_UC3]% best progeny of a mating plan, value = inte, Missing data = no
# selected_progeny: Meaning =  fraction of selected progeny. Value = string = "best" or "truncation", 2 levels. Missing data = no. "truncation" correspond to the [selection_rate_for_UC3]% best progeny


# Other info:
# header names matter
# In marker files (markers positions or genotypes), marker order should match the genetic map: by 1) chr 2) dcum 3) marker ID
# In genetic values files (phenotypes, GEBV or TBV) and genotypes files, ID should be sorted the same way
# tab separator
# decimal = "."
# columns order does not matter
# genotypes coded in 0, 1, 2. Haplotypes coded in 0, 1. Missing data = no.
# "levels" in column description are given for one file

# Info on each files

# 1) file for markers  
# variable for bash: ${titre_markers_used}
# file saved in ${r_markers}
# column 1: header = chr
# column 2: region
# column 3: pos
# column 4: marker
# column 5: genetic_map
# column 6: dcum
# column 7: value. Meaning = QTls effects or estimated marker effects, depending on the scenario 
# column 8: simulation
# column 9: qtls
# column 10: qtls_info
# column 11: genomic
# column 12: info
# column 13: heritability
# column 14: genomic
# column 15: population
# column 16: population_ID
# column order does not matter
# dimensions of file (without headers): nrows = Nmarkers 

# 2) file for genotypes of parents
# variable for bash: ${titre_genotypes_used}
# file saved in ${r_parents} for selected populations, or in ${r_results} for unselected populations and real data
# column 1: ID
# column 2: simulation
# column 3: qtls
# column 4: qtls_info
# column 5: genomic
# column 6: heritability
# column 7: population
# column 8: population_ID
# column 9 to 9+Nmarkers: markers ID
# dimensions of file (without headers) : nrows = Nparents 

# 3) file for haplotypes of parents
# variable for bash: ${titre_haplotypes_used}
# file saved in ${r_parents} for selected populations, or in ${r_results} for unselected populations and real data
# column 1: ID
# column 2: haplo
# column 3: simulation
# column 4: qtls
# column 5: qtls_info
# column 6: genomic
# column 7: heritability
# column 8: population
# column 9: population_ID
# column 10 to 10+Nmarkers: markers ID
# dimensions of file (without headers) : nrows = Nparents*2 

# 4) file for genetic values of parents
# variable for bash: ${titre_genetic_values_used}
# file saved in ${r_parents} for simulated populations, or in ${r_results} for real data
# column 1: ID
# column 2: value
# column 3: info
# column 3: qtls
# column 4: qtls_info
# column 5: genomic
# column 6: heritability
# column 7: population
# column 8: population_ID
# dimensions of file (without headers) : nrows = Nparents 

# 5) file for genetic similarity of parents
# variable for bash: ${titre_LDAK_used}
# file saved in ${r_parents} for simulated populations, or in ${r_results} for real data
# column 1: P1
# column 2: P2
# column 2: value
# column 3: info
# column 3: qtls
# column 4: qtls_info
# column 5: genomic
# column 6: heritability
# column 7: population
# column 8: population_ID
# dimensions of file (without headers) : nrows = Nparents * Nparents 

# 6) file of criteria
# variable for bash ${titre_criteria_base}.txt
# column 1: P1    
# column 2: P2    
# column 3: genetic_map    
# column 4: simulation    
# column 5: qtls    
# column 6: qtls_info    
# column 7: heritability    
# column 8: genomic    
# column 9: population    
# column 10: progeny    
# column 11: population_ID    
# column 12: CONSTRAINTS    
# column 13: sd    
# column 14: PM    
# column 15: UC1    
# column 16: UC2    
# column 17: PROBA    
# column 18: EMBV    
# column 19: OHV    
# column 20: progeny
# dimensions of file (without headers) : nrows = ([Nparents * (Nparents -1)]/2) * (1 - [proportion_of_crosses_used]) and also after removing the [most_related_crosses_removed]


# 6) file of mating plan
# variable for bash ${titre_mating_plan_base}${criterion}.txt
# column 1: P1    
# column 2: P2    
# column 3: genetic_map    
# column 4: simulation    
# column 5: qtls    
# column 6: qtls_info    
# column 7: heritability    
# column 8: genomic    
# column 9: population    
# column 10: progeny    
# column 11: population_ID    
# column 12: CONSTRAINTS    
# column 13: progeny    
# column 14: criterion    
# column 15: nbprogeny    
# dimensions of file (without headers) : nrows = between [Kmin] and [Kmax]
