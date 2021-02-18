#!/bin/bash



base=${1}
# base=/work/adanguy/these/croisements/scripts/base_cr_031120.sh
source ${base}

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


rm ${r_blupf90_blues}*
rm ${r_blupf90_map}*
rm ${r_blupf90_snp}*
rm ${r_blupf90_weights}*

titre_lines=${r_prepare}lines.txt

titre_markers_filtered_subset=${r_value_crosses}markers_filtered_subset.txt


titre_genotyping_matrix_filtered_imputed=${r_prepare}genotyping_matrix_filtered_imputed.txt



titre_phenotyping_data_blupf90=${r_blupf90_blues}blues.txt
titre_map_for_blupf90=${r_blupf90_map}map.txt
titre_genotyping_matrix_for_blupf9=${r_blupf90_snp}snp.txt
titre_weights_for_blupf90=${r_blupf90_weights}weights.txt



v1=${titre_lines}
v2=${titre_markers_filtered_subset}
v3=${titre_genotyping_matrix_filtered_imputed}
v4=${titre_phenotyping_data_blupf90}
v5=${titre_map_for_blupf90}
v6=${titre_genotyping_matrix_for_blupf9}
v7=${titre_weights_for_blupf90}


Rscript ${r_scripts}prepare_for_blupf90.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7}







# replace value in blupf90 parameter file for estimates from diagonal model

cp ${r_scripts}renumf90.par ${r_blupf90}renumf90_parents.par

./renumf90 ${r_blupf90}renumf90_parents.par > ${r_log_value_crosses_gblup}renumf90_parents.out

# Use the first estimates to estimate variance components of GBLUP model

cp ${r_blupf90}renf90.par ${r_blupf90}renf90_parents.par

rm ${r_blupf90}renf90.par

./airemlf90 ${r_blupf90}renf90_parents.par > ${r_log_value_crosses_gblup}airemlf90_parents.out


# Extract estimates for GBLUP model

genetic_variance=$(grep "Final Estimates" ${r_log_value_crosses_gblup}airemlf90_parents.out  -A8 | head -n3 | tail -n1 | sed "s/ //g")
residual_variance=$(grep "Final Estimates" ${r_log_value_crosses_gblup}airemlf90_parents.out  -A8 | head -n5 | tail -n1 | sed "s/ //g")



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

cp ${r_scripts}renumf90.par ${r_blupf90}renumf90_parents.par



sed -i "/genetic_variance/s/.*/${genetic_variance}/" ${r_blupf90}renumf90_parents.par
sed -i "/residual_variance/s/.*/${residual_variance}/" ${r_blupf90}renumf90_parents.par



# Launch data formatting and GBLUP model


./renumf90 ${r_blupf90}renumf90_parents.par > ${r_log_value_crosses_gblup}renumf90_parents2.out

cp ${r_blupf90}renf90.par ${r_blupf90}renf90_parents.par
# cp ${r_blupf90_snp}snp.txt_XrefID ${r}id_lines_2.txt

rm ${r_blupf90}renf90.par

./blupf90 ${r_blupf90}renf90_parents.par > ${r_log_value_crosses_gblup}blupf90_parents.out

cp ${r_blupf90}solutions ${r_value_crosses}blups_parents.txt

# Estimate SNP effect

cp ${r_blupf90}renf90_parents.par ${r_blupf90}postGSf90_parents.par


sed -i "/EM-REML/s/.*//" ${r_blupf90}postGSf90_parents.par
sed -i "/OPTION saveGInverse/s/.*/OPTION readGInverse/" ${r_blupf90}postGSf90_parents.par
sed -i "/OPTION saveA22Inverse/s/.*/OPTION readA22Inverse/" ${r_blupf90}postGSf90_parents.par



./postGSf90 ${r_blupf90}postGSf90_parents.par > ${r_log_value_crosses_gblup}postGSf90_parents.out


echo ${r_blupf90_snp}snp.txt | ./predf90 > ${r_log_value_crosses_gblup}predf90_parents.out



cp ${r_blupf90}SNP_predictions ${r_value_crosses}SNP_predictions_parents.txt
cp ${r_blupf90}snp_sol ${r_value_crosses}snp_sol_parents.txt
cp ${r_blupf90}snp_pred ${r_value_crosses}snp_pred

titre_gebv=${r_value_crosses}SNP_predictions_parents.txt
titre_snp_effects=${r_value_crosses}snp_sol_parents.txt
titre_lines=${r_prepare}lines.txt
titre_markers_filtered_subset=${r_value_crosses}markers_filtered_subset.txt
titre_markers_filtered_subset_estimated=${r_value_crosses}markers_filtered_subset_estimated.txt


v1=${titre_gebv}
v2=${titre_snp_effects}
v3=${titre_lines}
v4=${titre_markers_filtered_subset}
v5=${titre_markers_filtered_subset_estimated}

Rscript ${r_scripts}after_blupf90.R ${v1} ${v2} ${v3} ${v4} ${v5}



cp ${r_blupf90}postGSf90_parents.par ${r_log_value_crosses}
cp ${r_blupf90}renumf90_parents.par ${r_log_value_crosses}
cp ${r_blupf90}renf90_parents.par ${r_log_value_crosses}
