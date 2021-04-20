library(RColorBrewer)
library(rworldmap)
library(rgdal)
library(treemap)

###for rworldmap data
datafolder = "/Tamatoa/Second/CoffeeMap/data/" 
iso <- read_xls(paste0(here(),datafolder, 'iso_3digit_alpha_country_codes.xls'))

#join too the iso 3 digit codes
iso_lookup <- 
  data %>% 
  select(Country) %>%
  #update countries that didn't match to the table
  mutate(Country = str_to_title(Country)) %>% 
  mutate(Country = str_replace_all(Country, 'Tanzania', 'Tanzania, United Republic of'),
         Country = str_replace_all(Country, 'Democratic Republic Of The Congo', 'Congo, The Democratic Republic of'),
         Country = str_replace_all(Country, 'Sumatra', 'Indonesia'),) %>% 
  count(Country) %>% 
  rename(Definition = Country) %>% 
  merge(iso,.)

#join using joinCountryData2Map
Map <- joinCountryData2Map(iso_lookup, joinCode = "ISO3", nameJoinColumn = "Code Value")

#use robinson projection
Map <- spTransform(Map, CRS=CRS("+proj=robin +ellps=WGS84"))

#set the relevent countries from the data (the rest will be grey)
xylims <- Map[Map$NAME %in% str_to_title(data$Country),]

#set the colour
colourPalette <- brewer.pal(5,'YlOrBr')


###for treemap data
tree <- unite(prep_data %>% mutate_all(funs(str_to_title(.))) %>% 
                filter(Country == 'Costa Rica'), ItemSet, Country,Variety1,Processing1, sep = " + ")