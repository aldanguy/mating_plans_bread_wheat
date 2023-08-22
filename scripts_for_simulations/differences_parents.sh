#!/bin/bash
RANDOM=1
date +'%Y-%m-%d-%T'



base=${1}


source ${base}



       
# Step 1 : extract LDAK genomic matrix

titre_genotyping_matrice_parents=${r_prepare}genotyping.txt
titre_markers=${r_prepare}markers_${population_ref}.txt
titre_markers_output=${r_ldak}for_LDAK.map
titre_genotyping_output=${r_ldak}for_LDAK.ped


v1=${titre_genotyping_matrice_parents}
v2=${titre_markers}
v3=${titre_markers_output}
v4=${titre_genotyping_output}


# Rscript ${r_scripts}prepare_for_LDAK.R ${v1} ${v2} ${v3} ${v4}



#plink --file ${r_save}for_LDAK --recode --noweb --out ${r_save}for_LDAK2 >> ${r_log}plink.out
#plink --file ${r_save}for_LDAK2 --noweb --make-bed --out ${r_save}for_LDAK3 >> ${r_log}plink.out
cp /work2/genphyse/dynagen/adanguy/croisements/050321/value_crosses/for_LDAK* ${r_ldak}

cd ${r_ldak}
/work/adanguy/ldak5.1.linux --cut-weights sections --bfile ${r_ldak}for_LDAK3 --window-cm 1 --section-cm 1 --buffer-cm 1 
/work/adanguy/ldak5.1.linux --calc-weights-all sections --bfile ${r_ldak}for_LDAK3 
/work/adanguy/ldak5.1.linux --calc-kins-direct LDAK-Thin --bfile ${r_ldak}for_LDAK3 --weights ${r_ldak}sections/weights.all --power -1 --kinship-raw YES
cp ${r_ldak}LDAK-Thin.grm.raw ${r_ldak}g_ldak
rm ${r_ldak}LDAK-Thin.grm.raw
  
