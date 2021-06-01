



Sys.time()
cat("\n\ndifferences_parents.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <- Sys.time()

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))

titre_g_ldak <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/g_ldak"
titre_lines <-  "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_estimated.txt"


l <- fread(titre_lines)  %>%
  arrange(ID) %>%
  dplyr::select(ID) %>%
  unlist() %>%
  as.vector() %>%
  unique() %>%
  sub('_XX.*', '', .)


plan1 <- data.frame(P1=sample(l, size=10, replace=F), P2=sample(l, size=10, replace = F), nbprogeny=60)
plan2 <- data.frame(P1=sample(l, size=10, replace=F), P2=sample(l, size=10, replace = F), nbprogeny=60)
plan3 <- data.frame(P1=plan1$P1, P2=sample(l, size=10, replace = F), nbprogeny=60)






g <- fread(titre_g_ldak) %>% as.matrix()

colnames(g) <- l
rownames(g) <- l


heatmap(g)





g2 <- g[upper.tri(g, diag = F)]




# apparentement moyen intra plan


library(reshape2)
g3 <- setNames(melt(g), c('P2', 'P1', 'k')) %>%
  mutate(P12=P2) %>%
  filter(P1 != P12) %>%
  dplyr::select(-P12)



p1 <- plan1 %>% inner_join(g3, by=c("P1","P2"))
p2 <- plan2 %>% inner_join(g3, by=c("P1","P2"))

mean(p1$k)
var(p1$k)
mean(p2$k)
var(p2$k)
hist(g2)
mean(g2)
var(g2)

p <- rbind(p1, p2) %>%
  dplyr::select(P1, P2) %>%
  unlist() %>%
  as.vector() %>%
  unique() %>%
  sort()


expand.grid(p, p) %>%
  rename(P1=Var1, P2=Var2)






plan1_2 <- as.numeric()
for (i in plan1){
  
  for (j in plan2){
    
    plan1_2 <- c(plan1_2, g[i,j])
    
  }
    
    
    
    }
plan11 <- as.numeric()
for (i in 1:(length(plan1)-1)){
  
  for (j in (i+1):length(plan1)){
    
    plan11 <- c(plan11, g[plan1[i], plan1[j]])
    
  }
}
    
    
    
  



plan22 <- as.numeric()
for (i in 1:(length(plan2)-1)){
  
  for (j in (i+1):length(plan2)){
    
    plan22 <- c(plan22, g[plan2[i], plan2[j]])
    
  }
}

# distribution intra helps to see if parents of the same MP are related


var(plan11)
var(plan22)
var(plan1_2)
