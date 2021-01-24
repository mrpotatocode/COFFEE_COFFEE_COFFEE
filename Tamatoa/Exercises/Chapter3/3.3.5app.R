#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel("Chapter 3 Exercises"),  
  plotOutput("plot", width = "400px"),
    dataTableOutput("table")
)
server <- function(input, output, session) {
    output$plot <- renderPlot(plot(1:5), 
                              #3.3.5.1
                              width = 700, height = 300, res = 96)
    
    
    output$table <- renderDataTable(mtcars, options = list(pageLength = 5, 
                              #3.3.5.2                             
                              ordering = FALSE, searching=FALSE))
}

# Run the application 
shinyApp(ui = ui, server = server)
