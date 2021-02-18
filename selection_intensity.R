

# Goal : produce a table with selection intensity corresponding to each selection proportion
# Input : nothing
# Output : selection intensity table



Sys.time()
cat("\n\nselection_intensity.R\n\n")
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

d <- as.numeric(variables[1])
titre_selection_intensity <- variables[2]

# d <- 3300
# titre_selection_intensity <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/tab3_selection_intensity.txt"

deltaq <- 10^(floor(log10(1/d)))


# raw table of selection intensity
x=rev(seq(-5,5,deltaq/10))
tab <- data.frame(x=x, i=dnorm(x)/(1-pnorm(x)), q=1-pnorm(x))

# try to have regular increase in selection rate
q <- seq(deltaq,(1-deltaq), deltaq)
tab2 <- data.frame()
r=0.01
for (r in q){
  
  
  ligne <-  findInterval(r,tab$q)
  
  tab2 <- rbind(tab2, data.frame(s=tab$x[ligne], int_qij = tab$i[ligne], qij=r))
  
  
}


# maxx <- which.max(tab$x)
minx <- which.min(tab$x)
# tab2 <- rbind(tab2, data.frame(s=tab$x[maxx], int=tab$i[maxx], q=0))
tab2 <- rbind(tab2, data.frame(s=tab$x[minx], int_qij=0, qij=1))


tab3 <- tab2 %>% arrange(desc(qij)) %>% 
  dplyr::select(-s) %>%
  dplyr::select(qij,int_qij)



cat("\n\nOUTPUT : selection intensity table \n\n")
head(tab3)
write.table(tab3, titre_selection_intensity, quote=F, dec=".", sep="\t", row.names = F, col.names = T)
# column 1 = qij = selection rate
# column 2 = int_qij = selection intensity
# dim 9999*2


sessionInfo()