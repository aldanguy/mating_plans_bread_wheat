
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

qtls_info <- "TRUE"
CONSTRAINTS <- "CONSTRAINTS"


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


similarity2 <- similarity %>% filter(qtls_info==!!qtls_info & CONSTRAINTS==!!CONSTRAINTS)


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



gcompromis             

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



sharedp_unsel <- similarity2 %>%
  filter(metric=="parents" & population=="unselected")%>%
  inner_join(order_criterion, by=c("criterion1"="criterion")) %>%
   dplyr::rename(ordre1=ordre)%>%
   inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
   dplyr::rename(ordre2=ordre) %>%
   mutate(criterionA=ifelse(ordre1 <= ordre2, criterion1, criterion2))%>%
   mutate(criterionB=ifelse(ordre1 > ordre2, criterion1, criterion2)) %>%
   dplyr::select(criterionA, criterionB, value) %>%
   dplyr::rename(criterion1=criterionA, criterion2=criterionB) %>%
  unique() %>%
  filter(criterion1 != criterion2) %>%
   as.data.frame() %>%
   arrange(desc(value)) %>%
   mutate(order=1:n()) %>%
   mutate(type="upper") %>%
   dplyr::select(criterion1, criterion2, value, order, type) %>%
   arrange(criterion1, criterion2)
 


sharedp_sel <- similarity2 %>%
  filter(metric=="parents" & population=="selected")%>%
  inner_join(order_criterion, by=c("criterion1"="criterion")) %>%
  dplyr::rename(ordre1=ordre)%>%
  inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
  dplyr::rename(ordre2=ordre) %>%
  mutate(criterionA=ifelse(ordre1 <= ordre2, criterion1, criterion2))%>%
  mutate(criterionB=ifelse(ordre1 > ordre2, criterion1, criterion2)) %>%
  dplyr::select(criterionA, criterionB, value) %>%
  dplyr::rename(criterion1=criterionA, criterion2=criterionB) %>%
  unique() %>%
  filter(criterion1 != criterion2) %>%
  as.data.frame() %>%
  arrange(desc(value)) %>%
  mutate(order=1:n()) %>%
  mutate(type="upper") %>%
  dplyr::select(criterion1, criterion2, value, order, type) %>%
  arrange(criterion1, criterion2)

 
 # 
 # sharedp <- matrix(t(combn(order_criterion$criterion, m=2, simplify = T)), ncol=2) %>%
 #   as.data.frame() %>%
 #   dplyr::rename(criterion1=V1, criterion2=V2) %>%
 #   inner_join(order_criterion, by=c("criterion1"="criterion")) %>%
 #   dplyr::rename(ordre1=ordre)%>%
 #   inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
 #   dplyr::rename(ordre2=ordre) %>%
 #   mutate(criterionA=ifelse(ordre1 <= ordre2, criterion1, criterion2))%>%
 #   mutate(criterionB=ifelse(ordre1 > ordre2, criterion1, criterion2)) %>%
 #   dplyr::select(criterionA, criterionB) %>%
 #   dplyr::rename(criterion1=criterionA, criterion2=criterionB) %>%
 #   mutate(value=runif(n(), 0, 100)) %>%
 #   as.data.frame() %>%
 #   arrange(desc(value)) %>%
 #   mutate(order=1:n()) %>%
 #   mutate(type="upper") %>%
 #   dplyr::select(criterion1, criterion2, value, order, type) %>%
 #   arrange(criterion1, criterion2)
 # 
 

shareds_unsel <- similarity2 %>%
  filter(metric=="similarity" & population=="unselected")%>%
  inner_join(order_criterion, by=c("criterion1"="criterion")) %>%
  dplyr::rename(ordre1=ordre)%>%
  inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
  dplyr::rename(ordre2=ordre) %>%
  mutate(criterionA=ifelse(ordre1 >= ordre2, criterion1, criterion2))%>%
  mutate(criterionB=ifelse(ordre1 < ordre2, criterion1, criterion2)) %>%
  dplyr::select(criterionA, criterionB, value) %>%
  dplyr::rename(criterion1=criterionA, criterion2=criterionB) %>%
  unique() %>%
  filter(criterion1 != criterion2) %>%
  as.data.frame() %>%
  arrange(desc(value)) %>%
  mutate(order=1:n()) %>%
  mutate(type="lower") %>%
  dplyr::select(criterion1, criterion2, value, order, type) %>%
  arrange(criterion1, criterion2)


