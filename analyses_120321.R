



Sys.time()
cat("\n\analysis.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)
t1 <- Sys.time()


suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(ggpubr))
suppressPackageStartupMessages(library(MASS))
suppressPackageStartupMessages(library(viridis))
suppressPackageStartupMessages(library(ggplot2))



titre_crosses_WE <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/crosses_WE.txt"
titre_markers <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/markers_estimated.txt"
titre_lines <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_g2.txt"
titre_ped <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/pedigree_g2.txt"
titre_best_crosses <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/best_crosses.txt"

titre_lines_pred <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_g1_simFALSE_allcm_WE_sd_prediction_prefWE_pvarWE.txt"
titre_pedigree_pred <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/pedigree_g1_simFALSE_allcm_WE_sd_prediction_prefWE_pvarWE.txt"
titre_lines_parents <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_estimated.txt"


extraction <- function(string, character_split, number){
  
  out <- as.vector(unlist(strsplit(string, split=character_split)))
  
  if (number > length(out)){
    
    out <- NA
  } else {
    
    out <- out[number]
  }
  
  return(out)
  
}

get_density <- function(x, y, ...) {
  dens <- MASS::kde2d(x, y, ...)
  ix <- findInterval(x, dens$x)
  iy <- findInterval(y, dens$y)
  ii <- cbind(ix, iy)
  return(dens$z[ii])
}





# Question : Quel est le gain génétique permis par l'optimisation des croisements dans le cadre d'un programme de sélection réaliste ?




# Partie 1 : application à un programme de sélection réel
# A) précision des estimateurs
# B) Relation entre estimateurs
# C) overlapp entre critere
# D) Gain génétique 
# E) Couples et parents à l'origine des élites
# F) Un plan de croisement généreux (10 couples, Dmax=1000, aucune contrainte) favorise t-il un des critères ?
# Partie 2 : simulation de QTL, plusieurs architectures génétique
# A) effet de l'architecture sur la variance. 
# B) gain
# Partie 3 : effet de l'estimation
# A) précision des estimateurs, chute de variance
# B) chute du gain







# Partie 1 : application à un programme de sélection réel

# A) Précision des estimateurs

type="marker_simFALSE_allcm"
type2="gebv_simFALSE_allcm"

l1 <- fread(titre_lines_pred) %>%
  dplyr::select(ID, value)


p1 <- fread(titre_pedigree_pred) %>%
  dplyr::select(ID, P1, P2)

c1 <- fread(titre_crosses_WE) %>%
  filter(type=="marker_simFALSE_allcm") %>%
  dplyr::select(P1, P2, gebv, sd, logw, uc, uc_extreme) %>%
  mutate(logw=1 - 10^logw)

best_parental_line <- fread(titre_lines_parents) %>%
  filter(type=="gebv_simFALSE_allcm") %>% 
  dplyr::select(value) %>%
  unlist() %>%
  as.vector() %>%
  max()

f1 <- l1 %>%
  inner_join(p1, by=c("ID")) %>%
  group_by(P1, P2) %>%
  mutate(sup_best_parent=ifelse(value >= best_parental_line, 1, 0)) %>%
  mutate(sup_best_parent=sum(sup_best_parent)/n()) %>%
  mutate(superior_fraction=quantile(value, 0.93)) %>%
  mutate(sup_superior_fraction=ifelse(value >= superior_fraction, value, NA)) %>%
  mutate(superior_fraction_extreme=quantile(value, 1e-4)) %>%
  mutate(sup_superior_fraction_extreme=ifelse(value >= superior_fraction_extreme, value, NA)) %>%
  summarise(gebvo=mean(value), 
            sdo=sd(value), 
            uco=mean(sup_superior_fraction, na.rm=T), 
            uc_extremeo=mean(sup_superior_fraction_extreme, na.rm=T), 
            logwo=unique(sup_best_parent)) %>%
  inner_join(c1, by=c("P1","P2"))
  
pred_gebv <- f1 %>%
  ggplot(aes(x=gebv, y=gebvo)) +
  geom_point()+
  geom_abline(slope=1, intercept = 0, col="red") +
  theme_light() +
  xlab("expected mean of progeny") +
  ylab("observed")+
  theme(plot.title = element_text(hjust = 0.5))+
  ggtitle("Mean of progeny")

pred_sd <- f1 %>%
  ggplot(aes(x=sd, y=sdo)) +
  geom_point()+
  geom_abline(slope=1, intercept = 0, col="red") +
  theme_light() +
  xlab("expected sd of progeny") +
  ylab("observed")+
  theme(plot.title = element_text(hjust = 0.5))+
  ggtitle("Variability of progeny")


pred_uc <- f1 %>%
  ggplot(aes(x=uc, y=uco)) +
  geom_point()+
  geom_abline(slope=1, intercept = 0, col="red") +
  theme_light() +
  xlab("expected UC of progeny") +
  ylab("observed")+
  theme(plot.title = element_text(hjust = 0.5))+
  ggtitle("UC (q = 0.7%)")


pred_uc_extreme <- f1 %>%
  ggplot(aes(x=uc_extreme, y=uc_extremeo)) +
  geom_point()+
  geom_abline(slope=1, intercept = 0, col="red") +
  theme_light() +
  xlab("expected UC of progeny") +
  ylab("observed")+
  theme(plot.title = element_text(hjust = 0.5))+
  ggtitle("UC (q = 0.01%)")

pred_logw <- f1 %>%
  ggplot(aes(x=logw, y=logwo)) +
  geom_point()+
  geom_abline(slope=1, intercept = 0, col="red") +
  theme_light() +
  xlab("expected proba") +
  ylab("observed")+
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("Proba > best parent")


ggarrange(pred_gebv, pred_sd, pred_uc, pred_uc_extreme, pred_logw, ncol=2, nrow=1)

rm(l1, p1, c1, f1)

# B Relation entre estimateurs



c2 <- fread(titre_crosses_WE) %>%
  filter(type=="marker_simFALSE_allcm") %>%
  dplyr::select(P1, P2, gebv, sd, logw, uc, uc_extreme) 


gebv_sd <- c2 %>%
  mutate(density=get_density(gebv, sd, n = 100)) %>%
  slice(1:1000) %>% # to remove
  ggplot(aes(x=gebv, y=sd, col=density)) +
  geom_point()+
  theme_light() +
  xlab("expected mean of progeny") +
  ylab("expected sd of progeny")+
  theme(plot.title = element_text(hjust = 0.5)) + 
  scale_color_viridis()


gebv_logw <- c2 %>%
  slice(1:1000) %>% # to remove
  ggplot(aes(x=gebv, y=logw)) +
  geom_point()+
  theme_light() +
  xlab("expected mean of progeny") +
  ylab("Proba < best parent (log10)")+
  theme(plot.title = element_text(hjust = 0.5)) +
  geom_smooth(method="loess", col="blue", se=FALSE)

