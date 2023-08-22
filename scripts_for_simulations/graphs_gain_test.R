
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
titre_diversity <- "/home/adanguydesd/Documents/These_Alice/croisements/supplementary_files/diversity.txt"


r_graphs <- '/home/adanguydesd/Documents/These_Alice/croisements/figures/'

cat("\n\n INPUT : selection rate \n\n")
sel <- fread(titre_sel)
head(sel)
tail(sel)
dim(sel)


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



qtls_info <- "FALSE"
CONSTRAINTS <- "NO_CONSTRAINTS"


if (qtls_info=="FALSE"){
  
  titre_qtls="ESTIMATED"
  
} else {
  
  titre_qtls="TRUE"
  
  
}


if (CONSTRAINTS=="NO_CONSTRAINTS"){
  
  titre_constraints="NO CONSTRAINTS"
  
} else {
  
  titre_constraints="CONSTRAINTS"
  
  
}

titre <- paste0(titre_qtls, " + ", titre_constraints)
titre_graph <- paste0(titre_qtls, "_", titre_constraints)


titre1 <- paste0(r_graphs, titre_graph, ".tiff")
titre2 <- paste0(r_graphs, titre_graph, ".png")


order_criterion <- data.frame(criterion=c("PM","PROBA", "UC1","UC2","UC3", "EMBV", "OHV"),
                              ordre=1:7,
                              color=c("black","#F8766D", "#B79F00", "#00BA38", "#00BFC4", "#619CFF", "#F564E3"))

order_criterion_rev <- data.frame(criterion=rev(c("PM","PROBA", "UC1","UC2","UC3", "EMBV", "OHV")),
                              ordre=1:7,
                              color=c("black","#F8766D", "#B79F00", "#00BA38", "#00BFC4", "#619CFF", "#F564E3"))


#####

sel2 <- sel %>% filter(qtls_info==!!qtls_info & CONSTRAINTS==!!CONSTRAINTS)

gain2 <- gain %>% 
  filter(metric=="RI") %>%
  filter(qtls_info==!!qtls_info & CONSTRAINTS==!!CONSTRAINTS)

div2 <- div %>% filter(qtls_info==!!qtls_info & CONSTRAINTS==!!CONSTRAINTS)




#######

sel2 <- sel2 %>%
  mutate(criterion=factor(criterion, levels=order_criterion$criterion)) %>%
  mutate(population=factor(population, levels = c("unselected","selected"))) %>%
  mutate(selection_rate=100*selection_rate) %>%
  filter(selection_rate <=10)

gsel <- sel2 %>% 

  ggplot(aes(x=selection_rate, y=value, col=criterion, lty=criterion)) +
  geom_line(size=1) +
  facet_wrap(.~population, scales="free") +
  geom_hline(yintercept = 0, col="black", size=1) +
  geom_vline(xintercept = 7, col="grey", lty=2, size=1) +
  theme_light()+
  theme(strip.text.y = element_text(size = 0, color="black"),
        strip.text.x = element_text(size = 0, color="black"),
        strip.background = element_rect(color="black", fill="white", size=0),
        axis.title.y = element_text(size=18),
        axis.title.x = element_text(size=18),
        axis.text.x = element_text(size=18),
        axis.text.y = element_text(size=16),
        legend.text=element_text(size=18),
        legend.position = "none",
        plot.title = element_text(hjust = 0.5, size=18, face="bold"),
        legend.title=element_text(size=18)) +
  scale_x_continuous(trans="log10", breaks = c(0.1, 1, 7), labels = c("0.1","1","7")) +
  xlab("") +
  ylab("")+
  theme(legend.text=element_text(size=18),
        plot.title = element_text(hjust = 0.5, size=18, face="bold"),
        legend.title=element_text(size=18))+
  scale_color_manual(values = as.character(order_criterion$color))

  
  
gsel

