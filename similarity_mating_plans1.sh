#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
export LC_COLLATE=C
export LC_ALL=C
ulimit -s unlimited
export OMP_STACKSIZE=64M









base=${1}

source ${base}

file_jobs=${r0_log_jobs}similarity.txt

r=${r_big_files}article/similarity_mating_plans/
r_log=${r0_log}similarity_mating_plans/

mkdir -p ${r}
mkdir -p ${r_log}


populations=(unselected selected)
constraintsall=(CONSTRAINTS NO_CONSTRAINTS)
simulation=TRUE
genetic_map=WE
qtls=300rand


for constraints in ${constraintsall[*]}
do


for population in ${populations[*]}
do
    
    for population_ID in $(seq 1 ${nb_simulations})
    do



qtls_info=ESTIMATED
heritability=0.4
genomic=GBLUP

ID=s${simulation}_i${qtls_info}_q${qtls}_h${heritability}_g${genomic}_p${population}_n${population_ID}_m${genetic_map}_${constraints}


v1=${base}
v2=${ID}
v3=${population}



job_out=${r_log}similarity_mating_plans_${ID}.out


job_name=${ID}

job=$(sbatch -o ${job_out} -J ${job_name} --mem=3G --parsable ${r_scripts}similarity_mating_plans2.sh ${v1} ${v2} ${v3})
echo "${job_out} =" >> ${file_jobs}
echo "${job}" >> ${file_jobs}

           
qtls_info=TRUE
heritability=NA
genomic=NA

ID=s${simulation}_i${qtls_info}_q${qtls}_h${heritability}_g${genomic}_p${population}_n${population_ID}_m${genetic_map}_${constraints}


v2=${ID}



job_out=${r_log}similarity_mating_plans_${ID}.out


job_name=${ID}

job=$(sbatch -o ${job_out} -J ${job_name} --mem=3G --parsable ${r_scripts}similarity_mating_plans2.sh ${v1} ${v2} ${v3})
echo "${job_out} =" >> ${file_jobs}
echo "${job}" >> ${file_jobs}
  
            done
            
            
            done
            
            
            
            done
            
            
            
      
echo "end"


jobs_all=${r0}all_jobs.txt
cat ${r0_log_jobs}* > ${jobs_all}




sed -i '/^$/d' ${jobs_all}
while (( $(squeue -u adanguy | grep -f ${jobs_all} | wc -l) >= 1 )) 
do    
    sleep 1m
    cat ${r0_log_jobs}* > ${jobs_all}
    sed -i '/^$/d' ${jobs_all}
    echo "wait"
done
      
            


           
k=0

for f in ${r}similarity_*
do

    if [ ${k} -eq 0 ]
    then
    
    cat ${f} > ${r}similarity.txt
    
    else
    
    tail -n+2 ${f} >> ${r}similarity.txt
    
    
    fi
    
    k=$((${k}+1))
        #rm ${f}

    
done

      
k=0

for f in ${r}correlations_*
do

    if [ ${k} -eq 0 ]
    then
    
    cat ${f} > ${r}correlations.txt
    
    else
    
    tail -n+2 ${f} >> ${r}correlations.txt
    
    
    fi
    
    k=$((${k}+1))
        #rm ${f}

    
done



titre_similarity_input=${r}similarity.txt

titre_similarity_output=${r_results}similarity.txt


v1=${titre_similarity_input}
v2=${titre_similarity_output}


Rscript ${r_scripts}analyse_similarity.R ${v1} ${v2}


titre_correlations_input=${r}correlations.txt

titre_correlations_output=${r_results}correlations.txt


v1=${titre_correlations_input}
v2=${titre_correlations_output}


Rscript ${r_scripts}analyse_correlations.R ${v1} ${v2}



rm ${r}similarity.txt
rm ${r}correlations.txt



date +'%Y-%m-%d-%T'

