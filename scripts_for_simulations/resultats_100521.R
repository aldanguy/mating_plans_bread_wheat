


Sys.time()
cat("\n\nresultats.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(viridis))
suppressPackageStartupMessages(library(ggpubr))
suppressPackageStartupMessages(library(igraph))
suppressPackageStartupMessages(library(pheatmap))
suppressPackageStartupMessages(library(cowplot))

library(gridExtra)
library(grid)
library(ggplot2)
library(lattice)


titre_crossessimFALSE <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/crosses_simFALSE_gbasic_WE.txt"
titre_rils <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_gebv_simFALSE_gbasic_WE_sd_prediction_WE_RILsF5.txt"
titre_hds <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_gebv_simFALSE_gbasic_WE_sd_prediction_WE_HDs.txt"
titre_best_progenies <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/best_progenies_tbv.txt"
titre_perf <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/all_perf2.txt"
titre_parental_lines <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/best_parental_lines_tbv.txt"
titre_best_crosses <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/best_crosses2.txt"
titre_progenies_sup_best_parent <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/progenies_sup_best_parent_tbv.txt"
titre_ibs <-  "/home/adanguydesd/Documents/These_Alice/croisements/temp/IBS.txt"
repertoire_graph <- "/home/adanguydesd/Documents/These_Alice/croisements/graphs/"
titre_crosses <-  "/home/adanguydesd/Documents/These_Alice/croisements/temp/crosses.txt"



get_density <- function(x, y, ...) {
  dens <- MASS::kde2d(x, y, ...)
  ix <- findInterval(x, dens$x)
  iy <- findInterval(y, dens$y)
  ii <- cbind(ix, iy)
  return(dens$z[ii])
}


best_parental_lines <- fread(titre_parental_lines) %>%
  mutate(h=factor(h)) %>%
  mutate(r=as.factor(r)) %>%
  mutate(qtls=as.factor(qtls)) %>%
  filter(qtls=="300rand") %>%
  unique()
summary(best_parental_lines)

perf <- fread(titre_perf) %>%
  mutate(h=factor(h, levels=c("all known", "TBV known","her=0.4"))) %>%
  mutate(r=as.factor(r)) %>%
  mutate(qtls=as.factor(qtls)) %>%
  filter(qtls=="300rand") %>%
  mutate(critere=factor(critere, levels=c("gebv","logw","uc","uc_extreme","topq","embv"))) %>%
  mutate(optimization=as.factor(optimization)) %>%
  mutate(fitness=as.numeric(fitness)) %>%
  mutate(programme=as.factor(programme)) %>%
  filter(ifelse(critere=="logw" & optimization=="GA", F, T)) %>%
  filter(!is.na(fitness)) %>%
  filter(is.na(gen) | gen ==20000) %>%
  unique()


summary(perf)

best_progenies <- fread(titre_best_progenies) %>%
  mutate(h=factor(h, levels=c("all known", "TBV known","her=0.4"))) %>%
  mutate(r=as.factor(r)) %>%
  mutate(qtls=as.factor(qtls)) %>%
  mutate(critere=case_when(critere=="logw"~"proba.sup.best.parent",
                           critere=="uc"~ "UC q=7%",
                           critere=="uc_extreme"~"UC q=0.01%",
                           critere=="embv"~"EMBV",
                           critere=="gebv"~"mean.parents",
                           critere=="topq"~"sup.quantile")) %>%
  mutate(critere=factor(critere, levels=c("mean.parents", "proba.sup.best.parent", "UC q=7%","UC q=0.01%", "EMBV","sup.quantile" ))) %>%
  mutate(programme=as.factor(programme)) %>%
  mutate(rr=as.factor(rr)) %>%
  filter(qtls=="300rand") %>%
  unique()
summary(best_progenies)

progenies_sup_best_parent <- fread(titre_progenies_sup_best_parent)%>%
  mutate(h=factor(h, levels=c("all known", "TBV known","her=0.4"))) %>%
  mutate(r=as.factor(r)) %>%
  mutate(qtls=as.factor(qtls)) %>%
  filter(qtls=="300rand") %>%
  mutate(critere=case_when(critere=="logw"~"proba.sup.best.parent",
                           critere=="uc"~ "UC q=7%",
                           critere=="uc_extreme"~"UC q=0.01%",
                           critere=="embv"~"EMBV",
                           critere=="gebv"~"mean.parents",
                           critere=="topq"~"sup.quantile")) %>%
  mutate(critere=factor(critere, levels=c("mean.parents", "proba.sup.best.parent", "UC q=7%","UC q=0.01%", "EMBV","sup.quantile" ))) %>%
  mutate(programme=as.factor(programme)) %>%
  mutate(rr=as.factor(rr)) 
summary(progenies_sup_best_parent) 


IBS <- as.matrix(fread(titre_ibs))
rownames(IBS) <- colnames(IBS)

best_parent_simFALSE=8.0415916

# STEP 1 : check that predictors works fine
cr <- fread(titre_crossessimFALSE)

cr %>% 
  mutate(density=get_density(sd_HDs, sd_RILs, n = 100)) %>%
  ggplot(aes(x=sd_HDs, y=sd_RILs, col=density)) +
  geom_point() +
  geom_abline(slope=1, intercept = 0, col="red")+
  theme_light() +
  xlab("SD predicted HDs")+
  ylab("SD predicted RILs") +
  theme(plot.title = element_text(hjust = 0.5)) +
  scale_color_viridis()


uc0.07 <- fread(titre_rils) %>%
  group_by(P1, P2) %>%
  mutate(q0.07=quantile(value, 0.93)) %>%
  filter(value >= q0.07) %>%
  summarise(uc_obs=mean(value)) %>%
  ungroup() %>%
  inner_join(cr, by=c("P1","P2")) %>%
  dplyr::select(uc_obs, uc_RILs) %>%
  ggplot(aes(y=uc_obs, x=uc_RILs)) +
  geom_point() +
  geom_abline(slope=1, intercept = 0, col="red") +
  xlab("UC predicted")+
  ylab("UC observed") +
  theme_light() +
  theme(plot.title = element_text(hjust = 0.5)) +
  
  ggtitle("UC q=7%")


uc_0.0001 <- fread(titre_rils) %>%
  group_by(P1, P2) %>%
  arrange(desc(value)) %>%
  slice(1) %>%
  ungroup()%>%
  rename(best_1_1000_progeny_obs=value) %>%
  inner_join(cr, by=c("P1","P2")) %>%
  dplyr::select(best_1_1000_progeny_obs, uc_extreme_RILs)%>%
  ggplot(aes(y=best_1_1000_progeny_obs, x=uc_extreme_RILs)) +
  geom_point() +
  geom_abline(slope=1, intercept = 0, col="red") +
  theme_light() +
  xlab("best progeny among 1 000")+
  ylab("UC observed") +
  theme(plot.title = element_text(hjust = 0.5)) +
  
  ggtitle("UC q=0.01%")









lr_embv <- data.frame()
for (k in 1:100){

lr_embv <- rbind(lr_embv,
                 fread(titre_rils) %>%
                   group_by(P1, P2) %>%
  slice(sample(1:n(), size=60, replace = F))   %>%
  arrange(desc(value)) %>%
  slice(1) %>%
  ungroup())

}

embv <- lr_embv %>%
  group_by(P1, P2) %>%
  summarise(embv_60_obs=mean(value)) %>%
   ungroup() %>%
  inner_join(cr, by=c("P1","P2")) %>%
  mutate(embv_60_predicted=gebv+2.29420984716186*sd_RILs) %>%
  dplyr::select(embv_60_obs, embv_60_predicted)%>%
  ggplot(aes(y=embv_60_obs, x=embv_60_predicted)) +
  geom_point() +
  geom_abline(slope=1, intercept = 0, col="red") +
  theme_light() +
  xlab("EMBV 1 among 60 predicted")+
  ylab("EMBV 1 among 60 observed")+ 
   theme(plot.title = element_text(hjust = 0.5)) +

  ggtitle("EMBV")


 

logw <- fread(titre_rils) %>%
   group_by(P1, P2) %>%
   mutate(save=ifelse(value >= best_parent_simFALSE, 1, 0)) %>%
   summarise(prop_obs=sum(save)/n()) %>%
   inner_join(cr, by=c("P1","P2")) %>%
   rowwise() %>%
   mutate(prop_predicted=1-pnorm(best_parent_simFALSE, m=gebv, sd=sd_RILs)) %>%
   ungroup() %>%
   dplyr::select(prop_obs, prop_predicted)%>%
   ggplot(aes(y=prop_obs, x=prop_predicted)) +
   geom_point() +
   geom_abline(slope=1, intercept = 0, col="red") +
   theme_light() +
   xlab("% progeny > best parent predicted")+
   ylab("% progeny > best parent observed")+
   theme(plot.title = element_text(hjust = 0.5)) +
   ggtitle("logw")
 
 
 
gebv<-  fread(titre_rils) %>%
  group_by(P1, P2) %>%
  summarise(gebv_obs=mean(value))%>%
  ungroup() %>%
  inner_join(cr, by=c("P1","P2")) %>%
  dplyr::select(gebv_obs, gebv)%>%
  ggplot(aes(y=gebv_obs, x=gebv)) +
  geom_point() +
  geom_abline(slope=1, intercept = 0, col="red") +
  theme_light() +
  xlab("mean predicted")+
  ylab("mean observed")+
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("mean of progeny")


sd<-  fread(titre_rils) %>%
  group_by(P1, P2) %>%
  summarise(sd_obs=sd(value))%>%
  ungroup() %>%
  inner_join(cr, by=c("P1","P2")) %>%
  dplyr::select(sd_obs, sd_RILs)%>%
  ggplot(aes(y=sd_obs, x=sd_RILs)) +
  geom_point() +
  geom_abline(slope=1, intercept = 0, col="red") +
  theme_light() +
  xlab("sd predicted")+
  ylab("sd observed")+
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("variability of progeny")


fread(titre_crossessimFALSE) %>%
  dplyr::select(P1, P2, gebv, uc_RILs, uc_extreme_RILs) %>%
  pivot_longer(cols = c("uc_RILs", "uc_extreme_RILs"), names_to = "q") %>%
  mutate(q=ifelse(q=="uc_RILs", "0.7%", "0.01%")) %>%
  ggplot(aes(x=gebv, y=value, col=q)) +
  geom_point()+
  geom_abline(slope=1, col="red", intercept = 0) +
  theme_light()+
  xlab("parental mean")+
  ylab("UC")+
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("")+
  guides(col = guide_legend(override.aes = list(alpha=1)))

 

fread(titre_crossessimFALSE) %>%
  mutate(proba=1-exp(logw_RILs)) %>%
  ggplot(aes(x=gebv, y=proba)) +
  geom_point()+
  theme_light()+
  xlab("parental mean")+
  ylab("logw")+
  theme(plot.title = element_text(hjust = 0.5)) +
  ggtitle("")
 




# STEP 2 : genetic gain




perf %>% mutate(time=time/3600)%>%
  ggplot(aes(x=optimization, y=time, col=critere)) +
  geom_violin() +
  theme_light()

# best_progenies_real <- best_progenies %>%
#   filter(!grepl("top","programme")) %>%
#   inner_join(perf, by=c("qtls","h","r","critere","programme")) %>%
#   dplyr::select(-optimization, -time, -gen , -fitness) %>%
#   arrange(qtls, h, r, rr, critere, programme) %>%
#   mutate(programme=as.factor(programme)) %>%
#   filter(!is.na(value))
# best_progenies_top <- best_progenies %>%
#   filter(grepl("top",programme)) 
# 
# 
# best_progenies <- rbind(best_progenies_real, best_progenies_top)
# 



# programme top


best_progenies_simTRUE_top_gain <- best_progenies %>%
  filter(grepl("top",programme))  %>%
  dplyr::select(-programme) %>%
  group_by(qtls, h, r, critere, rr)%>%
  mutate(ref_gebv=ifelse(critere=="mean.parents", value, NA)) %>%
  group_by(qtls, h, r)%>%
  mutate(mean_ref_gebv=mean(ref_gebv, na.rm = T)) %>%
  group_by(qtls, h, r, critere)%>%
  mutate(value_critere=(value-mean_ref_gebv)/mean_ref_gebv) %>%
  summarise(value_critere_mean=mean(value_critere))%>%
  filter(critere!="mean.parents") %>%
  ungroup() 
  


gain_simTRUE_top <- best_progenies_simTRUE_top_gain  %>%
  ggplot(aes(x=critere, y=value_critere_mean))+
  geom_boxplot(outlier.shape = NA) +
  geom_point(data=best_progenies_simTRUE_top_gain, aes(x=critere, y=value_critere_mean, col=r)) +
  facet_grid(.~h, scales = "free") +
  theme_light() +
  xlab("")+
  theme(strip.text.y = element_text(color="black", size=12),
        strip.text.x = element_text(color="black", size=12),
        axis.text.x = element_text(angle = 90, size=12),
        axis.text.y = element_text(size=12),
        legend.title = element_text(size=12),
        axis.title.y = element_text(size=14),
        plot.title = element_text(hjust = 0.5, face="bold"),
        strip.background = element_rect(color="black", fill="white")) +
  ylab("criteria - mean.parents / mean.parents")+
  geom_hline(yintercept = 0, col="black") +
  guides(col=guide_legend("Position of QTLs", nrow=2)) +
  ggtitle("gain compare to mean.parents")
  




best_progenies_simTRUE_top_prop <-best_progenies %>%
  filter(grepl("top",programme))  %>%
  dplyr::select(-programme) %>%
  group_by(qtls, h, r, critere, rr)%>%
  mutate(ref_gebv=ifelse(critere=="mean.parents", value, NA)) %>%
  group_by(qtls, h, r)%>%
  mutate(mean_ref_gebv=mean(ref_gebv, na.rm = T)) %>%
  group_by(qtls, h, r, critere)%>%
  mutate(nrep=n()) %>%
  summarise(prop_sup_gebv = length(which(value >mean_ref_gebv & !is.na(mean_ref_gebv)))/unique(nrep)) %>%
  filter(critere !="mean.parents")





prop_simTRUE_top <- best_progenies_simTRUE_top_prop %>%
  ggplot(aes(x=critere, y=prop_sup_gebv))+
  geom_boxplot(outlier.shape = NA) +
  geom_point(data=best_progenies_simTRUE_top_prop, aes(x=critere, y=prop_sup_gebv, col=r)) +
  facet_grid(.~h, scales = "free") +
  theme_light() +
  geom_hline(yintercept = 0.5)+
  xlab("")+
  theme(strip.text.y = element_text(color="black", size=12),
        strip.text.x = element_text(color="black", size=12),
        plot.title = element_text(hjust = 0.5, face="bold"),
        axis.text.x = element_text(angle = 90, size=12),
        axis.title.y = element_text(size=14),
        legend.title = element_text(size=12),
                axis.text.y = element_text(size=12),
        strip.background = element_rect(color="black", fill="white")) +
  ylab("proba elite progeny > elite progeny from mean.parents")+
  guides(col=guide_legend("Position of QTLs", nrow=2)) +
  ggtitle("probability to do better than mean.parents")




best_progenies_simTRUE_gain <- best_progenies %>%
  filter(!grepl("top",programme))  %>%
  dplyr::select(-programme) %>%
  group_by(qtls, h, r, critere, rr)%>%
  mutate(ref_gebv=ifelse(critere=="mean.parents", value, NA)) %>%
  group_by(qtls, h, r)%>%
  mutate(mean_ref_gebv=mean(ref_gebv, na.rm = T)) %>%
  filter(!is.na(mean_ref_gebv)) %>%
  group_by(qtls, h, r, critere)%>%
  mutate(value_critere=(value-mean_ref_gebv)/mean_ref_gebv) %>%
  summarise(value_critere_mean=mean(value_critere))%>%
  filter(h%in% c("all known", "her=0.4")) %>%
  filter(!critere %in% c("sup.quantile")) %>%
  ungroup() 

summary(lm(value_critere_mean~critere, data=best_progenies_simTRUE_gain%>%
             filter(h%in% c("all known"))))

summary(lm(value_critere_mean~critere, data=best_progenies_simTRUE_gain%>%
             filter(h%in% c("her=0.4"))))


gain_simTRUE <- best_progenies_simTRUE_gain  %>%
  filter(critere!="mean.parents") %>%
  filter(h%in% c("all known", "her=0.4")) %>%
  filter(!critere %in% c("sup.quantile")) %>%
  ggplot(aes(x=critere, y=value_critere_mean))+
  geom_boxplot(outlier.shape = NA) +
  geom_point(data=best_progenies_simTRUE_gain%>%
               filter(h%in% c("all known", "her=0.4"))%>%
               filter(!critere %in% c("sup.quantile")) , aes(x=critere, y=value_critere_mean, col=r)) +
  facet_grid(.~h, scales = "free") +
  theme_light() +
  xlab("")+
  theme(strip.text.y = element_text(color="black", size=12),
        strip.text.x = element_text(color="black", size=12),
        plot.title = element_text(hjust = 0.5, face="bold"),
        axis.text.x = element_text(angle = 90, size=12),
        axis.title.y = element_text(size=14),
        legend.title = element_text(size=12),
        axis.text.y = element_text(size=12),
        strip.background = element_rect(color="black", fill="white")) +
  ylab("criteria - mean.parents / mean.parents")+
  geom_hline(yintercept = 0, col="black") +
  guides(col=guide_legend("QTLs set", nrow=2)) +
  ggtitle("gain compare to mean.parents")





best_progenies_simTRUE_prop <- best_progenies %>%
  filter(!grepl("top",programme))  %>%
  dplyr::select(-programme) %>%
  group_by(qtls, h, r, critere, rr)%>%
  mutate(ref_gebv=ifelse(critere=="mean.parents", value, NA)) %>%
  group_by(qtls, h, r)%>%
  mutate(mean_ref_gebv=mean(ref_gebv, na.rm = T)) %>%
  group_by(qtls, h, r, critere)%>%
  mutate(nrep=n()) %>%
  summarise(prop_sup_gebv = length(which(value >mean_ref_gebv & !is.na(mean_ref_gebv)))/unique(nrep)) %>%
  filter(critere !="mean.parents")





prop_simTRUE <- best_progenies_simTRUE_prop %>%
  filter(h%in% c("all known", "her=0.4")) %>%
  filter(!critere %in% c("sup.quantile")) %>%
  ggplot(aes(x=critere, y=prop_sup_gebv))+
  geom_boxplot(outlier.shape = NA) +
  geom_point(data=best_progenies_simTRUE_prop%>%
               filter(h%in% c("all known", "her=0.4")) %>%
               filter(!critere %in% c("sup.quantile")), aes(x=critere, y=prop_sup_gebv, col=r)) +
  facet_grid(.~h, scales = "free") +
  theme_light() +
  geom_hline(yintercept = 0.5)+
  xlab("")+
  theme(strip.text.y = element_text(color="black", size=12),
        strip.text.x = element_text(color="black", size=12),
        axis.text.x = element_text(angle = 90, size=12),
        axis.title.y = element_text(size=14),
        legend.title = element_text(size=12),
        axis.text.y = element_text(size=12),
        plot.title = element_text(hjust = 0.5, face="bold"),
        strip.background = element_rect(color="black", fill="white")) +
  ylab("frequency elite progeny > elite progeny from mean.parents")+
  guides(col=guide_legend("QTLs set", nrow=2)) +
  ggtitle("do better than mean.parents")




ggarrange(gain_simTRUE_top, prop_simTRUE_top,  ncol=2, nrow=1, common.legend = T, legend = "bottom", labels=c("A","B"))

  
ggarrange(gain_simTRUE, prop_simTRUE, ncol=2, nrow=1, common.legend = T, legend = "bottom", labels=c("A","B"))







output <- data.frame()
for (sup in seq(100, 130, 1)/100){
  
  print(sup)

output <- rbind(output, progenies_sup_best_parent %>% 
    mutate(best_parent2=best_parent*sup) %>%
    group_by(qtls, h, r, rr, programme, critere, .drop=F) %>%
      mutate(sup=length(which(value >= best_parent2))) %>%
      na.omit() %>%
      group_by(qtls, h, r, programme, critere, .drop=F) %>%
      summarise(n=sum(sup), nrep=sum(nrep)) %>%
      mutate(p=n/nrep) %>%
      na.omit() %>%
      group_by(qtls, h, programme, critere,.drop=F) %>%
      summarise(p_mean=mean(p, na.rm=T), p5=quantile(p, 0.05, na.rm=T), p95=quantile(p, 0.95, na.rm=T)) %>%
      na.omit() %>%
    ungroup() %>%
  mutate(best_parent=sup*100))


}




sup_real <- output %>% 
  filter(programme=="real") %>%
  filter(h%in% c("all known", "her=0.4")) %>%
  filter(!critere %in% c("sup.quantile")) %>%
  filter(best_parent <= 130) %>%
  ggplot(aes(x=best_parent, y=p_mean, col=critere)) +
  geom_line()+
  theme_light() +
  xlab("value of best parent (%)") +
  ylab("frequency progeny > value of best parent (%)") +
  facet_grid(.~h)+
  theme(strip.text.y = element_text(color="black", size=12),
        strip.text.x = element_text(color="black", size=12),
        axis.text.x = element_text( size=12),
        axis.title.y = element_text(size=14),
        axis.title.x = element_text(size=12),
        legend.text = element_text(size=12),
        
        legend.title = element_text(size=14),
        axis.text.y = element_text(size=12),
        plot.title = element_text(hjust = 0.5, face="bold"),
        strip.background = element_rect(color="black", fill="white")) +
  guides(col=guide_legend("criteria", override.aes = list(size=2))) +
  scale_x_continuous(breaks = seq(100, 200, 10))



sup_top <- output %>% 
  filter(programme=="real_top") %>%
  filter(best_parent <= 130) %>%
  ggplot(aes(x=best_parent, y=p_mean, col=critere)) +
  geom_line()+
  theme_light() +
  xlab("value of best parent (%)") +
  ylab("proba progeny > value of best parent (%)") +
  facet_grid(.~h)+
  theme(strip.text.y = element_text(color="black", size=12),
        strip.text.x = element_text(color="black", size=12),
        axis.text.x = element_text(size=12),
        axis.title.x = element_text(size=12),
        legend.text = element_text(size=12),
        axis.title.y = element_text(size=14),
        legend.title = element_text(size=14),
        axis.text.y = element_text(size=12),
        plot.title = element_text(hjust = 0.5, face="bold"),
        strip.background = element_rect(color="black", fill="white")) +
  guides(col=guide_legend("criteria")) +
  scale_x_continuous(breaks = seq(100, 200, 10))



ggarrange(sup_top, sup_real, nrow=2, common.legend = T, legend="right", labels = c("A","B"))



#### best crosses


best_crosses <- fread(titre_best_crosses) %>%
  mutate(h=factor(h, levels=c("all known", "TBV known","her=0.4"))) %>%
  mutate(r=as.factor(r)) %>%
  mutate(qtls=as.factor(qtls)) %>%
  mutate(critere=factor(critere, levels=c("gebv","logw","uc","uc_extreme","topq","embv"))) %>%
  mutate(programme=as.factor(programme)) 




# IBS <- matrix(sample(0:1, size=840*840, replace = T), ncol=840, nrow=840)
lines <- colnames(IBS)
# colnames(IBS) <- lines
# rownames(IBS) <- lines
# IBS[lower.tri(IBS)] = t(IBS)[lower.tri(IBS)]
# diag(IBS)=1


h="all known"
qtls="300rand"
critere="gebv"
programme="real_top"
r="1"
output <- data.frame()

for (h in sort(unique(best_crosses$h))){
  
  print(h)
  
  for (qtls in sort(unique(best_crosses$qtls))) {
    
    print(qtls)
    
    for (programme in sort(unique(best_crosses$programme))){
      
      print(programme)
      
      for (r in sort(unique(best_crosses$r))){
        
        print(r)
      
        
        Z=matrix(NA, ncol=length(lines), nrow=length(unique(best_crosses$critere)))
        colnames(Z) <- lines
        rownames(Z) <- sort(unique(best_crosses$critere))
        
        
      for (critere in sort(unique(best_crosses$critere))){
        
        

        
        
       vecteur <-  best_crosses %>%
          filter(h==!!h) %>%
          filter(qtls==!!qtls) %>%
          filter(programme==!!programme) %>%
          filter(r==!!r) %>%
          filter(critere==!!critere) %>%
            dplyr::select(-qtls, -h, -r, -programme, -critere) %>%
          pivot_longer(cols=c("P1","P2"), values_to = "P") %>%
          dplyr::select(-name) %>%
          mutate(P=factor(P, levels=lines))%>%
          group_by(P, .drop=F) %>%
          summarise(n=sum(nbprogeny)) %>%
          ungroup() %>%
          mutate(ntot=sum(n)) %>%
          arrange(P) %>%
          mutate(p=n/ntot) %>% dplyr::select(p) %>% unlist() %>%
          as.vector()
        
        ligne <- which(rownames(Z) == critere)
        Z[ligne,] <- vecteur
        
    
          
          
          
          
          
        
        
        
        
      }
        
        ZB <- tcrossprod(as.matrix(Z), as.matrix(IBS))
        ZBZ <- tcrossprod( as.matrix(ZB), as.matrix(Z))
        output <- rbind(output, melt(ZBZ) %>% mutate(h=!!h, qtls=!!qtls, programme=!!programme, r=!!r))
      
    }
  }
}


}




for (h in sort(unique(best_crosses$h))){
  
  print(h)
  
  for (qtls in sort(unique(best_crosses$qtls))) {
    
    print(qtls)
    
    for (programme in sort(unique(best_crosses$programme))){
      
      print(programme)
      


        df <- output %>%
          filter(h==!!h) %>%
          filter(qtls==!!qtls) %>%
          filter(programme==!!programme)  %>%
          group_by(Var1, Var2, h, qtls, programme) %>%
          summarise(value_mean=mean(value, na.rm=T), value_sd=sd(value, na.rm=T)) %>%
          ungroup() %>%
          na.omit() %>%
          dplyr::select(Var1, Var2, value_mean, value_sd)
        
        
        G <- graph.data.frame(df %>% dplyr::select(-value_sd),directed=FALSE)
        A1 <- as.matrix(as_adjacency_matrix(G,names=TRUE,sparse=FALSE,type="both", attr = "value_mean")) 
       
        
        G <- graph.data.frame(df %>% dplyr::select(-value_mean),directed=FALSE)
        A2 <- round(as.matrix(as_adjacency_matrix(G,names=TRUE,sparse=FALSE,type="both", attr = "value_sd")), 2)

        txt <- matrix(paste0(round(A1,2), "\n(", A2,")"), nrow=ncol(A1), ncol=ncol(A1), byrow = T)
        
        constraint=ifelse(grepl("top", programme),"no constraint","diversity constraints")
        qtls2=ifelse(grepl("chr", qtls),"1 QTL/chr","300 QTLS at random")

        titre_g <- paste0(repertoire_graph, paste0("IBS_",qtls,"_",h,"_", constraint, ".tiff"))
        tiff(titre_g, units="in", width = 6.75, height = 6.75, res=1200, compression = "lzw")
        pheatmap(A1, display_numbers = txt, main=paste0("IBS\n",qtls2, "\n", h ,"\n", constraint), legend=F, fontsize_col=12, 
                      fontsize_row=12,
                      angle_col=0, fontsize_number=12, number_color="black")
        dev.off()
        
      }
      
    }
  }




  
    
    for (programme in sort(unique(best_crosses$programme))){
      
      print(programme)
      
      
      
      df <- output %>%
        filter(programme==!!programme)  %>%
        group_by(Var1, Var2, qtls, programme) %>%
        summarise(value_mean=mean(value, na.rm=T), value_sd=sd(value, na.rm=T)) %>%
        ungroup() %>%
        na.omit() %>%
        dplyr::select(Var1, Var2, value_mean, value_sd)
      
      
      # library(igraph)
      G <- graph.data.frame(df %>% dplyr::select(-value_sd),directed=FALSE)
      A1 <- as.matrix(as_adjacency_matrix(G,names=TRUE,sparse=FALSE,type="both", attr = "value_mean")) 
      G <- graph.data.frame(df %>% dplyr::select(-value_mean),directed=FALSE)
      A2 <- round(as.matrix(as_adjacency_matrix(G,names=TRUE,sparse=FALSE,type="both", attr = "value_sd")), 2)
      
      txt <- matrix(paste0(round(A1,2), "\n(", A2,")"), nrow=ncol(A1), ncol=ncol(A1), byrow = T)
      
      constraint=ifelse(grepl("top", programme),"no constraint","diversity constraints")

      titre_g <- paste0(repertoire_graph, paste0("IBS_", constraint, ".tiff"))
      tiff(titre_g, units="in", width = 6.75, height = 6.75, res=1200, compression = "lzw")
      pheatmap(A1, display_numbers = txt, main=paste0("IBD\n", constraint), legend=F, fontsize_col=12, 
               fontsize_row=12,
               angle_col=0, fontsize_number=12, number_color="black")
      dev.off()
      
      print(titre_g)
      
    }
    






# data <- output %>%
#   filter(h==!!h) %>%
#   filter(qtls==!!qtls) %>%
#   filter(programme==!!programme) %>%
#   mutate(var1.2=as.numeric(factor(Var1, levels = levels(best_crosses$critere) )))%>%
#   mutate(var2.2=as.numeric(factor(Var2, levels = levels(best_crosses$critere) ))) %>%
#   filter(var1.2 <= var2.2) %>%
#   mutate(p=paste0(Var1, Var2)) %>%
#   na.omit()
# 
# pairwise.t.test(data$value, data$p, p.adjust.method = "bonf")
# 






h="all known"
qtls="300rand"
critere="gebv"
critere2="uc"

programme="real_top"
r="1"
output <- data.frame()

for (h in sort(unique(best_crosses$h))){
  
  print(h)
  
  for (qtls in sort(unique(best_crosses$qtls))) {
    
    print(qtls)
    
    for (programme in sort(unique(best_crosses$programme))){
      
      print(programme)
      
      for (r in sort(unique(best_crosses$r))){
        
        print(r)
        
        
        
        for (critere in sort(unique(best_crosses$critere))){
          
          
          for (critere2 in sort(unique(best_crosses$critere))){
            
          
          
          
          
          vecteur <-  best_crosses %>%
            filter(h==!!h) %>%
            filter(qtls==!!qtls) %>%
            filter(programme==!!programme) %>%
            filter(r==!!r) %>%
            filter(critere%in% !!c(critere, critere2)) %>%
            # filter(nbprogeny>=max(nbprogeny)/2)%>%
            mutate(nbprogenytot=sum(nbprogeny)) %>%
            dplyr::select(-qtls, -h, -r, -programme) %>%
            pivot_wider(id_cols = c("P1","P2","nbprogenytot"), values_from = c("nbprogeny"), names_from = "critere" )
          
          
          if (nrow(vecteur) >0 & ncol(vecteur)==5){
            
            vecteur <- vecteur  %>%
            na.omit() %>%
            dplyr::select(-P1, -P2) %>%
            pivot_longer(cols=c(critere, critere2)) %>%
            summarise(prop=max(0,sum(value)/unique(nbprogenytot))) %>%
            mutate(critere1=!!critere) %>%
            mutate(critere2=!!critere2)
            
            
          
          
          } else {
            
            
            vecteur <- data.frame(prop=NA, critere1=critere, critere2=critere2)
          }
          
          
          
          output <- rbind(output, vecteur %>% mutate(h=!!h, qtls=!!qtls, programme=!!programme, r=!!r))
          
          
          
        }
        
      
      }
    }
  }
  
  
}

}



output <- output %>%
  mutate(prop=ifelse(critere1==critere2, 1, prop)) %>%
  filter(ifelse(grepl("top", programme), !(critere1 %in% c("topq") | critere2 %in% c("topq")), T))  %>%
  mutate(var1.2=as.numeric(factor(critere1, levels = levels(best_crosses$critere) )))%>%
  mutate(var2.2=as.numeric(factor(critere2, levels = levels(best_crosses$critere) ))) %>%
  filter(var1.2 <= var2.2) %>%
  dplyr::select(-var1.2, -var2.2)






draw_progeny_in_common <- function(best_crosses, output, qtls,programme){

  plot_list=list()
  i=0

#      for (programme in rev(sort(unique(best_crosses$programme)))){
        
        #for (qtls in sort(unique(best_crosses$qtls))) {
          
          #print(qtls)
        
        for (h in sort(unique(best_crosses$h))){
  

          print(h)
          

            
        i=i+1
        

      
      df <- output %>%
        filter(h==!!h) %>%
        filter(qtls==!!qtls) %>%
        filter(programme==!!programme) %>% 
        filter(!(critere1 == "topq" | critere2 =="topq")) %>%
        group_by(critere1, critere2) %>%
        summarise(prop_mean=mean(prop, na.rm=T), prop_sd=sd(prop, na.rm=T)) %>%
        na.omit() %>%
        dplyr::select(critere1, critere2, prop_mean, prop_sd) %>%
        ungroup() %>%
        mutate(critere1=case_when(critere1=="logw"~"sup.best.parent",
                         critere1=="uc"~ "UC q=7%",
                         critere1=="uc_extreme"~"UC q=0.01%",
                         critere1=="embv"~"embv",
                         critere1=="gebv"~"mean.parents",
                         critere1=="topq"~"sup.quantile")) %>%
        mutate(critere2=case_when(critere2=="logw"~"sup.best.parent",
                         critere2=="uc"~ "UC q=7%",
                         critere2=="embv"~"embv",
                         critere2=="gebv"~"mean.parents",
                         critere2=="uc_extreme"~"UC q=0.01%",
                         critere2=="topq"~"sup.quantile")) %>%
        mutate(critere1=factor(critere1, levels=c("mean.parents", "sup.best.parent", "UC q=7%","UC q=0.01%", "embv","sup.quantile" )))%>%
        mutate(critere2=factor(critere2, levels=c("mean.parents", "sup.best.parent", "UC q=7%","UC q=0.01%", "embv","sup.quantile" ))) %>%
        arrange(critere1, critere2)
      
      
      G <- graph.data.frame(df %>% dplyr::select(-prop_sd),directed=FALSE)
      A1 <- round(as.matrix(as_adjacency_matrix(G,names=TRUE,sparse=FALSE,type="both", attr = "prop_mean")), 2)
      G <- graph.data.frame(df %>% dplyr::select(-prop_mean),directed=FALSE)
      A2 <- round(as.matrix(as_adjacency_matrix(G,names=TRUE,sparse=FALSE,type="both", attr = "prop_sd")), 2)
      
      txt <- matrix(paste0(round(A1,2), "\n(", A2,")"), nrow=ncol(A1), ncol=ncol(A1), byrow = T)
      diag(A1) <- 1
      txt <- matrix(round(100*A1), nrow=ncol(A1), ncol=ncol(A1), byrow = T)
      diag(txt) <- "100"
      
      constraint=ifelse(grepl("top", programme),"no constraint","diversity constraints")
      qtls2=ifelse(grepl("chr", qtls),"1 QTL/chr","300 QTLS at random")
      
      #titre_g <- paste0(repertoire_graph, paste0("progeny_common_",qtls,"_",h,"_", constraint, ".tiff"))
      #titre=paste0(constraint ,"\n", h)
      # tiff(titre_g, units="in", width = 6.75, height = 6.75, res=1200, compression = "lzw")
      # pheatmap(A1, display_numbers = txt, main=titre, legend=F, fontsize_col=12, 
      #          fontsize_row=12,
      #          angle_col=0, fontsize_number=12, number_color="black")
      # dev.off()
      
      show_colnames=ifelse(grepl("top", programme),T, F  )

      plot_list[[i]] <- pheatmap(A1, 
                                 display_numbers = txt, 
                                 legend=F, 
                                 fontsize_col=16, 
                               fontsize_row=16,
                               show_colnames=T,
                               fontsize_number=14, 
                               angle_col=270,
                               cluster_rows=T,
                               cluster_cols = T,
                               breaks = seq(0,1,0.01),
                               legend_breaks=c(0,1),
                               number_color="black")[[4]]
      
      
  
      
      }
    #}
 # }
  
  
  invisible(plot_list)
}
 
dev.off()
plot_list_real_300 <- draw_progeny_in_common(best_crosses = best_crosses, output = output, qtls="300rand", programme="real")
plot_list_top_300 <- draw_progeny_in_common(best_crosses = best_crosses, output = output, qtls="300rand", programme="real_top")




# g<-do.call(grid.arrange,plot_list)
# g


real300 <- grid.arrange(arrangeGrob(grobs= plot_list_real_300,ncol=3))
top300 <- grid.arrange(arrangeGrob(grobs= plot_list_top_300,ncol=3))



qtls300 <- ggdraw() + 
  draw_plot(top300, x =0, y= 0.47, height=0.45, width =0.95)+ 
  draw_plot(real300, x =0, y= 0, height=0.45, width =0.95) +
  draw_label("no constraint", x=0.98, y=0.8, fontfamily = "sans", fontface = "bold", angle=-90, size=20) +
  draw_label("diversity constraints", x=0.98, y=0.3, fontfamily = "sans", fontface = "bold", angle=-90, size=20)+
  draw_label("All known", x=0.1, y=0.95, fontfamily = "sans", fontface = "bold", size=20)+
  draw_label("TBV known", x=0.42, y=0.95, fontfamily = "sans", fontface = "bold", size=20)+
  draw_label("her=0.4", x=0.72, y=0.95, fontfamily = "sans", fontface = "bold", size=20)

titre_g<- paste0(repertoire_graph, paste0("progeny_common_300rand.png"))
png(titre_g, units="in", width = 14, height = 10, res=300)
qtls300
dev.off()
suppressPackageStartupMessages(library(png))


titre_g2<- paste0(repertoire_graph, paste0("progeny_common_300rand_v2.tiff"))

tiff(titre_g2, units="in", width = 6.75, height = 5, res=300, compression = "lzw")
ggdraw() + 
  draw_image(titre_g,x=0, y=-0.02, width = 1, height = 1, scale=1)+
  draw_label("Progeny in common (%)", x=0.5, y=0.975, fontfamily = "sans", fontface = "bold", size=20)+
  draw_label("300 QTLs", x=0.95, y=0.975, fontfamily = "sans", fontface = "bold", size=10)+
  draw_line(x=c(0.9, 0.999),
            y=c(0.999, 0.999))+
  draw_line(x=c(0.999, 0.999),
            y=c(0.999, 0.95))+
  draw_line(x=c(0.9, 0.999),
            y=c(0.95, 0.95))+
  draw_line(x=c(0.9, 0.9),
            y=c(0.999, 0.95))
  


dev.off()




output <- data.frame()



h="all known"
qtls="300rand"
critere="gebv"
critere2="uc"

programme="real"
r="1"
for (h in sort(unique(best_crosses$h))){
  
  print(h)
  
  for (qtls in sort(unique(best_crosses$qtls))) {
    
    print(qtls)
    
    for (programme in c("real","real_top")){
      
      print(programme)
      
      for (r in sort(unique(best_crosses$r))){
        
        print(r)
        
        
        
        for (critere in sort(unique(best_crosses$critere))){
          
          
          for (critere2 in sort(unique(best_crosses$critere))){
            
            
            
            
            
            vecteur <-  best_crosses %>%
              filter(h==!!h) %>%
              filter(qtls==!!qtls) %>%
              filter(programme==!!programme) %>%
              filter(r==!!r) %>%
              filter(critere%in% !!c(critere, critere2)) %>%
              # filter(nbprogeny>=max(nbprogeny)/2)%>%
              mutate(nbprogenytot=sum(nbprogeny)) %>%
              dplyr::select(-qtls, -h, -r, -programme) %>%
              pivot_longer(cols = c("P1","P2"), names_to  = "P") %>%
              dplyr::select(critere, nbprogeny, value) %>%
              group_by(value, critere) %>%
              summarise(nbprogeny=sum(nbprogeny)) %>%
              unique() %>%
              ungroup() %>%
              pivot_wider(id_cols = c("value"), values_from = c("nbprogeny"), names_from = "critere" ) 
            
            
            if (nrow(vecteur) >0 & ncol(vecteur)==3){
              
              vecteur <- vecteur  %>%
                dplyr::select(-value) %>%
                mutate(np=n()) %>%
                na.omit() %>%
                summarise(prop=nrow(.)/unique(np)) %>%
                mutate(critere1=!!critere) %>%
                mutate(critere2=!!critere2)
              
              
              
              
            } else {
              
              
              vecteur <- data.frame(prop=NA, critere1=critere, critere2=critere2)
            }
            
            
            
            output <- rbind(output, vecteur %>% mutate(h=!!h, qtls=!!qtls, programme=!!programme, r=!!r))
            
            
            
          }
          
          
        }
      }
    }
    
    
  }
  
}



output <- output %>%
  mutate(prop=ifelse(critere1==critere2, 1, prop)) %>%
  filter(ifelse(grepl("top", programme), !(critere1 %in% c("topq") | critere2 %in% c("topq")), T))  %>%
  mutate(var1.2=as.numeric(factor(critere1, levels = levels(best_crosses$critere) )))%>%
  mutate(var2.2=as.numeric(factor(critere2, levels = levels(best_crosses$critere) ))) %>%
  filter(var1.2 <= var2.2) %>%
  dplyr::select(-var1.2, -var2.2)






draw_parents_in_common <- function(best_crosses, output, qtls,programme){
  
  plot_list=list()
  i=0
  
  #      for (programme in rev(sort(unique(best_crosses$programme)))){
  
  #for (qtls in sort(unique(best_crosses$qtls))) {
  
  #print(qtls)
  
  for (h in sort(unique(best_crosses$h))){
    
    print(h)
    
    
    
    i=i+1
    
    
    
    df <- output %>%
      filter(h==!!h) %>%
      filter(qtls==!!qtls) %>%
      filter(!(critere1=="topq"|critere2=="topq")) %>%
      filter(programme==!!programme) %>% 
      group_by(critere1, critere2) %>%
      summarise(prop_mean=mean(prop, na.rm=T), prop_sd=sd(prop, na.rm=T)) %>%
      na.omit() %>%
      dplyr::select(critere1, critere2, prop_mean, prop_sd) %>%
      ungroup() %>%
      mutate(critere1=case_when(critere1=="logw"~"sup.best.parent",
                                critere1=="uc"~ "UC q=7%",
                                critere1=="uc_extreme"~"UC q=0.01%",
                                critere1=="embv"~"embv",
                                critere1=="gebv"~"mean.parents",
                                critere1=="topq"~"sup.quantile")) %>%
      mutate(critere2=case_when(critere2=="logw"~"sup.best.parent",
                                critere2=="uc"~ "UC q=7%",
                                critere2=="embv"~"embv",
                                critere2=="gebv"~"mean.parents",
                                critere2=="uc_extreme"~"UC q=0.01%",
                                critere2=="topq"~"sup.quantile")) %>%
      mutate(critere1=factor(critere1, levels=c("mean.parents", "sup.best.parent", "UC q=7%","UC q=0.01%", "embv","sup.quantile" )))%>%
      mutate(critere2=factor(critere2, levels=c("mean.parents", "sup.best.parent", "UC q=7%","UC q=0.01%", "embv","sup.quantile" ))) %>%
      arrange(critere1, critere2)
    
    
    G <- graph.data.frame(df %>% dplyr::select(-prop_sd),directed=FALSE)
    A1 <- round(as.matrix(as_adjacency_matrix(G,names=TRUE,sparse=FALSE,type="both", attr = "prop_mean")), 2)
    diag(A1) <- 1
    G <- graph.data.frame(df %>% dplyr::select(-prop_mean),directed=FALSE)
    A2 <- round(as.matrix(as_adjacency_matrix(G,names=TRUE,sparse=FALSE,type="both", attr = "prop_sd")), 2)
    
    txt <- matrix(paste0(round(A1,2), "\n(", A2,")"), nrow=ncol(A1), ncol=ncol(A1), byrow = T)
    txt <- matrix(round(100*A1), nrow=ncol(A1), ncol=ncol(A1), byrow = T)
    diag(txt) <- "100"
    
    constraint=ifelse(grepl("top", programme),"no constraint","diversity constraints")
    qtls2=ifelse(grepl("chr", qtls),"1 QTL/chr","300 QTLS at random")
    
    #titre_g <- paste0(repertoire_graph, paste0("progeny_common_",qtls,"_",h,"_", constraint, ".tiff"))
    #titre=paste0(constraint ,"\n", h)
    # tiff(titre_g, units="in", width = 6.75, height = 6.75, res=1200, compression = "lzw")
    # pheatmap(A1, display_numbers = txt, main=titre, legend=F, fontsize_col=12, 
    #          fontsize_row=12,
    #          angle_col=0, fontsize_number=12, number_color="black")
    # dev.off()
    
    show_colnames=ifelse(grepl("top", programme),T, F  )
    
    plot_list[[i]] <- pheatmap(A1, 
                               display_numbers = txt, 
                               legend=F, 
                               fontsize_col=16, 
                               fontsize_row=16,
                               show_colnames=T,
                               fontsize_number=14, 
                               angle_col=270,
                               cluster_rows=T,
                               cluster_cols = T,
                               legend_breaks=c(0,1),
                               breaks = seq(0,1,0.01),
                               number_color="black")[[4]]
    
    
    
    
  }
  #}
  # }
  
  
  invisible(plot_list)
}

dev.off()
plot_list_real_300 <- draw_parents_in_common(best_crosses = best_crosses, output = output, qtls="300rand", programme="real")
plot_list_top_300 <- draw_parents_in_common(best_crosses = best_crosses, output = output, qtls="300rand", programme="real_top")




# g<-do.call(grid.arrange,plot_list)
# g


real300 <- grid.arrange(arrangeGrob(grobs= plot_list_real_300,ncol=3))
top300 <- grid.arrange(arrangeGrob(grobs= plot_list_top_300,ncol=3))



qtls300 <- ggdraw() + 
  draw_plot(top300, x =0, y= 0.47, height=0.45, width =0.95)+ 
  draw_plot(real300, x =0, y= 0, height=0.45, width =0.95) +
  draw_label("no constraint", x=0.98, y=0.8, fontfamily = "sans", fontface = "bold", angle=-90, size=20) +
  draw_label("diversity constraints", x=0.98, y=0.3, fontfamily = "sans", fontface = "bold", angle=-90, size=20)+
  draw_label("All known", x=0.1, y=0.95, fontfamily = "sans", fontface = "bold", size=20)+
  draw_label("TBV known", x=0.42, y=0.95, fontfamily = "sans", fontface = "bold", size=20)+
  draw_label("her=0.4", x=0.72, y=0.95, fontfamily = "sans", fontface = "bold", size=20)

titre_g<- paste0(repertoire_graph, paste0("parents_common_300rand.png"))
png(titre_g, units="in", width = 14, height = 10, res=300)
qtls300
dev.off()
suppressPackageStartupMessages(library(png))


titre_g2<- paste0(repertoire_graph, paste0("parents_common_300rand_v2.tiff"))

tiff(titre_g2, units="in", width = 6.75, height = 5, res=300, compression = "lzw")
ggdraw() + 
  draw_image(titre_g,x=0, y=-0.02, width = 1, height = 1, scale=1)+
  draw_label("Parents in common (%)", x=0.5, y=0.975, fontfamily = "sans", fontface = "bold", size=20)+
  draw_label("300 QTLs", x=0.95, y=0.975, fontfamily = "sans", fontface = "bold", size=10)+
  draw_line(x=c(0.9, 0.999),
            y=c(0.999, 0.999))+
  draw_line(x=c(0.999, 0.999),
            y=c(0.999, 0.95))+
  draw_line(x=c(0.9, 0.999),
            y=c(0.95, 0.95))+
  draw_line(x=c(0.9, 0.9),
            y=c(0.999, 0.95))



dev.off()











#####


crosses <- fread(titre_crosses) %>%
  dplyr::select(P1, P2, h, r, gebv, sd_RILs) %>%
  pivot_wider(id_cols = c("P1","P2","r"), names_from = "h", values_from = c("gebv","sd_RILs")) 



sd <- crosses%>%
  filter(r=="r1r") %>%
  mutate(density=get_density(sd_RILs_NA, sd_RILs_0.4, n = 100)) %>%
  ggplot(aes(x=sd_RILs_NA, y=sd_RILs_0.4, col=density)) +
  geom_point()+
  geom_abline(slope=1, intercept = 0, col="red") +
  geom_smooth(method="lm", se=F, col="blue") +
  scale_colour_viridis() +
  theme_light() +
  xlab("sd progeny TRUE") +
  ylab("sd progeny estimated (her=0.4)") +
  theme(legend.position = "none",
        strip.text.y = element_text(color="black", size=12),
        strip.text.x = element_text(color="black", size=12),
        axis.text.x = element_text(size=12),
        axis.title.x = element_text(size=12),
        legend.text = element_text(size=12),
        axis.title.y = element_text(size=14),
        legend.title = element_text(size=14),
        axis.text.y = element_text(size=12),
        plot.title = element_text(hjust = 0.5, face="bold"),
        strip.background = element_rect(color="black", fill="white"))



gebv <- crosses%>%
  filter(r=="r1r") %>%
  mutate(density=get_density(gebv_NA, gebv_0.4, n = 100)) %>%
  ggplot(aes(x=gebv_NA, y=gebv_0.4, col=density)) +
  geom_point()+
  geom_abline(slope=1, intercept = 0, col="red") +
  geom_smooth(method="lm", se=F, col="blue") +
  scale_colour_viridis() +
  theme_light() +
  xlab("parental mean TRUE") +
  ylab("parental mean estimated (her=0.4)") +
  theme(legend.position = "none",
        strip.text.y = element_text(color="black", size=12),
        strip.text.x = element_text(color="black", size=12),
        axis.text.x = element_text(size=12),
        axis.title.x = element_text(size=12),
        legend.text = element_text(size=12),
        axis.title.y = element_text(size=14),
        legend.title = element_text(size=14),
        axis.text.y = element_text(size=12),
        plot.title = element_text(hjust = 0.5, face="bold"),
        strip.background = element_rect(color="black", fill="white"))


sd_gebv_true <- crosses%>%
  filter(r=="r1r") %>%
  mutate(density=get_density(gebv_NA, sd_RILs_NA, n = 100)) %>%
  ggplot(aes(x=gebv_NA, y=sd_RILs_NA, col=density)) +
  geom_point()+
  scale_colour_viridis() +
  theme_light() +
  xlab("parental mean TRUE") +
  ylab("sd progeny TRUE") +
  theme(legend.position = "none",
        strip.text.y = element_text(color="black", size=12),
        strip.text.x = element_text(color="black", size=12),
        axis.text.x = element_text(size=12),
        axis.title.x = element_text(size=12),
        legend.text = element_text(size=12),
        axis.title.y = element_text(size=14),
        legend.title = element_text(size=14),
        axis.text.y = element_text(size=12),
        plot.title = element_text(hjust = 0.5, face="bold"),
        strip.background = element_rect(color="black", fill="white"))




sd_gebv_her0.4 <- crosses%>%
  filter(r=="r1r") %>%
  mutate(density=get_density(gebv_0.4, sd_RILs_0.4, n = 100)) %>%
  ggplot(aes(x=gebv_0.4, y=sd_RILs_0.4, col=density)) +
  geom_point()+
  scale_colour_viridis() +
  theme_light() +
  xlab("parental mean estimated (her=0.4)") +
  ylab("sd progeny estimated (her=0.4)") +
  theme(legend.position = "none",
        strip.text.y = element_text(color="black", size=12),
        strip.text.x = element_text(color="black", size=12),
        axis.text.x = element_text(size=12),
        axis.title.x = element_text(size=12),
        legend.text = element_text(size=12),
        axis.title.y = element_text(size=14),
        legend.title = element_text(size=14),
        axis.text.y = element_text(size=12),
        plot.title = element_text(hjust = 0.5, face="bold"),
        strip.background = element_rect(color="black", fill="white"))


ggarrange(gebv, sd, ncol=2, labels=c("A","B"))
ggarrange(sd_gebv_true, sd_gebv_her0.4, ncol=2, labels = c("A","B"))




############"




head(best_crosses)
