#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'



base=${1}

simulation=${2}

method=${3}

type=${4}


source ${base}



r_log=${r_log_value_crosses_gblup}${type}/
r_save=${r_value_crosses_gblup}${type}/



r_save2=${r_save}temp/
rm -rf ${r_save}
mkdir -p ${r_save2}
mkdir -p ${r_log}
typeshort=$(echo ${type} | sed "s/_/./g" | sed "s/marker.//g")
echo ${type}



# goal
# estimate GEBV from pheno + geno ; estimate markers effects ; predict GEBV from marker effects

# input files
# snp.txt from prepare_phenotypes_and_markers.sh
# blues.txt from prepare_phenotypes_and_markers.sh
# map.txt from prepare_phenotypes_and_markers.sh
# weights.txt from prepare_phenotypes_and_markers.sh

# output files
# gebv.txt from predf90
# snp_effects from postGSf90
# id_lines_2 from renumf90
# blups.txt from blupf90

ulimit -s unlimited
export OMP_STACKSIZE=64M

cd ${r_save2}
cp ${r_blupf90}renumf90 ${r_save2}
cp ${r_blupf90}airemlf90 ${r_save2}
cp ${r_blupf90}blupf90 ${r_save2}
cp ${r_blupf90}postGSf90 ${r_save2}
cp ${r_blupf90}predf90 ${r_save2}





type2=$(echo ${type} | sed "s/_g.*$//g" | sed "s/marker_//g")

if [ ${simulation} == "FALSE" ]
    then
    titre_lines=${r_prepare}lines.txt
    type2=${type}
    if [ ${method} == "ldak" ]
        then
        
        # Step 1 : extract LDAK genomic matrix

        titre_genotyping_matrice_parents=${r_prepare}genotyping.txt
        titre_markers=${r_prepare}markers.txt
        titre_markers_output=${r_save}for_LDAK.map
        titre_genotyping_output=${r_save}for_LDAK.ped


        v1=${titre_genotyping_matrice_parents}
        v2=${titre_markers}
        v3=${titre_markers_output}
        v4=${titre_genotyping_output}



        # Rscript ${r_scripts}prepare_for_LDAK.R ${v1} ${v2} ${v3} ${v4}



        #plink --file ${r_save}for_LDAK --recode --noweb --out ${r_save}for_LDAK2 >> ${r_log}plink.out
        #plink --file ${r_save}for_LDAK2 --noweb --make-bed --out ${r_save}for_LDAK3 >> ${r_log}plink.out
        cp /work2/genphyse/dynagen/adanguy/croisements/050321/value_crosses/for_LDAK* ${r_save}


        /work/adanguy/ldak5.1.linux --cut-weights sections --bfile ${r_save}for_LDAK3 --window-cm 1 --section-cm 1 --buffer-cm 1 >> ${r_log}ldak.out
        /work/adanguy/ldak5.1.linux --calc-weights-all sections --bfile ${r_save}for_LDAK3  >> ${r_log}ldak.out 
        /work/adanguy/ldak5.1.linux --calc-kins-direct LDAK-Thin --bfile ${r_save}for_LDAK3 --weights ${r_save2}sections/weights.all --power -1 --kinship-raw YES >> ${r_log}ldak.out #power? 
        #/work/adanguy/ldak5.1.linux --linear single4 --bfile ${r_save}for_LDAK3 --pheno ${r_save}for_LDAK.txt --grm LDAK-Thin  >> ${r_log}ldak.out
        #/work/adanguy/ldak5.1.linux --calc-tagging ldak.thin --bfile ${r_save}for_LDAK3 --weights ${r_save2}sections/weights.all --power -.25 --window-cm 1 --save-matrix YES  >> ${r_log}ldak.out
        #/work/adanguy/ldak5.1.linux --sum-hers ldak.thin --tagfile ldak.thin.tagging --summary single4.summaries --matrix ldak.thin.matrix  >> ${r_log}ldak.out
        #/work/adanguy/ldak5.1.linux --ridge ridge --pheno ${r_save}for_LDAK.txt --bfile ${r_save}for_LDAK3 --ind-hers ldak.thin.ind.hers  >> ${r_log}ldak.out
        #/work/adanguy/ldak5.1.linux --calc-scores scores --scorefile ridge.effects --bfile ${r_save}for_LDAK3 --power 0  >> ${r_log}ldak.out
        cp ${r_save2}LDAK-Thin.grm.raw ${r_save}
        cat ${r_save2}sections/weights.all | cut -f2 -d" " | tail -n+2 > ${r_save}weights_ldak.txt
        
        
        titre_l=${r_save2}LDAK-Thin.grm.raw
        titre_output=${r_save}g_user

        v1=${titre_l}
        v2=${titre_output}
        Rscript ${r_scripts}convert_matrix.R ${v1} ${v2}
        
        cp ${r_save}g_user ${r_save2}g_user
        
        
    fi    

