# Final Manufacturer Attributes Affecting Extended Supply Chain Transparency

## Project Overview

This project investigates the attributes of final manufacturers that influence the likelihood of their upstream agricultural growers measuring and disclosing Scope 1 and 2 greenhouse gas (GHG) emissions. The core issue is the lack of transparency in extended supply chains, particularly concerning Scope 3 emissions, which are becoming increasingly important due to regulations like California's SB 253 and European Sustainability Reporting Standards. Understanding these manufacturer attributes can help in promoting greater sustainability and transparency throughout the supply chain.

## Executive Summary

This project utilizes data from The Sustainability Insight System (THESIS), collected by The Sustainability Consortium (TSC), to explore factors influencing GHG emissions disclosure by far-upstream agricultural suppliers in food manufacturing supply chains. The Awareness-Motivation-Capability (AMC) model serves as the theoretical framework to assess how final manufacturer attributes impact upstream supplier transparency. Logistic Regression analysis was performed using R on a dataset of approximately 797 observations before cleaning, and 511 after cleaning for the final models.

Key findings indicate that:
* **Capability attributes** of the manufacturer, such as past experience with THESIS and the information sources they use, are strong predictors of grower disclosure.
* **Motivation attributes**, like having a larger sustainability team, significantly increase the odds of transparency. Specifically, companies with sustainability teams of 3-5 members or more than 20 members showed significantly higher odds of their suppliers disclosing emissions.
* **Awareness attributes**, such as company type (public vs. private), also play a role, with private companies being associated with lower odds of supplier disclosure in initial models.
* Control variables like the manufacturer's overall corporate sustainability score and whether they have set GHG goals are highly significant, with higher scores and the presence of goals leading to increased supplier transparency.
* The model fit, as indicated by McFadden's Pseudo R-square, improved from basic AMC variables to an expanded model including controls and interaction adjustments (Model 1 $R^2 \approx 0.17$, Model 3 $R^2 \approx 0.56$).

The insights aim to help manufacturers develop strategies to encourage and enable their agricultural suppliers to be more transparent about their GHG emissions, ultimately preparing them for upcoming regulatory requirements.

## Insights Deep-Dive

### Data Source and Objective
The data for this project comes from The Sustainability Insight System (THESIS), a platform managed by The Sustainability Consortium (TSC). THESIS collects primary data from suppliers (growers) through Key Performance Indicators (KPIs) when requested by their direct customers (food manufacturers), often prompted by retailers like Walmart. An example KPI from the chocolate sector asks for the percentage of priority ingredients produced by suppliers who reported their Scope 1 and 2 GHG emissions.

The primary research question is: "What are a buying firm's attributes that make it more likely that their upstream growers will measure and disclose Scope 1 and 2 GHG emissions?". The dependent variable, "Extended Supply Chain Transparency," is a binary outcome (1 if growers disclose GHG emissions, 0 otherwise).

### Theoretical Framework: AMC Model
The Awareness-Motivation-Capability (AMC) model is used to structure the investigation:
* **Awareness**: The growers' understanding that their manufacturing buyers require GHG emissions data. Proxies for manufacturer attributes that might enhance this awareness include Company Size and Company Type (public/private).
* **Motivation**: The incentives driving growers to be transparent. Manufacturer attributes potentially influencing this include having a dedicated Sustainability Team, stated Sustainability Interest in THESIS, and public Disclosure of sustainability reports.
* **Capability**: The resources and skills growers need for data measurement and disclosure, potentially influenced by the manufacturer's Past Experience with THESIS, Other (sustainability reporting) Experience, and the Information Source used for THESIS reporting.

### Variables
* **Dependent Variable (DV)**:
    * `DV`: Binary variable indicating whether the growers reported Scope 1 and 2 GHG emissions (1 = Yes, 0 = No).
* **Independent Variables (Manufacturer Attributes)**:
    * `IV_CompSize`: Categorical, 5 levels based on annual revenue (e.g., 1-10 million USD, >1 billion USD).
    * `IV_CompType`: Binary, Public or Private company.
    * `IV_Disclosure`: Binary, Whether the company has a publicly available sustainability report.
    * `IV_SusTeam`: Categorical, Size of the sustainability team (e.g., None, 1-2, 3-5, >20 employees).
    * `IV_InfoSource`: Categorical, Source of information used for THESIS reporting (0, 1, 2, or 3 representing different sources/combinations).
    * `IV_PastEx`: Continuous, Number of years the company participated in THESIS.
    * `IV_OtherEx`: Continuous, Number of different sustainability reporting tools used other than THESIS.
