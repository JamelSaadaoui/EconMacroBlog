/*

In the context of hypothesis testing, power and size are important concepts related to the performance of the test. Specifically, for a two-sample t-test, which compares the means of two groups to determine whether there is a significant difference between them, these concepts can be defined as follows:

Power: Power is the probability that a test will correctly reject the null hypothesis when the alternative hypothesis is true. In other words, it measures the ability of the test to detect an actual effect (i.e., a true difference between the two groups). A higher power means that the test is more likely to identify a significant difference when one exists. The power of a test is influenced by factors such as sample size, effect size (the magnitude of the difference between the groups), and the significance level.

Size (or Significance Level): The size of a test, commonly denoted by alpha (α), is the probability of rejecting the null hypothesis when it is true. This is also known as a Type I error, or a false positive. The significance level is a threshold that determines how strong the evidence against the null hypothesis must be before it can be rejected. Commonly used significance levels are 0.05 and 0.01, which correspond to a 5% and 1% chance of making a Type I error, respectively.

For a two-sample t-test, the goal is to strike a balance between the power and size of the test. Ideally, you want to have high power to detect true effects and a low significance level to minimize the chances of making Type I errors. Increasing the sample size is one way to achieve higher power without increasing the risk of Type I errors.

In practice, researchers often conduct a power analysis before starting a study to determine the appropriate sample size needed to achieve the desired power and significance level. This helps ensure that the study is adequately powered to detect meaningful effects while minimizing the risk of false positives.


*/


cls
clear

* Set up parameters for power analysis
local alpha = 0.05   // significance level
local effect_size = 0.3 // expected effect size

* Set up range of sample sizes
local min_n = 10
local max_n = 1000
local step_n = 5

* Calculate the number of steps
local num_steps = round((`max_n' - `min_n') / `step_n' + 1)

* Create dataset with sample sizes
clear
set obs `num_steps'
gen sample_size = .
gen power = .
local i = 1

* Define a program to calculate power for a given sample size
capture program drop calc_power
program calc_power, rclass
    args n alpha effect_size
    sampsi 0.0 `effect_size', sd(1.0) n(`n') alpha(`alpha')
    return scalar power = r(power)
end

/*

Here's a detailed explanation of each line in this part of the code:

capture program drop calc_power: This line ensures that if a program named calc_power already exists, it will be removed before the new program is defined. capture prevents Stata from displaying an error message if the program does not exist.

program calc_power, rclass: This line starts the definition of a new program named calc_power. The rclass option specifies that the program will return results in the r() return list, which can be accessed after the program is executed.

args n alpha effect_size: This line specifies that the program takes three arguments: n (sample size), alpha (significance level), and effect_size (expected effect size). These arguments will be passed to the program when it's called.

sampsi 0.0 effect_size', sd(1.0) n(n') alpha(alpha'): This line calls Stata's built-in sampsi` command to perform a sample size and power analysis. The command calculates the power for a two-sample t-test with the given effect size, sample size, and significance level, assuming a standard deviation of 1.0 for both groups.

return scalar power = r(power): This line stores the calculated power from the sampsi command in a scalar named power. The r(power) refers to the power value that is stored in the r() return list after running the sampsi command. By assigning the value to a scalar in the return list, it can be easily accessed outside the program.

end: This line marks the end of the calc_power program definition.


*/

* Calculate power for each sample size, store and display the results
forvalues n = `min_n'(`step_n')`max_n' {
    calc_power `n' `alpha' `effect_size'
    local power = r(power)
    display "Sample size: " `n' " Power: " `power'
    replace sample_size = `n' in `i'
    replace power = `power' in `i'
    local i = `i' + 1
}


* Generate a scatter plot of power vs sample size
scatter power sample_size, ///
        xscale(range(`min_n' `max_n')) ylabel(0(0.1)1) /// 
        xtitle("Sample Size") ytitle("Power") ///
        title("Power Analysis") ///
        legend(off) ///
        msymbol(O) msize(small)

* Save the graph as a PNG file
graph export "power_analysis_plot.png", replace