gebv_uc <-c2 %>%
  dplyr::select(P1, P2, gebv, uc, uc_extreme) %>%
  pivot_longer(cols = c("uc","uc_extreme")) %>%
  mutate(name=case_when(name=="uc"~"q = 7%",
                        name=="uc_extreme"~ "q = 0.01%")) %>%
  mutate(name=factor(name, levels=c("q = 7%", "q = 0.01%"))) %>%
  slice(1:10000) %>% #to remove
  ggplot(aes(x=gebv, y=value, col=name)) + 
  geom_point() +
  theme_light() +
  xlab("gebv") +
  ylab("UC") +
  facet_grid(.~name) +
  geom_abline(slope=1, intercept = 0, col="red") +
  theme(strip.background = element_rect(color="black", fill="white"),
        strip.text.y = element_text(color="black"),
        strip.text.x = element_text(color="black"),
        legend.position = "none") +
  scale_color_manual(name="", values = rev(c("#F8766D", "#00BFC4")))



ggarrange(gebv_sd, gebv_logw, gebv_uc, ncol=1, nrow=1)

rm(c2)


# C) overlapp de couples

c3 <- fread(titre_crosses_WE) %>%
  filter(type=="marker_simFALSE_allcm") %>% 
  dplyr::select(P1, P2, gebv, sd, logw, uc, uc_extreme) %>%
  arrange(desc(gebv))


b3 <- fread(titre_best_crosses)  %>%
  filter(type=="marker_simFALSE_allcm") %>%
  filter(affixe=="real")  %>%
  dplyr::select(P1, P2, critere, nbprogeny)  %>%
  pivot_wider(id_cols = c("P1","P2"), names_from = "critere", values_from = "nbprogeny") %>%
  mutate(choosen=case_when(!is.na(gebv) & !is.na(logw) & !is.na(uc) & is.na(uc_extreme)~ "gebv+uc+logw+uc_extreme",
                           is.na(gebv) & !is.na(logw) & !is.na(uc) & is.na(uc_extreme) ~ "uc+logw",
                           is.na(gebv) & is.na(logw) & !is.na(uc) & is.na(uc_extreme)~ "uc",
                           is.na(gebv) & !is.na(logw) & is.na(uc) & is.na(uc_extreme)~ "logw",
                           !is.na(gebv) & is.na(logw) & is.na(uc) & is.na(uc_extreme)~ "gebv",
                           !is.na(gebv) & !is.na(logw) & is.na(uc) & is.na(uc_extreme)~ "gebv+logw",
                           !is.na(gebv) & is.na(logw) & !is.na(uc) & is.na(uc_extreme)~ "gebv+uc",
                           is.na(gebv) & is.na(logw) & is.na(uc) & is.na(uc_extreme)~ "none",
                           is.na(gebv) & !is.na(logw) & !is.na(uc) & !is.na(uc_extreme) ~ "uc+logw+uc_extreme",
                           is.na(gebv) & is.na(logw) & !is.na(uc) & !is.na(uc_extreme)~ "uc+uc_extreme",
                           is.na(gebv) & !is.na(logw) & is.na(uc) & !is.na(uc_extreme)~ "logw+uc_extreme",
                           !is.na(gebv) & is.na(logw) & is.na(uc) & !is.na(uc_extreme)~ "gebv+uc_extreme",
                           !is.na(gebv) & !is.na(logw) & is.na(uc) & !is.na(uc_extreme)~ "gebv+logw+uc_extreme",
                           !is.na(gebv) & is.na(logw) & !is.na(uc) & !is.na(uc_extreme)~ "gebv+uc+uc_extreme",
                           is.na(gebv) & is.na(logw) & is.na(uc) & !is.na(uc_extreme)~ "uc_extreme",
                           is.na(gebv) & is.na(logw) & is.na(uc) & is.na(uc_extreme)~ "none")) %>%
  dplyr::select(P1, P2, choosen, gebv, logw, uc, uc_extreme) %>%
  rename(gebv_progeny=gebv, logwprogeny=logw, ucprogeny=uc, uc_extremeprogeny=uc_extreme) %>%
  mutate(gebv_progeny=ifelse(gebv_progeny>=30, "nbprogeny>30", "nbprogeny<30")) %>%
  
  mutate(ucprogeny2=ifelse(ucprogeny>=30, "nbprogeny>30", "nbprogeny<30")) %>%
  mutate(uc_extremeprogeny=ifelse(uc_extremeprogeny>=30, "nbprogeny>30", "nbprogeny<30")) %>%
  mutate(logwprogeny=ifelse(logwprogeny>=30, "nbprogeny>30", "nbprogeny<30")) %>%
  mutate(gebv_progeny=factor(gebv_progeny,levels=c("nbprogeny>30", "nbprogeny<30"))) %>%
  mutate(ucprogeny=factor(ucprogeny,levels=c("nbprogeny>30", "nbprogeny<30"))) %>%
  mutate(uc_extremeprogeny=factor(uc_extremeprogeny,levels=c("nbprogeny>30", "nbprogeny<30"))) %>%
  mutate(logwprogeny=factor(logwprogeny,levels=c("nbprogeny>30", "nbprogeny<30"))) %>%
  
           
  inner_join(c3, by=c("P1","P2")) 


gebv <- c3 %>%
  slice(1:1000) %>% # to remove
  ggplot(aes(x=gebv, y=sd)) +
  geom_point()+
  theme_light() +
  xlab("expected mean of progeny") +
  ylab("expected sd of progeny")+
  theme(plot.title = element_text(hjust = 0.5)) + 
  geom_point(data=b3 %>% filter(grepl("gebv", choosen)), aes(x=gebv, y=sd, col="choosen"), size=2) +
  scale_color_manual(values=c("#7CAE00"), name="")+
  ggtitle("gebv")



# Remarquer ques le couple élite a droite n'a pas été choisi
# Moyen le plus efficace pour qu'il soit choisi = augmenter Cmax
# tentative d'explication : si j'ai un très bon parent et que je ne peux l'utiliser qu'un nombre limité de fois, 
# alors je préfère l'accoupler à des moins bons pour faire augmenter la fitness de la pop
# (au lieu d'avoir 60*top + , je préfère avoir )


uc <- c3 %>%
  slice(1:1000) %>% # to remove
  ggplot(aes(x=gebv, y=sd)) +
  geom_point()+
  theme_light() +
  xlab("expected mean of progeny") +
  ylab("expected sd of progeny")+
  theme(plot.title = element_text(hjust = 0.5)) + 
  geom_point(data=b3 %>% 
               filter(!is.na(choosen)) %>%
               mutate(choosen=paste0(choosen,"+")) %>%
               filter(grepl(pattern="+uc", x=choosen) | grepl("+uc+", choosen) | grepl("uc+", choosen)) , 
             aes(x=gebv, y=sd, size=ifelse(ucprogeny=="nbprogeny>30", 5, 2), col="choosen"), size=2) +
  theme(legend.position="none") +
  scale_color_manual(values=c("#00BFC4"))+
  ggtitle("UC (q = 7%)")


logw <- c3 %>%
  slice(1:1000) %>% # to remove
  ggplot(aes(x=gebv, y=sd)) +
  geom_point()+
  theme_light() +
  xlab("expected mean of progeny") +
  ylab("expected sd of progeny")+
  theme(plot.title = element_text(hjust = 0.5)) + 
  geom_point(data=b3 %>% filter(grepl("logw", choosen)), aes(x=gebv, y=sd, col="choosen"), size=2) +
  theme(legend.position="none") +
  scale_color_manual(values=c("#C77CFF"))+
  ggtitle("logw")

