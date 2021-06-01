#!/bin/bash
RANDOM=1
ulimit -s unlimited
export OMP_STACKSIZE=64M
date +'%Y-%m-%d-%T'

base=${1}

source ${base}

titre_genotyping_matrice_parents=${r_prepare}genotyping.txt
titre_markers=${r_prepare}markers.txt
titre_markers_output=${r_value_crosses}for_LDAK.map
titre_genotyping_output=${r_value_crosses}for_LDAK.ped


v1=${titre_genotyping_matrice_parents}
v2=${titre_markers}
v3=${titre_markers_output}
v4=${titre_genotyping_output}



Rscript ${r_scripts}pipeline_for_LDAK.R ${v1} ${v2} ${v3} ${v4}



r_sortie=${r}crossval/

v1=${titre_lines_parents}
v2=${nb_run}
v3=${r_sortie}

Rscript ${r_scripts}select_lines_crossval.R ${v1} ${v2} ${v3}




plink --file ${r_value_crosses}for_LDAK --recode --noweb --out ${r_value_crosses}for_LDAK2

plink --file ${r_value_crosses}for_LDAK2 --noweb --make-bed --out ${r_value_crosses}for_LDAK3


mkdir -p ${r}crossval/ldak/alldata/

cd ${r}crossval/ldak/alldata/


#### All predict all
rr=0
type=0
r_save2=${r}crossval/ldak/alldata/
r_save=${r}crossval/ldak/alldata/
r_log=${r}crossval/ldak/alldata/

#### STEP 1 : estimate weights with LDAK
/work/adanguy/ldak5.1.linux --cut-weights sections --bfile ${r_value_crosses}for_LDAK3 --no-thin YES --window-cm 10 --section-cm 10 --buffer-cm 1
/work/adanguy/ldak5.1.linux --calc-weights-all sections --bfile ${r_value_crosses}for_LDAK3
/work/adanguy/ldak5.1.linux --calc-kins-direct LDAK-Thin --bfile ${r_value_crosses}for_LDAK3 --weights ./sections/weights.all --power 1 --kinship-raw YES #power?

<<COMMENTS
/work/adanguy/ldak5.1.linux --linear single4 --bfile ${r_value_crosses}for_LDAK3 --pheno ${r_value_crosses}for_LDAK.txt --grm LDAK-Thin
/work/adanguy/ldak5.1.linux --calc-tagging ldak.thin --bfile ${r_value_crosses}for_LDAK3 --weights ./sections/weights.all --power -.25 --window-cm 1 --save-matrix YES
/work/adanguy/ldak5.1.linux --sum-hers ldak.thin --tagfile ldak.thin.tagging --summary single4.summaries --matrix ldak.thin.matrix
/work/adanguy/ldak5.1.linux --ridge ridge --pheno ${r_value_crosses}for_LDAK.txt --bfile ${r_value_crosses}for_LDAK3 --ind-hers ldak.thin.ind.hers
/work/adanguy/ldak5.1.linux --calc-scores scores --scorefile single4.score --bfile ${r_value_crosses}for_LDAK3 --power 0
COMMENTS
#### STEP 2 : use weights as input in BLUPF90

# A prepare input file for blupf90
cp ${r_blupf90}renumf90 ${r}crossval/ldak/alldata/
cp ${r_blupf90}airemlf90 ${r}crossval/ldak/alldata/
cp ${r_blupf90}blupf90 ${r}crossval/ldak/alldata/
cp ${r_blupf90}postGSf90 ${r}crossval/ldak/alldata/
cp ${r_blupf90}predf90 ${r}crossval/ldak/alldata/

titre_lines=${r_prepare}lines.txt
titre_markers=${r_prepare}markers.txt
titre_genotyping=${r_prepare}genotyping.txt
titre_phenotyping_blupf90=p.txt
titre_markers_blupf90=m.txt
titre_genotyping_blupf90=s.txt
titre_weights_blupf90=w.txt
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
v11=${type}


Rscript ${r_scripts}prepare_for_blupf90.R ${v1} ${v2} ${v3} ${v4} ${v5} ${v6} ${v7} ${v8} ${v9} ${v10} ${v11}

# change weight file
cp ${titre_weights_blupf90} weights_1.txt
cut -f2 -d" " ./sections/weights.all | tail -n+2 > ${titre_weights_blupf90}


# continue using blupf90 until obtaining gebv

cp ${r_scripts}renumf90.par ${r_log}renumf90_${type}.par 




sed -i "s|.*datafilepath.*|${titre_phenotyping_blupf90}|" ${r_log}renumf90_${type}.par
sed -i "s|mapfilepath|${titre_markers_blupf90}|" ${r_log}renumf90_${type}.par
sed -i "s|.*snpfilepath.*|${titre_genotyping_blupf90}|" ${r_log}renumf90_${type}.par
sed -i "s|weightsfilepath|${titre_weights_blupf90}|" ${r_log}renumf90_${type}.par

${r_save2}renumf90 ${r_log}renumf90_${type}.par > ${r_log}renumf90_${type}_1.out

# Use the first estimates to estimate variance components of GBLUP model

cp ${r_save2}renf90.par ${r_log}renf90_${type}.par 

${r_save2}airemlf90 ${r_log}renf90_${type}.par > ${r_log}airemlf90_${type}.out 

cp ${r_log}airemlf90_${type}.out ${r_log}airemlf90_ldak.out 

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


