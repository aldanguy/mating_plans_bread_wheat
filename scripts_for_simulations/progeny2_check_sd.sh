#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
export LC_COLLATE=C
export LC_ALL=C
ulimit -s unlimited
export OMP_STACKSIZE=64M





base=${1}
source ${base}
r=${2}
simulation=${3}
qtls_info=${4}
heritability=${5}
qtls=${6}
genomic=${7}
population=${8}
genetic_map=${9}
population_ID=${10}



echo ${base}
echo ${r}
echo ${simulation}
echo ${qtls_info}
echo ${heritability}
echo ${qtls}
echo ${genomic}
echo ${population}
echo ${genetic_map}



### first test
constraints=CONSTRAINTS
criterion=check

ID=s${simulation}_i${qtls_info}_q${qtls}_h${heritability}_g${genomic}_p${population}_n${population_ID}_m${genetic_map}_${constraints}
ID2=s${simulation}_iTRUE_q${qtls}_hNA_gNA_p${population}_n${population_ID}_m${genetic_map}_${constraints}


r_check_sd=${r}check_sd/
r_progeny_temp=${r_check_sd}progeny/temp/${ID}/



r_ref=${r_check_sd}


mkdir -p ${r_ref}



if [ -d "${r_progeny_temp}" ]
then
rm -rf ${r_progeny_temp}
fi
mkdir -p ${r_progeny_temp}
cd ${r_progeny_temp}





titre_criteria_GEBV=${r}criteria/criteria_${ID}_no_filter.txt
titre_criteria_TBV=${r}criteria/criteria_${ID2}_no_filter.txt

titre_mating_plan=${r_ref}mating_plan_${ID}_${criterion}.txt
titre_snp_pred=${r}gblup/raw/snp_pred_${ID}.txt
titre_genetic_map_used=${r_results}markers_${genetic_map}.txt

titre_TBV_progeny=${r_ref}TBV_progeny_${ID}_${criterion}.txt
titre_GEBV_progeny=${r_ref}GEBV_progeny_${ID}_${criterion}.txt
titre_genotypes_progeny=${r_progeny_temp}genotypes_progeny_${ID}_${criterion}.txt
titre_pedigree_progeny_temp=${r_progeny_temp}pedigree_progeny_temp_${ID}_${criterion}.txt
titre_pedigree_progeny=${r_ref}pedigree_progeny_${ID}_${criterion}.txt





if [ ${simulation} == "TRUE" ]
then

    


if [ ${qtls_info} == "TRUE" ] && [ ${population} == "unselected" ]
then

titre_haplotypes_used=${titre_haplotypes_parents0}
titre_markers_qtls=${r}markers/markers_QTLs_${ID}.txt
titre_TBV_parents=${r}parents/TBV_first_generation_${ID}.txt



elif [ ${qtls_info} == "TRUE" ] && [ ${population} == "selected" ]
then

titre_haplotypes_used=${r}parents/haplotypes_last_generation_${ID}.txt
titre_markers_qtls=${r}markers/markers_QTLs_${ID}.txt
titre_TBV_parents=${r}parents/TBV_last_generation_${ID}.txt


elif [ ${qtls_info} == "ESTIMATED" ] && [ ${population} == "unselected" ]
then


titre_haplotypes_used=${titre_haplotypes_parents0}
titre_markers_qtls=${r}markers/markers_QTLs_${ID}.txt
titre_GEBV_parents=${r}parents/GEBV_parents_${ID}.txt
titre_TBV_parents=${r}parents/TBV_first_generation_${ID}.txt
titre_markers_used_blupf90=${titre_markers_qtls}




elif [ ${qtls_info} == "ESTIMATED" ] && [ ${population} == "selected" ]
then


titre_haplotypes_used=${r}parents/haplotypes_last_generation_${ID}.txt
titre_GEBV_parents=${r}parents/GEBV_parents_${ID}.txt
titre_TBV_parents=${r}parents/TBV_last_generation_${ID}.txt
titre_markers_qtls=${r}markers/markers_QTLs_${ID}.txt
titre_markers_used_blupf90=${titre_markers_qtls}





fi



elif [ ${simulation} == "FALSE" ]
then


titre_haplotypes_used=${titre_haplotypes_parents0}

    titre_markers_used_blupf90=${titre_markers0}
titre_GEBV_parents=${titre_GEBV_parents0}


fi

colonne_PROBA_GEBV=$(head ${titre_GEBV_parents} -n1 | sed "s/\t/\n/g" | grep -n "value" | sed "s/:.*//g")
selection_treshold_PROBA_GEBV=$( cut -f${colonne_PROBA_GEBV} ${titre_GEBV_parents} | tail -n+2 | sort -g | tail -n1) # best GEBV

colonne_PROBA_TBV=$(head ${titre_TBV_parents} -n1 | sed "s/\t/\n/g" | grep -n "value" | sed "s/:.*//g")
selection_treshold_PROBA_TBV=$( cut -f${colonne_PROBA_TBV} ${titre_TBV_parents} | tail -n+2 | sort -g | tail -n1) # best GEBV