elif [ ${simulation} == "TRUE" ]
    then
    titre_lines=${r_value_crosses}lines_estimated.txt
    
      if [ ${method} == "ldak" ]
        then
        
        # Step 1 : extract LDAK genomic matrix

        titre_genotyping_matrice_parents=${r_prepare}genotyping.txt
        titre_markers=${r_prepare}markers.txt
        titre_markers_output=${r_save}for_LDAK.map
        titre_genotyping_output=${r_save}for_LDAK.ped


        v1=${titre_genotyping_matrice_parents}
        v2=${titre_markers}
        v3=${titre_markers_output}
        v4=${titre_genotyping_output}



        # Rscript ${r_scripts}prepare_for_LDAK.R ${v1} ${v2} ${v3} ${v4}



        #plink --file ${r_save}for_LDAK --recode --noweb --out ${r_save}for_LDAK2 >> ${r_log}plink.out
        #plink --file ${r_save}for_LDAK2 --noweb --make-bed --out ${r_save}for_LDAK3 >> ${r_log}plink.out
        cp /work2/genphyse/dynagen/adanguy/croisements/050321/value_crosses/for_LDAK* ${r_save}
        
        type3=$(echo ${type} | sed "s/_gldak//g" | sed "s/marker_//g")
        cat ${r_value_crosses_simulate_qtls}/${type3}/lines_${type3}.txt | grep -e "pheno" -e "used_as_parent" | cut -f7 | tail -n+2 > ${r_save}temp.txt
        
        cut -f1-2 ${r_save}for_LDAK.txt -d" " > ${r_save}temp2.txt
        paste ${r_save}temp2.txt ${r_save}temp.txt > ${r_save}for_LDAK.txt


        /work/adanguy/ldak5.1.linux --cut-weights sections --bfile ${r_save}for_LDAK3 --window-cm 10 --section-cm 10 --buffer-cm 1 >> ${r_log}ldak.out
        /work/adanguy/ldak5.1.linux --calc-weights-all sections --bfile ${r_save}for_LDAK3  >> ${r_log}ldak.out 
        /work/adanguy/ldak5.1.linux --calc-kins-direct LDAK-Thin --bfile ${r_save}for_LDAK3 --weights ${r_save2}sections/weights.all --power 1 --kinship-raw YES >> ${r_log}ldak.out #power? 
        #/work/adanguy/ldak5.1.linux --linear single4 --bfile ${r_save}for_LDAK3 --pheno ${r_save}for_LDAK.txt --grm LDAK-Thin >> ${r_log}ldak.out
        #/work/adanguy/ldak5.1.linux --calc-tagging ldak.thin --bfile ${r_save}for_LDAK3 --weights ${r_save2}sections/weights.all --power -.25 --window-cm 1 --save-matrix YES >> ${r_log}ldak.out
        #/work/adanguy/ldak5.1.linux --sum-hers ldak.thin --tagfile ldak.thin.tagging --summary single4.summaries --matrix ldak.thin.matrix >> ${r_log}ldak.out
        #/work/adanguy/ldak5.1.linux --ridge ridge --pheno ${r_save}for_LDAK.txt --bfile ${r_save}for_LDAK3 --ind-hers ldak.thin.ind.hers >> ${r_log}ldak.out
        #/work/adanguy/ldak5.1.linux --calc-scores scores --scorefile ridge.effects --bfile ${r_save}for_LDAK3 --power 0 >> ${r_log}ldak.out
        cp ${r_save2}LDAK-Thin.grm.raw ${r_save}
        cat ${r_save2}sections/weights.all | cut -f2 -d" " | tail -n+2 > ${r_save}weights_ldak.txt
        
        
        titre_l=${r_save2}LDAK-Thin.grm.raw
        titre_output=${r_save}g_user

        v1=${titre_l}
        v2=${titre_output}
        Rscript ${r_scripts}convert_matrix.R ${v1} ${v2}
        
        cp ${r_save}g_user ${r_save2}g_user
      
