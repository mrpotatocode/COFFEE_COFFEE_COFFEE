Week2
================
Thomas Rosenthal

21/01/2021

## Weekly Reflection

### Literature

Reading through
[Shapiro](https://web.stanford.edu/~gentzkow/research/CodeAndData.xhtml),
a few thoughts arise.

  - What automation options exist for this project?
      - Firstly, data collection. I really need that to be independent
        from me. In reality, I need a year’s worth of data. I’m going to
        get 3 months worth. A successful project will let me rerun
        analysis 9 months later without having done a whole lot.
      - Secondly, save files? Save tables? Save everything? Interesting.
        Coming from SQL, we often create \_LAND tables, write, run, and
        schedule a stored procedure to create a \_STAGE table and write
        another stored procure to build the reporting features. So three
        scripts (usually a basic pull to create the \_LAND table from a
        dir, and the two SPs) and two tables does most of the work. In
        this project, I don’t think it’ll be that simple. Just from the
        onset, it appears every week’s worth of raw data for EACH
        roaster will be one file. Why wouldn’t I also make a combined
        table down the road, rather than reload and recombine all the
        time. Hmmm…I will have to think about this.
  - Version Control
      - Well, better get better at GITHUB…
      - One thing I think they should have also pointed out with the
        \_firstinitiallastinitial (\_TR) method is that people leave
        orgs/projects. Nothing like random names popping up six years
        later.  
  - Normalize, Abstraction
      - It’s interesting – I think normalization is super useful as
        things scale. But in small projects, it creates a huge amount of
        wasted overhead. I’ve been debating how much I will normalize
        for this project
      - Same thing with abstraction, but for different reasoning…I’m not
        great at writing functions in R. Oh, in that case, this is a bad
        excuse. Okay, let’s find space for it in here.
  - Documentation
      - Great story with the light switch. Just keep people from running
        code that will break, rather than marking “don’t do this”.

### Shiny Functionality

I’ve spent most of this week playing around with some of the basic
functionality of Shiny apps.

In *Mastering Shiny*, Wickham lays out the “Getting Started” section
into three categories:

  - The basics: to help get us going with Shiny
      - the simplest possible `hello world` app
      - a few simple plots, some sliders and other input formats
      - and an overview of Shiny’s general capabilities.
  - Some structural UI necessities: to help get a feel for laying out
    the app.
  - Reactivity: to help to lay the foundation for *how* shiny works, at
    least from a purely functional perspective

I did this chapter after building the [mpg
app](https://shiny.rstudio.com/articles/build.html), where I essentially
wrote out the code (rather than copying and pasting, which helped
immensely) and changed some colours around. I was glad I did it in this
order actually. My version of this app (though it’s 99% the same) is
[here](https://github.com/mrpotatocode/COFEE_COFFEE_COFFEE/tree/main/Tamatoa/First).

#### Exercises

For [Chapter 2](https://mastering-shiny.org/basic-app.html#exercises) I
did a total of five exercises.

**2.8.1:**

``` r
library(shiny)
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

server <- function(input, output) {

    output$caption <-  renderText({
        paste0("Hello ", input$name)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
```

<!--html_preserve-->

<div class="muted well" style="width: 100% ; height: 400px ; text-align: center; box-sizing: border-box; -moz-box-sizing: border-box; -webkit-box-sizing: border-box;">

Shiny applications not supported in static R Markdown documents

</div>

<!--/html_preserve-->

**2.8.2:**

``` r
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
```

<!--html_preserve-->

<div class="muted well" style="width: 100% ; height: 400px ; text-align: center; box-sizing: border-box; -moz-box-sizing: border-box; -webkit-box-sizing: border-box;">

Shiny applications not supported in static R Markdown documents

</div>

<!--/html_preserve-->

**2.8.3**

``` r
ui <- fluidPage(
  
    # Application title
    titlePanel("Chapter 2 Exercises"),
  
    # Main panel for displaying outputs 
    mainPanel(
        #input
        sliderInput("x", label = "If x is", min = 1, max = 50, value = 30),
        sliderInput("y", label = "If y is", min = 1, max = 50, value = 5),
        strong("then x times y is"),
        
        h3(textOutput("product")),
        
    )
)

server <- function(input, output, session) {
    output$product <- renderText({ 
        input$x * input$y
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
```

<!--html_preserve-->

<div class="muted well" style="width: 100% ; height: 400px ; text-align: center; box-sizing: border-box; -moz-box-sizing: border-box; -webkit-box-sizing: border-box;">

Shiny applications not supported in static R Markdown documents

</div>

<!--/html_preserve-->

**2.8.4**

``` r
library(shiny)

ui <- fluidPage(
  
  # Application title
    titlePanel("Chapter 2 Exercises"),
  
    sliderInput("x", "If x is", min = 1, max = 50, value = 30),
    sliderInput("y", "and y is", min = 1, max = 50, value = 5),
    "then, (x * y) is", textOutput("product"),
    "and, (x * y) + 5 is", textOutput("product_plus5"),
    "and (x * y) + 10 is", textOutput("product_plus10")
)

server <- function(input, output, session) {
    formulaText <- reactive(input$x * input$y)
        
    output$product <- renderText(formulaText())
    output$product_plus5 <- renderText(formulaText() + 5)
    output$product_plus10 <- renderText(formulaText() + 10)
}

# Run the application 
shinyApp(ui = ui, server = server)
```

<!--html_preserve-->

<div class="muted well" style="width: 100% ; height: 400px ; text-align: center; box-sizing: border-box; -moz-box-sizing: border-box; -webkit-box-sizing: border-box;">

Shiny applications not supported in static R Markdown documents

</div>

<!--/html_preserve-->

**2.8.5** This just required fixing three lines in this code block,
which are annotated

``` r
library(ggplot2)

datasets <- data(package = "ggplot2")$results[c(2, 4, 10), "Item"]

ui <- fluidPage(
  
  # Application title
    titlePanel("Chapter 2 Exercises"),
    
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

shinyApp(ui = ui, server = server)
```

<!--html_preserve-->

<div class="muted well" style="width: 100% ; height: 400px ; text-align: center; box-sizing: border-box; -moz-box-sizing: border-box; -webkit-box-sizing: border-box;">

Shiny applications not supported in static R Markdown documents

</div>

<!--/html_preserve-->

For [Chapter 3](https://mastering-shiny.org/basic-ui.html) I combined
the collection of exercises into single shiny apps for each concept
(inputs, outputs, layout). I’ve annotated the exercise number.

**Inputs**

``` r
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


server <- function(input, output) {

    #this is just trying to make it semi cohesive/purposeful, not required, just for fun
    output$caption <-  renderText({
        paste0("Okay ", input$name
              ,", we will see you on ", input$x
              ,", to pick up your ", input$animal
              ,', weighing ', input$y, " pounds")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
```

<!--html_preserve-->

<div class="muted well" style="width: 100% ; height: 400px ; text-align: center; box-sizing: border-box; -moz-box-sizing: border-box; -webkit-box-sizing: border-box;">

Shiny applications not supported in static R Markdown documents

</div>

<!--/html_preserve-->

**Outputs**

``` r
ui <- fluidPage(
  
  # Application title
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
```

<!--html_preserve-->

<div class="muted well" style="width: 100% ; height: 400px ; text-align: center; box-sizing: border-box; -moz-box-sizing: border-box; -webkit-box-sizing: border-box;">

Shiny applications not supported in static R Markdown documents

</div>

<!--/html_preserve-->

**Layout**

``` r
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
```

<!--html_preserve-->

<div class="muted well" style="width: 100% ; height: 400px ; text-align: center; box-sizing: border-box; -moz-box-sizing: border-box; -webkit-box-sizing: border-box;">

Shiny applications not supported in static R Markdown documents

</div>

<!--/html_preserve-->

Feeling fairly confident, I read through
[Chapter 4](https://mastering-shiny.org/basic-reactivity.html) and
proceeded to the case study in
[Chapter 5](https://mastering-shiny.org/basic-case-study.html#exercises-5).

``` r
library(shiny)
library(vroom)
library(tidyverse)

#preprocesss
injuries <- vroom::vroom("Tamatoa/Exercises/Chapter5/neiss/injuries.tsv.gz")
products <- vroom::vroom("Tamatoa/Exercises/Chapter5/neiss/products.tsv")
population <- vroom::vroom("Tamatoa/Exercises/Chapter5/neiss/population.tsv")

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
```

<!--html_preserve-->

<div class="muted well" style="width: 100% ; height: 400px ; text-align: center; box-sizing: border-box; -moz-box-sizing: border-box; -webkit-box-sizing: border-box;">

Shiny applications not supported in static R Markdown documents

</div>

<!--/html_preserve-->

Needless to say, wow, there is a lot to make these things interesting
and intelligent. I’m glad to play with Wickham’s more established Shiny
app, but also reminded that it’s going to be a long road.

### Coffee Project

Things are going well overall. I’ve been using Eight Ounce Coffee’s
[website](https://eightouncecoffee.ca/) to start some scraping. My first
week’s scraper worked well, but wasn’t rerunable in the second week. It
seems there will be inconsitencies in the precise way they upload bags
to the website – mostly based on the number leading /n characters in the
`html_node` character string. These /n characters are used as splitting
mechanisms to grab the coffee name, rewrite it as a hypenated string,
and then pushed into a for loop with `read_html`. These individual
hyperlinks to pull in the coffee details. When the data comes in, it’s a
bit messy, and it looks like some weeks will have more details available
than others. I will have to build something flexible enough to properly
write each metric to the appropriate column. Unlike last week, I wrote
this week’s coffee to a csv when it’s all said and done so I don’t have
to rerun the HTML files again. Stuff gets taken down very quickly, as
you’d expect. Once a week seems good though (having actually popped into
The Library Specialty Coffee this week, their shelf mirrors Eight
Ounce’s website.) It shouldn’t take long to grab a lot more roasters
and use the same methodology. The resuling csv should be about 5 coffees
per roaster, per week (maybe slower for some of the smaller roasters),
so we’ll have close to 100 coffees a week scraped off Eight Ounce.
That’s really nice.
