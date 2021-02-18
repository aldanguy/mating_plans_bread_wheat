



# Goal : estimate BLUEs
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



titre_phenotypes <- variables[1]
titre_lines <- variables[2]

# titre_phenotypes <- "/work/adanguy/these/croisements/amont/Traitees_IS.txt"
# titre_lines <- "/work/adanguy/these/croisements/180120/lines.txt"

cat("\n\n INPUT : phenotypes \n\n")
phenotypes <- fread(titre_phenotypes)
head(phenotypes)
dim(phenotypes)
# column 1 = Geno = ID of variety (string, as many levels as number of variety, here 1 912)
# column 2 = LINE = ID of variety (capital letters, here 1 909)
# column 9 = Yield = yield (numeric, units ?)
# column 10 = Prot = proteine content ? (numeric, units ?)
# column 11 = Env = Environnement ID (product of column 3 Year and column 4 Site) (string, 145 levels)
# column 3-8 : no importance here
# dimension of file : 63 301 * 11
# phenotypes %>% dplyr::select(LINE) %>% unique() %>% unlist() %>% as.vector() %>% length()




cat("\n\n INPUT : correspondance between true ID and modified ID of lines \n\n")
lines <- fread(titre_lines)
head(lines)
dim(lines)
# column 1 = LINE = ID of variety (string, 3 185 levels = as many as varieties ID)
# column 2 = line2 = modified ID of variety (use in further analysis) (string, 3 185 levels)
# column 3 = phenotyped = variety phenotyped  (logical)
# column 4 = blue = estimate of variety yield (numeric, but NA for now)
# column 5 = genotyped = variety was genotyped (logical)
# column 6 = used_as_parent = variety used as parent (logical, but NA for now)
# dim file : 3185*6



#### Step 1 : estimate blues of varieties

# Prepare data for asmrel
phenotypes2 <- phenotypes %>%
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
  rename(blue=effect) %>%
  dplyr::select(LINE, blue) 



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

lines2 <- blues %>% full_join(lines %>%
                                   dplyr::select(LINE, line2, phenotyped, gebv, genotyped, used_as_parent, generation, best_crosses, run), by="LINE") %>%
  arrange(line2) %>%
  dplyr::select(LINE, line2, phenotyped, blue, gebv, genotyped, used_as_parent, generation, best_crosses, run)




#### Output



cat("\n\n OUTPUT : correspondance between true ID and modified ID of lines \n\n")
head(lines2)
dim(lines2)
write.table(lines2, titre_lines, col.names = T, row.names = F, dec=".", sep="\t", quote=F)
# column 1 = LINE = ID of variety (string, 3 185 levels = as many as varieties ID)
# column 2 = line2 = modified ID of variety (use in further analysis) (string, 3 185 levels)
# column 3 = phenotyped = variety phenotyped  (logical)
# column 4 = blue = estimate of variety yield (numeric)
# column 5 = genotyped = variety was genotyped (logical)
# column 6 = used_as_parent = variety used as parent (logical, but NA for now)
# dim file : 3185*6


sessionInfo()