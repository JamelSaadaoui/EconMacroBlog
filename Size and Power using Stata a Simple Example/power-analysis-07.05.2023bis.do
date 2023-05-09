cls
clear

* Set up parameters for power analysis
local alphas = "0.01 0.025 0.05 0.1 0.2" // different significance levels
local effect_size = 0.3 // expected effect size

* Set up range of sample sizes
local min_n = 10
local max_n = 500
local step_n = 5

* Calculate the number of steps
local num_steps = round((`max_n' - `min_n') / `step_n' + 1)

* Define a program to calculate power for a given sample size and alpha
capture program drop calc_power
program calc_power, rclass
    args n alpha effect_size
    sampsi 0.0 `effect_size', sd(1.0) n(`n') alpha(`alpha')
    return scalar power = r(power)
end

* Create a dataset with sample sizes
clear
set obs `num_steps'
gen sample_size = .

* Generate variables for power at different alpha levels
foreach a in `alphas' {
    local a_underscored: subinstr local a "." "_", all
    gen power_alpha_`a_underscored' = .
}


* Loop through each alpha value and calculate power for each sample size
foreach a in `alphas' {
    local a_underscored: subinstr local a "." "_", all
    local i = 1
    forvalues n = `min_n'(`step_n')`max_n' {
        calc_power `n' `a' `effect_size'
        local power = r(power)
        display "Alpha: " `a' " Sample size: " `n' " Power: " `power'
        replace sample_size = `n' in `i'
        replace power_alpha_`a_underscored' = `power' in `i'
        local i = `i' + 1
    }
}


* Generate a scatter plot of power vs sample size for all alphas
twoway (scatter power_alpha_0_01 sample_size, msymbol(O) msize(small)) ///
       (scatter power_alpha_0_025 sample_size, msymbol(O) msize(small)) ///
       (scatter power_alpha_0_05 sample_size, msymbol(O) msize(small)) ///
       (scatter power_alpha_0_1 sample_size, msymbol(O) msize(small)) ///
       (scatter power_alpha_0_2 sample_size, msymbol(O) msize(small)), ///
        xscale(range(`min_n' `max_n')) ylabel(0(0.1)1) ///
        xtitle("Sample Size") ytitle("Power") ///
        title("Power Analysis") ///
        legend(order(1 "Alpha = 0.01" 2 "Alpha = 0.025" 3 "Alpha = 0.05" ///
                    4 "Alpha = 0.1" 5 "Alpha = 0.2"))


* Save the graph as a PNG file
graph export "power_analysis_plot_combined.png", replace

save power, replace
