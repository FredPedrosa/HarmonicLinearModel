HLM <- function(scores) {
  # Load the ggplot2 package necessary for plotting.
  # Note: Ideally, package dependencies are declared outside the function.
  library(ggplot2) 
  
  # --- Error Function Definition for Optimization ---
  # This function calculates the error (sum of squared residuals) for a set
  # of harmonic model parameters, given the observed scores.
  # The goal of the optimization (via 'optim') will be to minimize the value returned by this function.
  harmonic_model_error <- function(params, scores) {
    # Extract parameters from the 'params' vector:
    freq <- params[1]  # Angular frequency (speed of oscillation)
    f <- params[2]     # Linear Trend coefficient ('f' in the model formula)
    a <- params[3]     # Intercept (baseline value at session 0, adjusted by cosine component)
    b <- params[4]     # Sine component coefficient (amplitude related to sine)
    c <- params[5]     # Cosine component coefficient (amplitude related to cosine)
    
    # Create a temporary dataframe with scores and session number (time)
    subject <- data.frame(Score = scores, Session = seq_along(scores))
    
    # Calculate the predicted values by the harmonic model + linear trend for the current parameters
    subject$Predicted <- a + b * sin(freq * subject$Session) + c * cos(freq * subject$Session) + f * subject$Session
    
    # Return the Sum of Squared Residuals (Total Squared Error)
    # This is the value that the 'optim' function will try to minimize.
    sum((subject$Score - subject$Predicted)^2) 
  }
  
  # --- Optimization of Harmonic Model Parameters + Trend 'f' ---
  # Define initial values (guesses) for the parameters to be optimized.
  # Choosing good starting values can help the optimization converge.
  start_params <- c(freq = 1,  # Initial frequency
                    f = 0,     # Initial linear trend (no trend)
                    a = mean(scores), # Initial intercept (mean of scores)
                    b = 1,     # Initial sine coefficient
                    c = 1)     # Initial cosine coefficient
  
  # Perform the optimization using the 'optim' function.
  # 'par' are the initial parameters.
  # 'fn' is the error function to minimize.
  # 'scores' are the data passed to the 'harmonic_model_error' function.
  # 'optim' searches for the 'par' values that minimize 'fn'.
  optim_result <- optim(par = start_params, fn = harmonic_model_error, scores = scores)
  
  # Extract the optimized parameters found by 'optim'.
  best_freq <- optim_result$par[1]
  best_f <- optim_result$par[2]  # Optimized linear trend WITHIN the harmonic model
  best_a <- optim_result$par[3]
  best_b <- optim_result$par[4]
  best_c <- optim_result$par[5]
  
  # --- Model Calculation and Combination ---
  # Create the final dataframe that will store data and predictions.
  subject <- data.frame(Score = scores, Session = seq_along(scores))
  
  # Calculate predicted values using the harmonic model with optimized parameters.
  subject$Predicted_Harmonic <- best_a + best_b * sin(best_freq * subject$Session) + 
    best_c * cos(best_freq * subject$Session) + best_f * subject$Session
  
  # Fit a simple linear regression model (Score ~ Session) for comparison.
  linear_model <- lm(Score ~ Session, data = subject)
  # Calculate predicted values from this simple linear model.
  subject$Predicted_Linear <- predict(linear_model, newdata = subject)
  
  # Calculate R² (coefficient of determination) for each model individually.
  # R² represents the proportion of score variance explained by each model.
  R2_harmonic <- 1 - sum((subject$Score - subject$Predicted_Harmonic)^2) / sum((subject$Score - mean(subject$Score))^2)
  R2_linear <- summary(linear_model)$r.squared
  
  # Combine the predictions from the harmonic and linear models.
  # This is a **custom** combination approach: a weighted average of predictions,
  # where the weights are the respective R² values of each model.
  # Models with higher R² (explaining more variance individually) have more weight in the combined prediction.
  # Note: Check if R2_harmonic + R2_linear is not zero to avoid division by zero, although unlikely.
  subject$Predicted_Combined <- (R2_harmonic * subject$Predicted_Harmonic + R2_linear * subject$Predicted_Linear) / 
    (R2_harmonic + R2_linear)
  
  # Calculate residuals of the combined model (difference between observed and combined predicted).
  subject$Residuals <- subject$Score - subject$Predicted_Combined
  
  # Calculate R² for the final combined model.
  R2_combined <- 1 - sum((subject$Score - subject$Predicted_Combined)^2) / sum((subject$Score - mean(subject$Score))^2)
  
  # --- Residual Diagnostics ---
  # Generate a Residuals vs. Fitted Values plot.
  # Useful for checking homoscedasticity (constant variance of residuals) and absence of patterns.
  plot_residuals <- ggplot(subject, aes(x = Predicted_Combined, y = Residuals)) +
    geom_point() +
    geom_hline(yintercept = 0, linetype = "dashed", color = "blue") + # Reference line at y=0
    theme_classic() +
    labs(title = "Residuals vs. Fitted Values",
         x = "Fitted Values",
         y = "Residuals")
  
  # Generate a Q-Q (Quantile-Quantile) plot of the residuals.
  # Useful for visually checking if residuals follow a normal distribution.
  # Points should approximately follow the blue diagonal line.
  plot_qq <- ggplot(subject, aes(sample = Residuals)) +
    stat_qq() +          # Plots residual quantiles vs. theoretical normal quantiles
    stat_qq_line(color = "blue") + # Adds the reference line
    theme_classic() +
    labs(title = "Normal Q-Q Plot of Residuals") # Title kept simple as original
  
  # Perform the Shapiro-Wilk test for normality of residuals.
  # Null hypothesis (H0): The residuals come from a normal distribution.
  # A high p-value (e.g., > 0.05) suggests no evidence to reject normality.
  shapiro_result <- shapiro.test(subject$Residuals)
  
  # --- Internal Function for Prediction Plot ---
  # Defines a helper function to create the time series plot with raw data and combined predictions.
  plot_harmonic_linear <- function(model_result, limits = c(0, 68)) { # Keeps the original default limit
    # Load ggplot2 again (not ideal, but maintaining original structure)
    library(ggplot2) 
    
    # Extract the adjusted data (with predictions) from the model result passed as argument
    subject_data <- model_result$adjusted_data 
    
    # Create a dataframe formatted for ggplot
    df <- data.frame(
      Session = subject_data$Session,              
      Score = subject_data$Score,                  
      Predicted = subject_data$Predicted_Combined  
    )
    
    # Build the plot
    p <- ggplot(df, aes(x = Session)) +
      # Points for observed (raw) data
      geom_point(aes(y = Score, color = "Raw Data"), size = 2) +  
      # Line for predicted values from the combined model
      geom_line(aes(y = Predicted, color = "Combined Model"), linewidth = 1) +  
      # Define colors and legend names (keeping originals)
      scale_color_manual(values = c("Raw Data" = "black", "Combined Model" = "blue"),
                         name = "Legend", 
                         labels = c("HL Model", "Raw Data")) + 
      labs(subtitle = "Estimated by Harmonic Linear Model", # Keeps original subtitle
           x = "Sessions", y = "Score") +  
      # Apply Y-axis limits (keeping original default)
      ylim(limits) + 
      theme_classic()  
    
    # Return the ggplot object
    return(p)
  }
  
  # --- Final Plot Generation and Result Printing ---
  # Call the internal function to create the prediction plot.
  # Passes the list containing 'adjusted_data', which is the 'subject' dataframe.
  # Keeps the original default limit of c(0, 68).
  plot_model <- plot_harmonic_linear(list(adjusted_data = subject)) 
  
  # Print a summary of results to the console using 'cat' (original format).
  cat("\n========== Harmonic Linear Model Results ==========\n")
  cat("R-squared: ", round(R2_combined, 4), "\n") # Changed R² to R-squared
  cat("Residual Normality (p-value): ", round(shapiro_result$p.value, 4), "\n")
  
  # Determine the overall trend ("Growth" or "Decline") based ONLY
  # on the slope coefficient of the SIMPLE LINEAR regression model.
  # Note: This does not use the optimized 'f' parameter from the harmonic model.
  trend <- ifelse(coef(linear_model)[2] > 0, "Growth", "Decline")
  
  # Print the individual's trend (original format).
  cat("Individual's Trend: ", trend, "\n\n")
  
  # Print the harmonic model parameters (original format).
  cat("Optimized Parameters of Harmonic Model:\n")
  cat("Intercept (a): ", round(best_a, 4), "\n")
  cat("Sine Coefficient (b): ", round(best_b, 4), "\n")
  cat("Cosine Coefficient (c): ", round(best_c, 4), "\n")
  cat("Linear Trend (f): ", round(best_f, 4), "\n")
  cat("Frequency (freq): ", round(best_freq, 4), "\n")
  cat("R-squared harmonic: ", round(R2_harmonic, 4), "\n\n") # Changed R² to R-squared
  
  # Print the linear model parameters (original format).
  cat("Parameters of Linear Model:\n")
  cat("Linear Intercept: ", round(coef(linear_model)[1], 4), "\n")
  cat("Linear Coefficient (Slope): ", round(coef(linear_model)[2], 4), "\n")
  cat("R-squared linear: ", round(R2_linear, 4), "\n\n") # Changed R² to R-squared
  
  
  # --- Return Results ---
  # Return a list containing the main results and objects for further analysis.
  # List element names kept exactly as in the original Portuguese version.
  # qq_plot and residuals_plot are now uncommented.
  return(list(
    R2 = R2_combined,
    optimized_frequency = best_freq,
    adjusted_data = subject,
    prediction_plot = plot_model,
    qq_plot = plot_qq,                # Now included in the return list
    residuals_plot = plot_residuals,  # Now included in the return list
    harmonic_parameters = list(
      intercept = best_a,
      sine_coef = best_b,
      cosine_coef = best_c,
      linear_trend = best_f,  # Original name kept
      frequency = best_freq
    ),
    linear_parameters = list(
      intercept = coef(linear_model)[1],
      slope_coef = coef(linear_model)[2]
    )
  ))
} 


# Example usage of the EstIT_HLM function 

# Sample score data
#scores <- c(6, 6, 8, 8, 7) # Example data

# Running the harmonic linear model estimation
#model_results <- HLM(scores)

# Accessing and printing diagnostic plots
#print(model_results$prediction_plot) # Show the main prediction plot

# Diagnostic plots can now be accessed and printed:
#print(model_results$qq_plot) 
#print(model_results$residuals_plot)

# Example of modifying the prediction plot limits after generation
#model_results$prediction_plot + ylim(0, 15) 


