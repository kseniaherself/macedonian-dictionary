setwd("Desktop/")
library(tidyverse)
library(rvest)
library(stringr)
# get list of all words ---------------------------------------------------

# here will be the whole abc
#letter <- c("а", "б", "в", "г", "д", "ѓ", "е", "ж", "з", "ѕ", "и", "ј", "к", "л", "љ", "м", "н", "њ", "о", "п", "р", "с", "т", "ќ", "у", "ф", "х", "ц", "ч", "џ", "ш") 
letter <- c("а", "б", "в", "г") 

# this chunk creates all links
links <- paste0("http://www.makedonski.info/letter/", letter)

# here will be all macedonian words
all_words <- NA

sapply(links, function(i) {
  # read an html file from the link
  source <- read_html(i)
  
  # read the menu part
  source %>%
    html_nodes("#ranges > select > option") %>%
    html_attrs() %>%
    unlist() %>%
    unname() ->
    new_links

    paste0("http://www.makedonski.info", new_links) %>% 
    str_replace_all(" ", "%20") ->
    new_links
  
  sapply(new_links, function(j) {
    # here is a page generated from menu span
    source2 <- read_html(j)
    
    source2 %>%
      html_nodes('#lexems') %>%
      html_text() %>%
      str_replace("  \n\t  \n\t    ", "") %>%
      str_replace_all("св. и несв.", "св и несв.") %>% 
      str_replace("г\\.", "г") %>%                #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("дипл\\.", "дипл") %>%          #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("инж\\.", "инж") %>%            #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_split("\\. ") %>%
      unlist() %>% 
      
      str_replace("  ", "/") %>% 
      str_replace("г/скр", "г./скр") %>%          #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("дипл/скр", "дипл./скр") %>%    #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("инж/скр", "инж./скр") %>%      #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace_all("/св и несв", "/св. и несв") ->
      add
    
    all_words <<- append(all_words, add[-length(add)])
  })
})

paste0("http://www.makedonski.info/show/", all_words) %>% 
  str_replace_all(" ", "%20") ->
  all_words
  
# get dectionary entrance -------------------------------------------------

entrance <- data_frame(all_words,
                       flexion = character(length(all_words)),
                       grammar = character(length(all_words)),
                       definition = character(length(all_words)),
                       translation = character(length(all_words)),
                       used = character(length(all_words)),
                       example = character(length(all_words)),
                       semem_links = character(length(all_words)),
                       idiom = character(length(all_words)),
                       derivation = character(length(all_words))
                       )

entrance <- entrance[-1,]
  
sapply(seq_along(entrance$all_words), function(k){
  source <- read_html(entrance$all_words[k])
  
  source %>%
    html_nodes('#main_lexem_view > div.flexion') %>%
    html_text() ->>
    entrance$flexion[k]
  
  source %>%
    html_nodes('#main_lexem_view > div.grammar') %>%
    html_text() ->>
    entrance$grammar[k]
  
  source %>%
    html_nodes('#main_lexem_view > div.definition > div.semem-links') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$definition[k]
  
  source %>%
    html_nodes('#categories > div') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$translation[k]
  
  #поедет в многозначных словах но мы это оставляем 
  source %>%
    html_nodes('#categories > span') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$used[k]
  
  source %>%
    html_nodes('#main_lexem_view > div:nth-child(4) > div.example') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$example[k]
  
  source %>%
    html_nodes('#main_lexem_view > div:nth-child(3) > div.semem-links') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$semem_links[k]
  
  source %>%
    html_nodes('#main_lexem_view > div:nth-child(10)') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$idiom[k]
  
  source %>%
    html_nodes('#main_lexem_view > div.prepend-2.last.derivation') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$derivation[k]
})


