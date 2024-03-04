
library(tidymodels)
library(vip)
library(rpart.plot)


credit_card_df<-read.csv("customer.csv")

credit_card_df$customer_status <- factor(credit_card_df$customer_status,
                                         levels = c("closed_account", "active"))

#Splitting the data into training and testing sets

set.seed(7)
cdf_split<-initial_split(credit_card_df,prop=0.75,strata=customer_status)

cdf_training<-cdf_split %>% training()

cdf_testing<-cdf_split %>% testing()

cdf_split

#Creating fold for cross validation
set.seed(7)
cdf_folds <- vfold_cv(cdf_training, v = 5)

cdf_recipe <- 
  recipe(customer_status ~ ., data = cdf_training)  %>% 
  step_YeoJohnson(all_numeric(), -all_outcomes()) %>%
  step_normalize(all_numeric(), -all_outcomes()) %>% 
  step_dummy(all_nominal(), -all_outcomes()) 

#Cross checking the feature engineering 
(cdf_recipe %>% 
    prep(training = cdf_training) %>%
    bake(new_data = NULL))


##Model 1 - Logistic Regression Model 

#Specifying the model
logistic_model <- logistic_reg() %>%
  set_engine('glm') %>%
  set_mode('classification')

#Creating a workflow
cdf_wf <- workflow() %>% 
  add_model(logistic_model) %>% 
  add_recipe(cdf_recipe)

#Fitting the model
cdf_logistic_fit <- cdf_wf %>% 
  fit(data = cdf_training)

#Exploring the model to see the importance of the predictors and plotting the same
cdf_trained_model <- cdf_logistic_fit %>% 
  extract_fit_parsnip()

vip(cdf_trained_model)

#Predicting using the test data
predictions_categories <- predict(cdf_logistic_fit, new_data = cdf_testing)
predictions_probabilities <- predict(cdf_logistic_fit, new_data = cdf_testing, type = 'prob')


test_results <- 
  cdf_testing %>% 
  dplyr::select(customer_status) %>% 
  bind_cols(predictions_categories) %>% 
  bind_cols(predictions_probabilities)

head(test_results)

#Evaluating the model performance 
#Confusion Matrix
conf_mat(test_results, 
         truth = customer_status, 
         estimate = .pred_class)

#ROC curve
roc_curve(test_results, 
          truth = customer_status,
          .pred_closed_account) %>% 
  autoplot()

#Looking at various performance metrics 
perf_metrics <- metric_set(accuracy, sens, spec, f_meas, roc_auc)

perf_metrics(test_results, 
             truth = customer_status, 
             estimate = .pred_class,
             .pred_closed_account)

##Model 2 -Decision Tree Model

#Specfying the model
tree_model <- 
  decision_tree(cost_complexity = tune(),
                tree_depth = tune(),
                min_n = tune()) %>% 
  set_engine('rpart') %>% 
  set_mode('classification')

#Creating a workflow
tree_workflow <- 
  workflow() %>% 
  add_model(tree_model) %>% 
  add_recipe(cdf_recipe)

#Creating a grid of hyperparameter values to test
tree_grid <- 
  grid_regular(cost_complexity(),
               tree_depth(),
               min_n(), 
               levels = 2)

#Tuning decision tree workflow
set.seed(7)
tree_tuning <- 
  tree_workflow %>% 
  tune_grid(resamples = cdf_folds, grid = tree_grid)

#Showing top 5 best models (roc_auc metric)
tree_tuning %>% show_best('roc_auc')

#Filtering out the best model based on roc_auc and checking the tree parameters for the same
(best_tree <- 
    tree_tuning %>% 
    select_best(metric = 'roc_auc'))

#Finalizing workflow
final_tree_workflow <- 
  tree_workflow %>% 
  finalize_workflow(best_tree)

#Fitting the model to the training data
tree_wf_fit <- 
  final_tree_workflow %>% 
  fit(data = cdf_training)

#Exploring the model to see the importance of the predictors and plotting the same
tree_fit <- 
  tree_wf_fit %>% 
  extract_fit_parsnip()

vip(tree_fit)

#Training the model and generating predictions on the test data
tree_last_fit <- 
  final_tree_workflow %>% 
  last_fit(cdf_split)

#Plotting the decsion tree
rpart.plot(tree_fit$fit, roundint = FALSE, extra = 1,cex=0.45)

#Evaluating the model performance
#Peformance metrics
tree_last_fit %>% collect_metrics()

#roc_auc plot
tree_last_fit %>% 
  collect_predictions() %>% 
  roc_curve(truth = customer_status, .pred_closed_account) %>% 
  autoplot()

#Confusion Matrix
tree_predictions <- tree_last_fit %>% collect_predictions()

conf_mat(tree_predictions, truth = customer_status, estimate = .pred_class)

## Model 3 - Random Forest

#Specifying the model
rf_model <- 
  rand_forest(mtry = tune(),
              trees = tune(),
              min_n = tune()) %>% 
  set_engine('ranger', importance = "impurity") %>% 
  set_mode('classification')

#Creating a workflow
rf_workflow <- 
  workflow() %>% 
  add_model(rf_model) %>% 
  add_recipe(cdf_recipe)

#Creating a grid of hyperparameter values to test
set.seed(7)
rf_grid <- 
  grid_random(mtry() %>% range_set(c(2, 4)),
              trees(),
              min_n(),
              size = 10)

#Tuning the hyperparameters created 
set.seed(7)
rf_tuning <- 
  rf_workflow %>% 
  tune_grid(resamples = cdf_folds, grid = rf_grid)

rf_tuning %>% show_best('roc_auc')

# Selecting and viewing the paramaters of the best model based on roc_auc
(best_rf <- 
    rf_tuning %>% 
    select_best(metric = 'roc_auc'))

#Finalizing the workflow
final_rf_workflow <- 
  rf_workflow %>% 
  finalize_workflow(best_rf)

#Fitting the model
rf_wf_fit <- 
  final_rf_workflow %>% 
  fit(data = cdf_training)

#Exploring the model to see the importance of the predictors and plotting the same
rf_fit <- 
  rf_wf_fit %>% 
  extract_fit_parsnip()

vip(rf_fit)

#Training the model and generating predictions on the test data
rf_last_fit <- 
  final_rf_workflow %>% 
  last_fit(cdf_split)

# Evaluating the model performance
# Performance metrics
rf_last_fit %>% collect_metrics()

# roc_auc plot
rf_last_fit %>% collect_predictions() %>% 
  roc_curve(truth = customer_status, .pred_closed_account) %>% 
  autoplot()

#Confusion matrix 
rf_predictions <- rf_last_fit %>% collect_predictions()

conf_mat(rf_predictions, truth = customer_status, estimate = .pred_class)