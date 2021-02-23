#!/bin/bash
RANDOM=1



base=${1}



source ${base}




simulation=${2}
subset=${3}
h=${4}
idrun=${5}













if [ ${simulation} == "FALSE" ]
then

    titre_markers=${r_prepare}markers_filtered.txt

    titre_lines=${r_prepare}lines.txt
    ID=sim${simulation}_${subset}cm
    IDshort=${simulation}${subset}
    r_log=${r_log_value_crosses_gblup}sim${simulation}/${subset}cm/
    r_save=${r_value_crosses}blupf90/sim${simulation}/${subset}cm/


elif [ ${simulation} == "TRUE" ]
then

    titre_markers=${r_value_crosses}markers_estimated_qtls.txt
    
    titre_lines=${r_value_crosses}lines_estimated_qtls.txt
    ID=sim${simulation}_${subset}cm_h${h}_r${idrun}
    IDshort=${simulation}${subset}${h}${idrun}
    r_log=${r_log_value_crosses_gblup}sim${simulation}/${subset}cm/h${h}/r${idrun}/
    r_save=${r_value_crosses}blupf90/sim${simulation}/${subset}cm/h${h}/r${idrun}/

fi





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


cd ${r_blupf90}

# Clean folder
rm ${r_blupf90}*.par


rm ${r_blupf90}A22i
rm ${r_blupf90}*.log
rm ${r_blupf90}chrsnp
rm ${r_blupf90}freqdata.count
rm ${r_blupf90}freqdata.count.after.clean
rm ${r_blupf90}Gen_call_rate
rm ${r_blupf90}Gen_conflicts
rm ${r_blupf90}Gi
rm ${r_blupf90}*.ped
rm ${r_blupf90}*.dat
rm ${r_blupf90}*.fields
rm ${r_blupf90}*.par
rm ${r_blupf90}Sft1e1.gnuplot
rm ${r_blupf90}Sft1e1.R
rm ${r_blupf90}*snp*
rm ${r_blupf90}SNP_predictions
rm ${r_blupf90}solutions
rm ${r_blupf90}sum2pq
rm ${r_blupf90}*fort*
rm ${r_blupf90}AI*
rm ${r_blupf90}fspak90.ord
rm ${r_blupf90}renf90.tables


rm ${r_blupf90_pheno}*
rm ${r_blupf90_map}*
rm ${r_blupf90_snp}*
rm ${r_blupf90_weights}*




titre_genotyping_matrix=${r_prepare}genotyping_matrix_filtered_imputed.txt
titre_phenotyping_data_blupf90=${r_blupf90_pheno}p${IDshort}.txt
titre_map_for_blupf90=${r_blupf90_map}m${IDshort}.txt
titre_genotyping_matrix_for_blupf90=${r_blupf90_snp}s${IDshort}.txt
titre_weights_for_blupf90=${r_blupf90_weights}w${IDshort}.txt
# subset=all
titre_function_sort_genotyping_matrix=${r_scripts}sort_genotyping_matrix.R
population=WE
#simulation=TRUE
#run=1


v1=${titre_lines}
v2=${titre_markers}
v3=${titre_genotyping_matrix}
v4=${titre_phenotyping_data_blupf90}
v5=${titre_map_for_blupf90}
v6=${titre_genotyping_matrix_for_blupf90}
v7=${titre_weights_for_blupf90}
v8=${subset}
v9=${titre_function_sort_genotyping_matrix}
v10=${population}
v11=${simulation}
v12=${idrun}
v13=${h}

Rscript ${r_scripts}prepare_for_blupf90.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11} ${v12} ${v13}





# replace value in blupf90 parameter file for estimates from diagonal model

cp ${r_scripts}renumf90.par ${r_blupf90}renumf90_${ID}.par




sed -i "s|.*datafilepath.*|${titre_phenotyping_data_blupf90}|" ${r_blupf90}renumf90_${ID}.par
sed -i "s|mapfilepath|${titre_map_for_blupf90}|" ${r_blupf90}renumf90_${ID}.par
sed -i "s|.*snpfilepath.*|${titre_genotyping_matrix_for_blupf90}|" ${r_blupf90}renumf90_${ID}.par
sed -i "s|weightsfilepath|${titre_weights_for_blupf90}|" ${r_blupf90}renumf90_${ID}.par





${r_blupf90}renumf90 ${r_blupf90}renumf90_${ID}.par > ${r_log}renumf90_${ID}_1.out

# Use the first estimates to estimate variance components of GBLUP model

cp ${r_blupf90}renf90.par ${r_blupf90}renf90_${ID}.par


${r_blupf90}airemlf90 ${r_blupf90}renf90_${ID}.par > ${r_log}airemlf90_${ID}.out


# Extract estimates for GBLUP model

genetic_variance=$(grep "Final Estimates" ${r_log}airemlf90_${ID}.out  -A8 | head -n3 | tail -n1 | sed "s/ //g")
residual_variance=$(grep "Final Estimates" ${r_log}airemlf90_${ID}.out  -A8 | head -n5 | tail -n1 | sed "s/ //g")