shareds_sel <- similarity2 %>%
  filter(metric=="similarity" & population=="selected")%>%
  inner_join(order_criterion, by=c("criterion1"="criterion")) %>%
  dplyr::rename(ordre1=ordre)%>%
  inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
  dplyr::rename(ordre2=ordre) %>%
  mutate(criterionA=ifelse(ordre1 >= ordre2, criterion1, criterion2))%>%
  mutate(criterionB=ifelse(ordre1 < ordre2, criterion1, criterion2)) %>%
  dplyr::select(criterionA, criterionB, value) %>%
  dplyr::rename(criterion1=criterionA, criterion2=criterionB) %>%
  unique() %>%
  filter(criterion1 != criterion2) %>%
  as.data.frame() %>%
  arrange(desc(value)) %>%
  mutate(order=1:n()) %>%
  mutate(type="lower") %>%
  dplyr::select(criterion1, criterion2, value, order, type) %>%
  arrange(criterion1, criterion2)

 
 # shareds <- matrix(t(combn(order_criterion$criterion, m=2, simplify = T)), ncol=2) %>%
 #   as.data.frame() %>%
 #   dplyr::rename(criterion1=V1, criterion2=V2) %>%
 #   inner_join(order_criterion, by=c("criterion1"="criterion")) %>%
 #   dplyr::rename(ordre1=ordre)%>%
 #   inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
 #   dplyr::rename(ordre2=ordre) %>%
 #   mutate(criterionA=ifelse(ordre1 >= ordre2, criterion1, criterion2))%>%
 #   mutate(criterionB=ifelse(ordre1 < ordre2, criterion1, criterion2)) %>%
 #   dplyr::select(criterionA, criterionB) %>%
 #   dplyr::rename(criterion1=criterionA, criterion2=criterionB) %>%
 #   mutate(value=runif(n(), 0, 100)) %>%
 #   as.data.frame() %>%
 #   arrange(desc(value)) %>%
 #   mutate(order=1:n()) %>%
 #   mutate(type="lower") %>%
 #   dplyr::select(criterion1, criterion2, value, order, type) %>%
 #   arrange(criterion1, criterion2)
 # 
 


sharedd_unsel <- similarity2 %>%
  filter(metric=="similarity" & population=="unselected")%>%
  inner_join(order_criterion, by=c("criterion1"="criterion")) %>%
  dplyr::rename(ordre1=ordre)%>%
  inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
  dplyr::rename(ordre2=ordre) %>%
  mutate(criterionA=ifelse(ordre1 >= ordre2, criterion1, criterion2))%>%
  mutate(criterionB=ifelse(ordre1 < ordre2, criterion1, criterion2)) %>%
  dplyr::select(criterionA, criterionB, value) %>%
  dplyr::rename(criterion1=criterionA, criterion2=criterionB) %>%
  unique() %>%
  filter(criterion1 == criterion2) %>%
  as.data.frame() %>%
  arrange(desc(value)) %>%
  mutate(order=1:n()) %>%
  mutate(type="diag") %>%
  dplyr::select(criterion1, criterion2, value, order, type) %>%
  arrange(criterion1, criterion2)


sharedd_sel <- similarity2 %>%
  filter(metric=="similarity" & population=="selected")%>%
  inner_join(order_criterion, by=c("criterion1"="criterion")) %>%
  dplyr::rename(ordre1=ordre)%>%
  inner_join(order_criterion, by=c("criterion2"="criterion")) %>%
  dplyr::rename(ordre2=ordre) %>%
  mutate(criterionA=ifelse(ordre1 >= ordre2, criterion1, criterion2))%>%
  mutate(criterionB=ifelse(ordre1 < ordre2, criterion1, criterion2)) %>%
  dplyr::select(criterionA, criterionB, value) %>%
  dplyr::rename(criterion1=criterionA, criterion2=criterionB) %>%
  unique() %>%
  filter(criterion1 == criterion2) %>%
  as.data.frame() %>%
  arrange(desc(value)) %>%
  mutate(order=1:n()) %>%
  mutate(type="diag") %>%
  dplyr::select(criterion1, criterion2, value, order, type) %>%
  arrange(criterion1, criterion2)

# 
# sharedd <- order_criterion %>%
#   dplyr::rename(criterion1=criterion) %>%
#   mutate(criterion2=criterion1) %>%
#   mutate(value=runif(n(), 0, 100)) %>%
#   ungroup() %>%
#   arrange(desc(value)) %>%
#   mutate(order=1:n()) %>%
#   mutate(type="diag") %>%
#   dplyr::select(criterion1, criterion2, value, order, type)%>%
#   arrange(criterion1, criterion2)
# 
# 


