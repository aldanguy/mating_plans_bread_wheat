
Sys.time()
cat("\n\ngraphs.R\n\n")
rm(list = ls())
graphics.off()
set.seed(12)
t1 <-Sys.time() 



suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
library(ggpubr)
suppressPackageStartupMessages(library(RColorBrewer))
suppressPackageStartupMessages(library(viridis))
suppressPackageStartupMessages(library(scales))

titre_sel <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/selection_rate.txt"
titre_gain <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/gain.txt"
titre_diversity <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/diversity.txt"

titre_similarity <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/similarity.txt"

r_graphs <- '/home/adanguydesd/Documents/These_Alice/croisements/temp/'

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


cat("\n\n INPUT : similairity \n\n")
similarity <- fread(titre_similarity)
head(similarity)
tail(similarity)
dim(similarity)

CONSTRAINTS <- "NO_CONSTRAINTS"


titre_graph <- "NO CONSTRAINTS"


titre1 <- paste0(r_graphs, titre_graph, ".tiff")
titre2 <- paste0(r_graphs, titre_graph, ".png")


order_criterion <- data.frame(criterion=c("PM","PROBA", "UC1","UC2","UC3", "EMBV", "OHV"),
                              ordre=1:7,
                              color=c("black","#F8766D", "#B79F00", "#00BA38", "#00BFC4", "#619CFF", "#F564E3"))

order_criterion_rev <- data.frame(criterion=rev(c("PM","PROBA", "UC1","UC2","UC3", "EMBV", "OHV")),
                              ordre=1:7,
                              color=c("black","#F8766D", "#B79F00", "#00BA38", "#00BFC4", "#619CFF", "#F564E3"))


#####


gain2 <- gain %>% 
  filter(metric=="RI") %>%
  filter(CONSTRAINTS==CONSTRAINTS) 
  
#######

sel2 <- sel %>%
  filter(CONSTRAINTS==!!CONSTRAINTS) %>%
  mutate(criterion=factor(criterion, levels=order_criterion$criterion)) %>%
  mutate(population=ifelse(population=="unselected", "Unselected", "Selected")) %>%
  mutate(population=factor(population, levels = c("Unselected","Selected"))) %>%
  mutate(qtls_info=ifelse(qtls_info=="FALSE", "ESTIMATED", qtls_info)) %>%
  mutate(qtls_info=factor(qtls_info, levels = c("TRUE","ESTIMATED"))) %>%
  mutate(selection_rate=100*selection_rate) %>%
  filter(selection_rate <=10)

gsel <- sel2 %>% 
  ggplot(aes(x=selection_rate, y=value, col=criterion, lty=criterion)) +
  geom_line(size=1) +
  facet_grid(qtls_info~population, scales="free") +
  geom_hline(yintercept = 0, col="black", size=1) +
  theme_light()+
  theme(strip.text.y = element_text(size = 18, color="black"),
        strip.text.x = element_text(size = 18, color="black"),
        strip.background = element_rect(color="black", fill="white", size=1),
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



g_legend <- sel2 %>%
  mutate(gain=0, genic_div=0) %>%
  ggplot(aes(y=gain, x=genic_div, col=criterion)) +
  geom_line(size=3)+
  theme_void() +
  ylab("") +
  xlab("") +
  theme(legend.text=element_text(size=18),
        legend.title=element_text(size=18))+
  scale_color_manual(values = as.character(order_criterion$color))


g1 <- ggdraw() +
  draw_plot(g_legend, x=0.45, y=0.25, height=0.5, width = 0.5)+
  draw_plot(gsel, x=0.06, y=0, height=0.93, width = 0.8)+
  draw_label("NO CONSTRAINTS", x=0.48, y=0.97, size = 22, fontface = "bold")+
  draw_label("Selection rate (%)", x=0.48, y=0.01, size = 16)+
  draw_label("Relative increase of TBV (%)", x=0.06, y=0.53, size = 16, angle=90, fontfamily = "")
g1

if(dev.cur() > 1) dev.off()
png(titre2, units="in", width = 15, height = 8, res=300)
g1
dev.off()

f2 <- ggdraw() + 
  draw_image(titre2,x=0.01, y=0, width = 1, height = 1, scale=1.07)
if(dev.cur() > 1) dev.off()
tiff(titre1, compression = "lzw", width =6.75, height =6.75*0.7, res=300, units="in")
f2
dev.off()

