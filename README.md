# Harmonic Linear Model for Individual Trajectory Estimation

An R syntax to calculate and plot harmonic linear model estimation for individual trajectories, applicable in areas like therapeutic processes.

## HLM Function README

The `HLM` function is a versatile tool designed to perform a Harmonic Linear Modeling (HLM) analysis on a time series of scores (e.g., from sessions). This function combines a harmonic model (sine and cosine terms) with both an internal linear trend component (optimized alongside harmonic parameters) and a separate simple linear model fit. It estimates the intraindividual trajectory of scores over sessions using a custom combination approach, providing model predictions, parameter estimates, and diagnostic plots. HLM was inspired in the 4 logistic parameters syntax by Gomes & Blesa (_apud_ Araújo e Blesa, 2024).

## Features

*   **Harmonic + Linear Trend Fitting:** Optimizes parameters for a model including intercept, sine, cosine, frequency, and an internal linear trend (`f`) using `optim`.
*   **Simple Linear Model Fitting:** Fits a standard linear regression (`lm(Score ~ Session)`) for comparison and overall trend assessment.
*   **Custom Model Combination:** Combines predictions from the optimized harmonic model and the simple linear model using a weighted average based on their respective R-squared values.
*   **Goodness-of-Fit:** Calculates R-squared for the harmonic component, the linear component, and the final combined model.
*   **Residual Diagnostics:**
    *   Performs the Shapiro-Wilk test for normality of the combined model's residuals.
    *   Generates a Normal Q-Q plot for the combined model's residuals.
    *   Generates a Residuals vs. Fitted Values plot for the combined model.
*   **Prediction Plot:** Creates a `ggplot2` plot showing the raw scores overlaid with the fitted line from the combined model.
*   **Parameter Output:** Prints key results and parameters to the console and returns them in a structured list.
*   **Trend Assessment:** Determines overall trend direction ("Growth" or "Decline") based on the slope of the simple linear model.

## How it Works

The function executes the following main steps:

1.  **Optimization:** Uses the `optim` function to find the parameters (frequency, internal linear trend `f`, intercept, sine coefficient, cosine coefficient) that minimize the sum of squared differences between the observed scores and the predictions of the `a + b*sin(freq*t) + c*cos(freq*t) + f*t` model.
2.  **Linear Fit:** Fits a separate simple linear model (`Score ~ Session`) using `lm`.
3.  **R-squared Calculation:** Computes R² for the optimized harmonic model (including term `f`) and the simple linear model.
4.  **Prediction Combination:** Creates final fitted values by calculating a weighted average of the predictions from the harmonic model and the simple linear model. The weights are the R² values of each respective model (`(R2_h * Pred_h + R2_l * Pred_l) / (R2_h + R2_l)`).
5.  **Combined Model Evaluation:** Calculates the overall R² and residuals based on these combined predictions.
6.  **Diagnostics & Plotting:** Performs residual tests and generates diagnostic and prediction plots using `ggplot2`.
7.  **Output:** Prints a summary to the console and returns a list containing detailed results.

## Usage

### Running Locally

1.  **Prerequisites:** Ensure you have R and RStudio (recommended) installed.
2.  **Install Packages:** Open R/RStudio and install the required package if you haven't already:
    ```R
    install.packages("ggplot2")
    ```
3.  **Define Function:** Copy the entire `HLM` function code and paste it into your R script or console to define the function in your current session. Alternatively, save the function code as an `.R` file (e.g., `HLM.R`) and load it using `source("HLM.R")`.
4.  **Prepare Data:** Create a numeric vector containing the scores in chronological order (session 1, session 2, etc.).
    ```R
    # Example scores
    my_scores <- c(10, 12, 11, 14, 15, 13, 16, 18) 
    ```
5.  **Run Function:** Call the function with your scores vector:
    ```R
    model_results <- HLM(my_scores)
    ```
6.  **Access Results:** The results are printed to the console, and the detailed output (including plots) is stored in the `model_results` list.
    ```R
    # View the main prediction plot
    print(model_results$prediction_plot) 
    
    # View diagnostic plots
    print(model_results$qq_plot)
    print(model_results$residuals_plot) 

    # Access specific parameters
    print(model_results$R2)
    print(model_results$harmonic_parameters)
    ```

## Input Requirements

*   **`scores`**: A numeric vector containing the sequence of scores over sessions. The order must be chronological.

## Output Interpretation

### Console Output

The function prints the following summary information to the console:

*   **R-squared:** The R² value for the final combined model.
*   **Residual Normality (p-value):** The p-value from the Shapiro-Wilk test on the combined model's residuals.
*   **Individual's Trend:** "Growth" or "Decline", based on the slope of the simple linear model fit.
*   **Optimized Parameters of Harmonic Model:** Intercept (a), Sine Coefficient (b), Cosine Coefficient (c), Internal Linear Trend (f), Frequency (freq), and the R² for this harmonic component.
*   **Parameters of Linear Model:** Intercept and Slope from the simple `lm` fit, and the R² for this linear component.

### Returned List (`model_results`)

The function returns a list containing the following elements:

*   **`R2`**: The R-squared value of the final combined model.
*   **`optimized_frequency`**: The optimized frequency (`freq`) parameter from the harmonic model component.
*   **`adjusted_data`**: A data frame containing the original `Session` and `Score`, plus `Predicted_Harmonic`, `Predicted_Linear`, `Predicted_Combined`, and `Residuals`.
*   **`prediction_plot`**: A `ggplot` object showing the raw scores and the fitted line from the combined model.
*   **`qq_plot`**: A `ggplot` object representing the Normal Q-Q plot of the combined model's residuals.
*   **`residuals_plot`**: A `ggplot` object showing the Residuals vs. Fitted values plot for the combined model.
*   **`harmonic_parameters`**: A list containing the optimized parameters of the harmonic component (`intercept`, `sine_coef`, `cosine_coef`, `linear_trend` (f), `frequency`).
*   **`linear_parameters`**: A list containing the parameters of the simple linear model component (`intercept`, `slope_coef`).

## Technology Stack

*   R
*   ggplot2
*   Base R (`optim`, `lm`, `shapiro.test`)

## How to Cite

### Citing this Function/Code:
Pedrosa, F. G. (2024). *HLM: R function for Harmonic Linear Model Estimation*. [Software]. Retrieved from https://github.com/FredPedrosa/HarmonicLinearModel

### Related Work Inspiration:
Araújo, J. de, & Blesa, H. (2024). Avaliando a trajetória do processo psicológico do indivíduo por meio de modelos. I Congresso Brasileiro de Psicometria e Análise de Dados, Porto Alegre. https://www.researchgate.net/publication/381741254_Avaliando_a_trajetoria_do_processo_psicologico_do_individuo_por_meio_de_modelos

## Author

*   **Prof. Dr. Frederico G. Pedrosa**
*   fredericopedrosa@ufmg.br


## License

This project is licensed under a modified version of the GNU General Public License v3.0.  
Commercial use is not permitted without explicit written permission from the author.