uc_extreme <- c3 %>%
  slice(1:1000) %>% # to remove
  ggplot(aes(x=gebv, y=sd)) +
  geom_point()+
  theme_light() +
  xlab("expected mean of progeny") +
  ylab("expected sd of progeny")+
  theme(plot.title = element_text(hjust = 0.5)) + 
  geom_point(data=b3 %>% filter(grepl("uc_extreme", choosen)), aes(x=gebv, y=sd, col="choosen"), size=2) +
  theme(legend.position="none") +
  scale_color_manual(values=c("#F8766D")) +
  ggtitle("UC (q = 0.01%)")


all <- c3 %>%
  slice(1:1000) %>% # to remove
  ggplot(aes(x=gebv, y=sd)) +
  geom_point()+
  theme_light() +
  xlab("expected mean of progeny") +
  ylab("expected sd of progeny")+
  theme(plot.title = element_text(hjust = 0.5)) + 
  geom_point(data=b3 %>% filter(!is.na(choosen)), aes(x=gebv, y=sd, col=choosen), size=2) +
  ggtitle("all")


ggarrange(gebv, logw, uc, uc_extreme, all, ncol=1, nrow=1)

rm(b3, c3)



# D) Gain génétique




l4 <- fread(titre_lines) %>%
  filter(type=="marker_simFALSE_allcm") %>% 
  filter(affixe=="real") %>%
  mutate(rr=as.factor(rr)) %>%
  mutate(critere=ifelse(critere=="uc", "UC q = 7%", critere)) %>%
  mutate(critere=ifelse(critere=="uc_extreme", "UC q = 0.01%", critere)) %>%
  mutate(critere=factor(critere, levels=c("gebv","logw", "UC q = 7%", "UC q = 0.01%"))) %>%
  group_by(critere, rr) %>%
  mutate(sd_progeny=sd(gebv)) %>%
  mutate(mean_progeny=mean(gebv)) %>%
  mutate(q0.93=quantile(gebv, 0.93)) %>%
  filter(gebv >= q0.93) %>%
  summarise(best=max(gebv), 
            mean=mean(gebv), 
            mean_progeny=unique(mean_progeny), 
            sd_progeny=unique(sd_progeny)) %>%
  ungroup()



p4 <- fread(titre_ped) %>%
  filter(type=="marker_simFALSE_allcm") %>%
  filter(affixe=="real") %>%
  dplyr::select(ID, P1, P2, critere, rr)

c4 <- fread(titre_crosses_WE) %>%
  filter(type=="marker_simFALSE_allcm") %>%
  arrange(desc(gebv)) %>%
  mutate(rank_gebv=1:n())

l4best <- fread(titre_lines) %>%
  filter(type=="marker_simFALSE_allcm") %>%
  filter(affixe=="real") %>%
  group_by(critere, rr) %>%
  mutate(best=max(gebv)) %>%
  filter(gebv==best) %>%
  dplyr::select(ID, rr, critere, gebv)%>% 
  inner_join(p4, by=c("ID","critere","rr")) %>%
  ungroup() %>%
  dplyr::select(P1, P2, critere, rr) %>%
  arrange(P1, P2) %>%
  full_join(c4, b=c("P1","P2")) %>%
  dplyr::select(P1, P2, rank_gebv, gebv, sd, logw, uc, uc_extreme, critere, rr)



best <- l4 %>% 
  ggplot(aes(x=critere, y=best, col=critere)) +
  geom_boxplot() +
  geom_point()+
  theme_light() +
  ylab("EBV")+
  xlab("")+
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("Best progeny")+
  theme(legend.position = "none")+
  scale_color_manual(values=c("#7CAE00","#C77CFF","#00BFC4","#F8766D"))

topmean <- l4 %>% 
  ggplot(aes(x=critere, y=mean, col=critere)) +
  geom_boxplot() +
  geom_point()+
  theme_light() +
  ylab("EBV")+
  xlab("")+
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("Mean of top 7% progeny")+
  theme(legend.position = "none")+
  scale_color_manual(values=c("#7CAE00","#C77CFF","#00BFC4","#F8766D"))



mean <- l4 %>% 
  ggplot(aes(x=critere, y=mean_progeny, col=critere)) +
  geom_boxplot() +
  geom_point()+
  theme_light() +
  ylab("EBV")+
  xlab("")+
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("Mean of all progeny")+
  theme(legend.position = "none")+
  scale_color_manual(values=c("#7CAE00","#C77CFF","#00BFC4","#F8766D"))



sd <- l4 %>% 
  ggplot(aes(x=critere, y=sd_progeny, col=critere)) +
  geom_boxplot() +
  geom_point()+
  theme_light() +
  ylab("EBV")+
  xlab("")+
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("sd of all progeny")+
  theme(legend.position = "none")+
  scale_color_manual(values=c("#7CAE00","#C77CFF","#00BFC4","#F8766D"))



ggarrange(best, topmean, mean, sd)



cat("\n\n best progeny \n\n")
modbest <- summary(lm(best~critere, data=l4))
modbest
cat("\n gain for logw (%) \n")
round(coefficients(modbest)[2]/coefficients(modbest)[1],2)
cat("\n gain for uc 7% (%) \n")
round(coefficients(modbest)[3]/coefficients(modbest)[1],2)
cat("\n gain for uc 0.01 (%) \n")
round(coefficients(modbest)[4]/coefficients(modbest)[1],2)

cat("\n\n mean of top 7% progeny \n\n")
modtopmean <- summary(lm(mean~critere, data=l4))
modtopmean
cat("\n gain for logw (%) \n")
round(coefficients(modtopmean)[2]/coefficients(modtopmean)[1],2)

cat("\n\n mean of all progeny \n\n")
modmean <- summary(lm(mean_progeny~critere, data=l4))
modmean
cat("\n gain for logw (%) \n")
round(coefficients(modmean)[2]/coefficients(modmean)[1],2)
cat("\n gain for uc 7% (%) \n")
round(coefficients(modmean)[3]/coefficients(modmean)[1],2)
cat("\n gain for uc 0.01 (%) \n")
round(coefficients(modmean)[4]/coefficients(modmean)[1],2)

cat("\n\n variability of progeny \n\n")
modsd <- summary(lm(sd_progeny~critere, data=l4))
modsd
cat("\n gain for logw (%) \n")
round(coefficients(modsd)[2]/coefficients(modsd)[1],2)
cat("\n gain for uc 0.01 (%) \n")
round(coefficients(modsd)[4]/coefficients(modsd)[1],2)
# Comment inclure la notion de risque ?

# les elites viennent de memes couples/parents


l4parents <- fread(titre_lines_parents) %>%
  filter(type=="gebv_simFALSE_allcm") %>%
  arrange(desc(value)) %>%
  mutate(rank_gebv=1:n()) %>%
  filter(ID %in% l4best$P1 | ID %in% l4best$P2) %>%
  dplyr::select(ID, rank_gebv)


