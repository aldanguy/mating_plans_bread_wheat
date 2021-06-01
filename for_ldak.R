

library(tidyverse)
library(data.table)


variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre <- variables[1]
type <- variables[2]
titre_output <- variables[3]

cat("\n\n INPUT\n\n")
f <- fread(titre)
head(f)
tail(f)
dim(f)



f2 <- f %>% rename(ID=ID2, value=Profile_1) %>% mutate (phenotyped=T, genotyped=T, used_as_parent=T, LINE=ID, type=type) %>%
  dplyr::select(LINE, ID, phenotyped, genotyped, used_as_parent, type, value) %>%
  mutate(type=paste0("gebv_", type)) %>%
  arrange(ID)

cat("\n\n OUTPUT\n\n")

head(f2)
tail(f2)
dim(f2)

write.table(f2, titre_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)

sessionInfo()