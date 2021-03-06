library(gplots)
#Get	the	spam	database	into	R	(install package kernlab)
library(kernlab)

#Split	into	a	training/test	set	of	80%	to	20%
data(spam) # spam dataset has 4601 email samples, 57 features, 2 types (SPAM and NONSPAM)
# testidx <- which(1:length(spam[,1])%%5 == 0) 
set.seed(100)
testidx <- sample(1:dim(spam)[1],0.2*dim(spam)[1],replace = FALSE)#randomly split the data into two parts
spamtrain <- spam[-testidx,] #(80% for training set)
spamtest <- spam[testidx,] #(20% for test set)



#Use SVM	with	2	kernels	of your	choice
library(e1071)
model1 <- svm(type~.,data=spamtrain, kernel = "radial", probability = TRUE) #use radial kernel, untuned
prediction1 <- predict(model1,spamtest, decision.values = TRUE, probability=TRUE)

model2 <- svm(type~.,data=spamtrain, kernel = "linear", probability = TRUE) #use linear kernet, untuned
prediction2 <- predict(model2,spamtest, decision.values = TRUE, probability=TRUE)

#Plot	ROC	curve	for	both	SVM	predictions	(Figure1.pdf)
#Report AUC for each on legend
library(ROCR)
pdf('Figure1.pdf')
pred_scores1 <- attr(prediction1, "probabilities")[,1]
pred1 <- prediction(pred_scores1, spamtest[,"type"])
perf1 <- performance(pred1, "tpr", "fpr") 
perf1.auc <- performance(pred1,'auc')
auc1 <- perf1.auc@y.values
plot(perf1,  colorize=TRUE)
title("ROC for SVM prediction w/ Radial Kernel")
legend('center',legend=parse(text=sprintf('AUC == %s',auc1)))

pred_scores2 <- attr(prediction2, "probabilities")[,1]
pred2 <- prediction(pred_scores2, spamtest[,"type"])
perf2 <- performance(pred2, "tpr", "fpr")
perf2.auc <- performance(pred2,'auc')
auc2 <- perf2.auc@y.values
plot(perf2, colorize=TRUE)
title("ROC for SVM prediction w/ Linear Kernel")
legend('center',legend=parse(text=sprintf('AUC == %s',auc2)))

dev.off()


#Split spam data into 10 equally sized part
folds <- rep(1:10,len=nrow(spam))
testScore <- list()
testLabel <- list()
for (j in 1:10){
  testidx <- which(folds == j)
  testGroup <- spam[testidx,]
  trainGroup <- spam[-testidx,]
  model1 <- svm(type~.,data=testGroup, kernel = "radial", probability = TRUE) #use the radial kernel model
  predictions <- predict(model1,testGroup, decision.values = TRUE, probability=TRUE)
  pred_scores <- attr(predictions, "probabilities")[,1]
  testLabel[j] <- list(testGroup[,"type"])
  testScore[j] <- list(pred_scores)
}

#Plot ROC curves for each cross-validation fold and corresponding predictions
#With average ROC curve and box plot
pdf('Figure2.pdf')
pred <- prediction(testScore, testLabel)
perf <- performance(pred,"tpr","fpr")
perf.auc <- performance(pred,"auc")
auc <- perf.auc@y.values
plot(perf,col="grey82",lty=3)
plot(perf, lwd=3,avg="vertical",spread.estimate="boxplot",add=T)
title("ROC for 10-fold cross-validation on radial kernal SVM prediction")
legend('center',legend=parse(text=sprintf("AUC==%s",auc)))

dev.off()