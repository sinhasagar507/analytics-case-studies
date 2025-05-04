rm(list=ls())
setwd("C:/Users/Chulhwan Kwon/Desktop/ASU/수업/2025 Spring/STP530/Finals")
library(car)
library(caret)
library(OptimalCutpoints)
library(readxl)
library(logistf)
library(ResourceSelection)

#===============================================================================
# Load data
m.data <- read_excel("Data.xlsx")

head(m.data)
m.data[, c(4, 7, 8, 12)] <- lapply(m.data[, c(4, 7, 8, 12)], factor)
str(m.data)

#summary(m.data)
#summary(m.data[, c(3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18)])
table(m.data$IV_CompSize)
table(m.data$IV_SusTeam)
table(m.data$IV_InfoSource)
table(m.data$C_KPI)

#pairs(m.data)
pairs(m.data[, c(3, 4, 5, 6, 7, 8, 9, 10)])
numeric_data <- m.data[sapply(m.data, is.numeric)]
cor_matrix <- cor(numeric_data)
print(cor_matrix)

#===============================================================================
# Fit logistic regression model
#m1 <- glm(DV ~ IV_CompSize + IV_CompType + IV_Disclosure  + IV_SusTeam +  IV_InfoSource + IV_PastEx + 
#            IV_OtherEx, data=m.data, family=binomial)
#summary(m1)

#m2 <- glm(DV ~ IV_CompSize + IV_CompType + IV_Disclosure  + IV_SusTeam +  IV_InfoSource + IV_PastEx + 
#            IV_OtherEx + C_NumbProduct + C_KPI + C_CorporateSus + C_GHGMaturity + C_ContractMF + 
#            C_SusPriorities + C_Competition + C_NumbSourcingCont, data=m.data, family=binomial)
#summary(m2)

#m3 <- glm(DV ~ IV_CompSize + IV_CompType + IV_Disclosure  + IV_SusTeam +  IV_InfoSource + IV_PastEx + 
#            IV_OtherEx + C_NumbProduct + C_CorporateSus + C_GHGMaturity + C_ContractMF + 
#            C_SusPriorities + C_NumbSourcingCont, data=m.data, family=binomial)
#summary(m3)

# Cross-tabulations to check for separation with categorical predictors
#table(m.data$IV_CompSize, m.data$DV)
#table(m.data$IV_CompType, m.data$DV)
#table(m.data$IV_Disclosure, m.data$DV)
#table(m.data$IV_SusTeam, m.data$DV)
#table(m.data$IV_InfoSource, m.data$DV)
#table(m.data$IV_PastEx, m.data$DV)
#table(m.data$IV_OtherEx, m.data$DV)
#table(cleaned_data$C_KPI, cleaned_data$DV)

#m4 <- logistf(DV ~ IV_CompSize + IV_CompType + IV_Disclosure  + IV_SusTeam +  IV_InfoSource + IV_PastEx + 
#          IV_OtherEx + C_NumbProduct + C_KPI + C_CorporateSus + C_GHGMaturity + C_ContractMF + 
#          C_SusPriorities + C_NumbSourcingCont, data=m.data, 
#          control = logistf.control(maxit = 100, maxstep = 5))
#summary(m4)

#===============================================================================
#Clean missing Data
vars_for_model <- c("DV", "IV_CompSize", "IV_CompType", "IV_Disclosure", 
                    "IV_SusTeam", "IV_InfoSource", "IV_PastEx", 
                    "IV_OtherEx", "C_NumbProduct", "C_KPI", 
                    "C_CorporateSus", "C_GHGMaturity", "C_ContractMF", 
                    "C_SusPriorities", "C_NumbSourcingCont", "C_Competition")

cleaned_data <- na.omit(m.data[ , vars_for_model ])

#new model
nm1 <- glm(DV ~ IV_CompSize + IV_CompType + IV_Disclosure  + IV_SusTeam +  IV_InfoSource + 
             IV_PastEx + IV_OtherEx, data=cleaned_data, family=binomial)
summary(nm1)
vif(nm1)

nm2 <- glm(DV ~ IV_CompSize + IV_CompType + IV_Disclosure  + IV_SusTeam +  IV_InfoSource + 
           IV_PastEx + IV_OtherEx + C_NumbProduct + C_KPI + C_CorporateSus + C_GHGMaturity + 
           C_ContractMF + C_SusPriorities + C_Competition + C_NumbSourcingCont, 
           data=cleaned_data, family=binomial)

# Cross-tabulations to check for separation with categorical predictors
table(cleaned_data$C_KPI, cleaned_data$DV)

nm3 <- glm(DV ~ IV_CompSize + IV_CompType + IV_Disclosure  + IV_SusTeam +  IV_InfoSource + 
             IV_PastEx + IV_OtherEx + C_NumbProduct + C_CorporateSus + C_GHGMaturity + 
             C_ContractMF + C_SusPriorities + C_Competition + C_NumbSourcingCont, 
             data=cleaned_data, family=binomial)