titre_crosses_input=${titre_criteria_GEBV}
nbcrosses=20
nbprogeny=200
titre_mating_plan_output=${titre_mating_plan}






v1=${titre_crosses_input}
v2=${nbcrosses}
v3=${nbprogeny}
v4=${titre_mating_plan_output}


Rscript ${r_scripts}select_crosses_for_check_sd_predictions.R ${v1} ${v2} ${v3} ${v4}








titre_markers_input=${titre_genetic_map_used}
titre_mating_plan_base_input=${titre_mating_plan}
titre_haplo_input=${titre_haplotypes_used}
num_simulation=1
titre_genotypes_output=${titre_genotypes_progeny}
titre_progeny_pedigree_output=${titre_pedigree_progeny_temp}






v1=${titre_markers_input}
v2=${titre_mating_plan_base_input}
v3=${titre_haplo_input}
v4=${num_simulation}
v5=${titre_genotypes_output}
v6=${titre_progeny_pedigree_output}


Rscript ${r_scripts}progeny.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6}







########################################## STEP 2 : GEBV

if [ ${qtls_info} == "ESTIMATED" ]
then


   

    titre_phenotyping_blupf90=${r_progeny_temp}p.txt
    titre_markers_blupf90=${r_progeny_temp}m.txt
    titre_genotyping_blupf90=${r_progeny_temp}s.txt
    titre_weights_blupf90=${r_progeny_temp}w.txt
    titre_genotypes_used=${titre_genotypes_progeny}
    titre_phenotypes_progeny=${titre_pedigree_progeny_temp}
    


    v1=${titre_phenotypes_progeny} # completely disconnected from analysis
    v2=${titre_markers_used_blupf90}
    v3=${titre_genotypes_used}
    v4=${titre_phenotyping_blupf90}
    v5=${titre_markers_blupf90}
    v6=${titre_genotyping_blupf90}
    v7=${titre_weights_blupf90}

    echo "STEP 2.1 : prepare_for_BLUPf90"

    Rscript ${r_scripts}prepare_for_BLUPf90.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7}
    
    cp ${titre_snp_pred} ${r_progeny_temp}snp_pred
    cp ${r_blupf90}predf90 ${r_progeny_temp}
    echo s.txt | ${r_progeny_temp}predf90


    

    
    titre_gebv_input=${r_progeny_temp}SNP_predictions
    titre_lines_input=${titre_pedigree_progeny_temp}
    titre_lines_output=${titre_GEBV_progeny}





    v1=${titre_gebv_input}
    v2=${titre_lines_input}
    v3=${titre_lines_output}


    Rscript ${r_scripts}after_BLUPf90_check.R ${v1} ${v2} ${v3}
    
  


    titre_lines_input=${titre_GEBV_progeny}
    titre_pedigree_input=${titre_pedigree_progeny_temp}
    titre_crosses_input=${titre_criteria_GEBV}
    Dmax_EMBV=60
    titre_graph=${r0_graphs}sd_predictions_${ID}_GEBV.png



    v1=${titre_lines_input}
    v2=${titre_pedigree_input}
    v3=${titre_crosses_input}
    v4=${selection_treshold_PROBA_GEBV}
    v5=${Dmax_EMBV}
    v6=${within_family_selection_rate_UC1}
    v7=${within_family_selection_rate_UC2}
    v8=${titre_graph}

    Rscript ${r_scripts}check_sd_predictions.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8}




    
    
    
fi

if [ ${simulation} == "TRUE" ]
then




    titre_genotypes_input=${titre_genotypes_progeny}
    titre_qtls_input=${titre_markers_qtls}
    titre_tbv_output=${titre_TBV_progeny}
    

    
    v1=${titre_genotypes_input}
    v2=${titre_qtls_input}
    v3=${titre_tbv_output}


    Rscript ${r_scripts}compute_tbv.R ${v1} ${v2} ${v3}
    
     titre_lines_input=${titre_TBV_progeny}
    titre_pedigree_input=${titre_pedigree_progeny_temp}
    titre_crosses_input=${titre_criteria_TBV}
    Dmax_EMBV=60
    titre_graph=${r0_graphs}sd_predictions_${ID}_TBV.png



    v1=${titre_lines_input}
    v2=${titre_pedigree_input}
    v3=${titre_crosses_input}
    v4=${selection_treshold_PROBA_TBV}
    v5=${Dmax_EMBV}
    v6=${within_family_selection_rate_UC1}
    v7=${within_family_selection_rate_UC2}
    v8=${titre_graph}

    Rscript ${r_scripts}check_sd_predictions.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8}



   





fi

colonne_value=$(head ${titre_pedigree_progeny_temp} -n1 | sed "s/\t/\n/g" | grep -n "^value$" | sed "s/:.*//g")

cut --complement -f${colonne_value} ${titre_pedigree_progeny_temp} > ${titre_pedigree_progeny}


    



cd ${r0}

rm -rf ${r_progeny_temp}









date +'%Y-%m-%d-%T'
