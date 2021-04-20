#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'


base=${1}

source ${base}


generation=${2}


file_jobs=${r_log_best_crosses_jobs}jobs_best_crosses_1.txt

types=$(cat ${r_value_crosses}markers_estimated.txt | cut -f7 | sort | uniq | grep -v "type" )
echo ${types[*]}
nbcores=2

population=${population_ref}
k=0
for critere in ${criteres[*]}
    do
    
    for affixe in ${affixes[*]}
        do
        
        for type in ${types[*]}
            do
            
            

        
            k=$((${k} +1))
            echo ${k}
            
  
            
        
        
            motif=$(echo ${type} | sed "s/marker_//g")
            ID1=g${generation}_${motif}_${population}
            ID2=${critere}_${affixe}
             
            echo ${ID1}_${ID2}
            
            job_out=${r_log_best_crosses}best_crosses_1_${ID1}_${ID2}.out
            job_name=${ID1}_${ID2}
            job=$(sbatch -o ${job_out} -J ${job_name} --parsable -c ${nbcores} --mem-per-cpu=10G ${r_scripts}best_crosses_1.sh ${base} ${generation} ${type} ${population} ${critere} ${affixe})
            echo "${job_out}" >> ${file_jobs}
            echo "${job}" >> ${file_jobs}
            
   
            
            
            while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 10 )) 
                do    
                sleep 1s
            done
            
            while (( $(squeue -u adanguy | wc -l) >= ${nb_jobs_allowed} ))
                do    
                sleep 1s
            done
            
            
            
        done
    done
done
    


sed -i '/^$/d' ${file_jobs}
while (( $(squeue -u adanguy | grep -f ${file_jobs} | wc -l) >= 1 )) 
do    
    sleep 1s
done



set +H
k=0
for critere in ${criteres[*]}
    do
    
    for affixe in ${affixes[*]}
        do
        
        for type in ${types[*]}
            do



       
        
        if [ ${k} -eq 0 ]
            then          




            if [ ! -f ${r_best_crosses_pedigree}ped_${motif}_${population}_${critere}_${affixe}_allg_allrr.txt ];
                then
                echo "error ${motif}_${population}_${critere}_${affixe} not found!"
                k=-1

            else
                cat ${r_best_crosses_pedigree}ped_${motif}_${population}_${critere}_${affixe}_allg_allrr.txt > ${r_best_crosses_pedigree}ped_allg_alltypes_allpop_allcriteres_allaffixes_allrr.txt
                cat ${r_best_crosses_lines}lines_${motif}_${population}_${critere}_${affixe}_allg_allrr.txt > ${r_best_crosses_pedigree}lines_allg_alltypes_allpop_allcriteres_allaffixes_allrr.txt

            fi        



            
          
            
        else
        
            if [ ! -f ${r_best_crosses_pedigree}ped_${motif}_${population}_${critere}_${affixe}_allg_allrr.txt ];
                then
                echo "error ${ID1}_${ID2}_${ID3} not found!"

            else
        
                tail -n+2 ${r_best_crosses_pedigree}ped_${motif}_${population}_${critere}_${affixe}_allg_allrr.txt >> ${r_best_crosses_pedigree}ped_allg_alltypes_allpop_allcriteres_allaffixes_allrr.txt
                tail -n+2 ${r_best_crosses_lines}lines_${motif}_${population}_${critere}_${affixe}_allg_allrr.txt >> ${r_best_crosses_pedigree}lines_allg_alltypes_allpop_allcriteres_allaffixes_allrr.txt
            fi     
        

        fi
        
        k=$((${k} + 1))
        
        # rm ${r_best_crosses_pedigree}ped_${motif}_${population}_${critere}_${affixe}_allg_allrr.txt
        # rm ${r_best_crosses_lines}lines_${motif}_${population}_${critere}_${affixe}_allg_allrr.txt
done

done
done







date +'%Y-%m-%d-%T'
