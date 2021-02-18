#!/bin/bash



base=${1}

source ${base}

nbcores=${2}

generation=${3}

affixe=${4}



critere=gebv
job_out=${r_log_best_crosses}${critere}/best_crosses_2_${critere}_g${generation}_${affixe}.out
job_name=${critere}_${affixe}
job=$(sbatch -o ${job_out} -J ${job_name} --parsable -c ${nbcores} --mem-per-cpu=10G ${r_scripts}best_crosses_2.sh ${base} ${nbcores} ${critere} ${generation} ${affixe})
echo "${job}" >> ${r_log_best_crosses}jobs_best_crosses_${affixe}.txt


critere=uc

job_out=${r_log_best_crosses}${critere}/best_crosses_2_${critere}_g${generation}_${affixe}.out
job_name=${critere}_${affixe}
job=$(sbatch -o ${job_out} -J ${job_name} --parsable -c ${nbcores} --mem-per-cpu=10G ${r_scripts}best_crosses_2.sh ${base} ${nbcores} ${critere} ${generation} ${affixe})
echo "${job}" >> ${r_log_best_crosses}jobs_best_crosses.txt

critere=logw
job_out=${r_log_best_crosses}${critere}/best_crosses_2_${critere}_g${generation}_${affixe}.out
job_name=${critere}_${affixe}
job=$(sbatch -o ${job_out} -J ${job_name} --parsable -c ${nbcores} --mem-per-cpu=10G ${r_scripts}best_crosses_2.sh ${base} ${nbcores} ${critere} ${generation} ${affixe})
echo "${job}" >> ${r_log_best_crosses}jobs_best_crosses.txt

critere=random
job_out=${r_log_best_crosses}${critere}/best_crosses_2_${critere}_g${generation}_${affixe}.out
job_name=${critere}_${affixe}
job=$(sbatch -o ${job_out} -J ${job_name} --parsable -c ${nbcores} --mem-per-cpu=10G ${r_scripts}best_crosses_2.sh ${base} ${nbcores} ${critere} ${generation} ${affixe})
echo "${job}" >> ${r_log_best_crosses}jobs_best_crosses.txt



<<COMMENTS


while (( $(squeue -u adanguy | grep -f ${r_log_best_crosses}jobs_best_crosses.txt | wc -l) >= 1 )) 
do    
    sleep 1s
done


for critere in (gebv uc logw random)
do


if [ ${simulation} != "TRUE" ] ; 
then 

# warning ensure that script gblup.sh have run before
rm ${r_blupf90}SNP_predictions
echo ${r_blupf90_snp}progeny_genotypes_${critere}.txt |  ${r_blupf90}/predf90 > ${r_log_gblup}predf90_${critere}.out
cp ${r_blupf90}SNP_predictions ${r}progenies_${critere}.txt



elif [ ${simulation} == "TRUE" ] ; 



job_out=${r_log}NA.out
job_name=NA
# job=$(sbatch -o ${job_out} -J ${job_name} --time=00:30:00 --mem=10G --parsable ${r_scripts}simulated_marker_effects.sh ${base})

fi

### next steps : fusionner fichier progenies critere puis boxplot
COMMENTS
