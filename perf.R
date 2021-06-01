
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


type <-  variables[1]
critere<- variables[2]
programme <- variables[3]
population_variance <- variables[4]
progeny <- variables[5]
optimization <- variables[6]
fitness <- variables[7]
time <- variables[8]
gen <- variables[9]
titre_output <- variables[10]


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

output <- data.frame(type=etat,
           sim=sim,
           qtls=qtls,
           h=h,
           r=r,
           g=g,
           population_variance=population_variance,
           critere=critere,
           programme=programme,
           progeny=progeny,
           optimization=optimization,
           time=time,
           gen=gen,
           fitness=fitness)


head(output)

write.table(output, titre_output, col.names = F, row.names = F, dec=".", sep="\t", quote=F)

sessionInfo()