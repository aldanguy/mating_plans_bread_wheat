

Sys.time()
cat("\n\nrepresentation_solutions.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(gplots))
suppressPackageStartupMessages(library(viridis))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")


titre_mod1 <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/res5modelesCE/RES_5_modelesCE/resshare1_9.csv"
titre_mod2 <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/res5modelesCE/RES_5_modelesCE/resshare2_9.csv"
titre_mod3 <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/res5modelesCE/RES_5_modelesCE/resshare3_9.csv"
titre_mod4 <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/res5modelesCE/RES_5_modelesCE/resshare4_9.csv"
titre_mod5 <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/res5modelesCE/RES_5_modelesCE/resshare5_9.csv"

r_graphe <- "/home/adanguydesd/Documents/These_Alice/croisements/graphs/"



alltitres <- c(titre_mod1, titre_mod2, titre_mod3, titre_mod4, titre_mod5)
modeles <- c("gebv","logw","embv","uc_intra_same","uc_intra_variable")
k=0



for (titre in alltitres){
  
  k=k+1
  mod <- fread(titre, skip=19, header=F, nrows=419-19) %>%
    rename(P1=V2, P2=V3) %>%
    dplyr::select(-V1)
  
  
  
  
  liste_parents <- mod %>% dplyr::select(P1, P2) %>% unlist() %>% as.vector() %>% unique() 
  nbparents = length(liste_parents)
  
  
  main=modeles[k]
  print(main)
  titre_graph <- paste0(r_graphe, "diversity_of_mating_plans_",main, "_CE_training.tiff")
  
  
  
  mf <- matrix(data=0, nrow=nbparents, ncol = nbparents)
  m <- matrix(data=0, nrow=nbparents, ncol = nbparents)
  for (h in 3:ncol(mod)){
    
    for (i in 1:(nbparents-1)){
      

      for (j in (i+1):nbparents){
        
        
        temp <- mod %>% dplyr::select(P1, P2, one_of(colnames(mod)[h])) %>%
          filter(P1 %in% liste_parents[c(i,j)] & P2 %in% liste_parents[c(i,j)])
        
        if (nrow(temp) > 0){
          
          
          m[i,j] <- temp[,3]
          m[j,i] <- temp[,3]
          
          
          
          
          
          
        }
      }
      
      
      
    }
    mf = mf + m
    
    
  }
  
  
  mf2 <- mf
  
  # mf2 <- mf2[,-which(colSums(mf2)==0)]
  # mf2 <- mf2[-which(rowSums(mf2)==0),]
  # mf2 <- mf2[,-which(colSums(mf2)<=10)]
  # mf2 <- mf2[-which(rowSums(mf2)<=10),]
  mf2 <- mf2/(ncol(mod)-2)
  mf2 <- log10(mf2)
  mf2[which(mf2==-Inf)] <- sort(unique(as.vector(mf2)))[2]
  # mf2[20:40,20:40]
  # v <- as.vector(mf2)
  # v <- v[which(v >0)]
  # hist(v, breaks = 100)
  
  my_palette <- colorRampPalette(rev(viridis(10)))(n = 100)
  tiff(titre_graph, width = 20, height = 20, compression = "lzw", units = "cm", res=300)
  heatmap.2(mf2,
            dendrogram='none', 
            Rowv=FALSE,
            Colv=FALSE,
            trace='none', 
            symbreaks = FALSE, 
            col=my_palette, 
            key.xlab ="",
            xlab="parents",
            ylab="parents",
            main=main,
            key.title="log10 of the mean Dij")
  dev.off()
  
}
