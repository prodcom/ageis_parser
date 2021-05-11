# National Greenhouse Gas Inventory parser (Post configuration and metadata)
# Auth: H McMillan
# License: MIT


# Define POST config
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
  'Cookie'           = 'ASP.NET_SessionId=cmmsnf1wkh4c0ocij1qagcln'
)

aegis_form_options <- function(year, location, gas)
  
  list(
    'ctl00$ScriptManager1' = 'ctl00$cph1$UpdatePanel1|ctl00$cph1$ButtonViewEmission',
    'ctl00$cph1$WebUserControlInventoryYearSelection1$InventoryYearDropDownID' = as.character(year),
    'ctl00$cph1$WebUserControlLocation1$LocationDropDownID' = '3',
    'ctl00$cph1$selectionFuelUNFCCC' = '1',
    'ctl00$cph1$selectionSectorUNFCCC' = paste(1:5509, collapse = ";"),
    'ctl00$cph1$selectionGasUNFCCC' = '33',
    'ctl00$cph1$selectionEmissionUNFCCC' = '13',
    '__EVENTTARGET' = '',
    '__EVENTARGUMENT' = '',
    '__LASTFOCUS' = '',
    '__VIEWSTATE' = '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',
    '__VIEWSTATEGENERATOR' = '0B5B08D9',
    '__EVENTVALIDATION' = 'cVWhXrnmG0hSDFU5FPHhmO/bEyrM5oYKmHalL3BLD5IdVWtNCkjCDNZKHsafxi2oBKxkGNsDotgLH0gCCelAbLmPAsjovxnh2ZvLpxcmkwEz9Gs2m3/+u5Rgi+C/yaPyJ4IKJ11yF9o9dxTy+ZECH5kl3R3yDkRpu/Lf1iE7+yvcHqOBp6y+U+DT9D3Y6AxKP7iA6vNMbthQygDIfRDHGuHOR2ns+Lr/XYwJG/vr5uKkPRItn+LvAi3uYhrENsFXY0ep5HX00FLPt5RXWmzuxyfj+2vwdiI1yQSZ8M77WGmKCQO+OkGMkcu2Eaw2qfzB/Pv/CPmvsN9MBEOQhvjgGBqhchR8tjNJQpDj30h5h2KjfqpHXNXJtvsKGhVar7FI18kwG4eAJrZ4+ERnljNURL2UK/EGt26rHHypTh7ebl160oqnL6G3EYArJy3eRqrtcCRUQIEMZVujZbNOSlGLB5Bk/KCRkLVeSWKkYuKjOuv8PX1iCfnLf4lkzvhuNnoQHRi7IjZk+DHDY6fPh9ECe25LO/XmEQz7cStpd9O9qE2jMFd/Gme1esf3mfwKUYZCZLENN7l1Deu95wmaJS5yAXEaqLc0LMVpzFEe4l4Fig5QDAFkdwuN7+D5a9BQdXiiAQXhpGw4AUYb112SkP6MynOXxP4kNJkRB0Q4faFEj3uce2RUsBW0KXnVZ6DY0vRvV8nV1cD8FPTEP3SHA0O74SX5oZ2z/COPurdaGYaAg+jwZ1fXC9N726G682jLLLxvc86ZXLOduE+Papsxd9jfcaTM/A2IDqBVuE5kxoWgnJ3J2FUXh4gkTNsAwvEa10Ej/0pvHM5NsgNym5SXDZurQPPHT/rRYvBNmkDdRoog8tXCVQ9mXIOfBz296TWLAycUbdqeVKhXBbFdsAigyuYbOmIVQQF9562/9PLzm8JFSLbydvt0ce8LNrwuBPzFa1DiyagFJmdONzTpEu2oxFYykt6P6Qn5gTib2NiGm6Bd4Avymij0ncscHXLK3Sy4GpVeKDoQRzUmg3A3k+plhNZRouPGO3xdh4YfRg+V9LWG0zPM+Y/GXO4dGvMTHZpT1clJj7SM6lItQmWl5RtwLsDL8GVPe5ezXuqDHF8TecTaiY88tpGHV4rAF+sTflNG5/pV',
    '__VIEWSTATEENCRYPTED' = '',
    '__ASYNCPOST' = 'true',
    'ctl00$cph1$ButtonViewEmission' = 'Click to View Emissions'
  )