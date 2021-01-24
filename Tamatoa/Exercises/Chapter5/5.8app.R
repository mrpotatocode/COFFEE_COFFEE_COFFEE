#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(vroom)
library(tidyverse)

#preprocesss
injuries <- vroom::vroom("neiss/injuries.tsv.gz")
products <- vroom::vroom("neiss/products.tsv")
population <- vroom::vroom("neiss/population.tsv")

count_top <- function(df, var, n) {
    df %>%
        mutate({{ var }} := fct_lump(fct_infreq({{ var }}), n = n)) %>%
        group_by({{ var }}) %>%
        summarise(n = as.integer(sum(weight)))
}

ui <- fluidPage(
    
    fluidRow(
        column(6,
               selectInput("code", "Product",
                           choices = setNames(products$prod_code, products$title),
                           width = "100%"
               )
        ),
        column(2, selectInput("y", "Y axis", c("rate", "count"))),
        
        column(4, sliderInput("x", label = "How many rows", min = 1, max = 25, value = 5))
    ),
    
    
    fluidRow(
        column(4, tableOutput("diag")),
        column(4, tableOutput("body_part")),
        column(4, tableOutput("location"))
    ),
    fluidRow(
        column(12, plotOutput("age_sex"))
    ),
    
    fluidRow(
        column(2, actionButton("story", "Tell me a story")),
        column(10, textOutput("narrative"))
    )
)

server <- function(input, output, session) {
    selected <- reactive(injuries %>% filter(prod_code == input$code))
    
    output$diag <- renderTable(count_top(selected(), diag, n = input$x), width = "100%")
    
    output$body_part <- renderTable(count_top(selected(), body_part, n = input$x), width = "100%")
    
    output$location <- renderTable(count_top(selected(), location, n = input$x), width = "100%")
    
    
    
    summary <- reactive({
        selected() %>%
            count(age, sex, wt = weight) %>%
            left_join(population, by = c("age", "sex")) %>%
            mutate(rate = n / population * 1e4)
    })
    
    output$age_sex <- renderPlot({
        if (input$y == "count") {
            summary() %>%
                ggplot(aes(age, n, colour = sex)) +
                geom_line() +
                labs(y = "Estimated number of injuries")
        } else {
            summary() %>%
                ggplot(aes(age, rate, colour = sex)) +
                geom_line(na.rm = TRUE) +
                labs(y = "Injuries per 10,000 people")
        }
    }, res = 96)
    
    output$narrative <- renderText({
        input$story
        selected() %>% pull(narrative) %>% sample(1)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
