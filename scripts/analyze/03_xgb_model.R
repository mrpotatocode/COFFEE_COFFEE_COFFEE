library(tidyverse)
library(tidymodels)
library(doFuture)

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