# National Greenhouse Gas Inventory parser
# Auth: H McMillan
# License: MIT

# This script is based off the XMLHttpRequest that is used to update the 
# National Greenhouse Gas Inventory website. The POST request returns a html
# table which can be parsed. All parts of the POST request are verbatim copies 
# of a manually executed update except for the year, location, gas type and 
# industries which are modified for as per the function call.

# NOTE: you may need to source this file instead of the usual run command as it
#       contains some strings longer than the parser allows (lines 81 and 83).


# Packages
library(tidyverse)
library(httr)
library(rvest)
library(pbapply)
library(snow)




# Error handling
`%iferror%` <- function(a, b) tryCatch({a}, error = function(e){b})




# Load gas type and location metadata
gas_table <- read_csv("API metadata/gases.csv")
location_table <- read_csv("API metadata/locations.csv")




# Define POST URL and headers
url <- 'https://ageis.climatechange.gov.au/'

ageis_headers <- c(
  'Connection'       = 'keep-alive',
  'sec-ch-ua'        = '" Not A;Brand";v="99", "Chromium";v="90", "Google Chrome";v="90"', 
  'DNT'              = '1',
  'sec-ch-ua-mobile' = '?0', 
  'User-Agent'       = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36',
  'Content-Type'     = 'application/x-www-form-urlencoded; charset=UTF-8',
  'Cache-Control'    = 'no-cache',
  'X-Requested-With' = 'XMLHttpRequest', 
  'X-MicrosoftAjax'  = 'Delta=true',
  'Accept'           = '*/*',
  'Origin'           = 'https://ageis.climatechange.gov.au',
  'Sec-Fetch-Site'   = 'same-origin',
  'Sec-Fetch-Mode'   = 'cors',
  'Sec-Fetch-Dest'   = 'empty', 
  'Referer'          = 'https://ageis.climatechange.gov.au/',
  'Accept-Language'  = 'en-GB,en-US;q=0.9,en;q=0.8',
  'Cookie'           = 'ASP.NET_SessionId=djsldjogtixt0lle2o4uhce2'
)




# Define function for post form options
aegis_form_options <- function(year, location, gas){
  
  location_number <- location_table$index[match(location, location_table$location)]
  gas_number <- gas_table$index[match(gas, gas_table$gas)]
  
  list(
    'ctl00$ScriptManager1' = 'ctl00$cph1$UpdatePanel1|ctl00$cph1$ButtonViewEmission',
    'ctl00$cph1$WebUserControlInventoryYearSelection1$InventoryYearDropDownID' = as.character(year),
    'ctl00$cph1$WebUserControlLocation1$LocationDropDownID' = location_number,
    'ctl00$cph1$selectionFuelUNFCCC' = '1',
    'ctl00$cph1$selectionSectorUNFCCC' = paste(1:5509, collapse = ";"),
    'ctl00$cph1$selectionGasUNFCCC' = gas_number,
    'ctl00$cph1$selectionEmissionUNFCCC' = '13',
    '__EVENTTARGET' = '',
    '__EVENTARGUMENT' = '',
    '__LASTFOCUS' = '',
    '__VIEWSTATE' = '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',
    '__VIEWSTATEGENERATOR' = '0B5B08D9',
    '__EVENTVALIDATION' = 'zZMXQIdaORTekEGNyn1LA5ShGH7gC2zWLxIAZsRWbpQqYguBNbCRLBSxMDQNBu1A1Ott8pXZYSLapU+Wh7r8gXaYF25HAfuU4Knh5bHHRaPchdIFXh7OCju/fHKQLtEigVB4VsFCH2NJh6vpM7ayAnPbidzAs1OgAXtHSOXB3TnIT28tT/8EKK9sDSLTpkfROePFL1p1MEkOFDMJmgWLXs10tjHO9OVhvVJvGKZuej4La9wOLIc17KEufbvEI77lTjR/VjIPktBol/kiq4bfqWIdAmfL8eOWoyppGLj8xwoI7oF8Jc92xi/Wj+2/QKErCVtHU75Th9ydlvgCJhi2mJquX6u2CxlT6P1wrzR6r0NAqS4B6IwY/qyuQNahKfAH/o3M+RbZBo3aHP5gEm+VrBJqNcN7C/GidVEJZW6+Lz/3Z2Ot1LsJ0jfu6fXLihlrpVIBBpxIu52DB00gA3akjbyXu3zQ1XI1aFdNJCVLbDDRS0/maXxJL3b8+pfPQDg1Yf5L9w3CeUjXdKnLs8kMirpK1MFAJXvIgr5GR62A7hUl3XoFTfUDjYVCvroqGlyIxgRPP+7dLnn9ZefJgQp5BRAn0V2Vnw+A/50pxoVYod0w7K4ARpjWIq4xspj1tJtU8N4s17ULGbH6kcwedU/6rR+a0ANZjr/hKzEQ6nBLiw1v3EeCjWHpyEx/fAcUyCaTRJoD2KMxS/R2K7toZja1zlWIJE6LzmRpFi4F1GLIdqSPXOfTs89Q+euzbIBKpND2gsjfIVAW0BxRoVjPE0nitvF4JlyCh4HRPJ40WEBucfd/IkTOdkJcqdXtuv4nT+PGD91N54uHotQ9p9dH8mdNXbLmM4rgOKDq1LHQd6suSfwL497/Q/rSxDdF2+yInC22l0nzITomPsBDwMT86sdyyYtCsfRo3nutdALP5SziP4RL6TGSNCzC2zvo7y4xLOI5PAxj1I0bOA0901OUehC9iKvMAlI/1+gZq/jM6o1xTOhzSWywMqh4Qd+UOXfpkT5UWtogjo2596iC8mljnwaDaeOQ4sTU66x/TAErC8UdUTdiiWaFR4oCy6KtyhkgRxes9iuoPQ43Tmx+Nn9GmbGUbkgTnYmBz8xOK/m588G37hBu9OB3IFgkjj5HC/IURHsB',
    '__VIEWSTATEENCRYPTED' = '',
    '__ASYNCPOST' = 'true',
    'ctl00$cph1$ButtonViewEmission' = 'Click to View Emissions'
  )
}




