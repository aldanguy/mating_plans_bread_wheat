
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
suppressPackageStartupMessages(library(ggpubr))


titre_correlations <- "/home/adanguydesd/Documents/These_Alice/croisements/supplementary_files/correlations.txt"

r_graphs <- '/home/adanguydesd/Documents/These_Alice/croisements/figures/'


cat("\n\n INPUT : similairity \n\n")
correlations <- fread(titre_correlations)
head(correlations)
tail(correlations)
dim(correlations)

titre_graph <- "correlations"


titre1 <- paste0(r_graphs, titre_graph, ".tiff")
titre2 <- paste0(r_graphs, titre_graph, ".png")


order_criterion <- data.frame(criterion=c("PM","PROBA", "UC1","UC2", "EMBV", "OHV", "sd"),
                              ordre=1:7,
                              color=c("black","#F8766D", "#B79F00", "#00BA38", "#00BFC4", "#619CFF", "#F564E3"))

order_criterion_rev <- data.frame(criterion=rev(c("PM","PROBA", "UC1","UC2", "EMBV", "OHV", "sd")),
                              ordre=1:7,
                              color=c("black","#F8766D", "#B79F00", "#00BA38", "#00BFC4", "#619CFF", "#F564E3"))


#####

correlations2 <- correlations 

#######

 
population="unselected"


shared_true <- correlations2 %>%
  filter(population==!!population & qtls_info==TRUE)%>%
  inner_join(order_criterion, by=c("criterion1"="criterion")) %>%
  dplyr::rename(ordre1=ordre)%>%
  inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
  dplyr::rename(ordre2=ordre) %>%
  mutate(criterionA=ifelse(ordre1 >= ordre2, criterion1, criterion2))%>%
  mutate(criterionB=ifelse(ordre1 < ordre2, criterion1, criterion2)) %>%
  dplyr::select(criterionA, criterionB, value) %>%
  dplyr::rename(criterion1=criterionA, criterion2=criterionB) %>%
  unique() %>%
  mutate(value=ifelse(criterion1==criterion2, 100, value)) %>%
  as.data.frame() 


shared_false <- correlations2 %>%
  filter( population==!!population & qtls_info=="FALSE")%>%
  inner_join(order_criterion, by=c("criterion1"="criterion")) %>%
  dplyr::rename(ordre1=ordre)%>%
  inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
  dplyr::rename(ordre2=ordre) %>%
  mutate(criterionA=ifelse(ordre1 <= ordre2, criterion1, criterion2))%>%
  mutate(criterionB=ifelse(ordre1 >ordre2, criterion1, criterion2)) %>%
  dplyr::select(criterionA, criterionB, value) %>%
  dplyr::rename(criterion1=criterionA, criterion2=criterionB) %>%
  unique() %>%
  filter(criterion1!= criterion2) %>%
  as.data.frame() 

shared <- rbind(shared_true, shared_false) %>%
   dplyr::select(criterion1, criterion2, value) %>%
  mutate(criterion1=factor(criterion1, levels = order_criterion_rev$criterion)) %>%
  mutate(criterion2=factor(criterion2, levels = order_criterion_rev$criterion)) %>%
   arrange(desc(criterion1), desc(criterion2)) %>%
  mutate(value=ifelse(criterion1==criterion2, NA, value))


gshared_unsel <- ggplot(shared, aes(x = criterion1,
                      y = criterion2,
                      fill = value)) +
  geom_tile(color="black") +
  geom_text(label = round(shared$value), size = 6, colour = "white") +
   theme(legend.position = "none")+
   xlab("") +
   ylab("")+
  theme(panel.grid.minor = element_blank()) +
  theme(panel.grid.major = element_blank()) +
  theme(axis.ticks = element_blank()) +
  theme(panel.background = element_rect(fill = "transparent"))+
  theme(legend.position = "none")+
  ylab("")+
  scale_y_discrete(position="left")+
  theme(strip.text.y = element_text(size = 18, color="black"),
        strip.text.x = element_text(size = 0, color="black"),
        strip.background = element_rect(color="black", fill="white", size=0),
        axis.title.y = element_text(size=18),
        axis.title.x = element_text(size=18),
        axis.text.x = element_text(size=0, angle=45, vjust=0.7),
        axis.text.y = element_text(size=0),
        legend.text=element_text(size=18),
        plot.title = element_text(hjust = 0.5, size=18, face="bold"),
        legend.title=element_text(size=18))+
  scale_fill_viridis(direction = -1, begin=0, end=1, na.value="white")+
  coord_fixed()

gshared_unsel


population="selected"




shared_true <- correlations2 %>%
  filter(population==!!population & qtls_info==TRUE)%>%
  inner_join(order_criterion, by=c("criterion1"="criterion")) %>%
  dplyr::rename(ordre1=ordre)%>%
  inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
  dplyr::rename(ordre2=ordre) %>%
  mutate(criterionA=ifelse(ordre1 >= ordre2, criterion1, criterion2))%>%
  mutate(criterionB=ifelse(ordre1 < ordre2, criterion1, criterion2)) %>%
  dplyr::select(criterionA, criterionB, value) %>%
  dplyr::rename(criterion1=criterionA, criterion2=criterionB) %>%
  unique() %>%
  mutate(value=ifelse(criterion1==criterion2, 100, value)) %>%
  as.data.frame() 


