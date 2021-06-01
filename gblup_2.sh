#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'




base=${1}



type=${2}



source ${base}



r_log=${r_log_value_crosses_gblup}${type}/
r_save=${r_value_crosses_gblup}${type}/



r_save2=${r_save}temp/
rm -rf ${r_save}
mkdir -p ${r_save2}
mkdir -p ${r_log}
typeshort=$(echo ${type} | sed "s/_/./g" )
type2=$(echo ${type} |sed "s/_g.*$//g" )
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


    


titre_lines=${r_value_crosses_lines}lines_pheno_${type2}.txt
titre_markers=${r_prepare}markers_${population_ref}.txt
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
v10=${type}


Rscript ${r_scripts}prepare_for_blupf90.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10}





# replace value in blupf90 parameter file for estimates from diagonal model
cp ${r_scripts}renumf90.par ${r_log}renumf90_${type}.par




sed -i "s|.*datafilepath.*|${titre_phenotyping_blupf90}|" ${r_log}renumf90_${type}.par
sed -i "s|mapfilepath|${titre_markers_blupf90}|" ${r_log}renumf90_${type}.par
sed -i "s|.*snpfilepath.*|${titre_genotyping_blupf90}|" ${r_log}renumf90_${type}.par
sed -i "s|weightsfilepath|${titre_weights_blupf90}|" ${r_log}renumf90_${type}.par

${r_save2}renumf90 ${r_log}renumf90_${type}.par > ${r_log}renumf90_${type}_1.out

# Use the first estimates to estimate variance components of GBLUP model

cp ${r_save2}renf90.par ${r_log}renf90_${type}.par

${r_save2}airemlf90 ${r_log}renf90_${type}.par > ${r_log}airemlf90_${type}.out


# Extract estimates for GBLUP model

genetic_variance=$(grep "Final Estimates" ${r_log}airemlf90_${type}.out  -A8 | head -n3 | tail -n1 | sed "s/ //g")
residual_variance=$(grep "Final Estimates" ${r_log}airemlf90_${type}.out  -A8 | head -n5 | tail -n1 | sed "s/ //g")


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
titre_markers=${r_prepare}markers.txt
titre_markers_output=${r_value_crosses_markers}markers_estimated_${type}.txt
titre_lines_output=${r_value_crosses_lines}lines_gebv_${type}.txt


v1=${titre_gebv}
v2=${titre_snp_effects}
v3=${titre_lines}
v4=${titre_markers}
v5=${titre_markers_output}
v6=${titre_lines_output}
v7=${type}

Rscript ${r_scripts}after_blupf90.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7}





populations=$(cut -f5 ${r_prepare}markers.txt | sort | uniq | grep -v "population")

for p in ${populations[*]}
    do
    head -n1 ${titre_markers_output} > ${r_value_crosses_markers}markers_estimated_${type}_${p}.txt
    grep ${p} ${titre_markers_output} >> ${r_value_crosses_markers}markers_estimated_${type}_${p}.txt
done

rm ${titre_markers_output}


cd ${r_save}
rm -rf ${r_save2}
date +'%Y-%m-%d-%T'
