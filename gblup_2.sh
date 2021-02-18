#!/bin/bash



base=${1}
# base=/work/adanguy/these/croisements/scripts/base_cr_031120.sh
source ${base}


subset=${2}

sim=${3}

subset=all
sim=F
generation=0
run=0

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

titre_lines=${r_prepare}lines.txt

titre_markers_filtered_qtls=${r_prepare}markers_filtered.txt
titre_genotyping_matrix_filtered_imputed=${r_prepare}genotyping_matrix_filtered_imputed.txt
titre_phenotyping_data_blupf90=${r_blupf90_pheno}p${subset}cmsim${sim}g${generation}r${run}.txt
titre_map_for_blupf90=${r_blupf90_map}m${subset}cmsim${sim}g${generation}r${run}.txt
titre_genotyping_matrix_for_blupf90=${r_blupf90_snp}s${subset}cmsim${sim}g${generation}r${run}.txt
titre_weights_for_blupf90=${r_blupf90_weights}w${subset}cmsim${sim}g${generation}r${run}.txt
# subset=all
titre_function_sort_genotyping_matrix=${r_scripts}sort_genotyping_matrix.R
population=WE


v1=${titre_lines}
v2=${titre_markers_filtered_qtls}
v3=${titre_genotyping_matrix_filtered_imputed}
v4=${titre_phenotyping_data_blupf90}
v5=${titre_map_for_blupf90}
v6=${titre_genotyping_matrix_for_blupf90}
v7=${titre_weights_for_blupf90}
v8=${subset}
v9=${titre_function_sort_genotyping_matrix}
v10=${population}

Rscript ${r_scripts}prepare_for_blupf90.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10}





# replace value in blupf90 parameter file for estimates from diagonal model

cp ${r_scripts}renumf90.par ${r_blupf90}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.par



sed -i "s|.*datafile.*|${titre_phenotyping_data_blupf90}|" ${r_blupf90}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.par
sed -i "s|.*mapfile.*|${titre_map_for_blupf90}|" ${r_blupf90}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.par
sed -i "s|.*snpfile.*|${titre_genotyping_matrix_for_blupf9}|" ${r_blupf90}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.par
sed -i "s|.*weightsfile.*|${titre_weights_for_blupf90}|" ${r_blupf90}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.par




./renumf90 ${r_blupf90}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.par > ${r_log_value_crosses_gblup}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.out

# Use the first estimates to estimate variance components of GBLUP model

cp ${r_blupf90}renf90.par ${r_blupf90}renf90_${subset}cm_sim${sim}_g${generation}_r${run}.par

rm ${r_blupf90}renf90.par

./airemlf90 ${r_blupf90}renf90_${subset}cm_sim${sim}_g${generation}_r${run}.par > ${r_log_value_crosses_gblup}airemlf90_${subset}cm_sim${sim}_g${generation}_r${run}.out


# Extract estimates for GBLUP model

genetic_variance=$(grep "Final Estimates" ${r_log_value_crosses_gblup}airemlf90_${subset}cm_sim${sim}_g${generation}_r${run}.out  -A8 | head -n3 | tail -n1 | sed "s/ //g")
residual_variance=$(grep "Final Estimates" ${r_log_value_crosses_gblup}airemlf90_${subset}cm_sim${sim}_g${generation}_r${run}.out  -A8 | head -n5 | tail -n1 | sed "s/ //g")



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


cp ${r_scripts}renumf90.par ${r_blupf90}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.par



sed -i "s|.*datafile.*|${titre_phenotyping_data_blupf90}|" ${r_blupf90}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.par
sed -i "s|.*mapfile.*|${titre_map_for_blupf90}|" ${r_blupf90}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.par
sed -i "s|.*snpfile.*|${titre_genotyping_matrix_for_blupf9}|" ${r_blupf90}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.par
sed -i "s|.*weightsfile.*|${titre_weights_for_blupf90}|" ${r_blupf90}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.par


sed -i "/genetic_variance/s/.*/${genetic_variance}/" ${r_blupf90}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.par
sed -i "/residual_variance/s/.*/${residual_variance}/" ${r_blupf90}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.par



