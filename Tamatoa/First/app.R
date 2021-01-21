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
    
    # Application title
    titlePanel("MPG"),
    
    # Sidebar layout with input and output definitions
    sidebarLayout(

        # Sidebar panel for inputs
        sidebarPanel(
            
            # Input: Selector for variable to plot against mpg
            selectInput("variable","Variable:",
                        c("Cylinders" ="cyl",
                          "Transmission" = "am",
                          "Gears" = "gear")),
            # Input: Checkbox for whether outliers should be included
            checkboxInput("outliers","Show Outliers",TRUE)
    ),

        # Main panel for displaying outputs 
        mainPanel(
            # Output: Formatted text for caption
            h3(textOutput("caption")),
            
            #Output: the Plot
            plotOutput("mpgPlot")
        )
    )
)

#Pre-process Data
mpgData <- mtcars
mpgData$am <- factor(mpgData$am, labels = c("Automatic", "Manual"))


# Define server logic to plot vars against mpg
server <- function(input, output) {
    
    #Forumla text
    #Reactive expression shared by the output$caption and output$mpgPlot
    formulaText <- reactive({
        paste0("mpg ~", input$variable) #okay so its gonna regress, cool
    })

    # Return the formula text for printing as a caption
    output$caption <-  renderText({formulaText()})

    #plot
    #include or exclude outliers
    
    output$mpgPlot <- renderPlot({
        boxplot(as.formula(formulaText()),
        data = mpgData,
        outline = input$outliers,
        col = "#7800D9", pch = 19)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
