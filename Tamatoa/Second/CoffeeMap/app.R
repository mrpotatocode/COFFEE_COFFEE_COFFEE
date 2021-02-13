#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#librarys
library(tidyverse)
library(readxl)
library(here)
library(ggplot2)
library(ggradar)
library(ggthemes)
library(rworldmap)

#load data

#switch these to work local vs on shinyapps.io
#datafolder = "/Tamatoa/Second/CoffeeMap/data/" 
datafolder = "/data/"

#overall data load
overall_data <- read_xlsx(paste0(here(),datafolder, '33cups.xlsx'), sheet = "Overall")
#need an empty row
overall_empty = c(0,"Pick a Coffee from here to start!","","","","","","","","",0,"","","2017-01-01","","",0)
overall_data <- rbind(overall_empty,overall_data) 

#tasting notes data load
t_notes_data <- read_xlsx(paste0(here(),datafolder, '33cups.xlsx'), sheet = "T_Notes")
#need an empty row
t_notes_empty = c(0,0,"Sweet",0,0)
t_notes_data <- rbind(t_notes_empty,t_notes_data)

#ISO data
iso <- read_xls(paste0(here(),datafolder, 'iso_3digit_alpha_country_codes.xls'))

#preprocess
data <- inner_join(overall_data,t_notes_data, by="ID")

#reduce altitude
altitude <- 
    overall_data %>% 
    select(ID, Roaster, Country, Name, Elevation) %>% 
    unite(Roaster, Country, Name) %>% 
    rename(group = Roaster) %>% 
    relocate(group, .after = ID) %>% 
    filter(!is.na(Elevation)) %>% 
    rename(value = Elevation) %>% 
    mutate(value = str_replace_all(value, "\\+", "") ,.keep=c("unused")) %>% 
    mutate(value = str_replace_all(value, "m", "") ,.keep=c("unused")) 

#math on ranges (1800-1900 = 1850)
altitude$value = sapply(strsplit(altitude$value, split = "-", fixed = TRUE), function(k) mean(as.numeric(k)))



#build UI
ui <- fluidPage(

    titlePanel("My Favourite Coffees"),

    fluidRow(column(6,
           selectInput("code", "Coffee",
                       choices = setNames(overall_data$ID, 
                                          overall_data$Coffee),
                       width = "100%")
            )
           
        ),
    
    fluidRow(
        column(4, tableOutput("table"))
            ),
    
    fluidRow(
        column(8, plotOutput("map"))
            ),
    
    fluidRow(
        column(6,plotOutput("wheel")),
        #column(6,tableOutput("t_notes_test"))
        column(6,plotOutput("triange"))
             )
)

#build server functions
server <- function(input, output) {
    
    selected <- reactive(overall_data %>% filter(ID == input$code) %>% select(-"BrewDate"))
    
    
    t_notes_radar <- reactive({ 
        t_notes_data %>% 
        select(-"X-Axis",-"Y-Axis",-"Ord") %>%  
        pivot_wider(names_from=TastingNote, values_from = Result) %>% 
        inner_join((overall_data %>% select(ID, Roaster, Country, Name)),.) %>% 
        unite(Roaster, Country, Name) %>% 
        rename(group = Roaster) %>% 
        select(-"NA") %>% 
        #mutate_each(funs(scales::rescale), -group) %>% 
        relocate(group, .before = Sweet) %>% 
        filter(ID == input$code)
        })
        
    t_notes_head <- reactive({t_notes_radar()  %>% select(-group) %>% mutate_if(is.character,as.numeric)})
    
    
    output$wheel <- renderPlot({
        ggradar(t_notes_head(),
                font.radar = "Times", axis.label.size = 4, plot.legend = TRUE, values.radar= c(1,3,5),
                grid.min=1, grid.mid = 3, grid.max = 5, grid.label.size = 4, 
                group.point.size = 3, group.colours = "#000000")
    })
    
    iso_lookup <- reactive({
        selected() %>% select(ID, Country) %>%
            rename(Definition = Country) %>% 
            merge(iso,.)
        })
    
    varDF <- reactive({data.frame(country = iso_lookup()$`Code Value`, Country.of.Origin = iso_lookup()$Definition)  
        })
    
    Map <- reactive({joinCountryData2Map(varDF(), joinCode = "ISO3",
                            nameJoinColumn = "country")
        })

    output$table <- renderTable(selected())
    
    output$map <- renderPlot({mapCountryData(Map(), nameColumnToPlot="Country.of.Origin", catMethod = "categorical",
                    missingCountryCol = gray(.8), aspect = 1)},res = 72)

    alt_min <- reactive(min(altitude[,"value"]))
    alt_max <- reactive(max(altitude[,"value"]))
    adj <- reactive((alt_max() - alt_min()) /10)
    max_adj <- reactive(alt_max() + adj())
        
    pos <-  reactive(altitude %>% filter(ID == input$code) %>% select("value"))
    height  <-  reactive((pos() - (alt_min())) /((max_adj()) - (alt_min())))
    a <-  reactive((height()*sin(0.5236)/sin(1.0472))*.875)
    
    IDx <- reactive(rep(c(0,input$code), each = 4))
    xx <- reactive(c(0, 1, .5, 0, 0, 1,(1-a()),a()))
    yy <- reactive(rep(c(alt_min(),alt_min(),max_adj(),alt_min(),
                     alt_min(),alt_min(),pos(),pos()), each = 1))
    
    positions <- reactive(tibble(
         ID = IDx(),
         x = xx(),
         y = yy()))
     
    data_poly <- reactive(merge(altitude, positions(), by = c("ID")))
    datapoly <- reactive(data_poly() %>% mutate(value = as.integer(value))
                         %>% mutate(x = as.numeric(x))
                         %>% mutate(y = as.numeric(y)))
    
    
    output$t_notes_test <- renderTable(datapoly())
    output$triange <- renderPlot({ggplot(datapoly(), aes(x = x, y = y)) +
        geom_polygon(aes(fill = value, group = ID)) +
        scale_fill_gradient(high = "#003d00", low = "#006000", na.value = NA, guide=FALSE) +
        ggtitle(paste0(paste0("Elevation: ",  datapoly()$value)[5], " MASL")) +
        theme_void()
        })

}

# Run the application 
shinyApp(ui = ui, server = server)
