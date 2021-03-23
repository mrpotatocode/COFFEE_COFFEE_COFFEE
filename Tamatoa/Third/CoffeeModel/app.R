#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

###librarys
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(tidyverse)
library(here)
library(tidymodels)
library(rvest)
library(data.table)
library(readxl)
library(SnowballC)


###load data
setwd(here::here())
#function for fread (data.table)
read_plus <- function(flnm) {
    read_csv(flnm) %>% 
        mutate(filename = flnm) %>% 
        rename_with(str_to_title)}

#tasting note folder
tasting_folder = "inputs/data/Conformed/"

SCAA_Notes = 
    #load tasting notes
    read_xlsx(here::here(tasting_folder,'SCAA_TastingNotes.xlsx'))

#load all from Automatic_Drip (coffee data)
raw_data = 
    list.files(path = "../Automatic_Drip/R/outputs/",
               pattern = "*.csv",
               full.names = T) %>% 
    map_df(~read_plus(.))

###Data Processing
#this will resolve the Sey issue, when done
oldest_sey = raw_data %>% unite(Variety, c(Variety, Varietal), na.rm = TRUE) %>% 
    unite(Processing, c(Processing, Process), na.rm = TRUE) %>% 
    filter(Filename %like% 'SeyArchive') %>% group_by(Filename) %>% arrange_(~ desc(Filename)) %>% filter(group_indices() == 1) %>% ungroup()

newer_seys = raw_data %>% unite(Variety, c(Variety, Varietal)) %>% 
    unite(Processing, c(Processing, Process)) %>% 
    filter(Filename %like% 'SeyArchive') %>% group_by(Filename) %>% arrange_(~ desc(Filename)) %>% filter(group_indices() != 1) %>% ungroup()

sey_achive = oldest_sey #plus the anti join logic later
sey_achive = sey_achive %>% select(-Url, -Filename, -J, -Procesing) %>% 
    mutate(Tastingnotes =  str_to_lower(Tastingnotes)) %>% 
    separate(Tastingnotes, into = c("TastingNote1","TastingNote2","TastingNote3"), sep = ",",  remove = FALSE)

ripes = tibble(words=c('red','yellow','pink','black','white','orange'))

data = raw_data %>% filter(Filename %like% 'SeyArchive' == FALSE) %>% unite(Variety, c(Variety, Varietal), na.rm = TRUE) %>% 
    unite(Processing, c(Processing, Process), na.rm = TRUE) %>% 
    select(-Url, -Filename, -J, -Procesing) %>% distinct() %>% 
    mutate(Tastingnotes =  str_to_lower(Tastingnotes)) %>% 
    separate(Tastingnotes, into = c("TastingNote1","TastingNote2","TastingNote3"), sep = ",",  remove = FALSE)
data = rbind(data,sey_achive)

data = data %>%
    mutate(TastingNote1 = str_trim(TastingNote1, side = c("both", "left", "right"))) %>% 
    mutate(TastingNote1 = wordStem(TastingNote1)) %>% 
    mutate(TastingNote2 = str_trim(TastingNote2, side = c("both", "left", "right"))) %>% 
    mutate(TastingNote2 = wordStem(TastingNote2)) %>% 
    mutate(TastingNote3 = str_trim(TastingNote3, side = c("both", "left", "right"))) %>% 
    mutate(TastingNote3 = wordStem(TastingNote3)) 

data = data %>% mutate(Processing = str_to_lower(Processing)) %>% 
    mutate(Red = str_extract(Processing, "red")) %>% 
    mutate(Yellow = str_extract(Processing, "yellow")) %>%
    mutate(Pink = str_extract(Processing, "pink")) %>%
    mutate(Black = str_extract(Processing, "black")) %>%
    mutate(White = str_extract(Processing, "white")) %>% 
    mutate(Orange = str_extract(Processing, "orange")) 

data = data %>% mutate(Variety = str_to_lower(Variety)) %>% 
    mutate(Red = ifelse(is.na(data$Red), str_extract(Variety, "red"), Red)) %>% 
    mutate(Yellow = ifelse(is.na(data$Yellow), str_extract(Variety, "yellow"), Yellow)) %>%
    mutate(Pink = ifelse(is.na(data$Pink), str_extract(Variety, "pink"), Pink)) %>%
    mutate(Black = ifelse(is.na(data$Black), str_extract(Variety, "black"), Black)) %>%
    mutate(White = ifelse(is.na(data$White), str_extract(Variety, "white"), White)) %>% 
    mutate(Orange = ifelse(is.na(data$Orange), str_extract(Variety, "orange"), Orange)) 

data = data %>% mutate(Altitude = sapply(strsplit(data$Altitude, split = "-", fixed = TRUE), function(k) mean(as.numeric(k))))

data$Processing = str_replace_all(data$Processing, str_c("\\b", str_c(ripes$words, collapse = "\\b( )?|"), "\\b( )?"), "")
data$Variety = str_replace_all(data$Variety, str_c("\\b", str_c(ripes$words, collapse = "\\b( )?|"), "\\b( )?"), "")

data = data %>% mutate(Processing = str_replace_all(str_replace_all(str_replace_all(str_replace_all(
    Processing,", ", "|"), " - ","|"), "\\/","|"), " and ","|")) %>%   
    separate(Processing, into = c("Processing1"), sep = "\\|",  remove = FALSE)