C <- l4best %>%
  arrange(desc(gebv)) %>%
  filter(!is.na(critere)) %>%
  group_by(P1, P2, critere, rank_gebv) %>%
  summarise(n=n()) %>%
  pivot_wider(id_cols = c("P1","P2","rank_gebv"), values_from = "n", names_from = "critere") %>%
  dplyr::select(P1, P2, gebv, logw, uc, uc_extreme, rank_gebv) %>%
  arrange(rank_gebv) 


P1 <- l4best %>%
  filter(!is.na(critere)) %>%
  group_by(P1, critere) %>%
  summarise(n=n()) %>%
  pivot_wider(id_cols = c("P1"), values_from = "n", names_from = "critere") %>%
  arrange(desc(gebv),  desc(logw), desc(uc)) %>%
  dplyr::select(P1, gebv, logw, uc, uc_extreme) %>%
  rename(P=P1) %>%
  ungroup()

P2 <- l4best %>%
  filter(!is.na(critere)) %>%
  group_by(P2, critere) %>%
  summarise(n=n()) %>%
  pivot_wider(id_cols = c("P2"), values_from = "n", names_from = "critere") %>%
  arrange(desc(gebv),  desc(logw), desc(uc)) %>%
  dplyr::select(P2, gebv, logw, uc, uc_extreme) %>%
  rename(P=P2) %>%
  ungroup()


P <- rbind(P1, P2) %>%
  group_by(P) %>%
  summarise(gebv=sum(gebv, na.rm=T),
            uc=sum(uc, na.rm=T),
            logw=sum(logw, na.rm=T),
            uc_extreme=sum(uc_extreme, na.rm=T)) %>%
  inner_join(l4parents, by=c("P"="ID")) %>%
  mutate(gebv=ifelse(gebv==0, NA, gebv))%>%
  mutate(uc=ifelse(uc==0, NA, uc))%>%
  mutate(logw=ifelse(logw==0, NA, logw))%>%
  mutate(uc_extreme=ifelse(uc_extreme==0, NA, uc_extreme)) %>%
  arrange(rank_gebv)
  
# Chaque élite a deux parents
# Le nombre de fois où un parent est compté = le nombre d'élite qu'il a généré.
# Plus ce nombre se rapproche de 10, plus cela signifie que les élites proviennent systématiquement de ce parent.

# 1 parent est à l'origine de de ~ 100% des élites
# Bilan :
# si on utilise logiciel d'optimisation, il vaut mieux utiliser logw car il est moins bete aec les contraintes
# uc est pas ouf dans ce type de système, à voir avec un système + généreux ?


rm (C, c4, l4, l4best, l4parents, p4, P, P1, P2)

# E) sytsème moins contraint
# hypohèse : l'UC a besoin de grands effectifs pour s'exprimer



l5 <- fread(titre_lines) %>%
  filter(type=="marker_simFALSE_allcm") %>% 
  filter(affixe=="simple") %>%
  mutate(rr=as.factor(rr)) %>%
  mutate(critere=ifelse(critere=="uc", "UC q = 7%", critere)) %>%
  mutate(critere=ifelse(critere=="uc_extreme", "UC q = 0.01%", critere)) %>%
  mutate(critere=factor(critere, levels=c("gebv","logw", "UC q = 7%", "UC q = 0.01%"))) %>%
  group_by(critere, rr) %>%
  mutate(sd_progeny=sd(gebv)) %>%
  mutate(mean_progeny=mean(gebv)) %>%
  mutate(q0.93=quantile(gebv, 0.93)) %>%
  filter(gebv >= q0.93) %>%
  summarise(best=max(gebv), 
            mean=mean(gebv), 
            mean_progeny=unique(mean_progeny), 
            sd_progeny=unique(sd_progeny)) %>%
  ungroup()





p5 <- fread(titre_ped) %>%
  filter(type=="marker_simFALSE_allcm") %>%
  filter(affixe=="simple") %>%
  dplyr::select(ID, P1, P2, critere, rr)

c5 <- fread(titre_crosses_WE) %>%
  filter(type=="marker_simFALSE_allcm") %>%
  arrange(desc(gebv)) %>%
  mutate(rank_gebv=1:n())

l5best <- fread(titre_lines) %>%
  filter(type=="marker_simFALSE_allcm") %>%
  filter(affixe=="simple") %>%
  group_by(critere, rr) %>%
  mutate(best=max(gebv)) %>%
  filter(gebv==best) %>%
  dplyr::select(ID, rr, critere, gebv)%>% 
  inner_join(p5, by=c("ID","critere","rr")) %>%
  ungroup() %>%
  dplyr::select(P1, P2, critere, rr) %>%
  arrange(P1, P2) %>%
  full_join(c5, b=c("P1","P2")) %>%
  dplyr::select(P1, P2, rank_gebv, gebv, sd, logw, uc, uc_extreme, critere, rr)



best <- l5 %>% 
  ggplot(aes(x=critere, y=best, col=critere)) +
  geom_boxplot() +
  geom_point()+
  theme_light() +
  ylab("EBV")+
  xlab("")+
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("Best progeny")+
  theme(legend.position = "none")+
  scale_color_manual(values=c("#7CAE00","#C77CFF","#00BFC4","#F8766D"))

topmean <- l5 %>% 
  ggplot(aes(x=critere, y=mean, col=critere)) +
  geom_boxplot() +
  geom_point()+
  theme_light() +
  ylab("EBV")+
  xlab("")+
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("Mean of top 7% progeny")+
  theme(legend.position = "none")+
  scale_color_manual(values=c("#7CAE00","#C77CFF","#00BFC4","#F8766D"))



mean <- l5 %>% 
  ggplot(aes(x=critere, y=mean_progeny, col=critere)) +
  geom_boxplot() +
  geom_point()+
  theme_light() +
  ylab("EBV")+
  xlab("")+
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("Mean of all progeny")+
  theme(legend.position = "none")+
  scale_color_manual(values=c("#7CAE00","#C77CFF","#00BFC4","#F8766D"))



sd <- l5 %>% 
  ggplot(aes(x=critere, y=sd_progeny, col=critere)) +
  geom_boxplot() +
  geom_point()+
  theme_light() +
  ylab("EBV")+
  xlab("")+
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("sd of all progeny")+
  theme(legend.position = "none")+
  scale_color_manual(values=c("#7CAE00","#C77CFF","#00BFC4","#F8766D"))



ggarrange(best, topmean, mean, sd)



cat("\n\n best progeny \n\n")
modbest <- summary(lm(best~critere, data=l4))
modbest


cat("\n\n mean of top 7% progeny \n\n")
modtopmean <- summary(lm(mean~critere, data=l4))


l5parents <- fread(titre_lines_parents) %>%
  filter(type=="gebv_simFALSE_allcm") %>%
  arrange(desc(value)) %>%
  mutate(rank_gebv=1:n()) %>%
  filter(ID %in% l5best$P1 | ID %in% l5best$P2) %>%
  dplyr::select(ID, rank_gebv)


