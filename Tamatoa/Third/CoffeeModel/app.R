
###librarys
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(tidyverse)
library(tidymodels)
library(xgboost)

###load data
prep_data <- read_csv("data/shiny_data.csv")

###load model
model <-  readRDS("data/xboost_coffee_group_all_v2.rds")

###preprocess drop downs
dropdowns <- prep_data %>% select(Variety1,Processing1,Country) %>% filter(!is.na(Country)) %>% distinct() %>% mutate_all(funs(str_to_title))

#unresolved spelling error,
dropdowns <- dropdowns %>% filter(!Country == "etbhiopia") 

###build UI
ui <- dashboardPage(
    
    skin = "green",

    header = dashboardHeader(title = "Tasting Note Prediction App"),
    
    sidebar = dashboardSidebar(
        sidebarMenu(
            #id = "tabs",
            menuItem("Tasting Notes", tabName = "Notes", icon = icon("coffee"), badgeLabel = "new", badgeColor = "green"),
            menuItem("Coffee Details", tabName = "Details", icon = icon("info-circle"), badgeLabel = "coming soon", badgeColor = "black")
        )),
    
    body = dashboardBody(
        tabItems(
            tabItem(tabName = "Notes",
            
                shinydashboard::box(h3("First: Make Your Parameter Selections"), width = 12),

                shinydashboard::box(h5("Varieties and Processes are Filtered to Relevant Countries"), width = 12),
                
                box(title = "Select a Country", selectInput("v_country",label = "Country",
                        choices = dropdowns %>% ungroup() %>% select(Country) %>% distinct() %>% 
                            arrange(Country)), width = 4),
                 
                box(title = "Select a Variety", uiOutput("varOutput"), width = 4),
                
                box(title = "Select a Process", uiOutput("procOutput"), width = 4),

                shinydashboard::box(h3("Then: Wait for Model Outcomes"), width = 12),
                
                fluidRow(column(12,
                    valueBoxOutput("Note1_prediction"),
                    valueBoxOutput("Note2_prediction"),
                    valueBoxOutput("Note3_prediction")
                )),
                
                shinydashboard::box(h5("Change Parameter Selections at any Time"), width = 12),
            ),
            
            tabItem(tabName = "Details",
                    shinydashboard::box(h3("My Favourite Coffees"), width = 12),
                    
                    shinydashboard::box(h3("In Progress!"), width = 12)
        
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

    df0 <- eventReactive(input$v_country,{
        dropdowns %>% filter(Country %in% input$v_country)
    })
    
    output$results <- renderTable({
        df0()})
    
    output$varOutput <- renderUI({
        selectInput("v_var", "Variety",sort(unique(df0()$Variety1)))
    })
    
    df1 <- eventReactive(input$v_var,{
        df0() %>% filter(Country %in% input$v_country)
    })
    
    output$procOutput <- renderUI({
        selectInput("v_proc", "Process",sort(unique(df1()$Processing1)))
    })
    
    
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
            color = 'green',
            icon = icon("lemon")
        )
    })
    
    output$Note2_prediction <- renderValueBox({
        
        valueBox(
            value = paste0(round(100*prediction()$value[2], 0), "%"),
            subtitle = paste0("Tasting Group: ", prediction()$note[2] %>% str_remove(".pred_")),
            color = 'green',
            icon = icon("seedling")
        )
    })
    
    output$Note3_prediction <- renderValueBox({
        
        valueBox(
            value = paste0(round(100*prediction()$value[3], 0), "%"),
            subtitle = paste0("Tasting Group: ", prediction()$note[3] %>% str_remove(".pred_")),
            color = 'green',
            icon = icon("cookie")
        )
    })
}

###run the application 
shinyApp(ui = ui, server = server)