data = data %>% mutate(Variety = str_replace_all(str_replace_all(str_replace_all(str_replace_all(
    Variety,", ", "|"), " and ","|"), " \\+ ","|"), "and ","|")) %>%   
    separate(Variety, into = c("Variety1","Variety2","Variety3","Variety4"), sep = "\\|",  remove = FALSE)

data = data %>%unite(Ripeness, c(Red, Yellow, Pink, Black, White, Orange), na.rm=TRUE)

data = data %>% mutate(Country = str_to_lower(Country))

SCAA_Notes <- SCAA_Notes %>% 
    mutate(l_note =  str_to_lower(Note))%>% 
    mutate(l_note = str_trim(l_note, side = c("both", "left", "right"))) %>% 
    
    #remove plurals, basic stemming
    mutate(l_note = wordStem(l_note)) 


merged_data =
    sqldf::sqldf("select d.*, n1.Trait as Trait1, n1.[Group] as Group1
              ,n2.Trait as Trait2, n2.[Group] as Group2
              ,n3.Trait as Trait3, n3.[Group] as Group3              
              from data d
              left join SCAA_Notes n1 on n1.l_note = d.TastingNote1
              left join SCAA_Notes n2 on n2.l_note = d.TastingNote2
              left join SCAA_Notes n3 on n3.l_note = d.TastingNote3")

#model <- readRDS("outputs/models/xboost_coffee_trait1.rds")
#model <-  readRDS("outputs/models/xboost_coffee_group1.rds")
model <-  readRDS("outputs/models/xboost_coffee_group_all.rds")

###build UI
ui <- dashboardPage(
    header = dashboardHeader(title = "Tasting Note Prediction App"),
    
    sidebar = dashboardSidebar(
        sidebarMenu(
            #id = "tabs",
            menuItem("Tasting Notes", tabName = "Notes", icon = icon("coffee"), badgeLabel = "new", badgeColor = "green"),
            menuItem("Coffee Details", tabName = "Details", icon = icon("info-circle"))
        )),
    
    body = dashboardBody(
        tabItems(
            tabItem(tabName = "Notes",
            
                shinydashboard::box(h3("First: Make Your Parameter Selections"), width = 12),

                box(title = "Select a Country", selectInput("v_country", label = "Country",
                                choices = sort(c('Honduras','Guatemala','Kenya','Colombia','Costa Rica','Brazil','Mexico',
                                            'Burundi','Nicaragua','Papua New Guinea','Rwanda','Peru','Panama','Ethiopia',
                                            'El Salvador','Tanzania','Bolivia','Ecuador'))), width = 4),
            
                box(title = "Select a Variety", selectInput("v_var", label = "Variety",
                                choices = sort(c('Catuai','Caturra','Castillo','Bourbon','Pacas','SL28','Heirloom',
                                            'Typica','Colombia','Ethiopia Heirloom','Ethiopian Landrace','V. Colombia'))), width = 4),
            
                box(title = "Select a Process", selectInput("v_proc",  label = "Processing",
                                choices = sort(c('Honey','Washed','Natural','Sundried','Fully Washed'))), width = 4),
            
                shinydashboard::box(h3("Then: Wait for Model Outcomes"), width = 12),
                
                fluidRow(column(12,
                    valueBoxOutput("Note1_prediction"),
                    valueBoxOutput("Note2_prediction"),
                    valueBoxOutput("Note3_prediction")
                )),
                
                shinydashboard::box(h4("Change Parameter Selections at any Time"), width = 12),
            ),
            
            tabItem(tabName = "Details",
                    shinydashboard::box(h3("My Favourite Coffees"), width = 12)
        
            )
        )
    ),
    footer = dashboardFooter(
        left = "MrPotatoCode",
        right = "2021"
    )
)

###build server functions
server <- function(input, output) {

    selected <- reactive({tibble("Variety1" = str_to_lower(input$v_var),
                                "Processing1" = str_to_lower(input$v_proc),
                                "Country" = str_to_lower(input$v_country))})
    
    prediction <- reactive(predict(
        model,
        selected(),
        type = "prob"
    ) %>% 
        gather() %>% 
        arrange(desc(value)) %>% 
        top_n(3) %>% 
        rename("note" = key))
    
    #prediction_color <- if_else(prediction$.pred_class == "Adelie", "blue", 
    #                           if_else(prediction$.pred_class == "Gentoo", "red", "yellow"))
    
    output$Note1_prediction <- renderValueBox({

        valueBox(
            value = paste0(round(100*prediction()$value[1], 0), "%"),
            subtitle = paste0("Tasting Group: ", prediction()$note[1] %>% str_remove(".pred_")),
            #color = prediction_color,
            icon = icon("lemon")
        )
    })
    
    output$Note2_prediction <- renderValueBox({
        
        valueBox(
            value = paste0(round(100*prediction()$value[2], 0), "%"),
            subtitle = paste0("Tasting Group: ", prediction()$note[2] %>% str_remove(".pred_")),
            #color = prediction_color,
            icon = icon("seedling")
        )
    })
    
    output$Note3_prediction <- renderValueBox({
        
        valueBox(
            value = paste0(round(100*prediction()$value[3], 0), "%"),
            subtitle = paste0("Tasting Group: ", prediction()$note[3] %>% str_remove(".pred_")),
            #color = prediction_color,
            icon = icon("cookie")
        )
    })
}

###run the application 
shinyApp(ui = ui, server = server)