# Define function to run POST and return dataframe
ageis_table <- function(year, location, gas){
  df <- POST(
    url = url,
    add_headers(.headers = ageis_headers),
    body = aegis_form_options(year = year, location = location, gas = gas),
    encode = "form"
    ) %>% 
    read_html() %>% 
    html_element("#ctl00_cph1_GridViewReport") %>% 
    html_table() %iferror%
    return(NULL)
  
  df$year <- year
  df$location <- location
  df$gas <- gas
  
  return(df)
}  




# Define all plausible combinations of year, location and gas
all_options <- expand.grid(
  years = 1990:2019, 
  locations = location_table$location,
  gases = gas_table$gas
)




# Initialize clusters for multithreaded scraping
cl <- makeCluster(parallel::detectCores(logical = T))
clusterEvalQ(cl, {library(tidyverse); library(httr); library(rvest)})
clusterExport(cl, c(
  "url", 
  "ageis_headers", 
  "aegis_form_options",
  "ageis_table",
  "all_options",
  "%iferror%",
  "gas_table",
  "location_table"
  )
)




# Run POST for all option combinations
all_data <- pblapply(
  1:nrow(all_options),
  function(i){
    ageis_table(
      all_options$years[i],
      all_options$locations[i],
      all_options$gases[i]
      )
  },
  cl = cl
  )




# Close cluster
stopCluster(cl)




# Row bind and clean output data
all_data <- all_data %>%
  bind_rows %>%
  rename(
    sector_code = 1,
    sector = Category,
    gigagrams = `Gg (1,000 Tonnes)`
    ) %>%
  mutate(
    sector_level = sector_code %>% str_remove_all("[:punct:]") %>% nchar(),
    gigagrams = gigagrams %>% str_remove_all(",") %>% as.numeric(),
    gas = gas %>% str_to_lower() %>% str_replace_all("[:blank:]", "_")
  ) %>%
  select(year, location, sector_level, sector_code, sector, gas, gigagrams) %>%
  pivot_wider(names_from = gas, values_from = gigagrams)




# Separate sector levels
sector_total <- all_data %>% filter(sector_level == 0) %>% select(-sector_level)
sector_lvl_1 <- all_data %>% filter(sector_level == 1) %>% select(-sector_level)
sector_lvl_2 <- all_data %>% filter(sector_level == 2) %>% select(-sector_level)
sector_lvl_3 <- all_data %>% filter(sector_level == 3) %>% select(-sector_level)
sector_lvl_4 <- all_data %>% filter(sector_level == 4) %>% select(-sector_level)
sector_lvl_5 <- all_data %>% filter(sector_level == 5) %>% select(-sector_level)




# Save all data
write_csv(all_data, "data/all data.csv")
write_csv(sector_total, "data/sector_total.csv")
write_csv(sector_lvl_1, "data/sector level 1.csv")
write_csv(sector_lvl_2, "data/sector level 2.csv")
write_csv(sector_lvl_3, "data/sector level 3.csv")
write_csv(sector_lvl_4, "data/sector level 4.csv")
write_csv(sector_lvl_5, "data/sector level 5.csv")