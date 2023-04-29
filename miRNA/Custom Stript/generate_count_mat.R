library(tidyverse)
all_file <- list.files('miRDeep2_output/',pattern = 'miRNA_expressed.csv',recursive = T)

df <- data.table::fread(paste0('miRDeep2_output/',all_file[1]))%>% 
    filter(read_count >0)
str_extract(all_file,'\\w+')


load_csv <- function(x) {
    file_name <- str_extract(x,'\\w+')
    df <- data.table::fread(paste0('miRDeep2_output/',x)) %>% 
        filter(read_count >0)
    colnames(df)[1] <- 'miRNA' 
    colnames(df)[2] <- file_name  
    return(df)
}

count_list <- map(all_file,load_csv)
miRNA_count <- purrr::reduce(count_list,full_join,) %>% 
    select(1,3,2,4:8) %>% 
    mutate(across(where(is.numeric), ~replace_na(.x, 0))) %>% 
    distinct(miRNA,.keep_all = T)

data.table::fwrite(miRNA_count,file = 'miRDeep2_output/miRNA_count_matrix.txt',sep = '\t')


