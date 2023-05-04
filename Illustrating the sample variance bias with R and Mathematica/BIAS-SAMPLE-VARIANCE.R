set.seed(123) # for reproducibility

n <- 10 # sample size
N <- 1000 # number of simulations

true_variance <- 1 # true population variance

# create a function to simulate the bias in the sample variance estimator
sample_variance_bias <- function() {
  x <- rnorm(n, mean = 0, sd = sqrt(true_variance)) 
  # generate a sample from a normal distribution
  biased_estimator <- sum((x - mean(x))^2) / n 
  # compute the biased estimator (dividing by n instead of n-1)
  unbiased_estimator <- sum((x - mean(x))^2) / (n - 1) 
  # compute the unbiased estimator (dividing by n-1)
  return(biased_estimator - true_variance) 
  # return the bias of the biased estimator
}

# simulate the bias across N simulations
bias <- replicate(N, sample_variance_bias())

# plot the histogram of the bias
hist(bias, main = 
       "Histogram of Sample Variance Bias", xlab = "Bias", ylab = "Frequency")

#View(bias)
