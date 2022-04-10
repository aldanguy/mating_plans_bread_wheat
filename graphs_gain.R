
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

titre_sel <- "/home/adanguydesd/Documents/These_Alice/croisements/supplementary_files/selection_rate.txt"
titre_gain <- "/home/adanguydesd/Documents/These_Alice/croisements/supplementary_files/gain.txt"


r_graphs <- '/home/adanguydesd/Documents/These_Alice/croisements/figures/'

cat("\n\n INPUT : selection rate \n\n")
sel <- fread(titre_sel)
head(sel)
tail(sel)
dim(sel)


cat("\n\n INPUT : gain \n\n")
gain <- fread(titre_gain)
head(gain)
tail(gain)
dim(gain)



CONSTRAINTS <- "CONSTRAINTS"


if (CONSTRAINTS=="NO_CONSTRAINTS"){
  
  titre_constraints="NO CONSTRAINTS scenarios"
  
} else {
  
  titre_constraints="CONSTRAINTS scenarios"
  
  
}

titre <- titre_constraints
titre_graph <- paste0(CONSTRAINTS,"_gain")


titre1 <- paste0(r_graphs, titre_graph, ".tiff")


order_criterion <- data.frame(criterion=c("PM","PROBA", "UC1","UC2","UC3", "EMBV", "OHV"),
                              ordre=1:7,
                              color=c("black","#F8766D", "#B79F00", "#00BA38", "#00BFC4", "#619CFF", "#F564E3"))

order_criterion_rev <- data.frame(criterion=rev(c("PM","PROBA", "UC1","UC2","UC3", "EMBV", "OHV")),
                              ordre=1:7,
                              color=c("black","#F8766D", "#B79F00", "#00BA38", "#00BFC4", "#619CFF", "#F564E3"))


#####

sel2 <- sel %>% filter(CONSTRAINTS==!!CONSTRAINTS)


gain2 <- gain  %>% filter(CONSTRAINTS==!!CONSTRAINTS)

#######

sel2 <- sel2 %>%
  mutate(criterion=factor(criterion, levels=order_criterion$criterion)) %>%
  mutate(population=ifelse(population=="selected", "Selected", "Unselected")) %>%
  mutate(population=factor(population, levels = c("Unselected","Selected"))) %>%
  mutate(qtls_info=ifelse(qtls_info=="TRUE", "TRUE", "ESTIMATED")) %>%
  
  mutate(qtls_info=factor(qtls_info, levels = c("TRUE","ESTIMATED"))) %>%

  mutate(selection_rate=100*selection_rate) %>%
  filter(selection_rate <=10)

gsel <- sel2 %>% 

  ggplot(aes(x=selection_rate, y=value, col=criterion)) +
  geom_line(size=1) +
  facet_grid(population~qtls_info, scales="free") +
  geom_vline(xintercept = 7, col="grey", lty=2, size=1) +
  theme_light()+
  theme(strip.text.y = element_text(size = 18, color="black"),
        strip.text.x = element_text(size = 18, color="black"),
        strip.background = element_rect(color="black", fill="white"),
        axis.title.y = element_text(size=18),
        axis.title.x = element_text(size=18),
        axis.text.x = element_text(size=18),
        axis.text.y = element_text(size=16),
        legend.text=element_text(size=18),
        legend.position = "right",
        plot.title = element_text(hjust = 0.5, size=18, face="bold"),
        legend.title=element_text(size=18)) +
  scale_x_continuous(trans="log10", breaks = c(0.1, 1, 7), labels = c("0.1","1","7")) +
  ylab("Relative increase in mean progeny TBV\n compare to PM (%)") +
  xlab("Selection rate among progeny")+
  ggtitle(titre)+
  theme(legend.text=element_text(size=18),
        plot.title = element_text(hjust = 0.5, size=18, face="bold"),
        legend.title=element_text(size=18))+
  scale_color_manual(values = as.character(order_criterion$color))

  
  
gsel


if(dev.cur() > 1) dev.off()
tiff(titre1, compression = "lzw", width =6.75, height =6.75*0.7, res=300, units="in")
gsel
dev.off()