rm ${r_blupf90}A22i
rm ${r_blupf90}*.log
rm ${r_blupf90}chrsnp
rm ${r_blupf90}freqdata.count
rm ${r_blupf90}freqdata.count.after.clean
rm ${r_blupf90}Gen_call_rate
rm ${r_blupf90}Gen_conflicts
rm ${r_blupf90}Gi
rm ${r_blupf90}*.ped
rm ${r_blupf90}*.dat
rm ${r_blupf90}*.fields
rm ${r_blupf90}*.par
rm ${r_blupf90}Sft1e1.gnuplot
rm ${r_blupf90}Sft1e1.R
rm ${r_blupf90}*snp*
rm ${r_blupf90}SNP_predictions
rm ${r_blupf90}solutions
rm ${r_blupf90}sum2pq
rm ${r_blupf90}*fort*
rm ${r_blupf90}AI*
rm ${r_blupf90}fspak90.ord
rm ${r_blupf90}renf90.tables


cp ${r_scripts}renumf90.par ${r_blupf90}renumf90_${ID}.par




sed -i "s|.*datafilepath.*|${titre_phenotyping_data_blupf90}|" ${r_blupf90}renumf90_${ID}.par
sed -i "s|mapfilepath|${titre_map_for_blupf90}|" ${r_blupf90}renumf90_${ID}.par
sed -i "s|.*snpfilepath.*|${titre_genotyping_matrix_for_blupf90}|" ${r_blupf90}renumf90_${ID}.par
sed -i "s|weightsfilepath|${titre_weights_for_blupf90}|" ${r_blupf90}renumf90_${ID}.par



sed -i "/genetic_variance/s/.*/${genetic_variance}/" ${r_blupf90}renumf90_${ID}.par
sed -i "/residual_variance/s/.*/${residual_variance}/" ${r_blupf90}renumf90_${ID}.par



# Launch data formatting and GBLUP model


${r_blupf90}renumf90 ${r_blupf90}renumf90_${ID}.par > ${r_log}renumf90_${ID}_2.out

cp ${r_blupf90}renf90.par ${r_blupf90}renf90_${ID}.par
# cp ${r_blupf90_snp}snp.txt_XrefID ${r}id_lines_2.txt


${r_blupf90}blupf90 ${r_blupf90}renf90_${ID}.par > ${r_log}blupf90_${ID}.out


# Estimate SNP effect

cp ${r_blupf90}renf90_${ID}.par ${r_blupf90}postGSf90_${ID}.par


sed -i "/EM-REML/s/.*//" ${r_blupf90}postGSf90_${ID}.par
sed -i "/OPTION saveGInverse/s/.*/OPTION readGInverse/" ${r_blupf90}postGSf90_${ID}.par
sed -i "/OPTION saveA22Inverse/s/.*/OPTION readA22Inverse/" ${r_blupf90}postGSf90_${ID}.par



${r_blupf90}postGSf90 ${r_blupf90}postGSf90_${ID}.par > ${r_log}postGSf90_${ID}.out


echo ${titre_genotyping_matrix_for_blupf90} | ${r_blupf90}predf90 > ${r_log}predf90_${ID}.out


cp ${r_blupf90}solutions ${r_save}blups_${ID}.txt
cp ${r_blupf90}SNP_predictions ${r_save}SNP_predictions_${ID}.txt
cp ${r_blupf90}snp_sol ${r_save}snp_sol_${ID}.txt
# snp_pred is a very special file. it is the only one recognized by blupf90 when estimating breeding value from genotypes. I think its name cannot be changed.
cp ${r_blupf90}snp_pred ${r_save}snp_pred_${ID}.txt

titre_snp_effects=${r_save}snp_sol_${ID}.txt
titre_gebv=${r_save}SNP_predictions_${ID}.txt
titre_markers_output=${r_save}markers_${ID}.txt
titre_lines_output=${r_save}lines_${ID}.txt
# subset=all


v1=${titre_gebv}
v2=${titre_snp_effects}
v3=${titre_lines}
v4=${titre_markers}
v5=${titre_markers_output}
v6=${titre_lines_output}
v7=${simulation}
v8=${subset}
v9=${idrun}
v10=${h}

Rscript ${r_scripts}after_blupf90.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10}



cp ${r_blupf90}postGSf90_${ID}.par ${r_save}
cp ${r_blupf90}renumf90_${ID}.par ${r_save}
cp ${r_blupf90}postGSf90_${ID}.par ${r_save}


rm ${r_blupf90}*.par
rm ${r_blupf90}A22i
rm ${r_blupf90}*.log
rm ${r_blupf90}chrsnp
rm ${r_blupf90}freqdata.count
rm ${r_blupf90}freqdata.count.after.clean
rm ${r_blupf90}Gen_call_rate
rm ${r_blupf90}Gen_conflicts
rm ${r_blupf90}Gi
rm ${r_blupf90}*.ped
rm ${r_blupf90}*.dat
rm ${r_blupf90}*.fields
rm ${r_blupf90}*.par
rm ${r_blupf90}Sft1e1.gnuplot
rm ${r_blupf90}Sft1e1.R
rm ${r_blupf90}*snp*
rm ${r_blupf90}SNP_predictions
rm ${r_blupf90}solutions
rm ${r_blupf90}sum2pq
rm ${r_blupf90}*fort*
rm ${r_blupf90}AI*
rm ${r_blupf90}fspak90.ord
rm ${r_blupf90}renf90.tables


rm ${r_blupf90_pheno}*
rm ${r_blupf90_map}*
rm ${r_blupf90_snp}*
rm ${r_blupf90_weights}*
