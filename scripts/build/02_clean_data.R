library(tidyverse)
library(data.table)
library(SnowballC)

#SEY -- its still a bit funky, this might need some additional work later
#currently we are just loading the oldest Sey archive and not updating it
oldest_sey = raw_data %>% unite(Variety, c(Variety, Varietal), na.rm = TRUE) %>% 
  unite(Processing, c(Processing, Process), na.rm = TRUE) %>% 
  filter(Filename %like% 'SeyArchive') %>% group_by(Filename) %>% arrange_(~ desc(Filename)) %>% filter(group_indices() == 1) %>% ungroup()

#load newer_sey, currently not joined to project
newer_seys = raw_data %>% unite(Variety, c(Variety, Varietal)) %>% 
  unite(Processing, c(Processing, Process)) %>% 
  filter(Filename %like% 'SeyArchive') %>% group_by(Filename) %>% arrange_(~ desc(Filename)) %>% filter(group_indices() != 1) %>% ungroup()

#will need to create a sey 
# plyr::match_df(newer_seys %>% select(Roaster, Coffeename, Region, Producer, Variety, Processing), 
#                  oldest_sey %>%  select(Roaster, Coffeename, Region, Producer, Variety,Processing))

# anti_join(newer_seys %>% select(Roaster, Coffeename, Producer, Variety, Processing), 
#                    oldest_sey %>%  select(Roaster, Coffeename, Producer, Variety,Processing))

sey_achive = oldest_sey #plus the anti join logic later
#split tasting notes
sey_achive = sey_achive %>% select(-Url, -Filename, -J, -Procesing) %>% 
  mutate(Tastingnotes =  str_to_lower(Tastingnotes)) %>% 
  mutate(Tastingnotes = str_replace_all(Tastingnotes,"/", ", ")) %>% 
  separate(Tastingnotes, into = c("TastingNote1","TastingNote2","TastingNote3"), sep = ",",  remove = FALSE)

#make ripes tibble for later
ripes = tibble(words=c('red','yellow','pink','black','white','orange'))

# split tasting notes
data = raw_data %>% filter(Filename %like% 'SeyArchive' == FALSE) %>% unite(Variety, c(Variety, Varietal), na.rm = TRUE) %>% 
  unite(Processing, c(Processing, Process), na.rm = TRUE) %>% 
  select(-Url, -Filename, -J, -Procesing) %>% distinct() %>% 
  mutate(Tastingnotes =  str_to_lower(Tastingnotes)) %>% 
  mutate(Tastingnotes = str_replace_all(str_replace_all(Tastingnotes,"/", ", ")," & ",", ")) %>% 
  separate(Tastingnotes, into = c("TastingNote1","TastingNote2","TastingNote3"), sep = ",",  remove = FALSE)

#add sey archive
data = rbind(data,sey_achive)

#stem tasting groups
data = data %>%
  mutate(TastingNote1 = str_trim(TastingNote1, side = c("both", "left", "right"))) %>% 
  mutate(TastingNote1 = wordStem(TastingNote1)) %>% 
  mutate(TastingNote2 = str_trim(TastingNote2, side = c("both", "left", "right"))) %>% 
  mutate(TastingNote2 = wordStem(TastingNote2)) %>% 
  mutate(TastingNote3 = str_trim(TastingNote3, side = c("both", "left", "right"))) %>% 
  mutate(TastingNote3 = wordStem(TastingNote3)) 

#set encoding, e.g. rose ≠ rosé (rosé becomes ros'e)
data <- data %>% mutate(TastingNote1 = iconv(TastingNote1, to='ASCII//TRANSLIT'), 
                        TastingNote2 = iconv(TastingNote2, to='ASCII//TRANSLIT'),
                        TastingNote3 = iconv(TastingNote3, to='ASCII//TRANSLIT'))

#extract ripeness from processing
data = data %>% mutate(Processing = str_to_lower(Processing)) %>% 
  mutate(Red = str_extract(Processing, "red")) %>% 
  mutate(Yellow = str_extract(Processing, "yellow")) %>%
  mutate(Pink = str_extract(Processing, "pink")) %>%
  mutate(Black = str_extract(Processing, "black")) %>%
  mutate(White = str_extract(Processing, "white")) %>% 
  mutate(Orange = str_extract(Processing, "orange")) 

#extract ripeness from Variety, if ripeness isn't already present from processing 
data = data %>% mutate(Variety = str_to_lower(Variety)) %>% 
  mutate(Red = ifelse(is.na(data$Red), str_extract(Variety, "red"), Red)) %>% 
  mutate(Yellow = ifelse(is.na(data$Yellow), str_extract(Variety, "yellow"), Yellow)) %>%
  mutate(Pink = ifelse(is.na(data$Pink), str_extract(Variety, "pink"), Pink)) %>%
  mutate(Black = ifelse(is.na(data$Black), str_extract(Variety, "black"), Black)) %>%
  mutate(White = ifelse(is.na(data$White), str_extract(Variety, "white"), White)) %>% 
  mutate(Orange = ifelse(is.na(data$Orange), str_extract(Variety, "orange"), Orange)) 

