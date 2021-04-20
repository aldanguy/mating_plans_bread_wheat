



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
type <- variables[4]
population <- variables[5]
critere <- variables[6]
affixe <-variables[7]
rr <- as.numeric(variables[8])


# titre_lines <- "/work/adanguy/these/croisements/180121/lines.txt"    
# titre_predictions <- "/work/adanguy/these/croisements/050221/sd_predictions/SNP_predictions"
# generation <- 1
# critere <- "gebv"

cat("\n\n INPUT : predictions of BV \n\n")
pred <- fread(titre_predictions)
head(pred)
tail(pred)
dim(pred)


pred2 <- pred %>% rename(ID=V1, value=V3) %>%
  mutate(generation=!!generation, type=!!type, population=!!population, critere=!!critere, affixe=!!affixe, rr=!!rr, used_as_parent=F) %>%
  dplyr::select(ID, generation, type, population, critere, affixe, rr, value, used_as_parent) %>%
  arrange(ID)


cat("\n\n OUTPUT : lines info")
head(pred2)
tail(pred2)
dim(pred2)
write_delim(pred2, titre_lines_critere, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")

sessionInfo()