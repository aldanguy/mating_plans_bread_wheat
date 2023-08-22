#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'
export LC_COLLATE=C
export LC_ALL=C
ulimit -s unlimited
export OMP_STACKSIZE=64M


# change gblup to GBLUP


base=${1}





source ${base}


r=${2}
r_log=${3}
ID=${4}
simulation=${5}
qtls_info=${6}
qtls=${7}
heritability=${8}
genomic=${9}
population=${10}
population_ID=${11}
titre_genetic_values_used=${12}
titre_markers_used=${13}
titre_genotypes_used=${14}
titre_LDAK_used=${15}
titre_haplotypes_used=${16}




echo ${base}
echo ${r}
echo ${r_log}
echo ${simulation}
echo ${qtls_info}
echo ${qtls}
echo ${heritability}
echo ${genomic}
echo ${population}
echo ${population_ID}
echo ${ID}
echo ${titre_genetic_values_used}
echo ${titre_markers_used}
echo ${titre_genotypes_used}
echo ${titre_LDAK_used}
echo ${titre_haplotypes_used}


      


# Directories

r_gblup=${r}gblup/
r_gblup_temp=${r_gblup}temp/${ID}/
r_gblup_raw=${r_gblup}raw/
r_gblup_param=${r_log}GBLUP_param/
r_LDAK=${r}LDAK/
r_LDAK_temp=${r_LDAK}temp/${ID}/
r_parents=${r}parents/
r_markers=${r}markers/



cd ${r}

# files specific of unselected scripts


########################################## PART 1 : Generate files


# Step 1 : names of files and some variables
# not of all of them will be used, this depends on the scenario






titre_markers_qtls=${r_markers}markers_QTLs_${ID}.txt


titre_function_calcul_index_variance_crosses=${r_scripts}calcul_index_variance_crosses.R



titre_genetic_variance=${r_gblup}genetic_variance_${ID}_TRUE.txt

param_renumf90_1=${r_gblup_param}renumf90_${ID}_TRUE.par
log_renumf90_1=${r_log}renumf90_${ID}_TRUE.txt
param_airemlf90=${r_gblup_param}renf90_${ID}_TRUE.par
log_airemlf90=${r_log}airemlf90_${ID}_TRUE.txt
param_renumf90_2=${r_gblup_param}postGSf90_1_${ID}_TRUE.par
log_renumf90_2=${r_log}postgsf90_1_${ID}_TRUE.txt
param_postGSf90=${r_gblup_param}postGSf90_2_${ID}_TRUE.par
log_postGSf90=${r_log}postGSf90_2_${ID}_TRUE.txt
log_predf90=${r_log}predf90_${ID}_TRUE.out








    if [ ${population} == "unselected" ]
    then


    titre_tbv_to_convert_to_phenotypes=${r_parents}TBV_first_generation_${ID}.txt

    titre_phenotypes_used=${r_parents}TBV_first_generation_${ID}.txt

    titre_markers_used_blupf90=${titre_markers_qtls}



    elif [ ${population} == "selected" ]
    then


    titre_tbv_to_convert_to_phenotypes=${r_parents}TBV_last_generation_${ID}.txt
 
    titre_phenotypes_used=${r_parents}TBV_last_generation_${ID}.txt
        titre_markers_used_blupf90=${titre_markers_qtls}






   fi


    



# Step 2 : simulate data

