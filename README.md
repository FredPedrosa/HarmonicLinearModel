# HarmonicLinearModel
An R syntax to calculate and plot harmonic linear model estimation for individual trajectories in music therapeutic processes

**EstIT_HLM Function README**
The EstIT_HLM function is a versatile tool designed to perform a Harmonic Linear Modeling (HLM) analysis on a set of scores. This function combines a harmonic model with a linear model to estimate the intraindividual trajectory of scores over sessions, providing both model predictions and diagnostic plots. EstIT_HLM was inspired in the 4 logistic parameters syntax by Gomes & Blesa (_apud_ Araújo e Blesa, 2024).

**Table of Contents**
•	Function Overview
•	Syntax
•	Arguments
•	Details
•	Return Values
•	Examples
•	Dependencies
 
**Function Overview**
The EstIT_HLM function performs a combined harmonic and linear regression analysis on a vector of scores. It estimates model parameters, computes residuals, generates diagnostic plots (such as Residuals vs. Fitted Values and Q-Q plots), and provides the R² values for the role model. This approach is particularly useful in contexts where data exhibits both periodic (harmonic) and linear trends. 

scores <- c(6,6,8,8,7) 
EstIT_HLM(scores)

**Arguments**
•	scores: A numeric vector of scores representing measurements taken over different sessions. These scores are used to fit both the harmonic and linear models.
Details

**The function performs the following steps:**

1.	Define Error Function for Harmonic Model: An internal function, harmonic_model_error, computes the sum of squared residuals between observed scores and the harmonic model's predictions. This error function is minimized during parameter optimization.

2.	Initialize Parameters: Initial guesses for the model parameters (frequency, linear trend, intercept, sine, and cosine coefficients) are set, with default values such as:
*	freq = 1 (frequency of the harmonic component),
*	f = 0 (linear trend),
*	a = mean of the scores (intercept),
*	b = 1 (sine coefficient),
*	c = 1 (cosine coefficient).

3.	Optimize Harmonic Model Parameters: The optim function is used to find the parameter values that minimize the error function. The optimized parameters (best_freq, best_f, best_a, best_b, best_c) are extracted for the harmonic model.

4.	Fit Harmonic and Linear Models:
*	The harmonic model is fitted with the optimized parameters.
*	A simple linear regression model is fitted using the lm function.

5.	Calculate R² Values: R² values are computed for the harmonic, linear, and combined models to assess model fit.

6.	Combine Models: A weighted combination of the harmonic and linear model predictions is computed based on their R² values.

7.	Plot Generation:
*	Residuals vs. Fitted Values Plot: Assesses the distribution of residuals.
*	Q-Q Plot: Checks the normality of residuals.
*	Prediction Plot: Shows observed scores versus the combined model's predictions.

8.	Statistical Tests:
*	A Shapiro-Wilk test is performed to check the normality of the residuals.

9.	Trend Analysis: The slope of the linear model is used to determine if the trend is increasing or decreasing.

10.	Output Results: The function prints the model's results, including R² values, parameter estimates, and diagnostic plots.

**Return Values**
The function returns a list containing:
•	R2: R² value for the combined harmonic-linear model.
•	optimized_frequency: The optimized frequency for the harmonic component.
•	adjusted_data: A data frame with observed scores, session numbers, predicted scores from both models, and residuals.
•	prediction_plot: A ggplot object of the combined model's predictions.
•	qq_plot: A Q-Q plot ggplot object to assess the normality of residuals.
•	residuals_plot: A ggplot object showing residuals vs. fitted values.
•	harmonic_parameters: A list with the optimized parameters (intercept, sine_coef, cosine_coef, linear_trend, frequency) for the harmonic model.
•	linear_parameters: A list with the parameters (intercept, slope_coef) for the linear model.

Examples (R)

# Example usage of the EstIT_HLM function

# Sample score data
scores <- c(6,6,8,8,7)

# Running the harmonic linear model estimation
model_results <- EstIT_HLM(scores)

# Accessing results
print(model_results)  # Prints role model’s parameters   
print(model_results$R2)  # Prints model’s  R² 
print(model_results$harmonic_parameters)  # Prints optimized harmonic model parameters
print(model_results$harmonic_parameters)  # Prints optimized harmonic model parameters
print(model_results$linear_parameters) # Prints linar model parameters


# Plotting diagnostic plots
print(model_results$prediction_plot)
print(model_results$qq_plot)
print(model_results$residuals_plot)

# Dependencies
This function requires the ggplot2 package for plotting:
install.packages("ggplot2")
library(ggplot2)

•	Ensure that the scores vector is appropriately preprocessed (e.g., no missing values) before using this function.
•	The function assumes that scores are measured over equidistant sessions.

References
Araújo, J. de, & Blesa, H. (2024). Avaliando a trajetória do processo psicológico do indivíduo por meio de modelos. I Congrsso Brasileiro de Psicometria e Análise de Dados, Porto Alegre. https://www.researchgate.net/publication/381741254_Avaliando_a_trajetoria_do_processo_psicologico_do_individuo_por_meio_de_modelos 


![image](https://github.com/user-attachments/assets/debfceb7-2e8c-4367-baa0-8783ab54f0e6)
