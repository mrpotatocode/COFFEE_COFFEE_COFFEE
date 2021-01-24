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
    titlePanel("Chapter 2 Exercises"),
    
    
    # Main panel for displaying outputs 
    
    mainPanel(
        #input
        sliderInput("x", label = "If x is", min = 1, max = 50, value = 30),
        "then x times 5 is",
        h3(textOutput("product")),
        
    )
    
    
)

server <- function(input, output, session) {
    output$product <- renderText({ 
        input$x * 5
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
