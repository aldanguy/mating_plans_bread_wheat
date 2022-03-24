


Sys.time()
cat("\n\ncrosses_CONSTRAINTS\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(igraph))
suppressPackageStartupMessages(library(ggpubr))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre_LDAK_input <-variables[1]
titre_crosses_NO_CONSTRAINTS_input <- variables[2]
most_related_crosses_removed <- as.numeric(variables[3])
titre_crosses_CONSTRAINTS_output <- variables[4]


# titre_ldak <- "/work2/genphyse/dynagen/adanguy/croisements/190821/ibs/ibs/ibs_ldak_unselected.txt"                                  
# titre_desirable_crosses_output <- "/work2/genphyse/dynagen/adanguy/croisements/190821/value_crosses/desirables_crosses/desirable_crosses_unselected.txt"


cat("\n\n INPUT G matrix from ldak \n\n")
ldak <- fread(titre_LDAK_input)
head(ldak)
tail(ldak)
dim(ldak)


cat("\n\n INPUT crosses \n\n")
crosses <- fread(titre_crosses_NO_CONSTRAINTS_input)
head(crosses)
tail(crosses)
dim(crosses)


if (most_related_crosses_removed >0){


desirable_crosses <- ldak %>% 
  filter(P1 != P2) %>%
  mutate(q=quantile(value, 1-most_related_crosses_removed)) %>%
  filter(value <q) %>%
  dplyr::select(P1, P2) %>%
  inner_join(crosses, by=c("P1","P2")) %>%
  arrange(P1, P2)%>%
  mutate(CONSTRAINTS="CONSTRAINTS") %>%
  dplyr::select(P1, P2, genetic_map, simulation, qtls, qtls_info, heritability, genomic, population, progeny, population_ID, CONSTRAINTS, sd, PM, UC1, UC2, PROBA, EMBV, OHV)




} else {
  
  desirable_crosses <- crosses %>%
    arrange(P1, P2)%>%
  mutate(CONSTRAINTS="NO_CONSTRAINTS") %>%
  dplyr::select(P1, P2, genetic_map, simulation, qtls, qtls_info, heritability, genomic, population, progeny, population_ID, CONSTRAINTS, sd, PM, UC1, UC2, PROBA, EMBV, OHV)

}


# 
# 
# ibs0 <- graph.data.frame(ldak,directed=FALSE)
# ibs0 <- as_adjacency_matrix(ibs0,names=TRUE,sparse=FALSE,attr="value",type='both')
# 
# 
# 
# 
# 
# 
# library(gridGraphics)
# library(grid)
# 
# grab_grob <- function(){
#   grid.echo()
#   grid.grab()
# }
# heatmap(ibs0)
# g1 <- grab_grob()
# grid.newpage()
# 
# 
# hist(ibs0, main="Distribution of covariances from LDAK software", xlab="Covariance", freq=F)
# g2 <- grab_grob()
# grid.newpage()
# 
# 
# 
# 
# # library(gridExtra)
# # grid.arrange(g,g, ncol=2, clip=TRUE)
# 
# lay <- grid.layout(nrow = 1, ncol=2)
# pushViewport(viewport(layout = lay))
# grid.draw(editGrob(g1, vp=viewport(layout.pos.row = 1, 
#                                   layout.pos.col = 1, clip=TRUE)))
# grid.draw(editGrob(g2, vp=viewport(layout.pos.row = 1, 
#                                   layout.pos.col = 2, clip=TRUE)))
# upViewport(1)

cat("\n\n OUPUT desirable corsses \n\n")

head(desirable_crosses)
tail(desirable_crosses)
dim(desirable_crosses)

write.table(desirable_crosses, titre_crosses_CONSTRAINTS_output, col.names = T, dec=".", sep=" ", quote=F, row.names = F)

sessionInfo()