div2 <- div2 %>% 
  filter(selected_progeny=="truncation" & info=="genic_div")%>%
  mutate(criterion=factor(criterion, levels=order_criterion$criterion)) %>%
  mutate(population=factor(population, levels = c("unselected","selected"))) %>%
  dplyr::select(-info) %>%
  dplyr::rename(genic_div=value)

gain2 <- gain2%>% 
  filter(selected_progeny == "truncation")  %>%
  mutate(criterion=factor(criterion, levels=order_criterion$criterion)) %>%
  mutate(population=factor(population, levels = c("unselected","selected")))  %>%
  dplyr::rename(gain=value)

 
compromis <- gain2 %>%
  inner_join(div2, by=c("population", "qtls_info", "CONSTRAINTS", "selected_progeny", "criterion"))


front_selected = compromis %>% filter(population=="selected") %>% arrange(desc(gain), desc(genic_div))
front_selected = front_selected[which(!duplicated(cummax(front_selected$genic_div))),]

front_unselected = compromis %>% filter(population=="unselected") %>% arrange(desc(gain), desc(genic_div))
front_unselected = front_unselected[which(!duplicated(cummax(front_unselected$genic_div))),]

front <- rbind(front_selected, front_unselected)

g_legend <- compromis %>%
  mutate(gain=0, genic_div=0) %>%
  ggplot(aes(y=gain, x=genic_div, col=criterion)) +
  geom_line(size=3)+
  theme_void() +
  ylab("") +
  xlab("") +
  theme(legend.text=element_text(size=18),
        legend.title=element_text(size=18))+
  scale_color_manual(values = as.character(order_criterion$color))

g_legend2 <- compromis %>%
  mutate(gain=0, genic_div=0) %>%
  ggplot(aes(y=gain, x=genic_div, col=criterion)) +
  geom_point(size=3)+
  theme_void() +
  ylab("") +
  xlab("") +
  theme(legend.text=element_text(size=18),
        legend.title=element_blank())+
  scale_color_manual(values = as.character(order_criterion$color))




gcompromis_no_legend <- compromis %>%
  ggplot(aes(y=gain, x=genic_div, col=criterion)) +
  geom_point(size=3)+
  facet_wrap(.~population, scales="free") +
  geom_line(data=front, aes(y=gain, x=genic_div, group=population), col="grey", size=1) +
  geom_point(size=3)+
  theme_light()+
  theme(strip.text.y = element_text(size = 0, color="black"),
        strip.text.x = element_text(size = 0, color="black"),
        strip.background = element_rect(color="black", fill="white", size=0),
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
  ylab("") +
  xlab("") +
  scale_color_manual(values = as.character(order_criterion$color))



g1 <- ggdraw() +
  draw_plot(g_legend, x=0.4, y=0.35, height=0.4, width = 0.5)+
  draw_plot(gsel, x=0.02, y=0.45, height=0.5, width = 0.8, scale=0.9)+
  draw_plot(gcompromis_no_legend, x=0.02, y=0.0005, height=0.5, width = 0.8, scale=0.9)+
  draw_label(titre, x=0.45, y=0.98, size = 22, fontface = "bold")+
  draw_label("Unselected", x=0.26, y=0.935, size = 16, fontface = "bold")+
  draw_label("Selected", x=0.62, y=0.935, size = 16, fontface = "bold")+
  draw_label("Selection rate among progeny (%)", x=0.45, y=0.5, size = 16)+
  draw_label("Relative increase of progeny genic diversity (%)", x=0.47, y=0.03, size = 16)+
  draw_label("Relative increase of progeny TBV (%)", x=0.06, y=0.55, size = 16, angle=90, fontfamily = "")

g1

if(dev.cur() > 1) dev.off()
png(titre2, units="in", width = 15, height = 8, res=300)
g1
dev.off()

f2 <- ggdraw() + 
  draw_image(titre2,x=0.03, y=0, width = 1, height = 1, scale=1.15)
if(dev.cur() > 1) dev.off()
tiff(titre1, compression = "lzw", width =6.75, height =6.75*0.7, res=300, units="in")
f2
dev.off()