x <- sort(sharedp_unsel$value, decreasing = F)
x <- (1:length(x))/length(x)
x <- rescale(x)
colfunc_lower <-colorRamp(brewer.pal(9, "Greens"))
col <- rgb(colfunc_lower(x), max=300)
color_lower <- data.frame(color=col) %>%
  mutate(order=n():1) %>%
  mutate(type="lower")
plot(rep(1,length(unique(x))),col=col,pch=19,cex=3)



x <- sort(shareds_unsel$value, decreasing = F)
x <- (1:length(x))/length(x)
x <- rescale(x)
colfunc_upper <-colorRamp(brewer.pal(9, "Blues"))
col <- rgb(colfunc_upper(x), max=300) 
color_upper <- data.frame(color=col) %>%
  mutate(order=n():1) %>%
  mutate(type="upper")
plot(rep(1,length(unique(x))),col=col,pch=19,cex=3)



x <- sort(sharedd_unsel$value, decreasing = F)
x <- (1:length(x))/length(x)
x <- rescale(x)
colfunc_diag <-  colorRamp(brewer.pal(9, "YlOrRd"))
col <- rgb(colfunc_diag(x), max=300) 
color_diag <- data.frame(color=col) %>%
  mutate(order=n():1) %>%
  mutate(type="diag")
plot(rep(1,length(unique(x))),col=col,pch=19,cex=3)


color_unsel <- rbind(color_lower, color_upper, color_diag)


shared_unsel <- rbind(sharedp_unsel, shareds_unsel, sharedd_unsel)  %>%
  left_join(color_unsel, by=c("order","type")) %>%
  ungroup() %>%
  arrange(criterion1, criterion2, type)  %>%
  arrange(type, criterion1, criterion2) %>%
  mutate(criterion1=factor(criterion1, levels = order_criterion$criterion)) %>%
  mutate(criterion2=factor(criterion2, levels = order_criterion$criterion)) %>%
  arrange(type, desc(criterion1), desc(criterion2))


shared_unsel <- shared_unsel%>%
  mutate(color2=factor(shared_unsel$color, levels = unique(shared_unsel$color))) %>%
  mutate(color3=as.factor(as.numeric(as.factor(color2))))


gshared_unsel <- ggplot(shared_unsel, aes(x = criterion1,
                      y = criterion2,
                      fill = color3)) +
  geom_tile() +
  geom_text(label = round(shared_unsel$value), size = 6, colour = "white") +
   theme(legend.position = "none")+
   scale_fill_manual(values=as.character(shared_unsel$color2))+
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
        axis.text.x = element_text(size=16, angle=45, vjust=0.7),
        axis.text.y = element_text(size=0),
        legend.text=element_text(size=18),
        plot.title = element_text(hjust = 0.5, size=18, face="bold"),
        legend.title=element_text(size=18))

gshared_unsel



x <- sort(sharedp_sel$value, decreasing = F)
x <- (1:length(x))/length(x)
x <- rescale(x)
colfunc_lower <-colorRamp(brewer.pal(9, "Greens"))
col <- rgb(colfunc_lower(x), max=300)
color_lower <- data.frame(color=col) %>%
  mutate(order=n():1) %>%
  mutate(type="lower")
plot(rep(1,length(unique(x))),col=col,pch=19,cex=3)



x <- sort(shareds_sel$value, decreasing = F)
x <- (1:length(x))/length(x)
x <- rescale(x)
colfunc_upper <-colorRamp(brewer.pal(9, "Blues"))
col <- rgb(colfunc_upper(x), max=300) 
color_upper <- data.frame(color=col) %>%
  mutate(order=n():1) %>%
  mutate(type="upper")
plot(rep(1,length(unique(x))),col=col,pch=19,cex=3)



x <- sort(sharedd_sel$value, decreasing = F)
x <- (1:length(x))/length(x)
x <- rescale(x)
colfunc_diag <-  colorRamp(brewer.pal(9, "YlOrRd"))
col <- rgb(colfunc_diag(x), max=300) 
color_diag <- data.frame(color=col) %>%
  mutate(order=n():1) %>%
  mutate(type="diag")
plot(rep(1,length(unique(x))),col=col,pch=19,cex=3)


color_sel <- rbind(color_lower, color_upper, color_diag)


shared_sel <- rbind(sharedp_sel, shareds_sel, sharedd_sel)  %>%
  left_join(color_sel, by=c("order","type")) %>%
  ungroup() %>%
  arrange(criterion1, criterion2, type)  %>%
  arrange(type, criterion1, criterion2) %>%
  mutate(criterion1=factor(criterion1, levels = order_criterion$criterion)) %>%
  mutate(criterion2=factor(criterion2, levels = order_criterion$criterion)) %>%
  arrange(type, desc(criterion1), desc(criterion2))


