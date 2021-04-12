## Schedule

### Week 1 – Plan Research, Initial Literature Review
#### Readings
- Gary King, How to Write a Publishable Paper as a Class Project https://gking.harvard.edu/papers
- Jesse Shapiro, Four Steps to an Applied Micro Paper https://www.brown.edu/Research/Shapiro/pdfs/foursteps.pdf
- Riederer, Emily, RMarkdown Driven Development (RmdDD) https://emilyriederer.netlify.com/post/rmarkdown-driven-development/
-  Miyakawa, Tsuyoshi, No raw data, no science: another possible source of the reproducibility crisis, Molecular Brain, https://doi.org/10.1186/s13041-020-0552-2
- Coffee Literature:
  - Conley & Wilson 2018: Coffee Terroir: Cupping Description Profiles and Their Impact Upon Prices in Central American Coffees, GeoJournal; Dordrecht, http://dx.doi.org.myaccess.library.utoronto.ca/10.1007/s10708-018-9949-1
  - Gagné, J. (2019, September 2). How Coffee Varietals and Processing Affect Taste [blog]. Retrieved from https://coffeeadastra.com/2019/07/23/how-coffee-varietals-and-processing-affect-taste-2/
#### Tasks
- Create Research Plan
- Conduct Initial Literature Review
- Review coffee roaster websites and rank on estimated ease of scraping

### Week 2 – Continue Literature Review, Identify Data, Build First Shiny App
#### Readings
- Wickham, Hadley, 2020, Mastering Shiny, Chapters 2-5
- Jesse Shapiro, Code and Data for the Social Sciences: A Practitioner's Guide https://web.stanford.edu/~gentzkow/research/CodeAndData.xhtml
#### Tasks
- Make first shiny app, following tutorial here: https://shiny.rstudio.com/articles/build.html
- Setup GitHub Repo
- Setup folders and initial README

### Week 3 – Finalize Literature Review, Gather Data
#### Readings
- Wickham, Hadley, 2020, Mastering Shiny, Chapters 7-8
- Review GitHub actions for scheduled R scripts: https://blog.simonpcouch.com/blog/r-github-actions-commit/
#### Tasks
- Build first webscrapers 
- Populate with historic (personal) coffee data to backfill dataset

### Week 4 – Continue Data Gathering, Establish Data Structures and Begin Data Automation
#### Readings
- Drake R package documentation, https://docs.ropensci.org/drake/
#### Tasks
- Build second webscrapers 
- Develop basic infrastructure for housing data
- Design data pipeline to update machine learning dataframe

### Week 5 – Automate Data Gathering, Initial Data Cleaning and Preparation, Build Second Shiny App
#### Readings
- Wickham, Hadley, 2020, Mastering Shiny, Chapters 8-9
#### Tasks
- Build third webscrapers
- Make second shiny app (content pending)
- Begin binning for tasting notes (reduce complexity of terms, e.g. ‘jasmine = ‘floral’
- Simplify other metrics
  - e.g. MASL ranges (‘1700-1750’ = 1700)
  - others certain to be identified
- Populate missing data if known
  - e.g. Region, region details

### Week 6 – Finalize Data Cleaning and Preparation, Conduct Exploratory Data Analysis, Begin Machine Learning Model Development
#### Readings
- Kuhn, Max and Julia Silge, 2021, Tidy Modeling with R, Chapters 1-5
- Wickham, Hadley, and Garrett Grolemund, 2017, R for Data Science, Chapters 2-8
#### Tasks
- Finish any data pipeline/architecture development 
- Prepare data for machine learning
  - Fully incorporate all datasources
  - Further cleaning if necessary
- Determine features of interest
  - association rule downward closure
  - stepwise,etc
- Familiarize with TidyModels
  - https://www.tidymodels.org/
  - https://www.tmwr.org/index.html

### Week 7 – Continue Machine Learning Model Development
#### Readings
- Kuhn, Max and Julia Silge, 2021, Tidy Modeling with R, Chapters 6-7
- Wickham, Hadley, and Garrett Grolemund, 2017, R for Data Science, Chapters 22-25
#### Tasks
- Design first machine learning model with TidyModels
  - Train/test
  - Basic confusion matrix/summary of model success

### Week 8 – Finalize Machine Learning Model Development, Evaluate Results, Build Third Shiny App
#### Readings
- Kuhn, Max and Julia Silge, 2021, Tidy Modeling with R, Chapters 8-9
- Wickham, Hadley, 2020, Mastering Shiny, Chapters 10-12
#### Tasks
- Continue machine learning development  
- Explore, script, and compare different machine learning algorithm performance

### Week 9 – Model Evaluation and Refinement with Data Augmentation
#### Readings
- Kuhn, Max and Julia Silge, 2021, Tidy Modeling with R, Chapters 10-12
#### Tasks
- Hypertune machine learning models to maximize outcomes as best as possible
- Testing/bootstrapping if not already completed
- Make third shiny app, based on Monica Alexander’s work:
  - https://www.monicaalexander.com/pdf/fc.pdf
  - https://monica-alexander.shinyapps.io/foster_care/

### Week 10 – Finalize Machine Learning Model and Data
#### Readings
- Kuhn, Max and Julia Silge, 2021, Tidy Modeling with R, Chapters 13-14
#### Tasks
- Evaluate machine learning results, write up realizations and analysis
- Submit RMD to GitHub Repo 

### Week 11 – Begin Final Shiny App
#### Readings
- Wickham, Hadley, 2020, Mastering Shiny, Chapters 13-16
#### Tasks
- Determine and confirm requirements of Shiny App features (filters, content, etc)
- Begin final shiny app of all coffee data and machine learning models

### Week 12 – Deploy Model via Shiny App
#### Readings
- Wickham, Hadley, 2020, Mastering Shiny, Chapters 17-23
#### Tasks
- Continue and finish final shiny app

### Week 13 – Shiny App Presentation, Reflection
#### Tasks
- Present shiny app
- Final submission of all RMD and Shiny App work to GitHub Repo 
