library(tidyverse)
library(tidymodels)
library(doFuture)

####### IF RERUNING WITH NEW DATA ####### 
####### YOU MUST UPDATE THE boosted_param OBJECT WITH NEW PARAMETERS ####### 
####### THIS SHOULD BE DONE BY RUNNING multi_stacked_model.Rmd ####### 

#set to 4 core processing
registerDoFuture()
cl <- parallel::makeCluster(4) 
plan(cluster, workers = cl)

#Rsample pacakge example 
## Create the train and test sets using Rsample
set.seed(42)
tidy_split <- initial_split(prep_data, prop = .75)
tidy_train <- training(tidy_split)
tidy_test <- testing(tidy_split)
tidy_kfolds <- vfold_cv(tidy_train)

#Recipes package 
## For preprocessing, feature engineering, and feature elimination 
tidy_rec <- recipe(TastingGroup ~., data = tidy_train) %>% 
  step_dummy(all_nominal(), -all_outcomes()) %>% 
  step_zv(all_predictors())

# Parsnip package 
## Standardized api for creating models 
tidy_boosted_model <- boost_tree(trees = tune(),
                                 min_n = tune(),
                                 learn_rate = tune(),
                                 tree_depth = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("xgboost")

####### UPDATE HERE ####### 
#manually create best params -- tune was run elsewhere, no point in rerunning within this script
boosted_param <- tribble(~"trees",~"min_n",~"tree_depth",~"learn_rate",~".config",
  as.integer(2000),as.integer(14),as.integer(1),0.1,as.factor('Preprocessor1_Model080'))

#Apply parameters to the models    
tidy_boosted_model <- finalize_model(tidy_boosted_model, boosted_param)

# Workflow package 
# For combining model, parameters, and preprocessing
boosted_wf <- workflow() %>% 
  add_model(tidy_boosted_model) %>% 
  add_recipe(tidy_rec)

# Yardstick package
# For extracting metrics from the model 
boosted_res <- last_fit(boosted_wf, tidy_split)

#create confusion matrix
conf_mat_b <- boosted_res %>% unnest(.predictions) %>% 
  conf_mat(truth = TastingGroup, estimate = .pred_class)

#fit final model
final_boosted_model <- fit(boosted_wf, prep_data)

#calculate accuracy
#select possible inputs
selected = prep_data %>% select(Variety1,Processing1,Country) %>% filter(!is.na(Country)) %>% distinct()

#produce top 3 predictions per input combination
motha_frockin_accuracy_n_shiz <- data.frame()
for(i in 1:nrow(selected)){
  answer <- predict(
    final_boosted_model,
    selected %>% dplyr::slice(i),
    type = "prob"
  ) %>% 
    gather() %>% 
    arrange(desc(value)) %>% 
    top_n(3)
  
  #bind
  motha_frockin_accuracy_n_shiz <- rbind(motha_frockin_accuracy_n_shiz,answer)
}

#add an id for each prediction
motha_frockin_accuracy_n_shiz$id <- c(0, rep(1:(nrow(motha_frockin_accuracy_n_shiz)-1)%/%3))
#adjust so first id = 1 instead of 0
motha_frockin_accuracy_n_shiz$id <- motha_frockin_accuracy_n_shiz$id+1

#remove the label ".pred_" produced by the predict() fx
motha_frockin_accuracy_n_shiz <- motha_frockin_accuracy_n_shiz %>% 
  mutate(note = key %>% str_remove(".pred_"), .keep = "unused")

#move note to the first column
motha_frockin_accuracy_n_shiz <- motha_frockin_accuracy_n_shiz %>% select(note, everything())

#merge back to selected so we have the coffee details associated with each predictions 
selected_predictions <- merge(motha_frockin_accuracy_n_shiz,mutate(selected, id = rownames(selected)))

#add coffee index
pre_prep_data$idx = rownames(pre_prep_data)
#add the actual tasting groups for all coffees back
final_accuracy <- sqldf::sqldf('select distinct idx, s.*,Group1,Group2,Group3 
                          from selected_predictions s 
                          join pre_prep_data p on s.Variety1 = p.Variety1 
                            and s.Processing1 = p.Processing1 
                            and s.Country = p.Country')

#add a boolean whether the predicted note matches one of the three tasting groups
final_accuracy <- final_accuracy %>% 
  mutate(Group1_c = note == Group1, Group2_c = note == Group2, Group3_c = note == Group3)

#quantify how many true/false labels per column
correct_predictions <- table(final_accuracy=='TRUE', names(final_accuracy)[col(final_accuracy)]) %>% data.frame()
