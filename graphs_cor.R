
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
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))
suppressPackageStartupMessages(library(viridis))
suppressPackageStartupMessages(library(ggpubr))
suppressPackageStartupMessages(library(igraph))
suppressPackageStartupMessages(library(pheatmap))
suppressPackageStartupMessages(library(cowplot))
suppressPackageStartupMessages(library(gridExtra))
suppressPackageStartupMessages(library(grid))
suppressPackageStartupMessages(library(png))
suppressPackageStartupMessages(library(lattice))

titre_cor <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/correlations.txt"

r_graphs <- '/home/adanguydesd/Documents/These_Alice/croisements/temp/'

cat("\n\n INPUT : correlations \n\n")
correlations <- fread(titre_cor)
head(correlations)
tail(correlations)
dim(correlations)

titre_graph <- "correlations"


titre1 <- paste0(r_graphs, titre_graph, ".tiff")
titre2 <- paste0(r_graphs, titre_graph, ".png")


order_criterion <- data.frame(criterion=c("PM","PROBA", "UC1","UC2","UC3", "EMBV", "OHV", "sd"),
                              ordre=1:8)
order_criterion_rev <- data.frame(criterion=rev(c("PM","PROBA", "UC1","UC2","UC3", "EMBV", "OHV", "sd")),
                              ordre=1:8)

#####

correlations2 <- correlations %>%
  inner_join(order_criterion, by=c("criterion1"="criterion")) %>%
  dplyr::rename(ordre1=ordre)%>%
  inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
  dplyr::rename(ordre2=ordre) %>%
  mutate(criterionA=ifelse(ordre1 <= ordre2, criterion1, criterion2))%>%
  mutate(criterionB=ifelse(ordre1 > ordre2, criterion1, criterion2)) %>%
  dplyr::select(-criterion1, -criterion2) %>%
  dplyr::rename(criterion1=criterionA, criterion2=criterionB) %>%
  unique() %>%
  dplyr::select(qtls_info, population, criterion1, criterion2, value) %>%
  mutate(criterion1=factor(criterion1, levels = order_criterion$criterion)) %>%
  mutate(criterion2=factor(criterion2, levels = order_criterion$criterion)) %>%
  arrange(criterion1, criterion2)



correlations_FALSE_sel <- correlations2 %>% filter(qtls_info=="FALSE" & population=="selected")
correlations_FALSE_unsel <- correlations2 %>% filter(qtls_info=="FALSE" & population=="unselected")

correlations_TRUE_sel <- correlations2 %>% filter(qtls_info=="TRUE" & population=="selected")
correlations_TRUE_unsel <- correlations2 %>% filter(qtls_info=="TRUE" & population=="unselected")


#######


G_FALSE_unsel <- graph.data.frame(correlations_FALSE_unsel %>% dplyr::select(criterion1, criterion2, value) %>%as.data.frame() ,directed=FALSE)
A_FALSE_unsel <- as_adjacency_matrix(G_FALSE_unsel,names=TRUE,sparse=FALSE,attr="value",type='both')


G_TRUE_unsel <- graph.data.frame(correlations_TRUE_unsel %>% dplyr::select(criterion1, criterion2, value) %>%as.data.frame() ,directed=FALSE)
A_TRUE_unsel <- as_adjacency_matrix(G_TRUE_unsel,names=TRUE,sparse=FALSE,attr="value",type='both')



G_FALSE_sel <- graph.data.frame(correlations_FALSE_sel %>% dplyr::select(criterion1, criterion2, value) %>%as.data.frame() ,directed=FALSE)
A_FALSE_sel <- as_adjacency_matrix(G_FALSE_sel,names=TRUE,sparse=FALSE,attr="value",type='both')


G_TRUE_sel <- graph.data.frame(correlations_TRUE_sel %>% dplyr::select(criterion1, criterion2, value) %>%as.data.frame() ,directed=FALSE)
A_TRUE_sel <- as_adjacency_matrix(G_TRUE_sel,names=TRUE,sparse=FALSE,attr="value",type='both')


