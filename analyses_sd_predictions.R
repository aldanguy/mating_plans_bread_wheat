

# Goal : Produce a standardized map for each population to compute variance-covariance matrix of progeny genotype
# Input : recombination profiles of several populations
# Output : standardized genetic map for each pop



Sys.time()
cat("\n\nanalyses_sd_predictions.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))



titre_lines_sd_predictions <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_sd_predictions.txt"
titre_pedigree_sd_predictions <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/pedigree_sd_predictions.txt"
titre_crosses <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/crosses.txt"
titre_genotyping <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/genotyping_sd_predictions.txt"
titre_pos <- "/home/adanguydesd/Documents/These_Alice/recombinaison/pipeline/amont/Vraies_positions_marqueurs.txt"


lines <- fread(titre_lines_sd_predictions) %>% filter(generation==1)
head(lines)
dim(lines)

ped <-  fread(titre_pedigree_sd_predictions) %>% filter(generation==1)
head(ped)
dim(ped)

crosses <- fread(titre_crosses)
head(crosses)
dim(crosses)




lines %>% slice(101:200) %>%
  summarise(sd=sd(gebv))

crosses %>% filter(P1=="AO07438_XXX00000000000000000" & P2=="EM00006_XXX00000000000000000")


geno <- fread(titre_genotyping, skip = 841, nrow=800)
geno[1:10,200:210]


lines2 <- lines %>% dplyr::select(ID, gebv)%>%
  inner_join(ped, by=c("ID")) %>%
  inner_join(crosses, by=c("P1","P2")) %>%
  dplyr::select(P1, P2, u, sd, log_w, uc, ID, gebv)


####### Check mean of progenies

lines2 %>% group_by(P1, P2,u) %>%
  summarise(mean=mean(gebv)) %>%
  ggplot(aes(x=u, y=mean)) +
  geom_point() +
  geom_abline(slope=1, intercept = 0, col="red")









mkrs <- fread(titre_genotyping, nrows = 1)
pos <- fread(titre_pos)

which(!!mkrs %in% pos$BW)


titre_best_crosses_gebv <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/best_crosses_gebv_g1.txt"
titre_best_crosses_uc <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/best_crosses_uc_g1.txt"


titre_lines_random <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_random.txt"
titre_lines_logw <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_logw.txt"



titre_pedigree_gebv <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/pedigree_gebv.txt"
titre_pedigree_uc <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/pedigree_uc.txt"
titre_pedigree_random <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/pedigree_random.txt"


sd <- fread(titre_sd_predictions) %>% filter(generation==1) %>% dplyr::select(ID, gebv)
crosses <- fread(titre_crosses)
pedigree_sd <- fread(titre_pedigree_sd_predictions) %>% filter(generation==1) %>% dplyr::select(ID, P1, P2)
sd2 <- sd %>% inner_join(pedigree_sd, by="ID") %>% inner_join(crosses, by=c("P1"="P1", "P2"="P2")) %>%
  arrange(ID)


sd3 <- sd2 %>% group_by(P1, P2, u, sd) %>%
  summarise(u_observe=mean(gebv), sd_observe=sd(gebv)) %>%
  mutate(ratio=sd_observe/sd)  %>%
  arrange(desc(sd_observe))

sd3 %>% ggplot(aes(x=u_observe, y=ratio)) + geom_point()

sd3 %>% ggplot(aes(x=u, y=u_observe)) + geom_point() +
  geom_abline(intercept = 0, slope = 1, col="red") +
  xlab("mean of parental EBV") +
  ylab("mean of 200 progenies") +
  ggtitle("Verification of expected mean of progenies")

sd3 %>% ggplot(aes(x=sd, y=sd_observe)) + geom_point() +
  geom_abline(intercept = 0, slope = 1, col="red") +
  xlab("sd predicted") +
  ylab("sd observed on 200 progenies") +
  ggtitle("Verification of expected variance of progenies")


sd2 %>% group_by(P1, P2, u, sd, uc) %>%
  mutate(q93=quantile(gebv, 0.9)) %>%
  filter(gebv >= q903) %>%
  summarise(UC93_observed=mean(gebv)) %>%
  mutate(UC93=u+1.76*sd) %>%
  mutate(UC93_2=u + 1.76*sd_observe) %>%
  ggplot(aes(x=UC93, y=UC93_observed)) +
  geom_point()+
  geom_abline(intercept = 0, slope = 1, col="red")

pdf(titre_pdf)
par(mfrow=c(2,2))
for (i in 1 : nrow(sd3)){
  
  temp <- sd2 %>% filter(P1 == sd3$P1[i] & P2==sd3$P2[i])
  hist(temp$gebv, main = paste0(sd3$P1[i], "\n", sd3$P2[i]), xlab="gebv of progeny", ylab="density", freq=F, n=100,)
  x <- seq(min(temp$gebv), max(temp$gebv), 0.001)
  lines(x, dnorm(x, mean=mean(temp$gebv), sd=sd(temp$gebv)), col="red")
  legend("topleft", legend=paste0("sd_obs/sd_pred = ",round(sd3$sd_observe[i]/sd3$sd[i],2)), bty="n")

}
  
dev.off()


best_crosses_gebv <- fread(titre_best_crosses_gebv)
best_crosses_uc <- fread(titre_best_crosses_uc)

quantile(best_crosses_uc$nbprogeny)
quantile(best_crosses_gebv$nbprogeny)



lines_gebv <- fread(titre_lines_gebv) %>% filter(generation ==1)
lines_uc <- fread(titre_lines_uc) %>% filter(generation ==1)
lines_random <- fread(titre_lines_random) %>% filter(generation ==1)
lines_logw <- fread(titre_lines_logw)%>% filter(generation ==1)

lines <- rbind(lines_gebv, lines_uc) %>% rbind(., lines_random) %>% rbind(., lines_logw)

lines %>% ggplot(aes(x = best_crosses, y=gebv)) + geom_boxplot()

best_parent=fread(titre_lines_gebv) %>% filter(generation ==0) %>% summarise(max=max(gebv, na.rm=T)) %>% unlist() %>% as.vector()

lines %>% group_by(best_crosses) %>%
  mutate(gebv2=ifelse(gebv >= quantile(gebv, 0.95), gebv, NA)) %>%
  mutate(gebv3=ifelse(gebv > best_parent, 1, 0)) %>%
  summarise(mean=mean(gebv), median=median(gebv), q95=quantile(gebv, 0.95), max=max(gebv), mean95=mean(gebv2, na.rm=T), sup_best_parent=sum(gebv3))
# results very close but gebv outperfom uc, why ?
# sd is badly estimated -> vérifier avec corrélation sd et descendants
# random meiosis (random should be centered on 0 right ?)-> essayer au moins 10
# can it be reduced/increase with constraint on mating plan ? le meilleur couple n'est pas utilisé à cause des contrainte. L'un des partenaire est à atteint Cmax

# about similarity in results
# parents/crosses are the same
# uc is mainly driven by , and crosses with strong u = with low sd

# what about filtration of u in a first place

sd(crosses$u)
sd(crosses$sd)


pedigree_gebv <- fread(titre_pedigree_gebv) %>%
  filter(generation==1) %>%
  mutate(best_crosses="gebv")



pedigree_uc <- fread(titre_pedigree_uc) %>%
  filter(generation==1) %>%
  mutate(best_crosses="uc")


pedigree_random <- fread(titre_pedigree_random) %>%
  filter(generation==1) %>%
  mutate(best_crosses="random")


pedigree <- rbind(pedigree_gebv, pedigree_uc, pedigree_random) %>%
  group_by(P1, P2, best_crosses) %>% 
  summarise(nbprogeny=n()) %>%
  pivot_wider(id_cols=c("P1","P2"), names_from = "best_crosses", values_from = "nbprogeny")


head(pedigree)

pedigree %>% filter(!is.na(uc) & !is.na(gebv)) %>% as.data.frame() %>% nrow() #64 crosses in common
pedigree %>% filter(uc >= 30 & gebv>=30) %>% as.data.frame() %>% nrow()
pedigree %>% filter(!is.na(uc) & !is.na(gebv)) %>%
  mutate(total=uc+gebv) %>%
  ungroup() %>%
  mutate(totaluc=sum(uc)) %>%
  mutate(totalgebv=sum(gebv)) %>%
  summarise(total=sum(total)/(3300*2))
# 38% of progenies coming from same crosses
# 50% of crosses used in uc are used in gebv, and 30%of crosses used in gebv are present in uc


lines %>% group_by(best_crosses) %>%
  mutate(q90=quantile(gebv, 0.9)) %>%
  filter(gebv>=q90) %>%
  dplyr::select(best_crosses, ID) %>%
  inner_join(rbind(pedigree_gebv, pedigree_uc, pedigree_random), by=c("ID"="ID","best_crosses"="best_crosses")) %>%
  group_by(best_crosses, P1, P2) %>%
  summarise(nbprogeny=n()) %>%
  pivot_wider(id_cols=c("P1","P2"), names_from = "best_crosses", values_from = "nbprogeny") %>%
  filter(!is.na(gebv) & !is.na(uc))
# 9 crosses in top 10 of gebv or uc are in common



# characteristic of parent used ?
# preidction of sigma




crosses <- fread(titre_crosses)
head(crosses)



topuc99 <- crosses %>% 
  mutate(top_uc=ifelse (uc >quantile(uc, 0.99), T, F))%>%
  ggplot(aes(x=u, y=sd, col=top_uc)) + geom_point()

topuc90 <- crosses %>% 
  mutate(top_uc=ifelse (uc >quantile(uc, 0.99), T, F))%>%
  ggplot(aes(x=u, y=sd, col=top_uc)) + geom_point()


crosses %>% 
  mutate(top_uc=ifelse (uc >quantile(uc, 0.90), T, F)) %>%
  full_join(pedigree %>%
              filter(uc >30 | gebv > 30) %>%
              mutate(choice=case_when(!is.na(uc) & !is.na(gebv) ~ "both",
                                      !is.na(uc) & is.na(gebv) ~ "uc only",
                                      is.na(uc) & !is.na(gebv) ~ "gebv only")),
            by=c("P1"="P1", "P2"="P2")) %>%
  mutate(choice = ifelse(is.na(choice), "none", choice)) %>%
  mutate(choice=factor(choice, levels=c("both","uc only","gebv only","none"))) %>%
  ggplot(aes(x=u, y=sd, col=choice)) + geom_point(size=0.5) +
  scale_colour_manual(values=c("red","blue","darkgreen","grey"))

crosses %>% 
  mutate(top_uc=ifelse (uc >quantile(uc, 0.90), T, F)) %>%
  full_join(pedigree %>%
              filter(uc >30 | gebv > 30) %>%
              mutate(choice=case_when(!is.na(uc) & !is.na(gebv) ~ "both",
                                      !is.na(uc) & is.na(gebv) ~ "uc only",
                                      is.na(uc) & !is.na(gebv) ~ "gebv only")),
            by=c("P1"="P1", "P2"="P2")) %>%
  mutate(choice = ifelse(is.na(choice), "none", choice)) %>%
  mutate(choice=factor(choice, levels=c("both","uc only","gebv only","none"))) %>%
  ggplot(aes(x=u, y=uc.x, col=choice)) + geom_point(size=0.5) +
  scale_colour_manual(values=c("red","blue","darkgreen","grey"))

# combien de parents/couples en commun
# meilleur descendant uc = meilleur descendant gebv
# uc et sd bien prédits



crosses %>% arrange(desc(uc)) %>% head()

best_crosses_uc %>% arrange(desc(nbprogeny))
best_crosses_uc %>% filter(P1=="AO15011_XXX00000000000000000" | P2=="AO15011_XXX00000000000000000")

crosses %>% filter(P1=="AO11006_XXX00000000000000000" & P2=="AO13029_XXX00000000000000000")


# le meilleur couple n'est pas utilisé à cause des contrainte. L'un des partenaire est à atteint Cmax
# pb: meilleur u = meilleur uc car à fort u, sd est faible
# refaire tourner plusieurs fois

sessionInfo()
















titre_lines_gebv <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_gebv_g1.txt"
titre_lines_uc <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_uc_g1.txt"
titre_lines_logw <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_logw_g1.txt"
titre_lines_random <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_random_g1.txt"




lines_gebv <- fread(titre_lines_gebv) %>% filter(generation==1)
lines_uc <- fread(titre_lines_uc) %>% filter(generation==1)
lines_logw <- fread(titre_lines_logw) %>% filter(generation==1)
lines_random <- fread(titre_lines_random) %>% filter(generation==1)


head(lines_gebv)
tail(lines_gebv)

lines <- rbind(lines_gebv, lines_uc, lines_logw, lines_random) %>%
  mutate(best_crosses=factor(best_crosses, levels=c("random","gebv","uc","logw"))) %>%
  filter(run==1)
head(lines)
tail(lines_gebv)


lines %>% ggplot(aes(x=best_crosses, y=gebv, col=best_crosses)) + geom_boxplot() +
  xlab("Method to choose best crosses") +
  ylab("EBV of all progenies (10 independent simulations)")

selection=0.001
lines %>%
  group_by(best_crosses) %>%
  mutate(q=quantile(gebv, 1-selection)) %>%
  filter(gebv >= q)%>% 
  ggplot(aes(x=best_crosses, y=gebv, col=best_crosses)) + geom_boxplot() +
  xlab("Method to choose best crosses") +
  ylab("EBV of 7% best progenies (10 independent simulations)")

parent_max <- fread(titre_lines_gebv) %>% filter(generation==0) %>%
  summarise(max=max(gebv, na.rm=T)) %>%
  unlist() %>%
  as.vector()

lines %>%
  group_by(best_crosses) %>%
  mutate(q=quantile(gebv, 1-selection)) %>%
  filter(gebv >= q)%>%
  summarise(q=unique(q),
            median=median(gebv),
            mean=mean(gebv),
            sdgebv=sd(gebv),
            max=max(gebv))
