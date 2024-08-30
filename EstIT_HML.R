EstIT_HLM <- function(scores) {
  # Load necessary packages
  library(ggplot2)
  
  # Error function for harmonic model optimization
  harmonic_model_error <- function(params, scores) {
    freq <- params[1]  # Frequency
    f <- params[2]     # Linear Trend
    a <- params[3]     # Intercept
    b <- params[4]     # Sine Coefficient
    c <- params[5]     # Cosine Coefficient
    
    subject <- data.frame(Score = scores, Session = seq_along(scores))
    
    # Harmonic model with optimized frequency and linear trend
    subject$Predicted <- a + b * sin(freq * subject$Session) + c * cos(freq * subject$Session) + f * subject$Session
    
    # Error to be minimized (squared residuals)
    sum((subject$Score - subject$Predicted)^2)
  }
  
  # Initial parameters for the harmonic model
  start_params <- c(freq = 1, f = 0, a = mean(scores), b = 1, c = 1)
  
  # Optimization of harmonic model parameters
  optim_result <- optim(par = start_params, fn = harmonic_model_error, scores = scores)
  best_freq <- optim_result$par[1]
  best_f <- optim_result$par[2]
  best_a <- optim_result$par[3]
  best_b <- optim_result$par[4]
  best_c <- optim_result$par[5]
  
  # Final fit of the harmonic model with optimized parameters
  subject <- data.frame(Score = scores, Session = seq_along(scores))
  subject$Predicted_Harmonic <- best_a + best_b * sin(best_freq * subject$Session) + 
    best_c * cos(best_freq * subject$Session) + best_f * subject$Session
  
  # Fit of a simple linear regression model
  linear_model <- lm(Score ~ Session, data = subject)
  subject$Predicted_Linear <- predict(linear_model, newdata = subject)
  
  # Calculate R² for each model
  R2_harmonic <- 1 - sum((subject$Score - subject$Predicted_Harmonic)^2) / sum((subject$Score - mean(subject$Score))^2)
  R2_linear <- summary(linear_model)$r.squared
  
  # Weighted combination of harmonic and linear models by R²
  subject$Predicted_Combined <- (R2_harmonic * subject$Predicted_Harmonic + R2_linear * subject$Predicted_Linear) / 
    (R2_harmonic + R2_linear)
  
  # Calculate residuals
  subject$Residuals <- subject$Score - subject$Predicted_Combined
  
  # Calculate R² for the combined model
  R2_combined <- 1 - sum((subject$Score - subject$Predicted_Combined)^2) / sum((subject$Score - mean(subject$Score))^2)
  
  # Residuals vs. Fitted Values Plot
  plot_residuals <- ggplot(subject, aes(x = Predicted_Combined, y = Residuals)) +
    geom_point() +
    geom_hline(yintercept = 0, linetype = "dashed", color = "blue") +
    theme_classic() +
    labs(title = "Residuals vs. Fitted Values",
         x = "Fitted Values",
         y = "Residuals")
  
  # Q-Q Plot to check normality of residuals
  plot_qq <- ggplot(subject, aes(sample = Residuals)) +
    stat_qq() +
    stat_qq_line(color = "blue") +
    theme_classic() +
    labs(title = "Residuals Q-Q plot")
  
  # Shapiro-Wilk test for normality of residuals
  shapiro_result <- shapiro.test(subject$Residuals)
  
  # Function to create the harmonic linear prediction plot
  plot_harmonic_linear <- function(model_result, limits = c(0, 68)) {
    # Load the ggplot2 package
    library(ggplot2)
    
    # Extract the adjusted data from the model result
    subject <- model_result$adjusted_data
    
    # Create a dataframe with session values and observed and predicted scores
    df <- data.frame(
      Session = subject$Session,              # Sessions
      Score = subject$Score,                  # Observed scores
      Predicted = subject$Predicted_Combined  # Predicted scores (combined by the model)
    )
    
    # Build the plot with observed and predicted scores
    p <- ggplot(df, aes(x = Session)) +
      geom_point(aes(y = Score, color = "Raw Data"), size = 2) +  # Points for observed data
      geom_line(aes(y = Predicted, color = "Combined Model"), linewidth = 1) +  # Line for predicted values
      scale_color_manual(values = c("Raw Data" = "black", "Combined Model" = "blue"),
                         name = "Legend",
                         labels = c("HL Model", "Raw Data" )) +
      labs(subtitle = "Estimated by Harmonic Linear Model",
           x = "Sessions", y = "Score") +  # Axis labels
      ylim(limits) +  # Y-axis limits
      theme_classic()  # Classic theme for the plot
    
    # Return the plot
    return(p)
  }
  
  # Create the prediction plot using the internal function
  plot_model <- plot_harmonic_linear(list(adjusted_data = subject))
  
  # Final model results
  cat("\n========== Harmonic Linear Model Results ==========\n")
  cat("R²: ", round(R2_combined, 4), "\n")
  cat("Residual Normality (p-value): ", round(shapiro_result$p.value, 4), "\n")
  
  # Determine trend based on the linear regression coefficient
  trend <- ifelse(coef(linear_model)[2] > 0, "Growth", "Decline")
  
  # Output to indicate the individual's trend
  cat("Individual's Trend: ", trend, "\n\n")
  
  cat("Optimized Parameters of Harmonic Model:\n")
  cat("Intercept (a): ", round(best_a, 4), "\n")
  cat("Sine Coefficient (b): ", round(best_b, 4), "\n")
  cat("Cosine Coefficient (c): ", round(best_c, 4), "\n")
  cat("Linear Trend (f): ", round(best_f, 4), "\n")
  cat("Frequency (freq): ", round(best_freq, 4), "\n\n")
  
  cat("Parameters of Linear Model:\n")
  cat("Linear Intercept: ", round(coef(linear_model)[1], 4), "\n")
  cat("Linear Coefficient (Slope): ", round(coef(linear_model)[2], 4), "\n\n")
  
  # Return results including plots and parameters
  return(list(
    R2 = R2_combined,
    optimized_frequency = best_freq,
    adjusted_data = subject,
    prediction_plot = plot_model,
    qq_plot = plot_qq,
    residuals_plot = plot_residuals,
    harmonic_parameters = list(
      intercept = best_a,
      sine_coef = best_b,
      cosine_coef = best_c,
      linear_trend = best_f,
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
scores <- c(6,6,8,8,7)

# Running the harmonic linear model estimation
model_results <- EstIT_HLM(scores)

# Plotting diagnostic plots
plot_HML <-model_results$prediction_plot
plot_HML +
  ylim(0, 15)

print(model_results$qq_plot)
print(model_results$residuals_plot)


