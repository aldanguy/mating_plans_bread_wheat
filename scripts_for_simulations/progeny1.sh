#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'



base=${1}
source ${base}

r_ref=${2}
r_log=${3}
ID=${4}
criterion=${5}
titre_mating_plan_base=${6}
titre_TBV_progeny_base=${7}
titre_markers_used=${8}
titre_haplotypes_used=${9}


echo ${base}
echo ${r_ref}
echo ${r_log}
echo ${ID}
echo ${criterion}
echo ${titre_mating_plan_base}
echo ${titre_TBV_progeny_base}
echo ${titre_markers_used}
echo ${titre_haplotypes_used}

r_log_progeny=${r_log}progeny/
mkdir -p ${r_log_progeny}




file_jobs=${r0_log_jobs}jobs_${ID}_${criterion}.txt



while [ ! -f "${titre_mating_plan_base}${criterion}.txt" ] 
    do
    
    echo "Waiting for starting mating plan  ${titre_mating_plan_base}${criterion}.txt"

    sleep 10m
    
    done


for num_simulation in $(seq 1 ${nb_mendelian_simulations})
do


    # echo ${num_simulation}


    job_out=${r_log_progeny}progeny2_${ID}_${criterion}_${num_simulation}.out


    job_name=${criterion}${ID}${num_simulation}



   
    v1=${base}
    v2=${r_ref}
    v3=${ID}
    v4=${criterion}
    v5=${titre_mating_plan_base}
    v6=${titre_TBV_progeny_base}
    v7=${titre_markers_used}
    v8=${titre_haplotypes_used}
    v9=${num_simulation}




        
    # job=$(sbatch -o ${job_out} -J ${job_name} --time=00:30:00 --mem=20G --parsable ${r_scripts}progeny2.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9})

    # echo "${job_out} =" >> ${file_jobs}
    # echo "${job}" >> ${file_jobs}
    

    while (( $(squeue -u adanguy  | wc -l) >=  ${nb_jobs_allowed})) 
    do    
    sleep 1m
    done




done

sed -i '/^$/d' ${file_jobs}

    while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
      do    
     sleep 1m

    done

cd ${r_ref}progeny/

titre=$( echo ${titre_TBV_progeny_base} | sed "s|/.*/TBV|TBV|g" )
titre2=${titre}${criterion}

nb_div=$(ls | grep ${titre2} | grep "_diversity.txt"  | wc -l)
nb_gain=$(ls | grep ${titre2} | grep "_gain.txt"  | wc -l)
nb_sel=$(ls | grep ${titre2} | grep "_sel.txt"  | wc -l)

nb_files=$(( ${nb_div} + ${nb_gain} + ${nb_sel}))
nb_tot_files_expected=$((${nb_mendelian_simulations}*3))


while (( ${nb_files} < ${nb_tot_files_expected} ))

do 


for num_simulation in $(seq 1 ${nb_mendelian_simulations})
do

    if [ ! -f "${titre_TBV_progeny_base}${criterion}_${num_simulation}_gain.txt" ] || [ ! -f "${titre_TBV_progeny_base}${criterion}_${num_simulation}_diversity.txt" ] || [ ! -f "${titre_TBV_progeny_base}${criterion}_${num_simulation}_sel.txt" ]
    then
    
    echo "${num_simulation} retry"
    


    job_out=${r_log_progeny}progeny2_${ID}_${criterion}_${num_simulation}.out


    job_name=${criterion}${ID}${num_simulation}



   
    v1=${base}
    v2=${r_ref}
    v3=${ID}
    v4=${criterion}
    v5=${titre_mating_plan_base}
    v6=${titre_TBV_progeny_base}
    v7=${titre_markers_used}
    v8=${titre_haplotypes_used}
    v9=${num_simulation}




        
    job=$(sbatch -o ${job_out} -J ${job_name} --time=00:30:00 --mem=20G --parsable ${r_scripts}progeny2.sh ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9})

    echo "${job_out} =" >> ${file_jobs}
    echo "${job}" >> ${file_jobs}
    sed -i '/^$/d' ${file_jobs}

    


    

    while (( $(squeue -u adanguy | grep ${job} | wc -l) >= 1 )) 
      do    
    sleep 1m

    done
    
        while (( $(squeue -u adanguy  | wc -l) >=  ${nb_jobs_allowed})) 
    do    
    sleep 1m
    done
    


    

        nb_div=$(ls | grep ${titre2} | grep "_diversity.txt"  | wc -l)
        nb_gain=$(ls | grep ${titre2} | grep "_gain.txt"  | wc -l)
        nb_sel=$(ls | grep ${titre2} | grep "_sel.txt"  | wc -l)

        nb_files=$(( ${nb_div} + ${nb_gain} + ${nb_sel}))   
        
   fi
 
    
done

done 

while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
do    
sleep 1m
sed -i '/^$/d' ${file_jobs}
done


k=0
for f in ${titre_TBV_progeny_base}*${criterion}*sel.txt
do

echo ${f}

 if [ ${k} -eq 0 ]
 then

    cat ${f} > ${titre_TBV_progeny_base}${criterion}_selection_rate_temp1.txt

 else
 
 tail -n+2 ${f} >> ${titre_TBV_progeny_base}${criterion}_selection_rate_temp1.txt
 
 fi
 
 k=$((${k}+1))
#rm ${f}

done


    

k=0
for f in ${titre_TBV_progeny_base}*${criterion}*diversity.txt
do

echo ${f}

 if [ ${k} -eq 0 ]
 then

    cat ${f} > ${titre_TBV_progeny_base}${criterion}_diversity_temp1.txt

 else
 
 tail -n+2 ${f} >> ${titre_TBV_progeny_base}${criterion}_diversity_temp1.txt
 
 fi
 
 k=$((${k}+1))
#rm ${f}

done



k=0
for f in ${titre_TBV_progeny_base}*${criterion}*gain.txt
do

echo ${f}

 if [ ${k} -eq 0 ]
 then

    cat ${f} > ${titre_TBV_progeny_base}${criterion}_gain_temp1.txt

 else
 
 tail -n+2 ${f} >> ${titre_TBV_progeny_base}${criterion}_gain_temp1.txt
 
 fi
 
 k=$((${k}+1))
#rm ${f}

done




titre_sel_rate_input=${titre_TBV_progeny_base}${criterion}_selection_rate_temp1.txt
titre_selection_rate_output=${titre_TBV_progeny_base}${criterion}_selection_rate_temp2.txt
titre_gain_input=${titre_TBV_progeny_base}${criterion}_gain_temp1.txt
titre_diversity_input=${titre_TBV_progeny_base}${criterion}_diversity_temp1.txt
titre_diversity_output=${titre_TBV_progeny_base}${criterion}_diversity_temp2.txt
titre_gain_output=${titre_TBV_progeny_base}${criterion}_gain_temp2.txt

v1=${titre_sel_rate_input}
v2=${titre_gain_input}
v3=${titre_diversity_input}
v4=${titre_selection_rate_output}
v5=${titre_diversity_output}
v6=${titre_gain_output}

 Rscript ${r_scripts}analyse_gain.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6}
 
 
 

rm ${titre_TBV_progeny_base}${criterion}_selection_rate_temp1.txt
rm ${titre_TBV_progeny_base}${criterion}_gain_temp1.txt
rm ${titre_TBV_progeny_base}${criterion}_diversity_temp1.txt
 

   
date +'%Y-%m-%d-%T'