fi

fi
    
  <<COMMENTS      
 
if [ ${method} == "ldak" ]
    then
    

    titre=${r_save2}scores.profile
    titre_output=${r_save}lines_${type}.txt
    
    v1=${titre}
    v2=${type2}_gldak
    v3=${titre_output}

    Rscript ${r_scripts}for_ldak.R ${v1} ${v2} ${v3}
        
elif [ ${method} == "basic" ]
    then

COMMENTS


# STEP 2 : run GBLUP


titre_markers=${r_prepare}markers.txt
titre_genotyping=${r_prepare}genotyping.txt
titre_phenotyping_blupf90=p${typeshort}.txt
titre_markers_blupf90=m${typeshort}.txt
titre_genotyping_blupf90=s${typeshort}.txt
titre_weights_blupf90=w${typeshort}.txt
titre_function_sort_genotyping_matrix=${r_scripts}sort_genotyping_matrix.R
titre_function_subset_markers=${r_scripts}subset_markers.R



v1=${titre_lines}
v2=${titre_markers}
v3=${titre_genotyping}
v4=${titre_phenotyping_blupf90}
v5=${titre_markers_blupf90}
v6=${titre_genotyping_blupf90}
v7=${titre_weights_blupf90}
v8=${titre_function_sort_genotyping_matrix}
v9=${titre_function_subset_markers}
v10=${population_ref}
v11=${type2}


Rscript ${r_scripts}prepare_for_blupf90.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11}



# replace value in blupf90 parameter file for estimates from diagonal model
cp ${r_scripts}renumf90.par ${r_log}renumf90_${type}.par




sed -i "s|.*datafilepath.*|${titre_phenotyping_blupf90}|" ${r_log}renumf90_${type}.par
sed -i "s|mapfilepath|${titre_markers_blupf90}|" ${r_log}renumf90_${type}.par
sed -i "s|.*snpfilepath.*|${titre_genotyping_blupf90}|" ${r_log}renumf90_${type}.par
sed -i "s|weightsfilepath|${titre_weights_blupf90}|" ${r_log}renumf90_${type}.par

${r_save2}renumf90 ${r_log}renumf90_${type}.par > ${r_log}renumf90_${type}_1.out

# Use the first estimates to estimate variance components of GBLUP model

cp ${r_save2}renf90.par ${r_log}renf90_${type}.par

if [ ${method} == "ldak" ]
    then
    rm ${titre_weights_blupf90}
    cp ${r_value_crosses_gblup}marker_simFALSE_allcm_gldak/g_user .
    sed -i "s|add_animal|user_file_inv|" ${r_log}renf90_${type}.par
    sed -i "/weighted/s/.*//" ${r_log}renf90_${type}.par
    sed -i "/tunedG/s/.*//" ${r_log}renf90_${type}.par
    sed -i "/SNP_file/s/.*//" ${r_log}renf90_${type}.par
    sed -i "/AlphaBeta/s/.*//" ${r_log}renf90_${type}.par
    sed -i "s/renadd01.ped/g_user/" ${r_log}renf90_${type}.par

    
fi

<<COMMENTS

if [ ${simulation} == "FALSE" ]
    then
        if [ ${method} == "ldak" ]
        then
        
        cp ${r_save}weights_ldak.txt ${titre_weights_blupf90}
        fi
elif [ ${simulation} == "TRUE" ]
    then
        if [ ${method} == "ldak" ]
        then
        cp ${r_value_crosses_gblup}marker_simFALSE_allcm_gldak/weights_ldak.txt ${titre_weights_blupf90}
        fi
fi
        
        
COMMENTS





############################### temporaire



# add user_file_inv under random; remove snp
${r_save2}airemlf90 ${r_log}renf90_${type}.par > ${r_log}airemlf90_${type}.out





