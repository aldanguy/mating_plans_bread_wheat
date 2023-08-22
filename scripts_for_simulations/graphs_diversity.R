
Sys.time()
cat("\n\ngraphs.R\n\n")
rm(list = ls())
graphics.off()
set.seed(12)
t1 <-Sys.time() 



suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(RColorBrewer))
suppressPackageStartupMessages(library(viridis))
suppressPackageStartupMessages(library(scales))
suppressPackageStartupMessages(library(cowplot))
suppressPackageStartupMessages(library(ggpubr))

titre_diversity <- "/home/adanguydesd/Documents/These_Alice/croisements/supplementary_files/diversity.txt"
titre_gain <- "/home/adanguydesd/Documents/These_Alice/croisements/supplementary_files/gain.txt"


r_graphs <- '/home/adanguydesd/Documents/These_Alice/croisements/figures/'



cat("\n\n INPUT : diversity \n\n")
div <- fread(titre_diversity)
head(div)
tail(div)
dim(div)


cat("\n\n INPUT : gain \n\n")
gain <- fread(titre_gain)
head(gain)
tail(gain)
dim(gain)

CONSTRAINTS <- "CONSTRAINTS"



if (CONSTRAINTS=="NO_CONSTRAINTS"){
  
  titre_constraints="NO CONSTRAINTS"
  
} else {
  
  titre_constraints="CONSTRAINTS"
  
  
}

titre <- paste0(titre_constraints, " scenarios")
titre_graph <- paste0(titre_constraints, "_tradeoff")


titre1 <- paste0(r_graphs, titre_graph, ".tiff")
titre2 <- paste0(r_graphs, titre_graph, ".png")


order_criterion <- data.frame(criterion=c("PM","PROBA", "UC1","UC2","UC3", "EMBV", "OHV"),
                              ordre=1:7,
                              color=c("black","#F8766D", "#B79F00", "#00BA38", "#00BFC4", "#619CFF", "#F564E3"))

order_criterion_rev <- data.frame(criterion=rev(c("PM","PROBA", "UC1","UC2","UC3", "EMBV", "OHV")),
                              ordre=1:7,
                              color=c("black","#F8766D", "#B79F00", "#00BA38", "#00BFC4", "#619CFF", "#F564E3"))


#####

div2 <- div %>% 
  filter(CONSTRAINTS==!!CONSTRAINTS)%>%
  filter(selected_progeny=="truncation" & info=="genic_div")%>%
  mutate(criterion=factor(criterion, levels=order_criterion$criterion)) %>%
  mutate(population=ifelse(population=="selected", "Selected", "Unselected")) %>%
  mutate(population=factor(population, levels = c("Unselected","Selected"))) %>%
  mutate(qtls_info=ifelse(qtls_info=="TRUE", "TRUE", "ESTIMATED")) %>%
  
  mutate(qtls_info=factor(qtls_info, levels = c("TRUE","ESTIMATED"))) %>%
  dplyr::select(-info) %>%
  dplyr::rename(genic_div=value)


gain2 <- gain%>% 
  filter(CONSTRAINTS==!!CONSTRAINTS)%>%
  filter(selected_progeny == "truncation" & metric=="RI")  %>%
  mutate(criterion=factor(criterion, levels=order_criterion$criterion)) %>%
  mutate(population=ifelse(population=="selected", "Selected", "Unselected")) %>%
  mutate(population=factor(population, levels = c("Unselected","Selected"))) %>%
  mutate(qtls_info=ifelse(qtls_info=="TRUE", "TRUE", "ESTIMATED")) %>%
  
  mutate(qtls_info=factor(qtls_info, levels = c("TRUE","ESTIMATED"))) %>% 
  dplyr::rename(gain=value)



#######



 
compromis <- gain2 %>%
  inner_join(div2, by=c("population", "qtls_info", "CONSTRAINTS", "selected_progeny", "criterion"))


front_selected_true = compromis %>% filter(population=="Selected" & qtls_info=="TRUE") %>% arrange(desc(gain), desc(genic_div))
front_selected_true = front_selected_true[which(!duplicated(cummax(front_selected_true$genic_div))),]

front_unselected_true = compromis %>% filter(population=="Unselected" & qtls_info=="TRUE") %>% arrange(desc(gain), desc(genic_div))
front_unselected_true = front_unselected_true[which(!duplicated(cummax(front_unselected_true$genic_div))),]

front_selected_ESTIMATED = compromis %>% filter(population=="Selected" & qtls_info=="ESTIMATED") %>% arrange(desc(gain), desc(genic_div))
front_selected_ESTIMATED = front_selected_ESTIMATED[which(!duplicated(cummax(front_selected_ESTIMATED$genic_div))),]

front_unselected_ESTIMATED = compromis %>% filter(population=="Unselected" & qtls_info=="ESTIMATED") %>% arrange(desc(gain), desc(genic_div))
front_unselected_ESTIMATED = front_unselected_ESTIMATED[which(!duplicated(cummax(front_unselected_ESTIMATED$genic_div))),]

front <- rbind(front_selected_true, front_unselected_true, front_selected_ESTIMATED, front_unselected_ESTIMATED)




g <- compromis %>%
  ggplot(aes(y=gain, x=genic_div, col=criterion)) +
  geom_point(size=3)+
  facet_grid(population~qtls_info, scales="free") +
  geom_line(data=front, aes(y=gain, x=genic_div, group=population), col="grey", size=1) +
  geom_point(size=3)+
  theme_light()+
  theme(strip.text.y = element_text(size = 18, color="black"),
        strip.text.x = element_text(size = 18, color="black"),
        strip.background = element_rect(color="black", fill="white"),
        axis.title.y = element_text(size=18),
        axis.title.x = element_text(size=18),
        axis.text.x = element_text(size=18),
        axis.text.y = element_text(size=16),
        legend.text=element_text(size=18),
        legend.position = "none",
        plot.title = element_text(hjust = 0.5, size=18, face="bold"),
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(-10,-10,-10,-10),
        legend.title=element_text(size=18)) + 
  ylab("Relative increase in mean progeny TBV\ncompare to PM (%)") +
  xlab("Relative increase in progeny genic variance\ncompare to PM (%)")+
  ggtitle(titre)+
  scale_color_manual(values = as.character(order_criterion$color))

g


if(dev.cur() > 1) dev.off()
tiff(titre1, compression = "lzw", width =6.75, height =6.75*0.7, res=300, units="in")
g
dev.off()



gain %>%
  filter(selected_progeny=="best" & metric=="sd_raw") %>%
 group_by(population, qtls_info, CONSTRAINTS) %>%
  summarise(value=max(value)) %>%
  pivot_wider(id_cols = c("population", "qtls_info"), names_from="CONSTRAINTS", values_from="value") %>%
  mutate(ratio=CONSTRAINTS/NO_CONSTRAINTS)


div %>%
  filter(selected_progeny=="truncation" & info=="genic_div_raw") %>%
  group_by(population, qtls_info, CONSTRAINTS) %>%
  summarise(value=max(value)) %>%
  pivot_wider(id_cols = c("population", "qtls_info"), names_from="CONSTRAINTS", values_from="value") %>%
  mutate(ratio=CONSTRAINTS/NO_CONSTRAINTS)