C <- l5best %>%
  arrange(desc(gebv)) %>%
  filter(!is.na(critere)) %>%
  group_by(P1, P2, critere, rank_gebv) %>%
  summarise(n=n()) %>%
  pivot_wider(id_cols = c("P1","P2","rank_gebv"), values_from = "n", names_from = "critere") %>%
  dplyr::select(P1, P2, gebv, logw, uc, uc_extreme, rank_gebv) %>%
  arrange(rank_gebv) 

C


# conclusion : ce 2e plan de croisements était trop simple
# sans les contraintes, ce sont les mes couples élites qui sont choisis

rm(c5, C, l5, l5best, p5, l5parents)


# Partie 2 : simulation######################################


# A) effect of QTL on criteria



markers <- fread(titre_markers) %>%
  filter(grepl("simTRUE", type))  %>%
  filter(population=="WE") %>%
  dplyr::select(-population, -dcum) %>%
  filter(type %in% c("marker_simTRUE_20cm_r2", # to remove
                     "marker_simTRUE_20cm_r1", 
                     "marker_simTRUE_allcm_r2", 
                     "marker_simTRUE_allcm_r1",
                     "marker_simTRUE_chrcm_r1",
                     "marker_simTRUE_chrcm_r2"))%>%
  rowwise() %>%
  mutate(h=extraction(type, "_", 4)) %>%
  mutate(h=ifelse(grepl("h",h), "estimated", "true")) %>%
  mutate(case=ifelse(h=="estimated",5,4)) %>%
  mutate(r=as.numeric(gsub("r","",extraction(type, "_", case)))) %>%
  mutate(subset=extraction(type, "_", 3)) %>%
  ungroup() %>%
  dplyr::select(-type, -case) %>%
  pivot_wider(id_cols = c("chr","region", "pos", "marker", "subset","r"), values_from = "value", names_from = "h") %>%
  mutate(subset=factor(subset, levels=c("allcm", "20cm","chrcm")))%>%
  mutate(r=as.factor(r)) %>%
  filter(true !=0) %>%
  mutate(r="simulated")



markers_false <- fread(titre_markers) %>%
  filter(type=="marker_simFALSE_allcm")  %>%
  filter(population=="WE") %>%
  mutate(r="real") %>%
  mutate(subset="real data") %>%
  rename(true=value) %>%
  dplyr::select(chr, region, pos, marker,subset, r,true)





m <- rbind(markers, markers_false) %>%
  mutate(r=factor(r, levels=c("simulated","real"))) %>%
  ggplot(aes(x=subset, y=true, col=r)) + geom_boxplot()+
  theme_light() +
  xlab("Number QTLs") +
  ylab("Effect") + guides(color=guide_legend("Data"))
    
m


c6 <- fread(titre_crosses_WE) %>%
  filter(grepl("simTRUE", type))  %>%
  dplyr::select(-generation, -population) %>%
  filter(type %in% c("marker_simTRUE_20cm_r2", # to remove
                     "marker_simTRUE_20cm_r1", 
                     "marker_simTRUE_allcm_r2", 
                     "marker_simTRUE_allcm_r1",
                     "marker_simTRUE_chrcm_r1",
                     "marker_simTRUE_20cm_h0.8_r1", 
                     "marker_simTRUE_allcm_h0.8_r2", 
                     "marker_simTRUE_allcm_h0.8_r1",
                     "marker_simTRUE_chrcm_h0.8_r1",
                     "marker_simTRUE_chrcm_r2")) %>%
  rowwise() %>%
  mutate(h=extraction(type, "_", 4)) %>%
  mutate(h=ifelse(grepl("h",h), "estimated", "true")) %>%
  mutate(case=ifelse(h=="estimated",5,4)) %>%
  mutate(r=as.numeric(gsub("r","",extraction(type, "_", case)))) %>%
  mutate(subset=extraction(type, "_", 3)) %>%
  ungroup() %>%
  dplyr::select(-type, -case) %>%
  pivot_longer(cols = c("gebv","uc","logw","uc_extreme", "sd"), names_to = "critere") %>%
  pivot_wider(id_cols = c("P1","P2","subset","critere", "r"), values_from = "value", names_from = "h") %>%
  mutate(subset=factor(subset, levels=c("allcm", "20cm","chrcm")))%>%
  mutate(r=as.factor(r))


c6_false <- fread(titre_crosses_WE) %>%
  filter(type=="marker_simFALSE_allcm") %>%
  dplyr::select(P1, P2, gebv, sd, logw, uc, uc_extreme) %>%
  pivot_longer(cols = c("gebv","sd","logw","uc","uc_extreme"), names_to = "critere", values_to = "true") %>%
  mutate(subset="real") %>%
  mutate(r="real") %>%
  dplyr::select(P1, P2, subset, critere, r, true)



sd <- rbind(c6 %>% dplyr::select(-estimated), c6_false) %>% filter(critere=="sd") %>% 
  ggplot(aes(x=subset, y = true, col=r)) +
  geom_violin() +
  ylab("sd (true)") +
  theme_light() +
  xlab("Impact of QTL number/size")+
  ggtitle("sd") +
  theme(plot.title = element_text(hjust = 0.5))


gebv <- rbind(c6, c6_false) %>% filter(critere=="gebv") %>% 
  ggplot(aes(x=subset, y = true, col=r)) +
  geom_violin() +
  ylab("gebv (true)") +
  theme_light() +
  xlab("Impact of QTL number/size")+
  ggtitle("gebv") +
  theme(plot.title = element_text(hjust = 0.5))





uc <- rbind(c6, c6_false) %>% filter(critere=="uc") %>% 
  ggplot(aes(x=subset, y = true, col=r)) +
  geom_violin() +
  ylab("UC q = 7% (true)") +
  theme_light() +
  xlab("Impact of QTL number/size")+
  ggtitle("UC q = 7%") +
  theme(plot.title = element_text(hjust = 0.5))



uc_extreme <- rbind(c6, c6_false) %>% filter(critere=="uc_extreme") %>% 
  ggplot(aes(x=subset, y = true, col=r)) +
  geom_violin() +
  ylab("UC q = 0.01% (true)") +
  theme_light() +
  xlab("Impact of QTL number/size")+
  ggtitle("UC q = 0.01%") +
  theme(plot.title = element_text(hjust = 0.5))


logw <- rbind(c6, c6_false) %>% filter(critere=="logw") %>% 
  ggplot(aes(x=subset, y = true, col=r)) +
  geom_violin() +
  ylab("logw (true)") +
  theme_light() +
  xlab("Impact of QTL number/size")+
  ggtitle("logw") +
  theme(plot.title = element_text(hjust = 0.5))



ggarrange(gebv, sd, logw, uc, uc_extreme, ncol=1, nrow=1, common.legend = T)


# B) genetic gain




