#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)

#preprocessing
datasets <- data(package = "ggplot2")$results[c(2, 4, 10), "Item"]

ui <- fluidPage(
    selectInput("dataset", label = "Dataset", choices = datasets),
    verbatimTextOutput("summary"),
    
    #fixed: plotOutput instead of table output
    plotOutput("plot")
)

server <- function(input, output, session) {
    dataset <- reactive({
        get(input$dataset, "package:ggplot2")
    })
    
    #fixed: summary misspelled
    output$summary <- renderPrint({
        summary(dataset())
    })
    
    #fixed: need to call dataset as dataset()
    output$plot <- renderPlot({
        plot(dataset())
    }, res = 96)
}

# Run the application 
shinyApp(ui = ui, server = server)
