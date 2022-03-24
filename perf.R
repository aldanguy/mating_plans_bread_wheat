
Sys.time()
cat("\n\nperf.R\n\n")
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



opti <- variables[1]
ID <- variables[2]
fitness <- variables[3]
titre_output <- variables[4]
criterion <- variables[5]
constraints <- variables[6]
time <- variables[7]
seed <- variables[8]
nbcrosses <- as.numeric(variables[9])
nbcrosses_tot <- as.numeric(variables[10])

output <- data.frame(opti=opti,
                     ID=ID,
                     criterion=criterion,
                     constraints=constraints,
                     time=time,
                     seed=seed,
                     pcrosses=round(100*nbcrosses/nbcrosses_tot),
                     fitness=fitness)


head(output)
dim(output)

write.table(output, titre_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

sessionInfo()