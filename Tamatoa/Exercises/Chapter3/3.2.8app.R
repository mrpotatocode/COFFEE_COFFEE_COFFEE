#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

ui <- fluidPage( 
    
    # Application title
    titlePanel("Chapter 3 Exercises"),
    
    
    # Main panel for displaying outputs 
    
    mainPanel(
        #3.2.8.1
        textInput("name", label=NULL,placeholder = "What's Your Name"),
        
        #3.2.8.2
        sliderInput("x", label = "When should we deliver"
                    , min = as.Date("2020-09-16"), max = as.Date("2020-09-23")
                    , value = as.Date("2020-09-17"), timeFormat = "%F", animate = FALSE),
        
        #3.2.8.3
        selectInput("animal", "What animals are you moving?", 
                    list(`Mammals` = list("Doggo", "Kitty", "IsThataHorse"),
                         `Reptiles` = list("Snek", "LizardWizard", "KingGizzard"),
                         `Rodent` = list("Gerbil", "Mouse", "Smooshy","MrPrickles"))
                    ,multiple = TRUE),
        
        #3.2.8.4
        sliderInput("y", label = "how much does it weigh"
                    , value = 150, min = 0, max = 1000, step = 5, animate = TRUE, interval),
        
        # Output: Formatted text for caption
        h3(textOutput("caption")),
        
    )
    
)


# Define server logic to plot vars against mpg
server <- function(input, output) {
    
    
    
    output$caption <-  renderText({
        paste0("Okay ", input$name
              ,", we will see you on ", input$x
              ,", to pick up your ", input$animal
              ,', weighing ', input$y, " pounds")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
