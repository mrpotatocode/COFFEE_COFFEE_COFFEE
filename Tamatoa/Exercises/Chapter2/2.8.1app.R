library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage( 
    
    # Application title
    titlePanel("Chapter 2 Exercises"),
    
        # Main panel for displaying outputs 
        mainPanel(
            #input
            textInput("name", "What's your name?"),
           
             # Output: Formatted text for caption
            h3(textOutput("caption")),
          
        )
)

# Define server logic to plot vars against mpg
server <- function(input, output) {

    output$caption <-  renderText({
        paste0("Hello ", input$name)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
