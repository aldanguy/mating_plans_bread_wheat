#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'

base=${1}




source ${base}


generation=${2}
type=${3}
population=${4}
critere=${5}
affixe=${6}



nbcores=2





source ${r_scripts}param_cr_${affixe}.sh
motif=$(echo ${type} | sed "s/marker_//g")

ID1=g${generation}_${motif}_${population}
ID2=${critere}_${affixe}



file_jobs=${r_log_best_crosses_jobs}jobs_best_crosses_2_${ID1}_${ID2}.txt

<<COMMENTS
nb_parents=800
titre_function_calcul=${r_scripts}calcul_index_compute_variance_crosses.R
titre_sortie=${r}crosses.txt

v1=${nb_parents}
v2=${titre_function_calcul}
v3=${titre_sortie}

Rscript ${r_scripts}simulate_crosses_file.R ${v1} ${v2} ${v3}
COMMENTS



titre_crosses=${r_value_crosses_crosses}crosses_${ID1}.txt

# Pmax=${Pmax}
# Kmax=${Kmax}
# Cmax=${Cmax}
# Kmin=${Kmin}
# critere=${critere}
titre_crosses_filtered=${r_best_crosses}crosses_filtered_${ID1}_${ID2}.txt




v1=${titre_crosses}
v2=${Pmax}
#v2=50000000
v3=${Kmax}
#v3=50000000
v4=${Cmax}
#v4=50000000
v5=${Kmin}
#v5=50000000
v6=${critere}
v7=${titre_crosses_filtered}


Rscript ${r_scripts}pre_filter_crosses.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7}




# numero of column in input (3 = u, 5= log_w, 6=UC)
# path of output
titre_best_crosses_cplex=${r_results}crosses_filtered_${ID1}_${ID2}_raw.txt
# path of input

# path of cplex programm
# titre_path_cplex="/work/degivry/CPLEX_Studio128/cplex/python/3.6/x86-64_linux/cplex/__init__.py"
# variables




v1=6
v2=${titre_best_crosses_cplex}
v3=${titre_crosses_filtered}
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

date +'%Y-%m-%d-%T'
python ${r_scripts}choose_crosses_update.py ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13} ${v14}
date +'%Y-%m-%d-%T'


# titre_best_crosses_cplex=${r}best_crosses_${critere}_raw.txt
titre_best_crosses=${r_best_crosses}best_crosses_${ID1}_${ID2}.txt



v1=${titre_best_crosses_cplex}
v2=${titre_best_crosses}
v3=${generation}
v4=${type}
v5=${population}
v6=${critere}
v7=${affixe}



Rscript ${r_scripts}after_cplex.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7}




if [ ${generation} -eq 1 ]
    then   

    cp ${r_prepare}genotyping.txt ${r_best_crosses_genotypes}genotypes_${ID1}_${ID2}.txt
    titre_genotyping_input=${r_best_crosses_genotypes}genotypes_${ID1}_${ID2}.txt
    titre_best_crosses_input=${r_best_crosses}best_crosses_${ID1}_${ID2}.txt
    titre_haplotypes_output=${r_best_crosses_haplotypes}haplotypes_${ID1}_${ID2}.txt

    v1=${titre_genotyping_input}
    v2=${titre_best_crosses_input}
    v3=${titre_haplotypes_output}

    Rscript ${r_scripts}convert_geno_to_haplo.R ${v1} ${v2} ${v3}
fi









for rr in $(seq 1 ${nb_run})
do



    next_generation=$((${generation} +1))



   
    ID3=rr${rr}
    
  
    
    job_out=${r_log_best_crosses}best_crosses_2_${ID1}_${ID2}_${ID3}.out
    job_name=${ID3}
    job=$(sbatch -o ${job_out} -J ${job_name} -c ${nbcores} --time=20:00:00 --mem-per-cpu=10G --parsable ${r_scripts}best_crosses_2.sh ${base} ${generation} ${type} ${population} ${critere} ${affixe} ${rr})
    echo "${job_out} =" >> ${file_jobs}
    echo "${job}" >> ${file_jobs}





done



sed -i '/^$/d' ${file_jobs}
while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
do    
    sleep 1s
done

set +H
k=0
for rr in $(seq 1 ${nb_run})
        do


        next_generation=$((${generation} +1))


        ID1=g${next_generation}_${motif}_${population}
        ID2=${critere}_${affixe}
        ID3=rr${rr}


        
        
        if [ ${k} -eq 0 ]
            then          


            if [ ! -f ${r_best_crosses_pedigree}pedigree_${ID1}_${ID2}_${ID3}.txt ];
                then
                echo "error ${ID1}_${ID2}_${ID3} not found!"
                k=-1

            else
                cat ${r_best_crosses_pedigree}pedigree_${ID1}_${ID2}_${ID3}.txt > ${r_best_crosses_pedigree}pedigree_${motif}_${population}_${critere}_${affixe}_allg_allrr.txt
                cat ${r_best_crosses_lines}lines_${ID1}_${ID2}_${ID3}.txt > ${r_best_crosses_lines}lines_${motif}_${population}_${critere}_${affixe}_allg_allrr.txt
            fi        




            
            

            
        else
        
        
            if [ ! -f ${r_best_crosses_pedigree}pedigree_${ID1}_${ID2}_${ID3}.txt ]
                then
                echo "error ${ID1}_${ID2}_${ID3} not found!"

            else
                tail -n+2 ${r_best_crosses_pedigree}pedigree_${ID1}_${ID2}_${ID3}.txt >> ${r_best_crosses_pedigree}pedigree_${motif}_${population}_${critere}_${affixe}_allg_allrr.txt
                tail -n+2 ${r_best_crosses_lines}lines_${ID1}_${ID2}_${ID3}.txt >> ${r_best_crosses_lines}lines_${motif}_${population}_${critere}_${affixe}_allg_allrr.txt
            fi     
        

        fi
        
        k=$((${k} + 1))
        
        # rm ${r_best_crosses_lines}ped_${ID1}_${ID2}_${ID3}.txt
        # rm ${r_best_crosses_lines}lines_${ID1}_${ID2}_${ID3}.txt
done



# rm ${r_value_crosses_crosses}crosses_${ID1}.txt
# rm ${r_best_crosses}crosses_filtered_${ID1}_${ID2}_raw.txt
# rm ${r_best_crosses}best_crosses_${ID1}_${ID2}.txt
date +'%Y-%m-%d-%T'