* **Control Variables**:
    * `C_NumbProduct` (Number of Assessments): Total sustainability assessments submitted.
    * `C_KPI` (KPI Category): The specific product category of the assessment (e.g., Dairy, Berries and Grapes, Complex Foods and Beverages).
    * `C_CorporateSus`: Corporate sustainability score.
    * `C_GHGMaturity` (GHG Goal): Maturity of GHG planning/whether a GHG goal is set.
    * `C_ContractMF`: Whether contract manufacturing is used.
    * `C_SusPriorities`: If sustainability is a stated priority.
    * `C_Competition` (Number of Competitors).
    * `C_NumbSourcingCont` (Sourcing Distance/Homogeneity).

### Methodology
The analysis was conducted using **Logistic Regression** in R.
1.  **Data Loading and Preparation**: The data was loaded from an Excel file ("Data.xlsx"). Categorical variables were converted to factors.
2.  **Data Cleaning**: Rows with missing data for the selected variables were omitted (`na.omit(m.data[ , vars_for_model ])`).
3.  **Model Fitting**: Several logistic regression models were fitted:
    * `nm1`: A model with basic AMC variables.
    * `nm3`: An expanded model including AMC variables and control variables.
4.  **Model Diagnostics**:
    * **Variance Inflation Factor (VIF)**: Checked for multicollinearity (`vif(nm1)`, `vif(nm3)`). VIF < 5 for all variables in the final model reported in slides.
    * **Hosmer-Lemeshow Test**: Assessed goodness-of-fit (`hoslem.test(cleaned_data$DV, preds1, g = 10)`). For `nm1`, p = 0.1665; for `nm3`, p = 0.7515, suggesting the models fit the data reasonably well.
    * **Influence Plot and Cook's D**: Used to identify influential observations (`car::influencePlot(nm3)`). The influence plot provided (`Rplot03.png`) shows studentized residuals against hat-values, with circle sizes proportional to Cook's D. Points like 774, 423, 438, 86, and 56 are labeled, with Cook's D values ranging up to 0.0791. The R code calculates the maximum Cook's D for `nm3` and identifies the top 10 influential rows.
    * **Likelihood-Ratio Test**: Used to assess global model utility. For `nm1`, $p < 0.001$; for `nm3`, $p < 0.001$, indicating both models are statistically significant compared to a null model.
    * **Pseudo R-squares**: McFadden's Pseudo R-square for `nm3` was calculated as `1-nm3$deviance/nm3$null.deviance`. The `STP530_Thesis_Final_Presentation_Extended.pptx` reported Model 1: $R^2 \approx 0.17$, Model 3: $R^2 \approx 0.56$.
    * **Binary Classification**: The R code includes steps for prediction and creating a confusion matrix, with an optimal cutpoint based on Youden's J (`OptimalCutpoints::optimal.cutpoints`) to balance sensitivity and specificity (around 0.47 from the pptx.

### Model Results (Focus on Model from Slide 25 & 26 of `THESIS_Slides.pdf`)
After modifications, the key significant predictors for increased likelihood of grower GHG disclosure were:
* **Company Size (3)** (100 million-1 billion USD, compared to the baseline category "Did not Specify" or the smallest size, depending on final model specification): B = 3.068, p = 0.041, Exp(B) = 21.507.
* **Past Experience**: B = 0.444, p = 0.033, Exp(B) = 1.559.
* **Disclosure (Public Disclosure)**: B = -1.593, p = 0.016, Exp(B) = 0.203. (Manufacturers with public disclosure reports were associated with *lower* odds of their suppliers disclosing).
* **Sustainability Team Size (2)** (3 to 5 employees, compared to None): B = 3.378, p < 0.001, Exp(B) = 29.303.
* **Sustainability Team Size (5)** (More than 20 employees, compared to None): B = 4.816, p < 0.001, Exp(B) = 123.485.
* **KPI Category (11)** (Cookies and Baked Goods, compared to Animal Base Foods): B = 4.959, p = 0.014, Exp(B) = 142.451.
* **KPI Category (14)** (Farmed Fish, compared to Animal Base Foods): B = 7.953, p = 0.003, Exp(B) = 2844.463.
* **Corporate Sustainability score**: B = 0.043, p < 0.001, Exp(B) = 1.044.
* **GHG Goal set**: B = 1.907, p = 0.003, Exp(B) = 6.73.
* **Number of Sourcing Areas (1)** (Domestic sourcing only, compared to a mix or international): B = -3.429, p = 0.001, Exp(B) = 0.032.
* **Number of Sourcing Areas (5 & 6)** (More diverse sourcing regions): Showed significantly higher odds (e.g., for category 6, B = 6.497, p = 0.002, Exp(B) = 663.303).

