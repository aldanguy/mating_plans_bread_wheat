#!/bin/bash



base=${1}

source ${base}
critere=${3}
nbcores=${2}
generation=${4}
affixe=${5}

source ${r_scripts}param_cr_${affixe}.sh



<<COMMENTS
nb_parents=800
titre_function_calcul=${r_scripts}calcul_index_compute_variance_crosses.R
titre_sortie=${r}crosses.txt

v1=${nb_parents}
v2=${titre_function_calcul}
v3=${titre_sortie}

Rscript ${r_scripts}simulate_crosses_file.R ${v1} ${v2} ${v3}
COMMENTS


if [ ${critere} == "gebv" ]
then
    colonne=4;
elif [ ${critere} == "logw" ]
then
    colonne=15
elif [ ${critere} == "uc" ]
then
    colonne=10
elif [ ${critere} == "random" ]
then
    colonne=3
fi


echo ${critere}
echo ${affixe}






# numero of column in input (3 = u, 5= log_w, 6=UC)
# path of output
titre_best_crosses_cplex=${r_best_crosses}${critere}/best_crosses_${critere}_g${generation}_${affixe}_raw.txt
# path of input
titre_variance_crosses=${r_value_crosses}crosses.txt

# path of cplex programm
# titre_path_cplex="/work/degivry/CPLEX_Studio128/cplex/python/3.6/x86-64_linux/cplex/__init__.py"
# variables




v1=${colonne}
v2=${titre_best_crosses_cplex}
v3=${titre_variance_crosses}
v4=${titre_path_cplex}



v5=${D}
v6=${Dmax}
v7=${Dmin}
v8=${Pmax}
v9=${Pmin}
v10=${Kmax}
v11=${Kmin}
v12=${Cmax}
v13=${nbcores}
v14=${critere}

python ${r_scripts}choose_crosses_update.py ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14}



# titre_best_crosses_cplex=${r}best_crosses_${critere}_raw.txt
titre_best_crosses=${r_best_crosses}${critere}/best_crosses_${critere}_g${generation}_${affixe}.txt
run=NA

v1=${titre_best_crosses_cplex}
v2=${titre_best_crosses}
v3=${generation}
v4=${run}

Rscript ${r_scripts}after_cplex.R ${v1} ${v2} ${v3} ${v4}






for idrun in $(seq 1 ${nb_run})
do

job_out=${r_log_best_crosses}${critere}/best_crosses_3_g${generation}_r${idrun}_${affixe}.out
job_name=${critere}_g${generation}_r${idrun}_${affixe}
job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --mem-per-cpu=10G --parsable ${r_scripts}best_crosses_3.sh ${base} ${critere} ${generation} ${idrun} ${nbcores} ${affixe})
echo "${job}" >> ${r_log_best_crosses}${critere}/jobs_best_crosses_${critere}_${affixe}.txt




done




while (( $(squeue -u adanguy | grep -f ${r_log_best_crosses}${critere}/jobs_best_crosses_${critere}_${affixe}.txt | wc -l) >= 1 )) 
do    
    sleep 1s
done





for idrun in $(seq 1 ${nb_run})
do 


    if ((idrun==1 ))
        
    then 
        
        cat ${r_best_crosses}${critere}/lines_${critere}_g${generation}_r${idrun}_${affixe}.txt > ${r_best_crosses}${critere}/lines_${critere}_g${generation}_${affixe}.txt
        #cat ${r_best_crosses}${critere}/genotyping_${critere}_g${generation}_r${idrun}_${affixe}.txt > ${r_best_crosses}${critere}/genotypes_${critere}_g${generation}_${affixe}.txt
        cat ${r_best_crosses}${critere}/pedigree_${critere}_g${generation}_r${idrun}_${affixe}.txt > ${r_best_crosses}${critere}/pedigree_${critere}_g${generation}_${affixe}.txt
        #cat ${r_best_crosses}${critere}/haplotypes_${critere}_g${generation}_r${idrun}_${affixe}.txt > ${r_best_crosses}${critere}/haplotypes_${critere}_g${generation}_${affixe}.txt

    else
        
        cat ${r_best_crosses}${critere}/lines_${critere}_g${generation}_r${idrun}_${affixe}.txt >> ${r_best_crosses}${critere}/lines_${critere}_g${generation}_${affixe}.txt
        # cat ${r_best_crosses}${critere}/genotyping_${critere}_g${generation}_r${idrun}_${affixe}.txt >> ${r_best_crosses}${critere}/genotypes_${critere}_g${generation}_${affixe}.txt
        cat ${r_best_crosses}${critere}/pedigree_${critere}_g${generation}_r${idrun}_${affixe}.txt >> ${r_best_crosses}${critere}/pedigree_${critere}_g${generation}_${affixe}.txt
        #cat ${r_best_crosses}${critere}/haplotypes_${critere}_g${generation}_r${idrun}_${affixe}.txt >> ${r_best_crosses}${critere}/haplotypes_${critere}_g${generation}_${affixe}.txt

            # rm ${f}

    fi
        
           
        rm ${r_best_crosses}${critere}/lines_${critere}_g${generation}_r${idrun}_${affixe}.txt
        # rm ${r_best_crosses}${critere}/genotyping_${critere}_g${generation}_r${idrun}_${affixe}.txt
        rm ${r_best_crosses}${critere}/pedigree_${critere}_g${generation}_r${idrun}_${affixe}.txt
        #rm ${r_best_crosses}${critere}/haplotypes_${critere}_g${generation}_r${idrun}_${affixe}.txt
         
          
done
rm -rf ${r_best_crosses}${critere}/${generation}/${affixe}/
