

# Interpolate genetic position of genotyped markers based on a population specific genetic map
# Input : genetic maps + marker position
# Output : genetic positions of genotyped markers



Sys.time()
cat("\n\ninterpolation_genetic_positions.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))


variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_genetic_map_input <- variables[1]
titre_markers_input <- variables[2]
population <- variables[3]
titre_markers_output <- variables[4]


 # titre_genetic_map_WE <- "/work2/genphyse/dynagen/adanguy/croisements/090221/prepare/genetic_map_WE.txt"  
 # titre_genetic_map_EE <- "/work2/genphyse/dynagen/adanguy/croisements/090221/prepare/genetic_map_EE.txt"  
 # titre_genetic_map_WA <- "/work2/genphyse/dynagen/adanguy/croisements/090221/prepare/genetic_map_WA.txt"  
 # titre_genetic_map_EA <- "/work2/genphyse/dynagen/adanguy/croisements/090221/prepare/genetic_map_EA.txt"  
 # titre_genetic_map_CsRe <- "/work2/genphyse/dynagen/adanguy/croisements/090221/prepare/genetic_map_CsRe.txt"
 # titre_markers_filtered <- "/work2/genphyse/dynagen/adanguy/croisements/090221/prepare/markers_filtered.txt"



# population <- "WE"

cat("\n\n INPUT : markers info \n\n")
fread(titre_genetic_map_input) %>% head()
fread(titre_genetic_map_input) %>% tail()
fread(titre_genetic_map_input) %>% dim()


cat("\n\n INPUT : markers with physical position \n\n")
fread(titre_markers_input) %>% head()
fread(titre_markers_input) %>% tail()
fread(titre_markers_input) %>% dim()
# column 1 = chr = chr ID with letters (string, 21 levels)
# column 2 = region = ID of chr region (string, 5 levels R1, R2a, C, R2b, R3)
# column 3 = pos = physical position of marker (intergers, units bp)
# column 4 = marker = marker ID (string, as many levels as number of markers, here 21 196)
# column 5 = dcum = facultativ, will be deleted



function_interpolation <- function(titre_genetic_map, markers){

  gen <- fread(titre_genetic_map)


interpol <- gen %>%
  dplyr::select(-population) %>%
  rbind(markers %>%
          dplyr::select(chr, region, pos, marker) %>%
          mutate(dcum=NA)) %>%
  arrange(chr, pos, marker, dcum) %>%
  group_by(marker) %>% 
  slice(1) %>% # if one genotyped marker is already present in genetic map
  ungroup() %>%
  arrange(chr, pos, marker)

head(interpol, 10)


na_index <- interpol %>%
  group_by(chr) %>%
  mutate(interpolation=approxfun(x=pos, y=dcum, ties="ordered", rule=1)(pos)) %>% # linear interpolation
  summarise(first_non_NA=first(which(!is.na(interpolation))), last_non_NA=last(which(!is.na(interpolation)))) %>%
  ungroup()

head(na_index)


interpol2 <- data.frame()
chr="1A"
# On va traiter différement les portions des chromosomes left et right
# Les deux portions auront la mm interpolations pour les mqs situés entre ceux de csre
# mais les modeles lineaires pour estimer les positions des mqs situés avant ou après csre changent
for (chr in unique(interpol$chr)){
  
  #print(chr)
  
  
  if(na_index$first_non_NA[which(na_index$chr==chr)] ==1){ # si tous les mqs en R1 ont pas pu etre interpoles (first_non_NA=1)
    
    # Dans ce cas, il suffit d'utiliser l'interpolation
    
    left <- interpol %>%
      filter(chr==!!chr) %>%
      mutate(interpolation=approxfun(x=pos, y=dcum, ties="ordered", rule=1)(pos)) %>%
      dplyr::select(chr, region, pos, dcum, interpolation, marker)
    
    
  } else { # si tous les mqs en R1 ont pas pu etre interpoles (first_non_NA !=1)
    
    # Dans ce cas, il faut estimer le taux de rec moyen de R1
    
    
    mod_left <- interpol %>% 
      filter(chr==!!chr) %>%
      filter(region=="R1") %>%
      filter(!is.na(dcum)) %>%
      lm(data=., dcum~pos) # taux de rec moyen de R1
    
    mod_left$coefficients[1] <- 0
    
    left <- interpol %>%
      filter(chr==!!chr) %>%
      mutate(interpolation=approxfun(x=pos, y=dcum, ties="ordered", rule=1)(pos)) %>%
      left_join(na_index, by="chr") %>%
      arrange(pos) %>%
      mutate(interpolation2=ifelse(row_number() <= first_non_NA,
                                   predict(mod_left, newdata=data.frame(interpol)), # modele lineaire pour les mqs extreme. On enleve l'intercept pour avoir juste le taux moyen
                                   interpolation)) %>% # interpolation pour les mqs au centre du chr
      mutate(jointure=interpolation2 - interpolation) %>% # l'interpolation et le modele lineaire ne prédisent pas necessairement la mm valeur au niveau de la joinnture left-centre du chr.
      mutate(jointure=ifelse(jointure ==0, NA, jointure)) %>%
      group_by(chr) %>%
      mutate(jointure=max(jointure, na.rm=T)) %>%
      ungroup() %>%
      mutate(interpolation3=case_when(row_number() > first_non_NA~interpolation2,
                                      row_number() <=first_non_NA & jointure >=0~interpolation2-jointure,
                                      row_number() <=first_non_NA & jointure <0~interpolation2 + jointure)) %>%
      mutate(minimum=interpolation3[1]) %>%
      mutate(interpolation4=ifelse(minimum <= 0, interpolation3 + abs(minimum), interpolation3 - minimum )) %>% # on fait commencer la carte genetique à 0 cM
      mutate(interpolation5=ifelse(row_number() > last_non_NA, NA, interpolation4)) %>%
      mutate(interpolation=interpolation5) %>%
      ungroup() %>%
      mutate(region = factor(region, levels=c("R1","R2a","C","R2b","R3"))) %>%
      dplyr::select(chr, region, pos, dcum, interpolation, marker)
    
    
    
  }
  
  
  if(na_index$last_non_NA[which(na_index$chr==chr)] ==nrow(left)){ # si tous les mqs en R1 ont pas pu etre interpoles (last_non_NA=dernier mqs)
    
    # Pas besoin d'en faire plus
    
    right <- left 
    
  } else { # si tous les mqs en R3 ont pas pu etre interpoles 
    
    # Dans ce cas, il faut estimer le taux de rec moyen de R3
    
    
    
    mod_right <- interpol %>%
      filter(chr==!!chr) %>%
      filter(region=="R3") %>%
      filter(!is.na(dcum)) %>%
      lm(data=., dcum~pos)# taux de rec moyen de R3
    
    
    mod_right$coefficients[1] <- 0
    
    
    
    right <-  left %>% left_join(na_index, by="chr") %>%
      arrange(pos) %>%
      mutate(interpolation2=ifelse(row_number() >= last_non_NA,
                                   predict(mod_right, newdata=data.frame(interpol)) ,
                                   interpolation)) %>%
      mutate(jointure=interpolation2 - interpolation) %>%
      group_by(chr) %>%
      mutate(jointure=ifelse(jointure !=0, jointure, NA)) %>%
      mutate(jointure=max(jointure, na.rm=T)) %>%
      ungroup() %>%
      mutate(interpolation3=case_when(row_number() < last_non_NA~interpolation2,
                                      row_number() >=last_non_NA & jointure >=0~interpolation2 - jointure,
                                      row_number() >=last_non_NA & jointure <0~interpolation2 - jointure))%>%
      mutate(interpolation=interpolation3) %>%
      ungroup() %>%
      mutate(region = factor(region, levels=c("R1","R2a","C","R2b","R3"))) %>%
      dplyr::select(chr, region, pos, dcum, interpolation, marker)
    
    
  } 
  
  
  nb_mqs <- nrow(right)
  nb_mqs_gen <- right %>% filter(!is.na(dcum)) %>% ungroup() %>% count()
  position_legend <- max(right$pos)
  
  
  graphe <- right %>% ggplot(aes(x=pos, y=interpolation)) +
    geom_line(col="black") +
    geom_point(aes(x=pos, y=dcum, col=region)) +
    theme_light() +
    xlab("physical position (pb)") +
    ylab("genetic position (cM)") +
    ggtitle(chr) +
    guides(colour=guide_legend("WE genetic map SNP")) +
    theme(plot.title = element_text(hjust = 0.5)) +
    annotate("text", x=position_legend, y = 10, vjust=1, hjust=1, label =  c(paste0("WE genetic ", nb_mqs_gen," SNP \n Interpolation of ", nb_mqs - nb_mqs_gen," new SNP")))
  
  graphe
  
  
  
  interpol2 <- rbind(interpol2, right)
  
  
} 

interpol3 <- interpol2 %>% dplyr::select(chr, region, pos, marker, interpolation) %>%
  filter(marker %in% markers$marker) %>%
  rename(dcum=interpolation) %>%
  arrange(chr, pos)

return(interpol3)


}


interpolation <- function_interpolation(titre_genetic_map_input, markers=fread(titre_markers_input)) %>%
  mutate(population=population) %>%
  dplyr::select(chr, region, pos, marker, population, dcum) %>%
  as.data.frame()


cat("\n\n OUTPUT : markers info \n\n")
head(interpolation)
tail(interpolation)
dim(interpolation)

write.table(interpolation, titre_markers_output, col.names = T, row.names = F, quote=F, dec=".", sep="\t")

sessionInfo()