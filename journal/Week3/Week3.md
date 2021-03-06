Week3
================
Thomas Rosenthal

28/01/2021

## Weekly Reflection

### My lesson in HTML node picking

For the past few weeks, I have been looking to programmatically navigate
from a collections page (think: results from a search on a webstore) to
a specific item’s page and extract details from it. To do this, a few
things have to happen.

For this example, I will use the coffees from [The Library Speciality
Coffee](https://www.thelibraryspecialtycoffee.com/) roaster on the
[Eight Ounce
Coffee](https://eightouncecoffee.ca/collections/the-library-specialty-coffee)
website. Let’s suppose that we want to quickly grab the **Altitude**
that each coffee was grown. We see that this information isn’t listed on
the collection
page.

<img src="imgs/TLS.png" width="40%" />

We’ll need to navigate to each coffee’s page, extract the **Altitude**,
write it to a table (assumedly with the coffee name, region, processing,
etc as well), and then move on to the next coffee and repeat the
process.

Our example coffee, Bensa Segera from Ethiopia, was grown at *2100-2300
m*:

<img src="imgs/bensa.png" width="45%" />

Using
[rvest](https://blog.rstudio.com/2014/11/24/rvest-easy-web-scraping-with-r/),
we’ll aim to grab the desired information from a saved html file
(because let’s be polite when we’re scraping someone else’s data).
Depending on the site complexity, this might seem incredibly daunting,
and you might find yourself doing a lot of trial and error to get to the
information you want to
extract…

``` r
library(rvest)
```

``` r
raw_data <- read_html("https://eightouncecoffee.ca/collections/the-library-specialty-coffee")
write_html(raw_data, "journal/Week3/inputs/TLS.html") # Note that we save the file as a html file
```

Once we have the html file, we’ll need to navigate to each coffee.

The page source will start to show us what we are looking for. Here I’ve
searched for “Bensa” just to move through the page a bit quicker.
<img src="imgs/page-source.png" width="75%" />

When I first started working with rvest, I thought it was necessary to
traverse an entire html “tree” going from one node to another.

It was looking something like this:

``` r
library(tidyverse)
rough <- raw_data %>% 
  html_nodes("body") %>% 
  html_nodes("div") %>%
  html_nodes("div") %>%
  html_nodes("main") %>%
  html_nodes("div") %>%
  html_nodes("div") %>%
  html_nodes("div") %>%
  html_text() 
tibble(raw_text = head(rough[46:55],10))
```

    ## # A tibble: 10 x 1
    ##    raw_text                                                                     
    ##    <chr>                                                                        
    ##  1 "\n\n  \n          Sold Out\n        \n      \n          \n\n\n      \n     …
    ##  2 "\n  \n          Sold Out\n        \n      \n          \n\n\n      \n       …
    ##  3 "\n          Sold Out\n        \n      \n          \n\n\n      \n        The…
    ##  4 "\n          Sold Out\n        "                                             
    ##  5 "\n          \n"                                                             
    ##  6 "\n          "                                                               
    ##  7 "\n        The Library - La Palma yi El Tucan lot416, Colombia, Anaerobic wa…
    ##  8 "The Library - La Palma yi El Tucan lot416, Colombia, Anaerobic washed"      
    ##  9 "The Library Specialty Coffee"                                               
    ## 10 "\n       No reviews  \n"

On a side note, it was possible to just use html\_nodes() once:

    html_nodes("body div div main div div div") %>%
    html_text() 

…but this is a bit beside the point\!

I have filtered this down to exclude a ton of irrelevant information for
the sake of this writeup (like the first 45 rows for example), but this
isn’t very programmatic. In reality, I ended up writing something to
grab the coffee lines because they had a unique number of \\n \\n \\n
\\n characters.

``` r
library(data.table)
some_data <- 
tibble(raw_text = rough[46:81])

some_data <- some_data %>% 
  mutate(is_TLS = if_else(raw_text %like% "\n\n\n\n\n\n\n\n\n\n\n\n\n\n ",1,0)) %>% 
  filter(is_TLS == 1) %>% 
  select(-is_TLS)
some_data
```

    ## # A tibble: 11 x 1
    ##    raw_text                                                                     
    ##    <chr>                                                                        
    ##  1 "\n\n  \n          Sold Out\n        \n      \n          \n\n\n      \n     …
    ##  2 "\n  \n          Sold Out\n        \n      \n          \n\n\n      \n       …
    ##  3 "\n          Sold Out\n        \n      \n          \n\n\n      \n        The…
    ##  4 "\n        The Library - La Palma yi El Tucan lot416, Colombia, Anaerobic wa…
    ##  5 "\n  \n          Sold Out\n        \n      \n          \n\n\n      \n       …
    ##  6 "\n          Sold Out\n        \n      \n          \n\n\n      \n        The…
    ##  7 "\n        The Library - Bensa Segera, Ethiopia, WashedThe Library Specialty…
    ##  8 "\n  \n          Sale\n        \n      \n          \n            \n\n\n     …
    ##  9 "\n          Sale\n        \n      \n          \n            \n\n\n      \n …
    ## 10 "\n        The Library - Potosi, Colombia, WashedThe Library Specialty Coffe…
    ## 11 "\n  \n          Sale\n        \n      \n          \n            \n\n\n     …

Obviously this wasn’t working well – I ended up with a lot of extra data
cleaning, and the number of \\n characters was changing week by week.
Ouch.

Unfortunately, even figuring out that coffee names were appearing every
n-th row wasn’t particularly programmatic…it would change week to week.

``` r
tibble(raw_text = head(rough[c(53,64,75,86)],4))
```

    ## # A tibble: 4 x 1
    ##   raw_text                                                                      
    ##   <chr>                                                                         
    ## 1 "The Library - La Palma yi El Tucan lot416, Colombia, Anaerobic washed"       
    ## 2 "The Library - Bensa Segera, Ethiopia, Washed"                                
    ## 3 "\n        The Library - Potosi, Colombia, WashedThe Library Specialty Coffee…
    ## 4 "\n            "

### Picking the right html\_node()

A better solution requires that we go back to the page
source.

<img src="imgs/class=.png" width="100%" />

While I was trying to browse through these html files with 12,000 lines,
I noticed that almost every `<div>` had either an **id =** or **class
=** within it. Ah ha.

Let’s try that instead.

``` r
clean <- raw_data %>% 
  html_nodes("div [class='grid-product__title grid-product__title--heading']") %>% 
  html_text()
clean
```

    ## [1] "The Library - La Palma yi El Tucan lot416, Colombia, Anaerobic washed"
    ## [2] "The Library - Bensa Segera, Ethiopia, Washed"                         
    ## [3] "The Library - Potosi, Colombia, Washed"                               
    ## [4] "The Library - San Pedro Necta, Guatemala, Washed"

This is great. Not only have we totally forgotten about this `<div>
<div> <div> <main>` nonsense, we are navigating to a single place on the
webpage.

This allows us to turn each of these coffee name strings into their
respective URLs. I noticed early on that coffee names were always the
same as the URLs (as lowercase strings with hyphens replacing spaces).

Let’s make it lowercase with `str_to_lower`:

``` r
our_data <- tibble(raw_text = clean)

coffee_names <- our_data %>% 
  mutate(lower_name =  str_to_lower(raw_text)) %>% 
  select(lower_name)
coffee_names
```

    ## # A tibble: 4 x 1
    ##   lower_name                                                           
    ##   <chr>                                                                
    ## 1 the library - la palma yi el tucan lot416, colombia, anaerobic washed
    ## 2 the library - bensa segera, ethiopia, washed                         
    ## 3 the library - potosi, colombia, washed                               
    ## 4 the library - san pedro necta, guatemala, washed

Some substitutions will help us here:

``` r
hypen_names <- coffee_names %>% 
  apply( MARGIN = 2, FUN = trimws) %>% 
  sapply(gsub, pattern = " ", replacement = "-", fixed = TRUE) %>% 
  sapply(gsub, pattern = ",", replacement = "", fixed = TRUE) %>%
  sapply(gsub, pattern = "---", replacement = "-", fixed = TRUE) %>%
  as.data.frame() %>% 
  rename(Hypen_Name = 1) 

rownames(hypen_names) <- 1:nrow(hypen_names)
hypen_names
```

    ##                                                          Hypen_Name
    ## 1 the-library-la-palma-yi-el-tucan-lot416-colombia-anaerobic-washed
    ## 2                          the-library-bensa-segera-ethiopia-washed
    ## 3                                the-library-potosi-colombia-washed
    ## 4                      the-library-san-pedro-necta-guatemala-washed

Now we can just add the collection prefix with paste:
‘<https://eightouncecoffee.ca/collections/the-library-specialty-coffee/products/>’

``` r
URLs <- paste0("https://eightouncecoffee.ca/collections/the-library-specialty-coffee/products/",hypen_names[,1])
URLs[1]
```

    ## [1] "https://eightouncecoffee.ca/collections/the-library-specialty-coffee/products/the-library-la-palma-yi-el-tucan-lot416-colombia-anaerobic-washed"

Within a for-loop, we can easily feed this into another rvest
`read_html`, pick the correct `html_node()` and extract the
**Altitude**.

``` r
coffee_table <- data.frame()

#I will just do this for the first coffee
for(i in URLs[1]){
  coffee_row <- read_html(i)
  
  coffee_details <- 
  coffee_row %>% 
    html_nodes("div [id='content'] ul li p") %>% 
    html_text()
  
  #write it out so you can use it again!
  write_html(coffee_row,paste0("journal/Week3/inputs/coffee.html"))
  
  coffee <- tibble(raw_text = coffee_details)
  
  #seperate details row into relevent columns
  coffee <- coffee %>%
    pivot_wider(names_from = 1, values_from = raw_text) %>% 
    rename(table = 1) %>%   
    separate(table, into = c("1","Region","Variety","Processing","Altitude", "TastingNotes"), sep = "\\w+:",  remove = TRUE) %>% 
    select("Region","Variety","Processing","Altitude", "TastingNotes")  
    
#append to a table  
  for (i in nrow(coffee)) {
      coffee_table <- rbind(coffee_table, data.frame(coffee))
  }
  #this is a nice little polite pause during loops!
  Sys.sleep(2.5)
}
coffee_table
```

    ##           Region                       Variety                  Processing
    ## 1  Cundinamarca   Castillo, Caturra, Colombia   'Lactic' Anaerobic Washed 
    ##   Altitude              TastingNotes
    ## 1   1350m   Prune, Red grape, Toffee

There we have it. Our **Altitude** is *2100-2300 m* just as we expected.

### Using html\_attr() instead…

So it works. Great. But there’s a problem with this approach. It
requires:

1)  coffee names to be the same as their URLs (or at least to have some
    discernable pattern)
2)  coffee names to be free of typos

That last point seemed like it wouldn’t happen. But I found out pretty
quickly that I was
wrong.

<img src="imgs/typo.png" width="35%" />

It might be hard to notice what’s happening here, but “Karogoto **AB**”
should have been “Karogoto **AA**” (AA and AB are Kenyan grades, which
isn’t overly important, but maybe you were wondering\!)

We can write a function to remove URLs that are incorrect:

    checkURLs <- lapply(URLs, function(u) {
      tryCatch({
        html_obj <- read_html(u)
        draft_table <- html_nodes(html_obj,'table')
        cik <- substr(u,start = 41,stop = 47)
        draft1 <- html_table(draft_table,fill = TRUE)
        final <- u
      }, error = function(x) NULL)
    })

…but there’s a better solution entirely. Extract the URL specifically
using `html_attr` rather than `html_text`.

While digging around in the page source, I noticed that the URL was
already
listed:

<img src="imgs/href=.png" width="100%" />

So immediately I tried to grab that with class = grid-product\_\_link

``` r
url <- raw_data %>% 
  html_nodes("div [class='grid-product__content'] a [class='grid-product__link ']") %>% 
  html_text()
url
```

    ## character(0)

No dice. This is where `html_attr` comes in.

``` r
url <- raw_data %>% 
  html_nodes("div [class='grid-product__content'] a") %>% 
  html_attr("href")
url
```

    ## [1] "/collections/the-library-specialty-coffee/products/the-library-la-palma-yi-el-tucan-lot416-colombia-anaerobic-washed"
    ## [2] "/collections/the-library-specialty-coffee/products/the-library-bensa-segera-ethiopia-washed"                         
    ## [3] "/collections/the-library-specialty-coffee/products/the-library-potosi-colombia-washed"                               
    ## [4] "/collections/the-library-specialty-coffee/products/the-library-san-pedro-necta-guatemala-washed"

We’ve picked the right html\_node with class=, and then asked for the
href= and ended up with our URLs.

Our Kenyan AA ≠ Kenyan AB problem is no more. We’ve asked for the URL
directly from the webpage, rather than extrapolating the name-to-URL
pattern and replacing the spaces with hyphens.

Everything else is the same from here.