## AMC Framework Findings
* **Awareness**: `IV_CompSize` & `IV_CompType` were partially significant in some model iterations. Larger companies (100M-1B USD) showed higher odds.
* **Motivation**: `IV_SusTeam` was a strong predictor, with larger teams significantly increasing disclosure odds. `IV_Disclosure` showed mixed/counterintuitive results.
* **Capability**: `IV_PastEx` (Past Experience) consistently showed a positive influence on disclosure. `IV_InfoSource` was also noted as a consistently strongest predictor in the summary presentation.
The capability attributes of the manufacturer appear to be most predictive of their growers' GHG disclosure.

## Implications and Recommendations
* Manufacturers with clearer information sourcing strategies and stronger contractual controls (implied through sourcing diversity and experience) tend to see higher supply chain transparency.
* Smaller and mid-sized firms might be less likely to induce disclosure from their suppliers without targeted efforts.
* A manufacturer's own GHG maturity (having set goals) and making sustainability a priority positively influences their suppliers' disclosure behavior.
* Strategic support, focusing on enhancing growers' awareness, motivation, and especially capability (providing tools, sharing experience), can prepare them for upcoming regulations like those starting in 2026.

## Limitations & Future Work
* **Cross-sectional Data**: The data is from a specific period, so causality cannot be definitively established.
* **Self-Reporting Bias**: Responses to THESIS surveys may be subject to self-reporting bias.
* **Generalizability**: Findings are based on companies participating in THESIS, which may not represent all food manufacturers.

Future work could involve:
* Using panel data from future THESIS waves to analyze trends over time.
* Incorporating qualitative insights from suppliers to understand their perspectives and challenges.
* Exploring supplier readiness for Scope 3 compliance in more detail.

## R Script Instructions

### R Script (`Final_Project_Code_250416.R`)
To run the R script for this project:
1.  **Set Working Directory**:
    * Modify the line `/Applications/saggydev/Spring_2025/STP 530/project/resources/` to your local directory where the "Data.xlsx" file is stored.
2.  **Install and Load Libraries**:
    * Ensure you have the following R libraries installed: `car`, `caret`, `OptimalCutpoints`, `readxl`, `logistf`, `ResourceSelection`.
    * You can install them using `install.packages("package_name")`. The script will load them.
3.  **Prepare Data**:
    * Make sure the "Data.xlsx" file is in the working directory.
4.  **Run the Script**:
    * Execute the script in R or RStudio.
    * The script performs:
        * Data loading and initial factor conversion.
        * Data cleaning by removing rows with missing values for model variables (`cleaned_data <- na.omit(m.data[ , vars_for_model ])`).
        * Fitting of logistic regression models (`nm1 <- glm(...)`, `nm3 <- glm(...)`).
        * Calculation of VIF for multicollinearity (`vif(nm1)`, `vif(nm3)`).
        * Hosmer-Lemeshow goodness-of-fit tests (`hoslem.test(...)`).
        * Likelihood-Ratio Tests for global model utility (derived from model summary deviances).
        * Calculation of Pseudo R-squares (McFadden's: `1-nm3$deviance/nm3$null.deviance`, and Tjur's).
        * Generation of influence plots (`car::influencePlot(nm3)`) and Cook's D statistics (`cooks.distance(nm3)`) to identify influential observations.
        * Steps for binary classification, including finding an optimal cutpoint using `OptimalCutpoints::optimal.cutpoints`.

## Technologies Used
* **R**: For statistical analysis and logistic regression modeling.
* **Microsoft Excel**: For initial data storage (Data.xlsx).

## Acknowledgement
This project utilizes data from The Sustainability Insight System (THESIS), provided by The Sustainability Consortium (TSC). The chocolate KPI documentation (`Chocolate_THESISKPIs_03.05.pdf`) provided context on the nature of THESIS assessments. Project planning and proposal documents (`Group_Project_Charter.pdf`, `Final_Project_Proposal.pdf`) outlined the initial scope and variables. The presentation slides (`THESIS_Slides.pdf`, `STP530_Thesis_Final_Presentation_Extended.pptx`) were key for summarizing results and interpretations.