# remove spaces and \n\t
entrance %>% 
  mutate(flexion = str_replace_all(flexion, "\n|\t", ""),
         grammar = str_replace_all(grammar, "\n|\t", ""),
         definition = str_replace_all(definition, "\n|\t", ""),
         translation = str_replace_all(translation, "\n|\t", ""),
         used = str_replace_all(used, "\n|\t", ""),
         example = str_replace_all(example, "\n|\t", ""),
         semem_links = str_replace_all(semem_links, "\n|\t", ""),
         idiom = str_replace_all(idiom, "\n|\t", ""),
         derivation = str_replace_all(derivation, "\n|\t", ""),
         flexion = str_replace_all(flexion, "\\s+", " "),
         grammar = str_replace_all(grammar, "\\s+", " "),
         definition = str_replace_all(definition, "\\s+", " "),
         translation = str_replace_all(translation, "\\s+", " "),
         used = str_replace_all(used, "\\s+", " "),
         example = str_replace_all(example, "\\s+", " "),
         semem_links = str_replace_all(semem_links, "\\s+", " "),
         idiom = str_replace_all(idiom, "\\s+", " "),
         derivation = str_replace_all(derivation, "\\s+", " "),
         word = str_replace(str_replace(all_words, ".*?/.*?/.*?/.*?/", ""), "/", ", "),
         word = str_replace_all(word, "%20", " ")) ->
  entrance

write_tsv(entrance, "macedonian_а-г.tsv")

#д-s -------------------------------------------------------------------------

letter <- c("д", "ѓ", "е", "ж", "з", "ѕ") 

# this chunk creates all links
links <- paste0("http://www.makedonski.info/letter/", letter)

# here will be all macedonian words
all_words <- NA

sapply(links, function(i) {
  # read an html file from the link
  source <- read_html(i)
  
  # read the menu part
  source %>%
    html_nodes("#ranges > select > option") %>%
    html_attrs() %>%
    unlist() %>%
    unname() ->
    new_links
  
  paste0("http://www.makedonski.info", new_links) %>% 
    str_replace_all(" ", "%20") ->
    new_links
  
  sapply(new_links, function(j) {
    # here is a page generated from menu span
    source2 <- read_html(j)
    
    source2 %>%
      html_nodes('#lexems') %>%
      html_text() %>%
      str_replace("  \n\t  \n\t    ", "") %>%
      str_replace_all("св. и несв.", "св и несв.") %>% 
      str_replace("г\\.", "г") %>%                #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("дипл\\.", "дипл") %>%          #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("инж\\.", "инж") %>%            #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_split("\\. ") %>%
      unlist() %>% 
      
      str_replace("  ", "/") %>% 
      str_replace("г/скр", "г./скр") %>%          #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("дипл/скр", "дипл./скр") %>%    #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("инж/скр", "инж./скр") %>%      #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace_all("/св и несв", "/св. и несв") ->
      add
    
    all_words <<- append(all_words, add[-length(add)])
  })
})

paste0("http://www.makedonski.info/show/", all_words) %>% 
  str_replace_all(" ", "%20") ->
  all_words

# get dectionary entrance -------------------------------------------------

entrance <- data_frame(all_words,
                       flexion = character(length(all_words)),
                       grammar = character(length(all_words)),
                       definition = character(length(all_words)),
                       translation = character(length(all_words)),
                       used = character(length(all_words)),
                       example = character(length(all_words)),
                       semem_links = character(length(all_words)),
                       idiom = character(length(all_words)),
                       derivation = character(length(all_words))
)

entrance <- entrance[-1,]

sapply(seq_along(entrance$all_words), function(k){
  source <- read_html(entrance$all_words[k])
  
  source %>%
    html_nodes('#main_lexem_view > div.flexion') %>%
    html_text() ->>
    entrance$flexion[k]
  
  source %>%
    html_nodes('#main_lexem_view > div.grammar') %>%
    html_text() ->>
    entrance$grammar[k]
  
  source %>%
    html_nodes('#main_lexem_view > div.definition > div.semem-links') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$definition[k]
  
  source %>%
    html_nodes('#categories > div') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$translation[k]
  
  #поедет в многозначных словах но мы это оставляем 
  source %>%
    html_nodes('#categories > span') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$used[k]
  
  source %>%
    html_nodes('#main_lexem_view > div:nth-child(4) > div.example') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$example[k]
  
  source %>%
    html_nodes('#main_lexem_view > div:nth-child(3) > div.semem-links') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$semem_links[k]
  
  source %>%
    html_nodes('#main_lexem_view > div:nth-child(10)') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$idiom[k]
  
  source %>%
    html_nodes('#main_lexem_view > div.prepend-2.last.derivation') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$derivation[k]
})


