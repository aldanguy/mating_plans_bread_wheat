

library(tidyverse)
library(data.table)


variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")



titre <- variables[1]
# titre <-"/work2/genphyse/dynagen/adanguy/croisements/200421/value_crosses/lines_estimated.txt"

f <- fread(titre)
head(f)
tail(f)
dim(f)
sort(unique(f$type))

extraction <- function(string, character_split, number){
  
  out <- as.vector(unlist(strsplit(string, split=character_split)))
  
  if (number > length(out)){
    
    out <- NA
  } else {
    
    out <- out[number]
  }
  
  return(out)
  
}
f2 <- f %>%
  na.omit() %>%
  filter(grepl("TRUE", type)) %>%
  filter(grepl("basic", type)| grepl("ldak", type)) %>%
  rowwise() %>%
  mutate(subset=extraction(string=type, character_split="_", number=3)) %>%
  mutate(h=extraction(string=type, character_split="_", number=4)) %>%
  mutate(r=extraction(string=type, character_split="_", number=5))%>%
  mutate(g=extraction(string=type, character_split="_", number=6)) %>%
  pivot_wider(id_cols=c("ID", "subset","h","r"), values_from = "value", names_from = "g") %>%
  na.omit() %>%
  arrange(desc(gbasic)) %>%
  group_by(subset, r, h) %>%
  mutate(rb=1:n())  %>%
  arrange(desc(gldak)) %>%
  group_by(subset, r, h) %>%
  mutate(rl=1:n()) %>%
  ungroup() 



f3 <- f %>%
  na.omit() %>%
  filter(grepl("tbv", type)) %>%
  rowwise() %>%
  mutate(subset=extraction(string=type, character_split="_", number=3)) %>%
  mutate(h=extraction(string=type, character_split="_", number=4)) %>%
  mutate(r=extraction(string=type, character_split="_", number=5))%>%
  dplyr::select(ID, value, h, r, subset) %>%
  rename(tbv=value) %>%
  arrange(desc(tbv)) %>%
  ungroup() %>%
  group_by(subset, h, r) %>%
  mutate(rt=1:n()) %>%
  ungroup() %>%
  ungroup()


f2 <- f2 %>% group_by(subset, h, r) %>% 
    inner_join(f3, by=c("ID", "subset", "r","h")) %>%
  ungroup()
  

f2 %>% filter(rt <= 10) %>%
  group_by(subset, h, r) %>%
  summarise(medianb=median(rb), medianl=median(rl), minb=min(rb),  minl=min(rl), maxl=max(rl),maxb=max(rb)) %>%
  group_by(subset, h) %>%
  summarise(mb=mean(medianb), ml=mean(medianl), minb=mean(minb), minl=mean(minl), maxb=mean(maxb), maxl=mean(maxl)) %>%
  as.data.frame()





f2 %>% filter(rt <= 100) %>%
  group_by(subset, h, r) %>%
  summarise(cb=cor(gbasic, tbv), cl=cor(gldak, tbv)) %>%
  group_by(subset, h) %>%
  summarise(mcb=mean(cb), mcl=mean(cl), sdcb=sd(cb), sdcl=sd(cl)) %>%
  as.data.frame()
  


sessionInfo()