shared_sel <- shared_sel%>%
  mutate(color2=factor(shared_sel$color, levels = unique(shared_sel$color))) %>%
  mutate(color3=as.factor(as.numeric(as.factor(color2))))


gshared_sel <- ggplot(shared_sel, aes(x = criterion1,
                                          y = criterion2,
                                          fill = color3)) +
  geom_tile() +
  geom_text(label = round(shared_sel$value), size = 6, colour = "white") +
  theme(legend.position = "none")+
  scale_fill_manual(values=as.character(shared_sel$color2))+
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
        axis.text.x = element_text(size=16, angle=45, vjust=0.7),
        axis.text.y = element_text(size=0),
        legend.text=element_text(size=18),
        plot.title = element_text(hjust = 0.5, size=18, face="bold"),
        legend.title=element_text(size=18))

gshared_sel



df <- data.frame(name = c("Parents in common (%)", "Similarity within mating plan", "Similarity between mating plans"),
                 colour = c("blue","red","green"),
                 x1 = runif(3, 0,0),
                 y1 = runif(3, 0,0)) %>%
  mutate(name=factor(name, levels=c("Parents in common (%)", "Similarity within mating plan", "Similarity between mating plans")))

fake <- 
  df %>% ggplot(aes(x1,y1, colour = name)) +
  geom_point(size = 3, shape=15) +
  scale_colour_manual(values = c(brewer.pal(n = 3, name = 'Blues')[3],
                                 brewer.pal(n = 3, name = 'YlOrRd')[3],
                                 brewer.pal(n = 3, name = 'Greens')[3]),
                      name = "Genetic similarity of parents") +
  theme_void() +
  theme(legend.text=element_text(size=18),
        legend.title.align=0.5,
        legend.title=element_text(size=18))


g1 <- ggdraw() +
  draw_plot(g_legend, x=0.2, y=0.56, height=0.5, width = 0.5)+
  draw_plot(g_legend2, x=0.2, y=0.27, height=0.5, width = 0.5)+
  draw_plot(gsel, x=0.09, y=0.6, height=0.33, width = 0.5)+
  draw_plot(gcompromis_no_legend, x=0.09, y=0.315, height=0.33, width = 0.5)+
  draw_label(titre, x=0.36, y=0.98, size = 22, fontface = "bold")+
  draw_label("Unselected", x=0.24, y=0.935, size = 16, fontface = "bold")+
  draw_label("Selected", x=0.47, y=0.935, size = 16, fontface = "bold")+
  draw_label("Selection rate (%)", x=0.65, y=0.66, size = 16)+
  draw_label("Relative increase of genic diversity (%)", x=0.72, y=0.375, size = 16)+
  draw_label("Relative increase of TBV (%)", x=0.1, y=0.65, size = 16, angle=90, fontfamily = "")+

  draw_plot(fake, x=0.63, y=0.05, height=0.35, width = 0.3) +
  draw_plot(gshared_unsel, x=0.04, y=-0.06, height=0.41, width = 0.3)+
  draw_plot(gshared_sel, x=0.365, y=-0.06, height=0.41, width = 0.3) +
  draw_label("PM", x=0.365, y=0.09, size = 16, fontface = "plain")+
  draw_label("PROBA", x=0.365, y=0.125, size = 16, fontface = "plain")+
  draw_label("UC1", x=0.365, y=0.165, size = 16, fontface = "plain")+
  draw_label("UC2", x=0.365, y=0.205, size = 16, fontface = "plain")+
  draw_label("UC3", x=0.365, y=0.245, size = 16, fontface = "plain")+
  draw_label("EMBV", x=0.365, y=0.285, size = 16, fontface = "plain")+
  draw_label("OHV", x=0.365, y=0.325, size = 16, fontface = "plain")+
  draw_label("A", x=0.04, y=0.9, size = 40, fontface = "bold")+
  draw_label("B", x=0.04, y=0.6, size = 40, fontface = "bold")+
  draw_label("C", x=0.04, y=0.3, size = 40, fontface = "bold")

g1

if(dev.cur() > 1) dev.off()
png(titre2, units="in", width = 15, height = 8, res=300)
g1
dev.off()

f2 <- ggdraw() + 
  draw_image(titre2,x=0.03, y=0, width = 1, height = 1, scale=1.07)
if(dev.cur() > 1) dev.off()
tiff(titre1, compression = "lzw", width =6.75, height =6.75*0.7, res=300, units="in")
f2
dev.off()

