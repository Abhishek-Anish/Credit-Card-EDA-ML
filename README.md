In our analysis to predict customer status, several classification models were explored. Classification models are tools in machine learning that allow us to predict the category or class, in our case, Active or Closed account, to which a new observation belongs, based on historical data. 
The ROC_AUC score is a performance measurement for classification problems. 
It tells us how well a model can distinguish between classes, with a score closer to 1 indicating a high ability to differentiate between customers likely to close their account and those likely to stay active.
Another method to evaluate the models is accuracy, which is calculated by taking the ratio of the number of correct predictions 
(if the model classified unseen data into the correct categories, closed account or active) to the total number of predictions made by the model. 
Like the ROC_AUC score, the closer the accuracy is to 1, the better the model is at predicting. Additionally, each model provides insights into which factors are most relevant in predicting customer status.

Three models were evaluated: Logistic Regression, Decision Trees, and Random Forest. The Logistic Regression model showed an accuracy of 0.88 and an ROC_AUC score of 0.95. 
The Decision Tree model exhibited an accuracy of 0.91 and an ROC_AUC score of 0.97. Finally, the Random Forest model demonstrated an accuracy of 0.96 and an ROC_AUC score of 0.99. 
These scores indicate great efficiency among the evaluated models. The numbers prove that the Random Forest model was the best, closely followed by the Decision Tree model, and then the Logistic Regression model. 
All models identified transactions from the last year and total spend from the last year as the top factors affecting customer status. 
Other notable factors influencing customer status include the Utilization Ratio, Transaction Ratio, Spend Ratio, Card Type, and Total Accounts.