l7 <- fread(titre_lines) %>%
  filter(grepl("simTRUE", type)) %>% 
  filter(type %in% c("marker_simTRUE_20cm_r2", # to remove
                     "marker_simTRUE_20cm_r1", 
                     "marker_simTRUE_allcm_r2", 
                     "marker_simTRUE_allcm_r1",
                     "marker_simTRUE_chrcm_r1",
                     "marker_simTRUE_chrcm_r2")) %>%
  filter(affixe=="real") %>%
  filter(!is.na(tbv)) %>%
  mutate(rr=as.factor(rr)) %>%
  mutate(critere=ifelse(critere=="uc", "UC q = 7%", critere)) %>%
  mutate(critere=ifelse(critere=="uc_extreme", "UC q = 0.01%", critere)) %>%
  mutate(critere=factor(critere, levels=c("gebv","logw", "UC q = 7%", "UC q = 0.01%"))) %>%
  dplyr::select(-generation, -population, -affixe, -used_as_parent, -gebv) %>%
  rowwise() %>%
  mutate(h=extraction(type, "_", 4)) %>%
  mutate(h=ifelse(grepl("h",h), "estimated", "true")) %>%
  mutate(case=ifelse(h=="estimated",5,4)) %>%
  mutate(r=as.numeric(gsub("r","",extraction(type, "_", case)))) %>%
  mutate(subset=extraction(type, "_", 3)) %>%
  ungroup() %>%
  mutate(r=as.factor(r)) %>%
  mutate(subset=factor(subset, levels=c("allcm","20cm","chrcm"))) %>%
  dplyr::select(-type, -case, -h) %>%
  group_by(critere, rr, subset, r) %>%
  mutate(sd_progeny=sd(tbv)) %>%
  mutate(mean_progeny=mean(tbv)) %>%
  mutate(q0.93=quantile(tbv, 0.93)) %>%
  filter(tbv >= q0.93) %>%
  summarise(best=max(tbv), 
            mean=mean(tbv), 
            mean_progeny=unique(mean_progeny), 
            sd_progeny=unique(sd_progeny)) %>%
  ungroup()


l7best <- l7 %>%
  arrange(critere, subset, r) %>%
  group_by(subset, r, critere) %>%
  mutate(ref=mean(best)) %>% # prendre le valeur moyenne du meilleur individu par simQTL
  group_by(subset, r) %>%
  mutate(ref=ifelse(critere !="gebv", NA, ref)) %>%
  mutate(ref=mean(ref, na.rm=T)) %>%
  ungroup() %>%
  group_by(critere, subset, r) %>%
  mutate(gain=(best-ref)/ref) %>%
  summarise(gain=mean(gain)) 


best <- l7best%>%
  ggplot(aes(x=critere, y=gain)) +
  geom_boxplot() +
  facet_grid(.~subset) +
  geom_point(data=l7best, aes(x=critere, y=gain, col=r)) +
  theme_light() +
  theme(axis.text.x = element_text(angle = 45, hjust=1))+
  xlab("") +
  ylab("gain (% from gebv)")+
  theme(strip.background = element_rect(color="black", fill="white"),
        strip.text.y = element_text(color="black"),
        strip.text.x = element_text(color="black"))+
  ggtitle("Best progeny") +
  theme(plot.title = element_text(hjust = 0.5))


l7topmean <- l7 %>%
  arrange(critere, subset, r) %>%
  group_by(subset, r, critere) %>%
  mutate(ref=mean(mean)) %>% # prendre le valeur moyenne du meilleur individu par simQTL
  group_by(subset, r) %>%
  mutate(ref=ifelse(critere !="gebv", NA, ref)) %>%
  mutate(ref=mean(ref, na.rm=T)) %>%
  ungroup() %>%
  group_by(critere, subset, r) %>%
  mutate(gain=(mean-ref)/ref) %>%
  summarise(gain=mean(gain))  

topmean <- l7topmean%>%
  ggplot(aes(x=critere, y=gain)) +
  geom_boxplot() +
  facet_grid(.~subset) +
  geom_point(data=l7topmean, aes(x=critere, y=gain, col=r)) +
  theme_light() +
  theme(axis.text.x = element_text(angle = 45, hjust=1))+
  xlab("") +
  ylab("gain (% from gebv)")+
  theme(strip.background = element_rect(color="black", fill="white"),
        strip.text.y = element_text(color="black"),
        strip.text.x = element_text(color="black"))+
  ggtitle("Mean of top 7% progeny") +
  theme(plot.title = element_text(hjust = 0.5))


l7mean <- l7 %>% 
  group_by(critere,rr, subset, r) %>%
  mutate(ref=mean_progeny) %>%
  ungroup() %>%
  mutate(ref=ifelse(critere=="gebv", ref, NA)) %>%
  group_by(subset, r) %>%
  mutate(ref=mean(ref, na.rm = T)) %>%
  mutate(ratio=mean_progeny/ref) %>%
  group_by(critere, subset, r) %>%
  summarise(ratio=mean(ratio))


mean <- l7mean%>%
  ggplot(aes(x=critere, y=ratio)) +
  geom_boxplot() +
  facet_grid(.~subset) +
  geom_point(data=l7mean, aes(x=critere, y=ratio, col=r)) +
  theme_light() +
  theme(axis.text.x = element_text(angle = 45, hjust=1))+
  xlab("") +
  ylab("ratio (% from gebv)")+
  theme(strip.background = element_rect(color="black", fill="white"),
        strip.text.y = element_text(color="black"),
        strip.text.x = element_text(color="black"))+
  ggtitle("Mean of all progeny") +
  theme(plot.title = element_text(hjust = 0.5))



l7sd <- l7 %>% 
  group_by(critere,rr, subset, r) %>%
  mutate(ref=sd_progeny) %>%
  ungroup() %>%
  mutate(ref=ifelse(critere=="gebv", ref, NA)) %>%
  group_by(subset, r) %>%
  mutate(ref=mean(ref, na.rm = T)) %>%
  mutate(ratio=sd_progeny/ref) %>%
  group_by(critere, subset, r) %>%
  summarise(ratio=mean(ratio))


sd <- l7sd%>%
  ggplot(aes(x=critere, y=ratio)) +
  geom_boxplot() +
  facet_grid(.~subset) +
  geom_point(data=l7sd, aes(x=critere, y=ratio, col=r)) +
  theme_light() +
  theme(axis.text.x = element_text(angle = 45, hjust=1))+
  xlab("") +
  ylab("ratio (% from gebv)")+
  theme(strip.background = element_rect(color="black", fill="white"),
        strip.text.y = element_text(color="black"),
        strip.text.x = element_text(color="black"))+
  ggtitle("Variability of all progeny") +
  theme(plot.title = element_text(hjust = 0.5))



ggarrange(best, topmean, mean, sd, ncol=2, nrow=2, common.legend=T)

rm(l7, best, mean, sd, topmean)

# B) effect of estimation