summary(nm3)
vif(nm3)

#nm4 <- logistf(DV ~ IV_CompSize + IV_CompType + IV_Disclosure  + IV_SusTeam +  IV_InfoSource + IV_PastEx + 
#                 IV_OtherEx + C_NumbProduct + C_KPI + C_CorporateSus + C_GHGMaturity + C_ContractMF + 
#                 C_SusPriorities + C_NumbSourcingCont, data=cleaned_data, 
#               control = logistf.control(maxit = 100, maxstep = 5))
#summary(nm4)


#===============================================================================
#Hosmer–Lemeshow test
preds1 <- predict(nm1, type = "response")
hoslem.test(cleaned_data$DV, preds1, g = 10)

preds2 <- predict(nm3, type = "response")
hoslem.test(cleaned_data$DV, preds2, g = 10)

#===============================================================================
# Model Predictions

predict(nm3, type="link")
predict(nm3, type="response")

#===============================================================================
# Confidence interval for model coefficients

# 95% CI
summary(nm3)$coefficients
qnorm(p=.975)


#===============================================================================
# Likelihood-Ratio Test of global model utility

summary(nm1)
# Likelihood-Ratio Test of global model utility
pchisq((617.91 - 478.29), df=(509 - 494), lower.tail=F)

summary(nm3)
# Likelihood-Ratio Test of global model utility
pchisq((617.91 - 406.26), df=(509 - 487), lower.tail=F)

#===============================================================================
# Pseudo R-squares

# McFadden's Pseudo R-square
1-nm3$deviance/nm3$null.deviance
# The deviances given in R outputs are -2 times of the log-likelihood

# Tjur'a Pseudo R-square
sel <- cleaned_data$DV == 1
cleaned_data[sel,]
cleaned_data[!sel,]

predict(nm3, type="response")[sel]
mean(predict(nm3, type="response")[sel])

predict(nm3, type="response")[!sel]
mean(predict(nm3, type="response")[!sel])

abs(mean(predict(nm3, type="response")[sel]) - 
      mean(predict(nm3, type="response")[!sel]))

#===============================================================================
# Diagnostics

# Influence plot

#car::influencePlot(nm1)
#car::influencePlot(nm2)
# Influence plot
car::influencePlot(nm3)


# Cook's D
p <- 23
n <- nrow(cleaned_data)
pf(q = cooks.distance(nm3), df1 = p, df2 = n - p)*100
max(pf(q = cooks.distance(nm3), df1 = p, df2 = n - p)*100)
round(max(pf(q = cooks.distance(nm3), df1 = p, df2 = n - p)*100), 5)
min(pf(q = cooks.distance(nm3), df1 = p, df2 = n - p)*100)

#To know the largest row for cook's D and the top 10
# Extract Cook's distances from m3
cd <- cooks.distance(nm3)

# Find the row with the maximum Cook's distance
max_index <- which.max(cd)
cat("Row with maximum Cook's distance is:", max_index, "with value:", cd[max_index], "\n\n")

# Get the indices of the top 10 influential rows (largest Cook's distances)
top10_indices <- order(cd, decreasing = TRUE)[1:10]
cat("Top 10 influential rows (by Cook's distance):\n")
for (i in top10_indices) {
  cat("Row", i, "with Cook's distance:", cd[i], "\n")
}

# Optionally, if you want to print the actual rows from the data used in m3:
# Use model.frame to ensure the row numbers align with those used in the model
model_data_m3 <- model.frame(nm3)
cat("\nRows from the fitted data corresponding to the top 10 influential cases:\n")
print(model_data_m3[top10_indices, ])


# DFBETA
dfbetas(nm3)
data.frame(cleaned_data, round(dfbetas(nm3), 2))

#===============================================================================
# Binary classification

pi <- predict(m2, type="response")

predicted.class <- rep(0, nrow(m.data))
predicted.class[pi > .8] <- 1

observed.class <- m.data$DV

side.by.side <- data.frame(predicted.pi=round(pi,2), predicted.class, observed.class)
side.by.side[order(side.by.side$predicted.pi),]

caret::confusionMatrix(data=factor(predicted.class), reference=factor(observed.class), positive="1")

# Optimal cutpoint based on Youden

ROC.data <- data.frame(pi, observed.class=m.data$m.data)

out <- OptimalCutpoints::optimal.cutpoints(X="pi", status="observed.class", tag.healthy = 0, 
                         methods="Youden", data=ROC.data)
out

tmp <- out$Youden$Global$measures.acc
Youden.results <- data.frame(tmp$cutoffs, tmp$Se, tmp$Sp, tmp$Se + tmp$Sp - 1)
colnames(Youden.results) <- c("cutoffs", "Sensitivity", "Specificity", "Youden")
Youden.results