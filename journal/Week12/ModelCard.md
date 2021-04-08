Model Card the `COFFEE_COFFEE_COFFEE` Multi Stacked Model, version 0.1
================
Thomas Rosenthal, GitHub:
[github.com/mrpotatocode](https://github.com/mrpotatocode),
April 8, 2021

## Model details

  - Developed by Thomas Rosenthal, April 2021. Contact via
    [email](t.rose.github@protonmail.com).

  - Gradiant Boosted Tree using XGBoost. Predictors: *Variety1*,
    *Processing1*, *Country*. Outcome: *TastingGroup*.

  - Implemented in R with tidymodels:
    [multi\_stacked\_model.Rmd](https://github.com/mrpotatocode/COFFEE_COFFEE_COFFEE/blob/main/scripts/draft_multi_stacked_model.Rmd).

## Intended use

  - The primary intended use is classification of Tasting Traits,
    Groups, or Notes labels. Tasting Traits describe large categories,
    such as “Fruity”; Tasting Groups describe smaller categories:
    “Citrus Fruit”; and Tasting Notes describe specific details:
    “Lemon”. Coffees attribute (predictors) combinations, lead to
    highly specific coffee flavours. This is the domain in which the
    model has been evaluated.

  - There are no current intended users (the project is in a state of
    development until more data has been acquired).

  - Commercial use is not intended (and is not preferred).

## Factors

  - The Model is evaluated on coffee attributes (Roaster; Country and
    region of production; Variety; Harvest characteristics; Processing;
    Taste).

An example coffee is
shown:

| Roaster | Country | Region     | Variety  | Processing | Altitude | Harvest                | Tasting Notes                 |
| ------- | ------- | ---------- | -------- | ---------- | -------- | ---------------------- | ----------------------------- |
| Sey     | Ecuador | Pallatanga | Mejorado | Washed     | 1700     | July - September, 2019 | Bergamot, Jasmine, Lemongrass |

  - The underlying dataset was built from scraped data and some manual
    collection. For details on this work see the [working
    paper](https://github.com/mrpotatocode/COFFEE_COFFEE_COFFEE/tree/main/outputs/coffee%20paper.md).

## Metrics

  - The primary evaluation metric is ROC\_AUC. Accuracy metrics are
    harder to tune for lower due to the shape of the data (there are no
    rankings in tasting labels, but three are expected per coffee, even
    predictions that are accurate will produce an automatically
    calculated accuracy score no higher than 33%).
    
    | .truth       | .pred       | .accuracy |
    | ------------ | ----------- | --------- |
    | Citrus Fruit | Brown Sugar | x         |
    | Brown Sugar  | Brown Sugar | ✓         |
    | Berry Fruit  | Brown Sugar | x         |
    

  - XGBoost predicted probablilites used within the presentation layer
    (Shiny app) select the top three tasting labels, along with their
    probabilities.
    
    | .pred       | .prob |
    | ----------- | ----- |
    | Brown Sugar | .68   |
    | Berry Fruit | .14   |
    | Stone Fruit | .07   |
    

  - Final accuracy is calculated through boolean truth table logic based
    on XGBoost predictions for the set of possibilities. Where
    \(\frac{\sum(_⊤)}n\) = Accuracy (.66 for this
    example)
    
    | .pred       | .truth1      | .truth2     | .truth3     | .bool1 | .bool2 | .bool3 |
    | ----------- | ------------ | ----------- | ----------- | ------ | ------ | ------ |
    | Brown Sugar | Citrus Fruit | Brown Sugar | Berry Fruit | F      | T      | F      |
    | Berry Fruit | Citrus Fruit | Brown Sugar | Berry Fruit | F      | F      | T      |
    | Stone Fruit | Citrus Fruit | Brown Sugar | Berry Fruit | F      | F      | F      |
    

## Evaluation Data

  - The dataset is a collection of csv files, concetenated together
    (lengthwise). Code can be found in the
    [Datasheet](https://github.com/mrpotatocode/COFFEE_COFFEE_COFFEE/blob/main/journal/Week8/DataSheet-0.1.md)
    and is relatively straight forward.

  - The motivation for producing this dataset and model was exploratory.
    Research supports the assertion that controlled coffee production
    variables should produce consistent tastes.

  - Several important preprocessing are required:
    
      - Update the supplemental [tasting note
        mapping](https://github.com/mrpotatocode/COFFEE_COFFEE_COFFEE/tree/main/inputs/data/Conformed)
        to include newly acquired tasting notes from raw data
      - Extract and parse string values into relevent feature columns
      - Dummy all nominal predictors
      - Remove zero variance predictors

## Training data

  - A standard 75:25 split is used. Later iterations may reconsider this
    due to the cyclical nature of coffee production (certain coffee
    producing countries come harvest more and less frequently than
    others).

  - 10 fold cross validation is applied during tuning

## Ethical Considerations

  - This model is based on data scraped from various websites, and while
    these scrapers are reproducible, it is rare for coffee details to be
    archived, so exact coffee details are unlikely to be completely
    reproducible.

  - For discussion of the ethical considerations underlying the
    COFFEE\_COFFEE\_COFFEE dataset, see the
    [Datasheet](https://github.com/mrpotatocode/COFFEE_COFFEE_COFFEE/blob/main/journal/Week8/DataSheet-0.1.md).

## Caveats and recommendations

  - This dataset is still very young. Coffee data collection should
    occur for at least an entire calendar year before using this dataset
    for less exploratory applications.

  - Model scores are far lower than preferred. Tasting Groups are the
    current Outcome to accomodate for lack of data. Some coffees produce
    consistent tasting notes within the same group (e.g. a coffee
    tasting of Raspberry and Red Currant, would classify as Berry Fruit,
    Berry Fruit). The model cannot produce duplicate predictions (though
    probability scores may indicate that a duplicate is frequent). The
    frequency at which this occurs is not measurable at this time.

# References

<div id="refs" class="references">

<div id="ref-tidymodels">

Kuhn, Max, and Hadley Wickham. 2020. *Tidymodels: A Collection of
Packages for Modeling and Machine Learning Using Tidyverse Principles.*
<https://www.tidymodels.org>.

</div>

<div id="ref-2019modelcard">

Mitchell, Margaret, Simone Wu, Andrew Zaldivar, Parker Barnes, Lucy
Vasserman, Ben Hutchinson, Elena Spitzer, Inioluwa Deborah Raji, and
Timnit Gebru. 2019. “Model Cards for Model Reporting.” *Proceedings of
the Conference on Fairness, Accountability, and Transparency*.
<https://doi.org/10.1145/3287560.3287596>.

</div>

</div>