#fix altitude to be integer (remove masl, m, etc), and average ranges (2000-2100) becomes 2050
data = data %>% mutate(Altitude  = str_replace_all(str_replace_all(str_replace_all(str_replace_all(str_replace_all(str_replace_all(
  Altitude, "m,", " -"), " masl", ""),"masl", "")," m", ""),"m", ""),' - ','-'))
data = data %>% mutate(Altitude = sapply(strsplit(data$Altitude, split = "-", fixed = TRUE), function(k) mean(as.numeric(k))))
data$Altitude[is.nan(data$Altitude)] <- NA

#remove ripeness from processing and variety
data$Processing = str_replace_all(data$Processing, str_c("\\b", str_c(ripes$words, collapse = "\\b( )?|"), "\\b( )?"), "")
data$Variety = str_replace_all(data$Variety, str_c("\\b", str_c(ripes$words, collapse = "\\b( )?|"), "\\b( )?"), "")

#split out multiple processes into a single Processing1 column (should include more later), e.g. Natural, Patio Dried
data = data %>% mutate(Processing = str_replace_all(str_replace_all(str_replace_all(str_replace_all(
  Processing,", ", "|"), " - ","|"), "\\/","|"), " and ","|")) %>%   
  separate(Processing, into = c("Processing1"), sep = "\\|",  remove = FALSE)

#address some common spelling errors in varieties
data = data %>% mutate(Variety = str_replace_all(str_replace_all(str_replace_all(str_replace_all(str_replace_all(str_replace_all(
  Variety, 'ethiopian','ethiopia'),'gesha','geisha'),'v. colombia','colombia'),'parainema','paraneima'),'sl 28','sl28'),'sl-28','sl28'))

#split out varieties into four columns 
data = data %>% mutate(Variety = str_replace_all(str_replace_all(str_replace_all(str_replace_all(str_replace_all(str_replace_all(str_replace_all(
  Variety,", ", "|"), " and ","|"), " \\+ ","|"), "and ","|")," & ","|"),"& ","|"), " - ","|")) %>%   
  separate(Variety, into = c("Variety1","Variety2","Variety3","Variety4"), sep = "\\|",  remove = FALSE)

#incorporate ripeness values
data = data %>%unite(Ripeness, c(Red, Yellow, Pink, Black, White, Orange), na.rm=TRUE)

#replace red_yellow with a single colour "orange" 
data = data %>% mutate(Ripeness = ifelse(Ripeness == 'red_yellow', "orange", Ripeness))

data = data %>% mutate(Country = str_to_lower(Country))

data <- data %>%
  mutate(across(everything(), ~ifelse(.=="", NA, as.character(.))))

#stem tasting notes table (SCAA_Notes)
SCAA_Notes <- SCAA_Notes %>% 
  mutate(l_note =  str_to_lower(Note))%>% 
  mutate(l_note = str_trim(l_note, side = c("both", "left", "right"))) %>% 
  
  #remove plurals, basic stemming
  mutate(l_note = wordStem(l_note)) %>% 
  
  #fix encoding
  mutate(l_note = iconv(l_note, to='ASCII//TRANSLIT'))

#merge data with SCAA_Notes -- include the hierarchy for all three tasting notes
merged_data =
  sqldf::sqldf("select d.*, n1.Trait as Trait1, n1.[Group] as Group1
              ,n2.Trait as Trait2, n2.[Group] as Group2
              ,n3.Trait as Trait3, n3.[Group] as Group3              
              from data d
              left join SCAA_Notes n1 on trim(n1.l_note) = trim(d.TastingNote1)
              left join SCAA_Notes n2 on trim(n2.l_note) = trim(d.TastingNote2)
              left join SCAA_Notes n3 on trim(n3.l_note) = trim(d.TastingNote3)
              ")

#remove any duplicates
merged_data = merged_data %>% distinct()

#select modelling columns
pre_prep_data = merged_data %>% select(Variety1, Processing1, Country, Group1, Group2, Group3 ) 

#remove low variance varieties
pre_prep_data = pre_prep_data %>% group_by(Variety1) %>% filter(!is.na(Variety1)) %>% 
  filter(n() >= 5) 

#remove low variance processes
pre_prep_data = pre_prep_data %>% group_by(Processing1) %>% filter(!is.na(Processing1)) %>%
  filter(n() >= 5)

#stack tasting notes
prep_data = melt(pre_prep_data, id.vars=1:3) #id.vars=1:4
prep_data = prep_data %>% drop_na(value) %>% select(-variable) %>% rename('TastingGroup' = value)