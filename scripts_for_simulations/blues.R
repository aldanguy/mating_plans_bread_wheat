



# Goal : estimate BLUEs from phenotype file
# Input : phenotypic data
# Output : BLUEs



Sys.time()
cat("\n\nblues.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(asreml))




variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_phenotypes_input <- variables[1]
titre_lines_input <- variables[2]
titre_lines_output <- variables[3]

# titre_phenotypes <- "/work/adanguy/these/croisements/amont/Traitees_IS.txt"
# titre_lines <- "/work/adanguy/these/croisements/180120/lines.txt"

cat("\n\n INPUT : phenotypes \n\n")
fread(titre_phenotypes_input) %>% arrange(LINE) %>% head()
fread(titre_phenotypes_input) %>% arrange(LINE) %>% tail()
fread(titre_phenotypes_input) %>% dim()



cat("\n\n INPUT : lines info \n\n")
fread(titre_lines_input) %>% head()
fread(titre_lines_input) %>% tail()
fread(titre_lines_input) %>% filter(genotyped==T & phenotyped==T) %>% head()
fread(titre_lines_input) %>% dim()




#### Step 1 : estimate blues of varieties

# Prepare data for asmrel
phenotypes2 <- fread(titre_phenotypes_input) %>%
  mutate(LINE=as.factor(LINE), Env=as.factor(Env)) %>% 
  arrange(LINE, Env) %>%
  dplyr::select(LINE,Env, Yield)

# Mixte model with LINE as fixed effect -> blues
model_line_fixed=asreml(Yield ~ LINE,random = ~ Env+LINE:Env,maxiter=1000,data=phenotypes2)

# Extract asreml results
blues <- coef(model_line_fixed, pattern="LINE") %>%
  head(length(unique(phenotypes2$LINE))) %>%
  as.data.frame()%>%
  rownames_to_column(var="LINE") %>%
  mutate(LINE=gsub("LINE_","", LINE)) %>%
  rename(value=effect) %>%
  dplyr::select(LINE, value) 



#### Step 2 : compute heritability of yield

# Mixte model with LINE as random effect -> genetic variability
model_all_random=asreml(Yield ~ 1,random= ~ LINE+ Env+LINE:Env,
                        maxiter=1000,data=phenotypes2)

vcomp=as.data.frame(summary(model_all_random)$varcomp)
nam=rownames(vcomp)
vcomp=round(vcomp$component, digits=2)
names(vcomp)=nam

cat ("\n\n Variance components according asreml \n\n")
print(vcomp)
cat("\n\n plot heritability \n\n")
h2_plot=round(vcomp["LINE!LINE.var"]/
                (vcomp["LINE!LINE.var"]+vcomp["LINE:Env!LINE.var"]+vcomp["R!variance"]), digits=2)

print(paste0("heritability=",h2_plot,"_h2"))



# step 3 : prepare for print

lines2 <- blues %>% full_join(fread(titre_lines_input) %>%
                                   dplyr::select(LINE, ID, phenotyped, genotyped), by="LINE") %>%
  arrange(ID) %>%
  mutate(type="pheno_simFALSE") %>%
  dplyr::select(LINE, ID, phenotyped, genotyped, type, value)




#### Output



cat("\n\n OUTPUT : lines info \n\n")
head(lines2)
tail(lines2)
lines2 %>% filter(phenotyped==T & genotyped==T) %>% head()
dim(lines2)
write.table(lines2, titre_lines_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)



sessionInfo()