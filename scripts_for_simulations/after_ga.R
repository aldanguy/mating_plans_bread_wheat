



Sys.time()
cat("\n\nafter_ga.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(ggpubr))


variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")

titre_best_crosses_ag <- variables[1]
titre_best_crosses_output <- variables[2]
type <- variables[3]
population_variance <- variables[4]
critere=variables[5]
programme=variables[6]
titre_evolution=variables[7]
evolution_graph=variables[8]
model=as.numeric(variables[9])
progeny <- variables[10]


cat("\n\n INPUT : output of AG \n\n")
f <- fread(titre_best_crosses_ag, skip=9)
head(f)
tail(f)
dim(f)


cat("\n\n INPUT : output of AG \n\n")
evolution <- fread(titre_evolution)
head(evolution)
tail(evolution)
dim(evolution)
1+model

evolution <- evolution %>% dplyr::select(c(1, 1+model))
colnames(evolution)  <- c("num_gen","fitness")

maximum=max(evolution$fitness)

graph <- evolution %>%
  ggplot(aes(x=num_gen, y=fitness)) +
  geom_point() +
  theme_light() +
  xlab("generation") +
  ylab("fitness") +
  geom_hline(yintercept = maximum, col="red") +
  ggtitle(paste0(type,"_", population_variance, "_", critere, "_",programme,"_",progeny)) +
  geom_smooth(se=F, col="blue", method="loess")

ggsave(evolution_graph, graph)

sim=gsub("sim","",as.vector(unlist(strsplit(type, split="_")))[1])


if (sim == "FALSE"){
  
  g=gsub("g","",as.vector(unlist(strsplit(type, split="_")))[2])
  h=NA
  r=NA
  qtls=NA
  
  etat="estimated"
  
  
  
} else if (sim=="TRUE") {
  
  
  if (grepl("_h", type)){
    
    qtls=as.vector(unlist(strsplit(type, split="_")))[2]
    h=gsub("h","",as.vector(unlist(strsplit(type, split="_")))[3])
    r=paste0(as.vector(unlist(strsplit(type, split="_")))[4],"r")
    g=gsub("g","",as.vector(unlist(strsplit(type, split="_")))[5])
    etat="estimated"
    
    
    
    
  } else if (!grepl("_h", type)) {
    
    qtls=as.vector(unlist(strsplit(type, split="_")))[2]
    r=paste0(as.vector(unlist(strsplit(type, split="_")))[3],"r")
    h=NA
    g=NA
    etat="real"
    
    
    
  }
  
  
}



f <- f %>% mutate(type=!!etat,
                  sim=!!sim,
                  qtls=!!qtls,
                  h=!!h,
                  r=!!r,
                  population_variance=!!population_variance,
                  critere=!!critere,
                  progeny=!!progeny,
                  programme=!!programme) %>%
  dplyr::select(P1, P2, type, sim, qtls, h, r, population_variance, critere, programme, progeny,nbprogeny) %>%
  arrange(P1, P2)


cat("\n\n output : clean output of AG \n\n")
head(f)
tail(f)
dim(f)

write.table(f, titre_best_crosses_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)


sessionInfo()