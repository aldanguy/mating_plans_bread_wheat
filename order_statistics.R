

# Compute expected mean of higher order statistic in a finite sample
# Input : selection intensity table
# Output : table



Sys.time()
cat("\n\norder_statistics.R\n\n")
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



D <- as.numeric(variables[1])
titre_selection_intensity_input <- variables[2]
titre_expected_best_order_statistic <- variables[3]

# titre_selection_intensity_input <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/tab3_selection_intensity.txt"
# d <- 3300

cat("\n\nINPUT : selection intensity table \n\n")
fread(titre_selection_intensity_input) %>% head()
fread(titre_selection_intensity_input) %>% tail()
fread(titre_selection_intensity_input) %>% dim()


selection_intensity2 <- fread(titre_selection_intensity_input) %>% arrange(qij)


burrows <- function(x, selection_intensity){
  
  
  ligne <- findInterval(1/x, selection_intensity$qij)
  # selection_intensity[ligne,]
  int_qij <- selection_intensity$int_qij[ligne]
  
  int_app = int_qij - ((x - 1)/((2+2*x)*int_qij))
  
  return(int_app)
  
}


tab2 = data.frame()
for (x in c(2:D)){
  
  int_app=burrows(x=x, selection_intensity=selection_intensity2 )
  
  tab2 <- rbind(tab2, data.frame(dij=x, int_best_dij=int_app))
  
}



tab2 <- rbind(tab2, data.frame(dij=1, int_best_dij=0))
tab2 <- tab2 %>% arrange(dij)


cat("\n\n OUPUT : expected mean of higher statistical order \n\n")
head(tab2)
tail(tab2)
dim(tab2)
write.table(tab2, titre_expected_best_order_statistic, col.names = T, row.names = F, dec=".", sep="\t", quote=F)
# column 1 = dij = number of samples (integers)
# column 2 = int_best_dij = excpeted mean of the best among samples from Burrows


sessionInfo()
