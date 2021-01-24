#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)


ui <-  fluidPage(
    
    #3.4.6.3
    theme = shinytheme("sandstone"),
    
    titlePanel("Chapter 3 Exercises"),
    sidebarLayout(
        
        #3.4.6.2
        position = "right",
        sidebarPanel(
            numericInput("m", "Number of samples:", 2, min = 1, max = 100)
        ),
        
        #3.4.6.1
        mainPanel (
        fluidRow(
            column(10,
            plotOutput("hist")),
            
            column(10,
            plotOutput('scatter'))
        )
        )
    )
)


server <- function(input, output, session) {
    output$hist <- renderPlot({
        means <- replicate(1e4, mean(runif(input$m)))
        hist(means, breaks = 20)
    }, res = 96)
    
    #3.4.6.1
    output$scatter <- renderPlot(plot(1:5))
}
# Run the application 
shinyApp(ui = ui, server = server)
