
# Goal: extract mating plan form ga outputs


Sys.time()
cat("\n\nafter_genetic_algorithm.R\n\n")
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

titre_mating_plan_ga_input <- variables[1]
titre_fitness_evolution_ga_input <- variables[2]
titre_crosses_input <- variables[3]
criterion <- variables[4]
titre_mating_plan_output <- variables[5]
titre_fitness_graph_output <- variables[6]
model_number <- as.numeric(variables[7])


cat("\n\n INPUT : output of AG \n\n")
m <- fread(titre_mating_plan_ga_input, skip=9)
head(m)
tail(m)
dim(m)

cat("\n\n INPUT : crosses \n\n")
crosses <- fread(titre_crosses_input)
head(crosses)
tail(crosses)
dim(crosses)


cat("\n\n INPUT : output of AG \n\n")
e <- fread(titre_fitness_evolution_ga_input)
head(e)
tail(e)
dim(e)

e2 <- e %>% dplyr::select(c(1, 1+model_number))
colnames(e2)  <- c("num_gen","fitness")

maximum=max(e2$fitness)

graph <- e2 %>%
  ggplot(aes(x=num_gen, y=fitness)) +
  geom_point() +
  theme_light() +
  xlab("generation") +
  ylab("fitness") +
  geom_hline(yintercept = maximum, col="red") +
  ggtitle(paste0("Fitness for ", criterion)) +
  geom_smooth(se=F, col="blue", method="loess")

ggsave(titre_fitness_graph_output, graph)


mf <- m %>% 
  inner_join(crosses %>%
               dplyr::select(P1, P2, genetic_map, simulation, qtls, qtls_info, heritability, genomic, population, progeny, population_ID, CONSTRAINTS),
             by=c("P1","P2")) %>%
  mutate(criterion=!!criterion) %>%
  dplyr::select(P1, P2, genetic_map, simulation, qtls, qtls_info, heritability, genomic, population, progeny, population_ID, CONSTRAINTS, criterion, nbprogeny) %>%
  arrange(P1, P2)


cat("\n\n output : clean output of AG \n\n")
head(mf)
tail(mf)
dim(mf)

write.table(mf, titre_mating_plan_output, col.names = T, row.names = F, dec=".", sep="\t", quote=F)


sessionInfo()