# remove spaces and \n\t
entrance %>% 
  mutate(flexion = str_replace_all(flexion, "\n|\t", ""),
         grammar = str_replace_all(grammar, "\n|\t", ""),
         definition = str_replace_all(definition, "\n|\t", ""),
         translation = str_replace_all(translation, "\n|\t", ""),
         used = str_replace_all(used, "\n|\t", ""),
         example = str_replace_all(example, "\n|\t", ""),
         semem_links = str_replace_all(semem_links, "\n|\t", ""),
         idiom = str_replace_all(idiom, "\n|\t", ""),
         derivation = str_replace_all(derivation, "\n|\t", ""),
         flexion = str_replace_all(flexion, "\\s+", " "),
         grammar = str_replace_all(grammar, "\\s+", " "),
         definition = str_replace_all(definition, "\\s+", " "),
         translation = str_replace_all(translation, "\\s+", " "),
         used = str_replace_all(used, "\\s+", " "),
         example = str_replace_all(example, "\\s+", " "),
         semem_links = str_replace_all(semem_links, "\\s+", " "),
         idiom = str_replace_all(idiom, "\\s+", " "),
         derivation = str_replace_all(derivation, "\\s+", " "),
         word = str_replace(str_replace(all_words, ".*?/.*?/.*?/.*?/", ""), "/", ", "),
         word = str_replace_all(word, "%20", " ")) ->
  entrance

write_tsv(entrance, "macedonian_д-ѕ.tsv")

#и-њ --------------------------------------------------------------------- 

letter <- c("и", "ј", "к", "л", "љ", "м", "н", "њ") 

# this chunk creates all links
links <- paste0("http://www.makedonski.info/letter/", letter)

# here will be all macedonian words
all_words <- NA

sapply(links, function(i) {
  # read an html file from the link
  source <- read_html(i)
  
  # read the menu part
  source %>%
    html_nodes("#ranges > select > option") %>%
    html_attrs() %>%
    unlist() %>%
    unname() ->
    new_links
  
  paste0("http://www.makedonski.info", new_links) %>% 
    str_replace_all(" ", "%20") ->
    new_links
  
  sapply(new_links, function(j) {
    # here is a page generated from menu span
    source2 <- read_html(j)
    
    source2 %>%
      html_nodes('#lexems') %>%
      html_text() %>%
      str_replace("  \n\t  \n\t    ", "") %>%
      str_replace_all("св. и несв.", "св и несв.") %>% 
      str_replace("г\\.", "г") %>%                #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("дипл\\.", "дипл") %>%          #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("инж\\.", "инж") %>%            #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_split("\\. ") %>%
      unlist() %>% 
      
      str_replace("  ", "/") %>% 
      str_replace("г/скр", "г./скр") %>%          #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("дипл/скр", "дипл./скр") %>%    #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("инж/скр", "инж./скр") %>%      #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace_all("/св и несв", "/св. и несв") ->
      add
    
    all_words <<- append(all_words, add[-length(add)])
  })
})

paste0("http://www.makedonski.info/show/", all_words) %>% 
  str_replace_all(" ", "%20") ->
  all_words

# get dectionary entrance -------------------------------------------------

entrance <- data_frame(all_words,
                       flexion = character(length(all_words)),
                       grammar = character(length(all_words)),
                       definition = character(length(all_words)),
                       translation = character(length(all_words)),
                       used = character(length(all_words)),
                       example = character(length(all_words)),
                       semem_links = character(length(all_words)),
                       idiom = character(length(all_words)),
                       derivation = character(length(all_words))
)

entrance <- entrance[-1,]

sapply(seq_along(entrance$all_words), function(k){
  source <- read_html(entrance$all_words[k])
  
  source %>%
    html_nodes('#main_lexem_view > div.flexion') %>%
    html_text() ->>
    entrance$flexion[k]
  
  source %>%
    html_nodes('#main_lexem_view > div.grammar') %>%
    html_text() ->>
    entrance$grammar[k]
  
  source %>%
    html_nodes('#main_lexem_view > div.definition > div.semem-links') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$definition[k]
  
  source %>%
    html_nodes('#categories > div') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$translation[k]
  
  #поедет в многозначных словах но мы это оставляем 
  source %>%
    html_nodes('#categories > span') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$used[k]
  
  source %>%
    html_nodes('#main_lexem_view > div:nth-child(4) > div.example') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$example[k]
  
  source %>%
    html_nodes('#main_lexem_view > div:nth-child(3) > div.semem-links') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$semem_links[k]
  
  source %>%
    html_nodes('#main_lexem_view > div:nth-child(10)') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$idiom[k]
  
  source %>%
    html_nodes('#main_lexem_view > div.prepend-2.last.derivation') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$derivation[k]
})


