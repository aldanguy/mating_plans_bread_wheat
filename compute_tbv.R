Sys.time()
cat("\n\ncompute_tbv.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <- Sys.time()

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")







titre_genotypes_input <- variables[1]
titre_qtls_input <- variables[2]
titre_tbv_output <- variables[3]







cat("\n\n INPUT : genotypes info \n\n ")
g <- fread(titre_genotypes_input)
g %>% dplyr::select(1:10) %>% head()
g %>% dplyr::select(1:10) %>% tail()
dim(g)


cat("\n\n INPUT : QTLs info \n\n ")
m <- fread(titre_qtls_input)
head(m)
tail(m)
dim(m)

m2 <- m %>%
  arrange(chr, dcum, marker) %>%
  filter(value!=0)

g2 <- g %>% arrange(ID) %>%
  dplyr::select(one_of(m2$marker)) %>%
  as.matrix()


TBV <- tcrossprod(g2, t(as.matrix(m2$value)))

out <- data.frame(ID=g$ID) %>%
  mutate(value=!!TBV) %>%
  mutate(info="TBV") %>%
  inner_join(g %>% dplyr::select(-starts_with("AX")), by="ID") %>%
  arrange(ID) %>%
  dplyr::select(ID, value, info, everything())



cat("\n\n OUPUT : TBV \n\n")
head(out)
tail(out)
dim(out)
write_delim(out, titre_tbv_output, delim = "\t", na = "NA", append = F,  col_names = T, quote_escape = "none")


sessionInfo()