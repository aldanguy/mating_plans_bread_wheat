#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
export LC_COLLATE=C
export LC_ALL=C
ulimit -s unlimited
export OMP_STACKSIZE=64M



base=${1}
source ${base}
echo ${base}


r=${r_big_files}article/

r_log=${r0_log}check_sd/
mkdir -p ${r_log}
file_jobs=${r0_log_jobs}jobs_check_sd.txt


qtls=300rand
genetic_map=WE
simulation=TRUE
constraints=CONSTRAINTS


qtls_info=TRUE
heritability=NA
genomic=NA
population=unselected
population_ID=4

ID=s${simulation}_i${qtls_info}_q${qtls}_h${heritability}_g${genomic}_p${population}_n${population_ID}_m${genetic_map}_${constraints}



v1=${base}
v2=${r}
v3=${simulation}
v4=${qtls_info}
v5=${heritability}
v6=${qtls}
v7=${genomic}
v8=${population}
v9=${genetic_map}
v10=${population_ID}



job_out=${r_log}check_${ID}.out


job_name=sd${ID}



job=$(sbatch -o ${job_out} -J ${job_name} --mem=3G --parsable ${r_scripts}progeny2_check_sd.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} )

echo "${job_out} =" >> ${file_jobs}
echo "${job}" >> ${file_jobs}



qtls_info=ESTIMATED
heritability=0.4
genomic=GBLUP
population=unselected
population_ID=20

ID=s${simulation}_i${qtls_info}_q${qtls}_h${heritability}_g${genomic}_p${population}_n${population_ID}_m${genetic_map}_${constraints}



v1=${base}
v2=${r}
v3=${simulation}
v4=${qtls_info}
v5=${heritability}
v6=${qtls}
v7=${genomic}
v8=${population}
v9=${genetic_map}
v10=${population_ID}



job_out=${r_log}check_${ID}.out


job_name=sd${ID}



job=$(sbatch -o ${job_out} -J ${job_name} --mem=3G --parsable ${r_scripts}progeny2_check_sd.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} )

echo "${job_out} =" >> ${file_jobs}
echo "${job}" >> ${file_jobs}





qtls_info=ESTIMATED
heritability=0.4
genomic=GBLUP
population=selected
population_ID=3

ID=s${simulation}_i${qtls_info}_q${qtls}_h${heritability}_g${genomic}_p${population}_n${population_ID}_m${genetic_map}_${constraints}



v1=${base}
v2=${r}
v3=${simulation}
v4=${qtls_info}
v5=${heritability}
v6=${qtls}
v7=${genomic}
v8=${population}
v9=${genetic_map}
v10=${population_ID}



job_out=${r_log}check_${ID}.out


job_name=sd${ID}



job=$(sbatch -o ${job_out} -J ${job_name} --mem=3G --parsable ${r_scripts}progeny2_check_sd.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} )

echo "${job_out} =" >> ${file_jobs}
echo "${job}" >> ${file_jobs}




qtls_info=TRUE
heritability=NA
genomic=NA
population=selected
population_ID=2

ID=s${simulation}_i${qtls_info}_q${qtls}_h${heritability}_g${genomic}_p${population}_n${population_ID}_m${genetic_map}_${constraints}



v1=${base}
v2=${r}
v3=${simulation}
v4=${qtls_info}
v5=${heritability}
v6=${qtls}
v7=${genomic}
v8=${population}
v9=${genetic_map}
v10=${population_ID}



job_out=${r_log}check_${ID}.out


job_name=sd${ID}



job=$(sbatch -o ${job_out} -J ${job_name} --mem=3G --parsable ${r_scripts}progeny2_check_sd.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} )

echo "${job_out} =" >> ${file_jobs}
echo "${job}" >> ${file_jobs}



qtls_info=TRUE
heritability=NA
genomic=NA
population=selected
population_ID=11
constraints=NO_CONSTRAINTS

ID=s${simulation}_i${qtls_info}_q${qtls}_h${heritability}_g${genomic}_p${population}_n${population_ID}_m${genetic_map}_${constraints}



v1=${base}
v2=${r}
v3=${simulation}
v4=${qtls_info}
v5=${heritability}
v6=${qtls}
v7=${genomic}
v8=${population}
v9=${genetic_map}
v10=${population_ID}



job_out=${r_log}check_${ID}.out


job_name=sd${ID}



job=$(sbatch -o ${job_out} -J ${job_name} --mem=3G --parsable ${r_scripts}progeny2_check_sd.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} )

echo "${job_out} =" >> ${file_jobs}
echo "${job}" >> ${file_jobs}



date +'%Y-%m-%d-%T'