markers <- fread(titre_markers) %>%
  filter(grepl("simTRUE", type))  %>%
  filter(population=="WE") %>%
  dplyr::select(-population, -dcum) %>%
  filter(type %in% c("marker_simTRUE_20cm_r2", # to remove
                     "marker_simTRUE_20cm_r1", 
                     "marker_simTRUE_allcm_r2", 
                     "marker_simTRUE_allcm_r1",
                     "marker_simTRUE_chrcm_r1",
                     "marker_simTRUE_20cm_h0.8_r1", 
                     "marker_simTRUE_allcm_h0.8_r2", 
                     "marker_simTRUE_allcm_h0.8_r1",
                     "marker_simTRUE_chrcm_h0.8_r1",
                     "marker_simTRUE_chrcm_h0.8_r2"))%>%
  rowwise() %>%
  mutate(h=extraction(type, "_", 4)) %>%
  mutate(h=ifelse(grepl("h",h), "estimated", "true")) %>%
  mutate(case=ifelse(h=="estimated",5,4)) %>%
  mutate(r=as.numeric(gsub("r","",extraction(type, "_", case)))) %>%
  mutate(subset=extraction(type, "_", 3)) %>%
  ungroup() %>%
  dplyr::select(-type, -case) %>%
  pivot_wider(id_cols = c("chr","region", "pos", "marker", "subset","r"), values_from = "value", names_from = "h") %>%
  mutate(subset=factor(subset, levels=c("allcm", "20cm","chrcm")))%>%
  mutate(r=as.factor(r)) 


allcm <- markers %>%
  filter(subset=="allcm") %>%
  ggplot(aes(x=true, y=estimated)) + geom_point()+
  theme_light() +
  xlab("true value") +
  ylab("estimated") +
  geom_smooth(method="lm", se=F, col="blue") +
  geom_abline(slope=1, intercept = 0, col="red")+
  facet_wrap(.~r, ncol=3) +
  theme(strip.background = element_rect(color="black", fill="white"),
        strip.text.y = element_text(color="black"),
        strip.text.x = element_text(color="black"))+
  ggtitle("All markers = qtls") +
  theme(plot.title = element_text(hjust = 0.5))



m20cm <- markers %>%
  filter(subset=="20cm") %>%
  ggplot(aes(x=true, y=estimated)) + geom_point()+
  theme_light() +
  xlab("true value") +
  ylab("estimated") +
  geom_smooth(method="lm", se=F, col="blue") +
  geom_abline(slope=1, intercept = 0, col="red")+
  facet_wrap(.~r, ncol=3) +
  theme(strip.background = element_rect(color="black", fill="white"),
        strip.text.y = element_text(color="black"),
        strip.text.x = element_text(color="black"))+
  ggtitle("Every 20 cM marker = qtls") +
  theme(plot.title = element_text(hjust = 0.5))


chrcm <- markers %>%
  filter(subset=="chrcm") %>%
  ggplot(aes(x=true, y=estimated)) + geom_point()+
  theme_light() +
  xlab("true value") +
  ylab("estimated") +
  geom_smooth(method="lm", se=F, col="blue") +
  geom_abline(slope=1, intercept = 0, col="red")+
  facet_wrap(.~r, ncol=3) +
  theme(strip.background = element_rect(color="black", fill="white"),
        strip.text.y = element_text(color="black"),
        strip.text.x = element_text(color="black"))+
  ggtitle("On marker per chr = qtls") +
  theme(plot.title = element_text(hjust = 0.5))



ggarrange(allcm, m20cm, chrcm, ncol=3, nrow=3)









sd <- rbind(c6 %>% dplyr::select(-true), c6_false %>% rename(true=estimated)) %>%
  filter(critere=="sd") %>% 
  ggplot(aes(x=subset, y = estimated, col=r)) +
  geom_violin() +
  ylab("sd (estimated)") +
  theme_light() +
  xlab("Impact of QTL number/size")+
  ggtitle("sd") +
  theme(plot.title = element_text(hjust = 0.5))


gebv <- rbind(c6 %>% dplyr::select(-true), c6_false %>% rename(true=estimated)) %>%
  filter(critere=="gebv") %>% 
  ggplot(aes(x=subset, y = estimated, col=r)) +
  geom_violin() +
  ylab("gebv (estimated)") +
  theme_light() +
  xlab("Impact of QTL number/size")+
  ggtitle("gebv") +
  theme(plot.title = element_text(hjust = 0.5))





uc <-  rbind(c6 %>% dplyr::select(-true), c6_false %>% rename(true=estimated)) %>%
  filter(critere=="uc") %>% 
  ggplot(aes(x=subset, y = estimated, col=r)) +
  geom_violin() +
  ylab("UC q = 7% (estimated)") +
  theme_light() +
  xlab("Impact of QTL number/size")+
  ggtitle("UC q = 7%") +
  theme(plot.title = element_text(hjust = 0.5))



uc_extreme <-  rbind(c6 %>% dplyr::select(-true), c6_false %>% rename(true=estimated)) %>%
  filter(critere=="uc_extreme") %>% 
  ggplot(aes(x=subset, y = estimated, col=r)) +
  geom_violin() +
  ylab("UC q = 0.01% (estimated)") +
  theme_light() +
  xlab("Impact of QTL number/size")+
  ggtitle("UC q = 0.01%") +
  theme(plot.title = element_text(hjust = 0.5))


logw <-  rbind(c6 %>% dplyr::select(-true), c6_false %>% rename(true=estimated)) %>%
  filter(critere=="logw") %>% 
  ggplot(aes(x=subset, y = estimated, col=r)) +
  geom_violin() +
  ylab("logw (true)") +
  theme_light() +
  xlab("Impact of QTL number/size")+
  ggtitle("logw") +
  theme(plot.title = element_text(hjust = 0.5))







ggarrange(gebv, sd, logw, uc, uc_extreme, ncol=1, nrow = 1, common.legend = T)






gebv <- c6 %>%
  filter(critere=="gebv") %>%
  ggplot(aes(x=true, y=estimated)) + geom_point()+
  geom_abline(slope=1, col="red", intercept = 0)+
  facet_grid(subset~r) +
  ggtitle("gebv") +
  theme(plot.title = element_text(hjust = 0.5))+
  theme_light()





sd <- c6 %>%
  filter(critere=="sd") %>%
  ggplot(aes(x=true, y=estimated)) + geom_point()+
  geom_abline(slope=1, col="red", intercept = 0)+
  facet_grid(subset~r) +
  ggtitle("sd") +
  theme(plot.title = element_text(hjust = 0.5))+
  theme_light()



logw <- c6 %>%
  filter(critere=="logw") %>%
  ggplot(aes(x=true, y=estimated)) + geom_point()+
  geom_abline(slope=1, col="red", intercept = 0)+
  facet_grid(subset~r) +
  ggtitle("logw") +
  theme(plot.title = element_text(hjust = 0.5))+
  theme_light()


uc <- c6 %>%
  filter(critere=="uc") %>%
  ggplot(aes(x=true, y=estimated)) + geom_point()+
  geom_abline(slope=1, col="red", intercept = 0)+
  facet_grid(subset~r) +
  ggtitle("UC q = 7%") +
  theme(plot.title = element_text(hjust = 0.5))+
  theme_light()


uc_extreme <- c6 %>%
  filter(critere=="uc_extreme") %>%
  ggplot(aes(x=true, y=estimated)) + geom_point()+
  geom_abline(slope=1, col="red", intercept = 0)+
  facet_grid(subset~r) +
  ggtitle("UC q = 0.01%") +
  theme(plot.title = element_text(hjust = 0.5))+
  theme_light()



ggarrange(gev, sd, logw, uc, uc_extreme, ncol=1, nrow=1)



rm(c6, c6_false)


# Gain genetique