# remove spaces and \n\t
entrance %>% 
  mutate(flexion = str_replace_all(flexion, "\n|\t", ""),
         grammar = str_replace_all(grammar, "\n|\t", ""),
         definition = str_replace_all(definition, "\n|\t", ""),
         translation = str_replace_all(translation, "\n|\t", ""),
         used = str_replace_all(used, "\n|\t", ""),
         example = str_replace_all(example, "\n|\t", ""),
         semem_links = str_replace_all(semem_links, "\n|\t", ""),
         idiom = str_replace_all(idiom, "\n|\t", ""),
         derivation = str_replace_all(derivation, "\n|\t", ""),
         flexion = str_replace_all(flexion, "\\s+", " "),
         grammar = str_replace_all(grammar, "\\s+", " "),
         definition = str_replace_all(definition, "\\s+", " "),
         translation = str_replace_all(translation, "\\s+", " "),
         used = str_replace_all(used, "\\s+", " "),
         example = str_replace_all(example, "\\s+", " "),
         semem_links = str_replace_all(semem_links, "\\s+", " "),
         idiom = str_replace_all(idiom, "\\s+", " "),
         derivation = str_replace_all(derivation, "\\s+", " "),
         word = str_replace(str_replace(all_words, ".*?/.*?/.*?/.*?/", ""), "/", ", "),
         word = str_replace_all(word, "%20", " ")) ->
  entrance

write_tsv(entrance, "macedonian_и-њ.tsv")

#о-ќ ----------------------------------------------------------------------

letter <- c("о", "п", "р", "с", "т", "ќ") 
# this chunk creates all links
links <- paste0("http://www.makedonski.info/letter/", letter)

# here will be all macedonian words
all_words <- NA

sapply(links, function(i) {
  # read an html file from the link
  source <- read_html(i)
  
  # read the menu part
  source %>%
    html_nodes("#ranges > select > option") %>%
    html_attrs() %>%
    unlist() %>%
    unname() ->
    new_links
  
  paste0("http://www.makedonski.info", new_links) %>% 
    str_replace_all(" ", "%20") ->
    new_links
  
  sapply(new_links, function(j) {
    # here is a page generated from menu span
    source2 <- read_html(j)
    
    source2 %>%
      html_nodes('#lexems') %>%
      html_text() %>%
      str_replace("  \n\t  \n\t    ", "") %>%
      str_replace_all("св. и несв.", "св и несв.") %>% 
      str_replace("г\\.", "г") %>%                #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("дипл\\.", "дипл") %>%          #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("инж\\.", "инж") %>%            #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_split("\\. ") %>%
      unlist() %>% 
      
      str_replace("  ", "/") %>% 
      str_replace("г/скр", "г./скр") %>%          #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("дипл/скр", "дипл./скр") %>%    #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("инж/скр", "инж./скр") %>%      #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace_all("/св и несв", "/св. и несв") ->
      add
    
    all_words <<- append(all_words, add[-length(add)])
  })
})

paste0("http://www.makedonski.info/show/", all_words) %>% 
  str_replace_all(" ", "%20") ->
  all_words

# get dectionary entrance -------------------------------------------------

entrance <- data_frame(all_words,
                       flexion = character(length(all_words)),
                       grammar = character(length(all_words)),
                       definition = character(length(all_words)),
                       translation = character(length(all_words)),
                       used = character(length(all_words)),
                       example = character(length(all_words)),
                       semem_links = character(length(all_words)),
                       idiom = character(length(all_words)),
                       derivation = character(length(all_words))
)

entrance <- entrance[-1,]