shared_false <- correlations2 %>%
  filter( population==!!population & qtls_info=="FALSE")%>%
  inner_join(order_criterion, by=c("criterion1"="criterion")) %>%
  dplyr::rename(ordre1=ordre)%>%
  inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
  dplyr::rename(ordre2=ordre) %>%
  mutate(criterionA=ifelse(ordre1 <= ordre2, criterion1, criterion2))%>%
  mutate(criterionB=ifelse(ordre1 >ordre2, criterion1, criterion2)) %>%
  dplyr::select(criterionA, criterionB, value) %>%
  dplyr::rename(criterion1=criterionA, criterion2=criterionB) %>%
  unique() %>%
  filter(criterion1!= criterion2) %>%
  as.data.frame() 

shared <- rbind(shared_true, shared_false) %>%
  dplyr::select(criterion1, criterion2, value) %>%
  mutate(criterion1=factor(criterion1, levels = order_criterion_rev$criterion)) %>%
  mutate(criterion2=factor(criterion2, levels = order_criterion_rev$criterion)) %>%
  arrange(desc(criterion1), desc(criterion2)) %>%
  mutate(value=ifelse(criterion1==criterion2, NA, value))


gshared_sel <- ggplot(shared, aes(x = criterion1,
                                    y = criterion2,
                                    fill = value)) +
  geom_tile(color="black") +
  geom_text(label = round(shared$value), size = 6, colour = "white") +
  theme(legend.position = "none")+
  xlab("") +
  ylab("")+
  theme(panel.grid.minor = element_blank()) +
  theme(panel.grid.major = element_blank()) +
  theme(axis.ticks = element_blank()) +
  theme(panel.background = element_rect(fill = "transparent"))+
  theme(legend.position = "none")+
  ylab("")+
  scale_y_discrete(position="left")+
  theme(strip.text.y = element_text(size = 18, color="black"),
        strip.text.x = element_text(size = 0, color="black"),
        strip.background = element_rect(color="black", fill="white", size=0),
        axis.title.y = element_text(size=18),
        axis.title.x = element_text(size=18),
        axis.text.x = element_text(size=0, angle=45, vjust=0.7),
        axis.text.y = element_text(size=0),
        legend.text=element_text(size=18),
        plot.title = element_text(hjust = 0.5, size=18, face="bold"),
        legend.title=element_text(size=18))+
  scale_fill_viridis(direction = -1, begin=0, end=1, na.value="white")+
  coord_fixed()

gshared_sel

initial <- 0.15

delta=0.09

g1 <- ggdraw() +
  draw_plot(gshared_unsel, x=-0.25, y=-0.1, scale=0.7)+
  draw_plot(gshared_sel, x=0.23, y=-0.1, scale=0.7)+
  draw_label(order_criterion_rev$criterion[1], x=0.5, y=initial, size = 16, fontface = "plain")+
  draw_label(order_criterion_rev$criterion[2], x=0.5, y=initial+delta, size = 16, fontface = "plain")+
  draw_label(order_criterion_rev$criterion[3], x=0.5, y=initial+delta*2, size = 16, fontface = "plain")+
  draw_label(order_criterion_rev$criterion[4], x=0.5, y=initial+delta*3, size = 16, fontface = "plain")+
  draw_label(order_criterion_rev$criterion[5], x=0.5, y=initial+delta*4, size = 16, fontface = "plain")+
  draw_label(order_criterion_rev$criterion[6], x=0.5, y=initial+delta*5, size = 16, fontface = "plain")+
  draw_label(order_criterion_rev$criterion[7], x=0.5, y=initial+delta*6, size = 16, fontface = "plain")+
  draw_label("Unselected", x=0.27, y=0.8, size = 18, fontface = "bold")+
  draw_label("Selected", x=0.75, y=0.8, size = 18, fontface = "bold")+
  draw_label("TRUE", x=0.098, y=0.77, size = 18)+
  draw_label("TRUE", x=0.58, y=0.77, size = 18)+
  draw_label("ESTIMATED", x=0.39, y=0.08, size = 18)+
  draw_label("ESTIMATED", x=0.87, y=0.08, size = 18)+
  draw_label(paste0("Correlations of criteria\nin the 10% crosses with highest PM"), x=0.5, y=0.9, size = 20, fontface = "bold")+
  draw_line(    x = c(0.08,0.08),
    y = c(0.65, 0.75))+
  draw_line(    x = c(0.08,0.14),
    y = c(0.75, 0.75))+
draw_line(  x = c(0.56,0.56),
  y = c(0.65, 0.75))+
  draw_line(    x = c(0.56,0.62),
    y = c(0.75, 0.75))+
  draw_line(  x = c(0.915,0.915),
              y = c(0.1, 0.19))+
  draw_line(    x = c(0.835,0.915),
                y = c(0.1, 0.1))+
  draw_line(  x = c(0.435,0.435),
              y = c(0.1, 0.19))+
  draw_line(    x = c(0.35,0.435),
                y = c(0.1, 0.1))
  
  

g1



if(dev.cur() > 1) dev.off()
png(titre2, units="in", width = 15, height = 8, res=300)
g1
dev.off()

f2 <- ggdraw() + 
  draw_image(titre2,x=0.03, y=0, width = 1, height = 1, scale=1.01)
if(dev.cur() > 1) dev.off()
tiff(titre1, compression = "lzw", width =6.75, height =6.75*0.7, res=300, units="in")
f2
dev.off()

