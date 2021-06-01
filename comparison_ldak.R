





Sys.time()
cat("\n\ncomparison_LDAK.R\n\n")
rm(list = ls())
graphics.off()
set.seed(1)

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(compiler))



variables <- commandArgs(trailingOnly=TRUE)
cat("\n\nVariables : \n")
print(variables)
cat("\n\n")


titre_a <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_estimated_all_ldak.txt"
titre_w <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_estimated_weights_ldak.txt"
titre_g <- "/home/adanguydesd/Documents/These_Alice/croisements/temp/lines_estimated_g_ldak.txt"



extraction <- function(string, character_split, number){
  
  out <- as.vector(unlist(strsplit(string, split=character_split)))
  
  if (number > length(out)){
    
    out <- NA
  } else {
    
    out <- out[number]
  }
  
  return(out)
  
}


a <- fread(titre_a) %>%
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
  rename(gldak_a=gldak)

w <- fread(titre_w) %>%
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
  rename(gldak_w=gldak)



g <- fread(titre_g) %>%
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
  rename(gldak_g=gldak)


tbv <- fread(titre_g) %>%
  na.omit() %>%
  filter(grepl("TRUE", type)) %>%
  filter(grepl("tbv", type)) %>%
  rowwise() %>%
  mutate(subset=extraction(string=type, character_split="_", number=3)) %>%
  mutate(h=extraction(string=type, character_split="_", number=4)) %>%
  mutate(r=extraction(string=type, character_split="_", number=5))%>%
  dplyr::select(ID, subset, h, r , value) %>%
  rename(tbv=value)


f <- a %>% inner_join(w, by=c("ID","subset", "h","r", "gbasic")) %>%
  inner_join(g, by=c("ID","subset", "h","r", "gbasic")) %>%
  inner_join(tbv, by=c("ID","subset", "h","r")) %>%
  arrange(subset, h, r, ID) 


### all parents
f %>% group_by(subset, h, r) %>%
  summarise(pente_basic_ldaka=as.vector(lm(gbasic~gldak_a)$coefficients[2]),
            pente_basic_ldakw=as.vector(lm(gbasic~gldak_w)$coefficients[2]),
            pente_basic_ldakg=as.vector(lm(gbasic~gldak_g)$coefficients[2]),
            cor_basic_ldaka=cor(gbasic, gldak_a),
            cor_basic_ldakw=cor(gbasic, gldak_w),
            cor_basic_ldakg=cor(gbasic, gldak_g),
            cor_tbv_basic=cor(tbv, gbasic),
            cor_tbv_ldaka=cor(tbv, gldak_a),
            cor_tbv_ldakw=cor(tbv, gldak_w),
            cor_tbv_ldakg=cor(tbv, gldak_g)) %>%
  group_by(subset, h) %>%
  summarise(nrep=n(),
            mean_cor_basic_ldaka=round(mean(cor_basic_ldaka), 2),
            mean_cor_basic_ldakw=round(mean(cor_basic_ldakw), 2),
            mean_cor_basic_ldakg=round(mean(cor_basic_ldakg), 2),
            sd_cor_basic_ldaka=round(sd(cor_basic_ldaka), 2),
            sd_cor_basic_ldakw=round(sd(cor_basic_ldakw), 2),
            sd_cor_basic_ldakg=round(sd(cor_basic_ldakg), 2),
            mean_slope_basic_ldaka=round(mean(pente_basic_ldaka), 2),
            mean_slope_basic_ldakw=round(mean(pente_basic_ldakw), 2),
            mean_slope_basic_ldakg=round(mean(pente_basic_ldakg), 2),
            sd_slope_basic_ldaka=round(sd(pente_basic_ldaka), 2),
            sd_slope_basic_ldakw=round(sd(pente_basic_ldakw), 2),
            sd_slope_basic_ldakg=round(sd(pente_basic_ldakg), 2),
            mean_cor_tbv_basic=round(mean(cor_tbv_basic), 2),
            mean_cor_tbv_ldaka=round(mean(cor_tbv_ldaka), 2),
            mean_cor_tbv_ldakw=round(mean(cor_tbv_ldakw), 2),
            mean_cor_tbv_ldakg=round(mean(cor_tbv_ldakg), 2),
            sd_cor_tbv_basic=round(sd(cor_tbv_basic), 2),
            sd_cor_tbv_ldaka=round(sd(cor_tbv_ldaka), 2),
            sd_cor_tbv_ldakw=round(sd(cor_tbv_ldakw), 2),
            sd_cor_tbv_ldakg=round(sd(cor_tbv_ldakg), 2)) %>%
  as.data.frame()






# top 100 parents
f %>% group_by(subset, h, r) %>%
  arrange(desc(tbv)) %>%
  mutate(rtbv=1:n()) %>%
  filter(rtbv <= 100) %>%
  summarise(pente_basic_ldaka=as.vector(lm(gbasic~gldak_a)$coefficients[2]),
            pente_basic_ldakw=as.vector(lm(gbasic~gldak_w)$coefficients[2]),
            pente_basic_ldakg=as.vector(lm(gbasic~gldak_g)$coefficients[2]),
            cor_basic_ldaka=cor(gbasic, gldak_a),
            cor_basic_ldakw=cor(gbasic, gldak_w),
            cor_basic_ldakg=cor(gbasic, gldak_g),
            cor_tbv_basic=cor(tbv, gbasic),
            cor_tbv_ldaka=cor(tbv, gldak_a),
            cor_tbv_ldakw=cor(tbv, gldak_w),
            cor_tbv_ldakg=cor(tbv, gldak_g)) %>%
  group_by(subset, h) %>%
  summarise(nrep=n(),
            mean_cor_basic_ldaka=round(mean(cor_basic_ldaka), 2),
            mean_cor_basic_ldakw=round(mean(cor_basic_ldakw), 2),
            mean_cor_basic_ldakg=round(mean(cor_basic_ldakg), 2),
            sd_cor_basic_ldaka=round(sd(cor_basic_ldaka), 2),
            sd_cor_basic_ldakw=round(sd(cor_basic_ldakw), 2),
            sd_cor_basic_ldakg=round(sd(cor_basic_ldakg), 2),
            mean_slope_basic_ldaka=round(mean(pente_basic_ldaka), 2),
            mean_slope_basic_ldakw=round(mean(pente_basic_ldakw), 2),
            mean_slope_basic_ldakg=round(mean(pente_basic_ldakg), 2),
            sd_slope_basic_ldaka=round(sd(pente_basic_ldaka), 2),
            sd_slope_basic_ldakw=round(sd(pente_basic_ldakw), 2),
            sd_slope_basic_ldakg=round(sd(pente_basic_ldakg), 2),
            mean_cor_tbv_basic=round(mean(cor_tbv_basic), 2),
            mean_cor_tbv_ldaka=round(mean(cor_tbv_ldaka), 2),
            mean_cor_tbv_ldakw=round(mean(cor_tbv_ldakw), 2),
            mean_cor_tbv_ldakg=round(mean(cor_tbv_ldakg), 2),
            sd_cor_tbv_basic=round(sd(cor_tbv_basic), 2),
            sd_cor_tbv_ldaka=round(sd(cor_tbv_ldaka), 2),
            sd_cor_tbv_ldakw=round(sd(cor_tbv_ldakw), 2),
            sd_cor_tbv_ldakg=round(sd(cor_tbv_ldakg), 2)) %>%
  as.data.frame()