A_TRUE <- A_TRUE_sel
A_TRUE[upper.tri(A_TRUE)] <- A_TRUE_unsel[upper.tri(A_TRUE_unsel)]


A_FALSE <- A_FALSE_sel
A_FALSE[upper.tri(A_FALSE)] <- A_FALSE_unsel[upper.tri(A_FALSE_unsel)]

A_FALSE<-A_FALSE[,c(7:1),drop = FALSE] 

A_TRUE_text <- A_TRUE
diag(A_TRUE) <- NA


A_FALSE_text <- A_FALSE
A_FALSE[c(7, 7+6, 7+6+6, 7+6+6+6, 7+6+6+6+6, 7+6+6+6+6+6, 7+6+6+6+6+6+6)] <- NA



plot_list_A_TRUE <- pheatmap(A_TRUE*100, 
                        display_numbers = round(A_TRUE_text*100), 
                        legend=F, 
                        fontsize_col=30, 
                        fontsize_row=30,
                        show_colnames=T,
                        show_rownames =F,
                        
                        fontsize_number=30, 
                        angle_col=270,
                        cluster_rows=F,
                        cluster_cols = F,
                      na_col = "darkred",
                        breaks = seq(0,100,1),
                        legend_breaks=c(0,1),
                        number_color="black")[[4]]



plot_list_A_FALSE <- pheatmap(A_FALSE*100, 
                             display_numbers = round(A_FALSE_text*100), 
                             legend=F, 
                             fontsize_col=30, 
                             fontsize_row=30,
                             show_colnames=T,
                             show_rownames =F,
                             fontsize_number=30, 
                             angle_col=270,
                             cluster_rows=F,
                             cluster_cols = F,
                             na_col = "darkred",
                             breaks = seq(0,100,1),
                             legend_breaks=c(0,1),
                             number_color="black")[[4]]





g1 <- ggdraw() +
  draw_plot(plot_list_A_TRUE, x=0.05, y=0, height=0.7, width = 0.4, scale = 1)+
  draw_plot(plot_list_A_FALSE, x=0.55, y=0, height=0.7, width = 0.4, scale = 1)+
   draw_label("Selected", x=0.025, y=0.47, size = 24, fontface = "plain", angle=90 )+
   draw_label("Selected", x=0.97, y=0.47, size = 24, fontface = "plain", angle=-90 )+
   draw_label("Unselected", x=0.25, y=0.73, size = 24, fontface = "plain", angle=0 )+
   draw_label("Unselected", x=0.75, y=0.73, size = 24, fontface = "plain", angle=0 )+
   draw_label("sd", x=0.5, y=0.23, size = 24, fontface = "plain")+
   draw_label("OHV", x=0.5, y=0.3, size = 24, fontface = "plain")+
   draw_label("EMBV", x=0.5, y=0.37, size = 24, fontface = "plain")+
   draw_label("UC2", x=0.5, y=0.44, size = 24, fontface = "plain")+
   draw_label("UC1", x=0.5, y=0.51, size = 24, fontface = "plain")+
   draw_label("PROBA", x=0.5, y=0.58, size = 24, fontface = "plain")+
   draw_label("PM", x=0.5, y=0.65, size = 24, fontface = "plain")+
   draw_label("TRUE", x=0.25, y=0.8, size = 24, fontface = "bold")+
   draw_label("FALSE", x=0.75, y=0.8, size = 24, fontface = "bold")+
   draw_label("Correlation of criteria", x=0.5, y=0.9, size = 24, fontface = "bold")
   




g1

if(dev.cur() > 1) dev.off()
png(titre2, units="in", width = 15, height = 8, res=300)
g1
dev.off()

f2 <- ggdraw() + 
  draw_image(titre2,x=0.01, y=0, width = 1, height = 1, scale=1.02)
if(dev.cur() > 1) dev.off()
tiff(titre1, compression = "lzw", width =6.75, height =6.75*0.7, res=300, units="in")
f2
dev.off()