# Launch data formatting and GBLUP model


./renumf90 ${r_blupf90}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.par > ${r_log_value_crosses_gblup}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}_2.out

cp ${r_blupf90}renf90.par ${r_blupf90}renf90_${subset}cm_sim${sim}_g${generation}_r${run}.par
# cp ${r_blupf90_snp}snp.txt_XrefID ${r}id_lines_2.txt

rm ${r_blupf90}renf90.par

./blupf90 ${r_blupf90}renf90_${subset}cm_sim${sim}_g${generation}_r${run}.par > ${r_log_value_crosses_gblup}blupf90_${subset}cm_sim${sim}_g${generation}_r${run}.out

cp ${r_blupf90}solutions ${r_value_crosses}blups_${subset}cm_sim${sim}_g${generation}_r${run}.txt

# Estimate SNP effect

cp ${r_blupf90}renf90_${subset}cm_sim${sim}_g${generation}_r${run}.par ${r_blupf90}postGSf90_${subset}cm_sim${sim}_g${generation}_r${run}.par


sed -i "/EM-REML/s/.*//" ${r_blupf90}postGSf90_${subset}cm_sim${sim}_g${generation}_r${run}.par
sed -i "/OPTION saveGInverse/s/.*/OPTION readGInverse/" ${r_blupf90}postGSf90_${subset}cm_sim${sim}_g${generation}_r${run}.par
sed -i "/OPTION saveA22Inverse/s/.*/OPTION readA22Inverse/" ${r_blupf90}postGSf90_${subset}cm_sim${sim}_g${generation}_r${run}.par



./postGSf90 ${r_blupf90}postGSf90_${subset}cm_sim${sim}_g${generation}_r${run}.par > ${r_log_value_crosses_gblup}_${subset}cm_sim${sim}_g${generation}_r${run}.out


echo ${titre_genotyping_matrix_for_blupf90} | ./predf90 > ${r_log_value_crosses_gblup}predf90_${subset}cm_sim${sim}_g${generation}_r${run}.out



cp ${r_blupf90}SNP_predictions ${r_value_crosses}SNP_predictions_${subset}cm_sim${sim}_g${generation}_r${run}.out
cp ${r_blupf90}snp_sol ${r_value_crosses}snp_sol_${subset}cm_sim${sim}_g${generation}_r${run}.out


# snp_pred is a very special file. it is the only one recognized by blupf90 when estimating breeding value from genotypes. I think its name cannot be changed.
mkdir -p ${r_value_crosses}files_snp_pred_blupf90/${subset}cm/${sim}/${generation}/${run}/
cp ${r_blupf90}snp_pred ${r_value_crosses}files_snp_pred_blupf90/${subset}cm/sim${sim}/g${generation}/r${run}/snp_pred

titre_gebv=${r_value_crosses}SNP_predictions_${subset}cm_sim${sim}_g${generation}_r${run}.out
titre_snp_effects=${r_value_crosses}snp_sol_${subset}cm_sim${sim}_g${generation}_r${run}.out
titre_lines=${r_prepare}lines.txt
titre_markers_filtered_qtls=${r_prepare}markers_filtered.txt
titre_markers_filtered_qtls_estimated=${r_value_crosses}markers_filtered_${subset}cm_sim${sim}_g${generation}_r${run}.out
# subset=all


v1=${titre_gebv}
v2=${titre_snp_effects}
v3=${titre_lines}
v4=${titre_markers_filtered_qtls}
v5=${titre_markers_filtered_qtls_estimated}
v6=${subset}

Rscript ${r_scripts}after_blupf90.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6}



cp ${r_blupf90}postGSf90_${subset}cm_sim${sim}_g${generation}_r${run}.par ${r_log_value_crosses_gblup}
cp ${r_blupf90}renumf90_${subset}cm_sim${sim}_g${generation}_r${run}.par ${r_log_value_crosses_gblup}
cp ${r_blupf90}postGSf90_${subset}cm_sim${sim}_g${generation}_r${run}.par ${r_log_value_crosses_gblup}


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
