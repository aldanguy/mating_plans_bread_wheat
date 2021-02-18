



# Goal : gather data
# Input : blupf90 outputs, gebv and snp effects
# Output : files updated



Sys.time()
cat("\n\nafter_blupf90_2.R\n\n")
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

titre_lines_critere <- variables[1]
titre_predictions <- variables[2]
generation <- as.numeric(variables[3])
critere <- variables[4]
run <- as.numeric(variables[5])
titre_lines <- variables[6]


# titre_lines <- "/work/adanguy/these/croisements/180121/lines.txt"    
# titre_predictions <- "/work/adanguy/these/croisements/050221/sd_predictions/SNP_predictions"
# generation <- 1
# critere <- "gebv"

cat("\n\n INPUT : predictions of BV \n\n")
pred <- fread(titre_predictions)
head(pred)
dim(pred)

lines <- fread(titre_lines)
head(lines)
dim(lines)


pred2 <- pred %>% rename(ID=V1, gebv=V3) %>%
  mutate(LINE=NA, phenotyped=F, blue=NA, genotyped=T, used_as_parent=F, generation=generation, best_crosses=critere, run=run) %>%
  dplyr::select(LINE, ID, phenotyped, blue, gebv, genotyped, used_as_parent, generation, best_crosses, run)


if (generation == 1 & run==1){
  
  
 
  
  lines <- fread(titre_lines) %>% rename(ID=line2) %>%
    mutate(best_crosses=critere) %>%
    rbind(., pred2) 
  

  }else if (generation==1 & run !=1){
    
    
    lines <- pred2
    
  
} else {
  
  lines <- fread(titre_lines_critere) %>%
    rbind(., pred2) 
  
  
}

cat("\n\n OUTPUT : lines info")
print(tail(lines))
dim(lines)
write_delim(lines, titre_lines_critere, delim = "\t", na = "NA", append = F,  col_names = (generation == 1 & run==1) , quote_escape = "none")

sessionInfo()