sapply(seq_along(entrance$all_words), function(k){
  source <- read_html(entrance$all_words[k])
  
  source %>%
    html_nodes('#main_lexem_view > div.flexion') %>%
    html_text() ->>
    entrance$flexion[k]
  
  source %>%
    html_nodes('#main_lexem_view > div.grammar') %>%
    html_text() ->>
    entrance$grammar[k]
  
  source %>%
    html_nodes('#main_lexem_view > div.definition > div.semem-links') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$definition[k]
  
  source %>%
    html_nodes('#categories > div') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$translation[k]
  
  #поедет в многозначных словах но мы это оставляем 
  source %>%
    html_nodes('#categories > span') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$used[k]
  
  source %>%
    html_nodes('#main_lexem_view > div:nth-child(4) > div.example') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$example[k]
  
  source %>%
    html_nodes('#main_lexem_view > div:nth-child(3) > div.semem-links') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$semem_links[k]
  
  source %>%
    html_nodes('#main_lexem_view > div:nth-child(10)') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$idiom[k]
  
  source %>%
    html_nodes('#main_lexem_view > div.prepend-2.last.derivation') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$derivation[k]
})


# remove spaces and \n\t
entrance %>% 
  mutate(flexion = str_replace_all(flexion, "\n|\t", ""),
         grammar = str_replace_all(grammar, "\n|\t", ""),
         definition = str_replace_all(definition, "\n|\t", ""),
         translation = str_replace_all(translation, "\n|\t", ""),
         used = str_replace_all(used, "\n|\t", ""),
         example = str_replace_all(example, "\n|\t", ""),
         semem_links = str_replace_all(semem_links, "\n|\t", ""),
         idiom = str_replace_all(idiom, "\n|\t", ""),
         derivation = str_replace_all(derivation, "\n|\t", ""),
         flexion = str_replace_all(flexion, "\\s+", " "),
         grammar = str_replace_all(grammar, "\\s+", " "),
         definition = str_replace_all(definition, "\\s+", " "),
         translation = str_replace_all(translation, "\\s+", " "),
         used = str_replace_all(used, "\\s+", " "),
         example = str_replace_all(example, "\\s+", " "),
         semem_links = str_replace_all(semem_links, "\\s+", " "),
         idiom = str_replace_all(idiom, "\\s+", " "),
         derivation = str_replace_all(derivation, "\\s+", " "),
         word = str_replace(str_replace(all_words, ".*?/.*?/.*?/.*?/", ""), "/", ", "),
         word = str_replace_all(word, "%20", " ")) ->
  entrance

write_tsv(entrance, "macedonian_о-ќ.tsv")

#у-ш ---------------------------------------------------------------------

letter <- c("у", "ф", "х", "ц", "ч", "џ", "ш") 

# this chunk creates all links
links <- paste0("http://www.makedonski.info/letter/", letter)

# here will be all macedonian words
all_words <- NA

sapply(links, function(i) {
  # read an html file from the link
  source <- read_html(i)
  
  # read the menu part
  source %>%
    html_nodes("#ranges > select > option") %>%
    html_attrs() %>%
    unlist() %>%
    unname() ->
    new_links
  
  paste0("http://www.makedonski.info", new_links) %>% 
    str_replace_all(" ", "%20") ->
    new_links
  
  sapply(new_links, function(j) {
    # here is a page generated from menu span
    source2 <- read_html(j)
    
    source2 %>%
      html_nodes('#lexems') %>%
      html_text() %>%
      str_replace("  \n\t  \n\t    ", "") %>%
      str_replace_all("св. и несв.", "св и несв.") %>% 
      str_replace("г\\.", "г") %>%                #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("дипл\\.", "дипл") %>%          #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("инж\\.", "инж") %>%            #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_split("\\. ") %>%
      unlist() %>% 
      
      str_replace("  ", "/") %>% 
      str_replace("г/скр", "г./скр") %>%          #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("дипл/скр", "дипл./скр") %>%    #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace("инж/скр", "инж./скр") %>%      #ИЗМЕНЕНИЕ: ДОБАВЛЕНО 
      str_replace_all("/св и несв", "/св. и несв") ->
      add
    
    all_words <<- append(all_words, add[-length(add)])
  })
})

paste0("http://www.makedonski.info/show/", all_words) %>% 
  str_replace_all(" ", "%20") ->
  all_words

# get dectionary entrance -------------------------------------------------

