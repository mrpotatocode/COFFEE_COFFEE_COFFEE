library(RColorBrewer)
library(rworldmap)
library(rgdal)

datafolder = "/Tamatoa/Second/CoffeeMap/data/" 
iso <- read_xls(paste0(here(),datafolder, 'iso_3digit_alpha_country_codes.xls'))

iso_lookup <- 
  data %>% 
  select(Country) %>%
  mutate(Country = str_to_title(Country)) %>% 
  mutate(Country = str_replace_all(Country, 'Tanzania', 'Tanzania, United Republic of'),
         Country = str_replace_all(Country, 'Democratic Republic Of The Congo', 'Congo, The Democratic Republic of'),
         Country = str_replace_all(Country, 'Sumatra', 'Indonesia'),) %>% 
  count(Country) %>% 
  rename(Definition = Country) %>% 
  merge(iso,.)

Map <- joinCountryData2Map(iso_lookup, joinCode = "ISO3",
                           nameJoinColumn = "Code Value")

Map <- spTransform(Map, CRS=CRS("+proj=robin +ellps=WGS84"))

xylims <- Map[Map$NAME %in% str_to_title(data$Country),]
colourPalette <- brewer.pal(5,'YlOrBr')