l9 <- fread(titre_lines) %>%
  filter(affixe=="real") %>%
  filter(grepl("simTRUE", type)) %>%
  filter(grepl("_h0.8_", type)) %>%
  filter(type %in% c("marker_simTRUE_20cm_h0.8_r2", # to remove
                     "marker_simTRUE_20cm_h0.8_r1", 
                     "marker_simTRUE_allcm_h0.8_r2", 
                     "marker_simTRUE_allcm_h0.8_r1",
                     "marker_simTRUE_chrcm_h0.8_r1",
                     "marker_simTRUE_chrcm_h0.8_r2")) %>%
  filter(!is.na(tbv)) %>%
  mutate(rr=as.factor(rr)) %>%
  mutate(critere=ifelse(critere=="uc", "UC q = 7%", critere)) %>%
  mutate(critere=ifelse(critere=="uc_extreme", "UC q = 0.01%", critere)) %>%
  mutate(critere=factor(critere, levels=c("gebv","logw", "UC q = 7%", "UC q = 0.01%"))) %>%
  dplyr::select(-generation, -population, -affixe, -used_as_parent, -gebv) %>%
  rowwise() %>%
  mutate(h=extraction(type, "_", 4)) %>%
  mutate(h=ifelse(grepl("h",h), "estimated", "true")) %>%
  mutate(case=ifelse(h=="estimated",5,4)) %>%
  mutate(r=as.numeric(gsub("r","",extraction(type, "_", case)))) %>%
  mutate(subset=extraction(type, "_", 3)) %>%
  ungroup() %>%
  mutate(r=as.factor(r)) %>%
  mutate(subset=factor(subset, levels=c("allcm","20cm","chrcm"))) %>%
  dplyr::select(-type, -case, -h) %>%
  group_by(critere, rr, subset, r) %>%
  mutate(sd_progeny=sd(tbv)) %>%
  mutate(mean_progeny=mean(tbv)) %>%
  mutate(q0.93=quantile(tbv, 0.93)) %>%
  filter(tbv >= q0.93) %>%
  summarise(best=max(tbv), 
            mean=mean(tbv), 
            mean_progeny=unique(mean_progeny), 
            sd_progeny=unique(sd_progeny)) %>%
  ungroup()







l9best <- l9 %>%
  arrange(critere, subset, r) %>%
  group_by(subset, r, critere) %>%
  mutate(ref=mean(best)) %>% # prendre le valeur moyenne du meilleur individu par simQTL
  group_by(subset, r) %>%
  mutate(ref=ifelse(critere !="gebv", NA, ref)) %>%
  mutate(ref=mean(ref, na.rm=T)) %>%
  ungroup() %>%
  group_by(critere, subset, r) %>%
  mutate(gain=(best-ref)/ref) %>%
  summarise(gain=mean(gain)) 




best <- l9best%>%
  ggplot(aes(x=critere, y=gain)) +
  geom_boxplot() +
  facet_grid(.~subset) +
  geom_point(data=l9best, aes(x=critere, y=gain, col=r)) +
  theme_light() +
  theme(axis.text.x = element_text(angle = 45, hjust=1))+
  xlab("") +
  ylab("gain (% from gebv)")+
  theme(strip.background = element_rect(color="black", fill="white"),
        strip.text.y = element_text(color="black"),
        strip.text.x = element_text(color="black"))+
  ggtitle("Best progeny") +
  theme(plot.title = element_text(hjust = 0.5))


l9topmean <- l9 %>%
  arrange(critere, subset, r) %>%
  group_by(subset, r, critere) %>%
  mutate(ref=mean(mean)) %>% # prendre le valeur moyenne du meilleur individu par simQTL
  group_by(subset, r) %>%
  mutate(ref=ifelse(critere !="gebv", NA, ref)) %>%
  mutate(ref=mean(ref, na.rm=T)) %>%
  ungroup() %>%
  group_by(critere, subset, r) %>%
  mutate(gain=(mean-ref)/ref) %>%
  summarise(gain=mean(gain))  

topmean <- l9topmean%>%
  ggplot(aes(x=critere, y=gain)) +
  geom_boxplot() +
  facet_grid(.~subset) +
  geom_point(data=l9topmean, aes(x=critere, y=gain, col=r)) +
  theme_light() +
  theme(axis.text.x = element_text(angle = 45, hjust=1))+
  xlab("") +
  ylab("gain (% from gebv)")+
  theme(strip.background = element_rect(color="black", fill="white"),
        strip.text.y = element_text(color="black"),
        strip.text.x = element_text(color="black"))+
  ggtitle("Mean of top 7% progeny") +
  theme(plot.title = element_text(hjust = 0.5))


l9mean <- l9 %>% 
  group_by(critere,rr, subset, r) %>%
  mutate(ref=mean_progeny) %>%
  ungroup() %>%
  mutate(ref=ifelse(critere=="gebv", ref, NA)) %>%
  group_by(subset, r) %>%
  mutate(ref=mean(ref, na.rm = T)) %>%
  mutate(ratio=mean_progeny/ref) %>%
  group_by(critere, subset, r) %>%
  summarise(ratio=mean(ratio))


mean <- l9mean%>%
  ggplot(aes(x=critere, y=ratio)) +
  geom_boxplot() +
  facet_grid(.~subset) +
  geom_point(data=l9mean, aes(x=critere, y=ratio, col=r)) +
  theme_light() +
  theme(axis.text.x = element_text(angle = 45, hjust=1))+
  xlab("") +
  ylab("ratio (% from gebv)")+
  theme(strip.background = element_rect(color="black", fill="white"),
        strip.text.y = element_text(color="black"),
        strip.text.x = element_text(color="black"))+
  ggtitle("Mean of all progeny") +
  theme(plot.title = element_text(hjust = 0.5))



l9sd <- l9 %>% 
  group_by(critere,rr, subset, r) %>%
  mutate(ref=sd_progeny) %>%
  ungroup() %>%
  mutate(ref=ifelse(critere=="gebv", ref, NA)) %>%
  group_by(subset, r) %>%
  mutate(ref=mean(ref, na.rm = T)) %>%
  mutate(ratio=sd_progeny/ref) %>%
  group_by(critere, subset, r) %>%
  summarise(ratio=mean(ratio))


sd <- l9sd%>%
  ggplot(aes(x=critere, y=ratio)) +
  geom_boxplot() +
  facet_grid(.~subset) +
  geom_point(data=l9sd, aes(x=critere, y=ratio, col=r)) +
  theme_light() +
  theme(axis.text.x = element_text(angle = 45, hjust=1))+
  xlab("") +
  ylab("ratio (% from gebv)")+
  theme(strip.background = element_rect(color="black", fill="white"),
        strip.text.y = element_text(color="black"),
        strip.text.x = element_text(color="black"))+
  ggtitle("Variability of all progeny") +
  theme(plot.title = element_text(hjust = 0.5))





ggarrange(best, topmean, mean, sd, common.legend = T)



modbest <- summary(lm(gain~ critere*subset, data=l9best))
modbest

modtopmean <- summary(lm(gain~ critere*subset, data=l9topmean))
modtopmean

# Reste à faire : travailler sur erreur de profil
# gain génétique perdu à cause estimation