${r_save2}postGSf90 ${r_log}postGSf90_${type}.par > ${r_log}postGSf90_${type}.out # add readGinverse et snp

echo ${titre_genotyping_blupf90} | ${r_save2}predf90 > ${r_log}predf90_${type}.out


titre_lines_input=${r_save2}SNP_predictions
titre_lines_to_keep=${r_value_crosses}for_LDAK.txt
nb_run=${rr}
modele=ldak
titre_lines_output=${r}crossval/gebv_ldak_alldata.txt



v1=${titre_lines_input}
v2=${titre_lines_to_keep}
v3=${nb_run}
v4=${modele}
v5=${titre_lines_output}

Rscript ${r_scripts}after_blupf90_4.R ${v1} ${v2} ${v3} ${v4} ${v5}
    

#### STEP 3 : use current weights as input in BLUPF90

cp weights_1.txt ${titre_weights_blupf90}

cp ${r_scripts}renumf90.par ${r_log}renumf90_${type}.par 




sed -i "s|.*datafilepath.*|${titre_phenotyping_blupf90}|" ${r_log}renumf90_${type}.par
sed -i "s|mapfilepath|${titre_markers_blupf90}|" ${r_log}renumf90_${type}.par
sed -i "s|.*snpfilepath.*|${titre_genotyping_blupf90}|" ${r_log}renumf90_${type}.par
sed -i "s|weightsfilepath|${titre_weights_blupf90}|" ${r_log}renumf90_${type}.par

${r_save2}renumf90 ${r_log}renumf90_${type}.par > ${r_log}renumf90_${type}_1.out

# Use the first estimates to estimate variance components of GBLUP model

cp ${r_save2}renf90.par ${r_log}renf90_${type}.par 

${r_save2}airemlf90 ${r_log}renf90_${type}.par > ${r_log}airemlf90_${type}.out 

cp ${r_log}airemlf90_${type}.out ${r_log}airemlf90_blupf90.out 


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


${r_save2}postGSf90 ${r_log}postGSf90_${type}.par > ${r_log}postGSf90_${type}.out # add readGinverse et snp

echo ${titre_genotyping_blupf90} | ${r_save2}predf90 > ${r_log}predf90_${type}.out


titre_lines_input=${r_save2}SNP_predictions
titre_lines_to_keep=${r_value_crosses}for_LDAK.txt
nb_run=${rr}
titre_lines_output=${r}crossval/gebv_blupf90_alldata.txt



v1=${titre_lines_input}
v2=${titre_lines_to_keep}
v3=${nb_run}
v4=blupf90
v5=${titre_lines_output}

Rscript ${r_scripts}after_blupf90_4.R ${v1} ${v2} ${v3} ${v4} ${v5}





    
    
for rr in $(seq 1 ${nb_run})
do

    echo ${rr}


    repertoire=${r}crossval/ldak/${rr}/
    
    mkdir -p ${repertoire}
    cd ${repertoire}

    
    

    

    
    ############### pb avec blupf90 pred -> il faut que le nombre d'individu soit constants. Faire jusqu'à postgs, et là rajouter les pheno (0 pour les remove) et les geno (tous) BOF
    
    
    sed -i "s/^/LINE\t/" ${r_save2}lines_temp.txt 
    sed -i "s/$/\tTRUE/" ${r_save2}lines_temp.txt 
    sed -i "s/$/\tTRUE/" ${r_save2}lines_temp.txt 
    sed -i "s/$/\tTRUE/" ${r_save2}lines_temp.txt 
    sed -i "s/$/\tpheno_simFALSE/" ${r_save2}lines_temp.txt 
    sed -i "s/$/\t0/" ${r_save2}lines_temp.txt 

    
    cat ${r_save2}lines_temp.txt  >> ${titre_lines}


    
    # Format of LDAK output
    titre_gebv=${repertoire}scores.profile
    titre_output=${r_sortie}gebv_ldak_${rr}.txt
    
    v1=${titre_gebv}
    v2=${rr}
    v3=${titre_output}

    Rscript ${r_scripts}after_ldak.R ${v1} ${v2} ${v3}
    
    
    type=${rr}
    r_log=${r_log_crossval}
    r_save=${repertoire}
    simulation=crossval
    
    job_out=${r_log}gblup_${type}.out
    job_name=${type}
    job=$(sbatch -o ${job_out} -J ${job_name} --time=00:20:00 --parsable ${r_scripts}gblup_2.sh ${base} ${type} ${r_log} ${r_save} ${simulation})
    
    while (( $(squeue -u adanguy | grep ${job} | wc -l) >= 1 )) 
        do    
        sleep 1s
    done




    
    
    titre_lines_input=${repertoire}SNP_predictions_${rr}.txt
    titre_lines_to_keep=${r_sortie}lines_to_remove_${rr}.txt
    nb_run=${rr}
    titre_lines_output=${r_sortie}gebv_blupf90_${rr}.txt

    v1=${titre_lines_input}
    v2=${titre_lines_to_keep}
    v3=${nb_run}
    v4=${titre_lines_output}

    Rscript ${r_scripts}after_blupf90_4.R ${v1} ${v2} ${v3} ${v4}
    
done

    
k=0
for f in ${r_sortie}gebv_*.txt
do

    if [ ${k} -eq 0 ]
    then 
    
    cat ${f} > ${r}crossval.txt
    
    else
    
    tail -n+2 ${f} >> ${r}crossval.txt
    
    fi
    
    k=$((${k} +1))
    
done
    
    
    
    
    