echo "STEP 1 : prepare data"



    echo "STEP 1.1 : simulate QTLs"


    titre_markers_input=${titre_markers0}
    titre_genotyping_input=${titre_genotypes_parents0}
    titre_lines_input=${titre_GEBV_parents0}
    # qtls
    # population_ID
    titre_markers_output=${titre_markers_qtls}
    titre_tbv_output=${r_parents}TBV_first_generation_${ID}.txt


    v1=${titre_markers_input}
    v2=${titre_genotyping_input}
    v3=${titre_lines_input}
    v4=${qtls}
    v5=${population_ID}
    v6=${titre_markers_output}
    v7=${titre_tbv_output}

    Rscript ${r_scripts}simulate_QTLs.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7}  
    
    
    if [ ${population} == "selected" ]
    then




        echo "STEP 1.2 : simulate selected population"


        titre_markers_qtls_input=${titre_markers_qtls}
        titre_tbv_starting_parents_input=${r_parents}TBV_first_generation_${ID}.txt
        titre_haplotypes_starting_parents_input=${titre_haplotypes0}
        #progeny
        #Kmin
        # selection_rate_for_UC3 
        # D
        nb_cycles=3
        titre_tbv_candidate_parents_output=${r_parents}TBV_last_generation_${ID}.txt
        titre_genotypes_candidate_parents_output=${r_parents}genotypes_last_generation_${ID}.txt




        v1=${titre_markers_qtls_input}
        v2=${titre_tbv_starting_parents_input}
        v3=${titre_haplotypes_parents0}
        v4=300
        v5=${selection_rate_for_UC3}
        v6=3300
        v7=${nb_cycles}
        v8=${titre_tbv_candidate_parents_output}
        v9=${titre_genotypes_candidate_parents_output}





        Rscript ${r_scripts}first_selection_cycles.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} 
        
     echo "STEP 1.3 : convert genotypes to haplotypes"
     
     
    



    fi
  
    
    



    echo "STEP 2 : GBLUP"

    if [ -d "${r_gblup_temp}" ]
    then
        rm -rf ${r_gblup_temp}
    fi
    mkdir -p ${r_gblup_temp}
    cd ${r_gblup_temp}


    # goal
    # estimate GEBV from pheno + geno ; estimate markers effects ; predict GEBV from marker effects

    # input files
    # snp.txt from prepare_phenoIDs_and_markers.sh
    # blues.txt from prepare_phenoIDs_and_markers.sh
    # map.txt from prepare_phenoIDs_and_markers.sh
    # weights.txt from prepare_phenoIDs_and_markers.sh

    # output files
    # GEBV.txt from predf90
    # snp_effects from postGSf90
    # id_lines_2 from renumf90
    # blups.txt from blupf90


    cp ${r_blupf90}renumf90 ${r_gblup_temp}
    cp ${r_blupf90}airemlf90 ${r_gblup_temp}
    cp ${r_blupf90}postGSf90 ${r_gblup_temp}
    cp ${r_blupf90}predf90 ${r_gblup_temp}




    titre_phenotyping_blupf90=p.txt
    titre_markers_blupf90=m.txt
    titre_genotyping_blupf90=s.txt
    titre_weights_blupf90=w.txt
    
    



    v1=${titre_phenotypes_used}
    v2=${titre_markers_used_blupf90}
    v3=${titre_genotypes_used}
    v4=${titre_phenotyping_blupf90}
    v5=${titre_markers_blupf90}
    v6=${titre_genotyping_blupf90}
    v7=${titre_weights_blupf90}

    echo "STEP 2.1 : prepare_for_BLUPf90"

    Rscript ${r_scripts}prepare_for_BLUPf90_TRUE.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7}





    # replace value in blupf90 parameter file for estimates from diagonal model
    cp ${r_scripts}renumf90.par ${param_renumf90_1}




    sed -i "s|.*datafilepath.*|${titre_phenotyping_blupf90}|" ${param_renumf90_1}
    sed -i "s|mapfilepath|${titre_markers_blupf90}|" ${param_renumf90_1}
    sed -i "s|.*snpfilepath.*|${titre_genotyping_blupf90}|" ${param_renumf90_1}
    sed -i "s|weightsfilepath|${titre_weights_blupf90}|" ${param_renumf90_1}

    ${r_gblup_temp}renumf90 ${param_renumf90_1} > ${log_renumf90_1}

    # Use the first estimates to estimate variance components of GBLUP model

    cp ${r_gblup_temp}renf90.par ${param_airemlf90}

    ${r_gblup_temp}airemlf90 ${param_airemlf90} > ${log_airemlf90}


    # Extract estimates for GBLUP model

    genetic_variance=$(grep "Final Estimates" ${log_airemlf90}  -A8 | head -n3 | tail -n1 | sed "s/ //g")
    residual_variance=$(grep "Final Estimates" ${log_airemlf90}  -A8 | head -n5 | tail -n1 | sed "s/ //g")


    cp ${r_scripts}renumf90.par ${param_renumf90_2}




    sed -i "s|.*datafilepath.*|${titre_phenotyping_blupf90}|" ${param_renumf90_2}
    sed -i "s|mapfilepath|${titre_markers_blupf90}|" ${param_renumf90_2}
    sed -i "s|.*snpfilepath.*|${titre_genotyping_blupf90}|" ${param_renumf90_2}
    sed -i "s|weightsfilepath|${titre_weights_blupf90}|" ${param_renumf90_2}




    sed -i "/genetic_variance/s/.*/${genetic_variance}/" ${param_renumf90_2}
    sed -i "/residual_variance/s/.*/${residual_variance}/" ${param_renumf90_2}





    sed -i "/EM-REML/s/.*//" ${param_renumf90_2}
    sed -i "/OPTION saveGInverse/s/.*/OPTION readGInverse/" ${param_renumf90_2}
    sed -i "/OPTION saveA22Inverse/s/.*/OPTION readA22Inverse/" ${param_renumf90_2}
    sed -i "/OPTION missing -999/s/.*//" ${param_renumf90_2}
    sed -i "/OPTION no_quality_control/s/.*//" ${param_renumf90_2}

    ${r_gblup_temp}renumf90 ${param_renumf90_2} > ${log_renumf90_2}

    cp ${r_gblup_temp}renf90.par ${param_postGSf90}


    ${r_gblup_temp}postGSf90 ${param_postGSf90} > ${log_postGSf90}


    echo ${titre_genotyping_blupf90} | ${r_gblup_temp}predf90 > ${log_predf90}



    cp ${r_gblup_temp}solutions ${r_gblup_raw}blups_${ID}.txt
    cp ${r_gblup_temp}SNP_predictions ${r_gblup_raw}SNP_predictions_${ID}.txt
    cp ${r_gblup_temp}snp_sol ${r_gblup_raw}snp_sol_${ID}.txt
    # snp_pred is a very special file. it is the only one recognized by blupf90 when estimating breeding value from genoIDs. I think its name cannot be changed.
    cp ${r_gblup_temp}snp_pred ${r_gblup_raw}snp_pred_${ID}.txt



    echo "STEP 2.2 : after_BLUPf90.R"

        
    titre_GEBV_input=${r_gblup_raw}SNP_predictions_${ID}.txt
    titre_snp_effects_input=${r_gblup_raw}snp_sol_${ID}.txt
    titre_lines_input=${titre_phenotypes_used}
    titre_markers_input=${titre_markers0}
    titre_markers_output=${titre_markers_used}
    titre_lines_output=${titre_genetic_values_used}




    v1=${titre_GEBV_input}
    v2=${titre_snp_effects_input}
    v3=${titre_lines_input}
    v4=${titre_markers_input}
    v5=${titre_markers_output}
    v6=${titre_lines_output}


    Rscript ${r_scripts}after_BLUPf90.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6}


    cd ${r}


    echo -e "simulation\tqtls\tqtls_info\theritability\tgenomic\tpopulation\tpopulation_ID\tgenetic_variance\tresidual_variance" > ${titre_genetic_variance}
    echo -e "${simulation}\t${qtls}\t${qtls_info}\t${heritability}\t${genomic}\t${population}\t${population_ID}\t${genetic_variance}\t${residual_variance}" >> ${titre_genetic_variance}


    head ${titre_genetic_variance}



date +'%Y-%m-%d-%T'




########################################## END