cp ${r_save2}solutions ${r_save}blups_${type}.txt
titre_snp_effects=${r_save}snp_sol_${type}.txt
titre_gebv=${r_save}blups_${type}.txt
titre_markers_output=${r_save}markers_${type}.txt
titre_lines_output=${r_save}lines_${type}.txt
titre_lines=${r_prepare}lines.txt
# subset=all


v1=${titre_gebv}
v2=${titre_snp_effects}
v3=${titre_lines}
v4=${titre_markers}
v5=${titre_markers_output}
v6=${titre_lines_output}
v7=${type}

Rscript ${r_scripts}after_blupf90_test_ldak.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7}



###################" temporaire


<<COMMENTS
# Extract estimates for GBLUP model

genetic_variance=$(grep "Final Estimates" ${r_log}airemlf90_${type}.out  -A8 | head -n3 | tail -n1 | sed "s/ //g")
residual_variance=$(grep "Final Estimates" ${r_log}airemlf90_${type}.out  -A8 | head -n5 | tail -n1 | sed "s/ //g")

echo "genetic and residual variance"
echo ${genetic_variance}
echo ${residual_variance}

cp ${r_scripts}renumf90.par ${r_log}renumf90_${type}.par





sed -i "s|.*datafilepath.*|${titre_phenotyping_blupf90}|" ${r_log}renumf90_${type}.par
sed -i "s|mapfilepath|${titre_markers_blupf90}|" ${r_log}renumf90_${type}.par
sed -i "s|.*snpfilepath.*|${titre_genotyping_blupf90}|" ${r_log}renumf90_${type}.par
sed -i "s|weightsfilepath|${titre_weights_blupf90}|" ${r_log}renumf90_${type}.par


sed -i "/genetic_variance/s/.*/${genetic_variance}/" ${r_log}renumf90_${type}.par
sed -i "/residual_variance/s/.*/${residual_variance}/" ${r_log}renumf90_${type}.par



# Launch data formatting and GBLUP model

${r_save2}renumf90 ${r_log}renumf90_${type}.par > ${r_log}renumf90_${type}_2.out

cp ${r_save2}renf90.par ${r_log}renf90_${type}.par
# remove save ascii option

${r_save2}blupf90 ${r_log}renf90_${type}.par > ${r_log}blupf90_${type}.out


# Estimate SNP effect
cp ${r_log}renf90_${type}.par ${r_log}postGSf90_${type}.par


sed -i "/EM-REML/s/.*//" ${r_log}postGSf90_${type}.par
sed -i "/OPTION saveGInverse/s/.*/OPTION readGInverse/" ${r_log}postGSf90_${type}.par
sed -i "/OPTION saveA22Inverse/s/.*/OPTION readA22Inverse/" ${r_log}postGSf90_${type}.par



${r_save2}postGSf90 ${r_log}postGSf90_${type}.par > ${r_log}postGSf90_${type}.out


echo ${titre_genotyping_blupf90} | ${r_save2}predf90 > ${r_log}predf90_${type}.out



cp ${r_save2}solutions ${r_save}blups_${type}.txt
cp ${r_save2}SNP_predictions ${r_save}SNP_predictions_${type}.txt
cp ${r_save2}snp_sol ${r_save}snp_sol_${type}.txt
# snp_pred is a very special file. it is the only one recognized by blupf90 when estimating breeding value from genotypes. I think its name cannot be changed.
cp ${r_save2}snp_pred ${r_save}snp_pred_${type}.txt



titre_snp_effects=${r_save}snp_sol_${type}.txt
titre_gebv=${r_save}SNP_predictions_${type}.txt
titre_markers_output=${r_save}markers_${type}.txt
titre_lines_output=${r_save}lines_${type}.txt
titre_lines=${r_prepare}lines.txt
# subset=all


v1=${titre_gebv}
v2=${titre_snp_effects}
v3=${titre_lines}
v4=${titre_markers}
v5=${titre_markers_output}
v6=${titre_lines_output}
v7=${type}

Rscript ${r_scripts}after_blupf90.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7}


fi
COMMENTS




cd ${r_save}
rm -rf ${r_save2}
date +'%Y-%m-%d-%T'