entrance <- data_frame(all_words,
                       flexion = character(length(all_words)),
                       grammar = character(length(all_words)),
                       definition = character(length(all_words)),
                       translation = character(length(all_words)),
                       used = character(length(all_words)),
                       example = character(length(all_words)),
                       semem_links = character(length(all_words)),
                       idiom = character(length(all_words)),
                       derivation = character(length(all_words))
)

entrance <- entrance[-1,]

sapply(seq_along(entrance$all_words), function(k){
  source <- read_html(entrance$all_words[k])
  
  source %>%
    html_nodes('#main_lexem_view > div.flexion') %>%
    html_text() ->>
    entrance$flexion[k]
  
  source %>%
    html_nodes('#main_lexem_view > div.grammar') %>%
    html_text() ->>
    entrance$grammar[k]
  
  source %>%
    html_nodes('#main_lexem_view > div.definition > div.semem-links') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$definition[k]
  
  source %>%
    html_nodes('#categories > div') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$translation[k]
  
  #поедет в многозначных словах но мы это оставляем 
  source %>%
    html_nodes('#categories > span') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$used[k]
  
  source %>%
    html_nodes('#main_lexem_view > div:nth-child(4) > div.example') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$example[k]
  
  source %>%
    html_nodes('#main_lexem_view > div:nth-child(3) > div.semem-links') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$semem_links[k]
  
  source %>%
    html_nodes('#main_lexem_view > div:nth-child(10)') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$idiom[k]
  
  source %>%
    html_nodes('#main_lexem_view > div.prepend-2.last.derivation') %>%
    html_text() %>% 
    paste0(collapse = "NEXT_MEANING") ->>
    entrance$derivation[k]
})


# remove spaces and \n\t
entrance %>% 
  mutate(flexion = str_replace_all(flexion, "\n|\t", ""),
         grammar = str_replace_all(grammar, "\n|\t", ""),
         definition = str_replace_all(definition, "\n|\t", ""),
         translation = str_replace_all(translation, "\n|\t", ""),
         used = str_replace_all(used, "\n|\t", ""),
         example = str_replace_all(example, "\n|\t", ""),
         semem_links = str_replace_all(semem_links, "\n|\t", ""),
         idiom = str_replace_all(idiom, "\n|\t", ""),
         derivation = str_replace_all(derivation, "\n|\t", ""),
         flexion = str_replace_all(flexion, "\\s+", " "),
         grammar = str_replace_all(grammar, "\\s+", " "),
         definition = str_replace_all(definition, "\\s+", " "),
         translation = str_replace_all(translation, "\\s+", " "),
         used = str_replace_all(used, "\\s+", " "),
         example = str_replace_all(example, "\\s+", " "),
         semem_links = str_replace_all(semem_links, "\\s+", " "),
         idiom = str_replace_all(idiom, "\\s+", " "),
         derivation = str_replace_all(derivation, "\\s+", " "),
         word = str_replace(str_replace(all_words, ".*?/.*?/.*?/.*?/", ""), "/", ", "),
         word = str_replace_all(word, "%20", " ")) ->
  entrance

write_tsv(entrance, "macedonian_у-ш.tsv")

t1 <- read_tsv("macedonian_а-г.tsv")
t2 <- read_tsv("macedonian_д-ѕ.tsv")
t3 <- read_tsv("macedonian_и-њ.tsv")
t4 <- read_tsv("macedonian_о-ќ.tsv")
t5 <- read_tsv("macedonian_у-ш.tsv")

final_df <- rbind(t1, t2, t3, t4,t5)
final_df %>%
  rowwise() %>%
  mutate(dict_entry = unlist(str_split(word, ","))[1]) ->
  final_df

colnames(final_df)[1] <- "link"
colnames(final_df)[3] <- "POS"
colnames(final_df)[6] <- "usage"

write_tsv(final_df, "macedonian_dict.tsv")
final_df <- read_tsv("macedonian_dict.tsv")

# rowwise say you whether there is "NEXT_MEANING" stuff
final_df$next_meaning <- NA
sapply(seq_along(final_df$link), function(i){
  final_df$next_meaning[i] <<- TRUE %in% str_detect(final_df[i,], "NEXT_MEANING")
})


