clear
/* Set the number of simulations */
local nsim = 1000

/* Create an empty matrix to store the results */
matrix results = J(`nsim', 1, .)

/* Loop over the simulations */
forvalues i = 1/`nsim' {
    /* Simulate the data */
    clear
    set obs 100
    gen x = rnormal()
    gen y = 2*x + rnormal()

    /* Estimate the model */
    reg y x

    /* Store the coefficient estimate */
    matrix results[`i',1] = _b[x]
}


/* Store the results in a matrix */

matrix list results

svmat double results, name(results)

/* Calculate the mean and standard deviation of the results */
sum results, detail

return list

/* Store mean and standard deviation in local macros */
local mean = r(mean)
local sd = r(sd)

/* Print mean and standard deviation to screen */
di "Mean: " `r(mean)'
di "Standard deviation: " `r(sd)'

/* Distribution of the estimates */

set scheme white_tableau

capture drop pres
pctile pres = results, nquantiles(1000)
return list

scalar p025 = r(r25)
scalar p975 = r(r975)
display `r(r25)'
display `r(r975)'
histogram results, xline(`r(r25)' `r(r975)')

graph export "C:\Users\jamel\Dropbox\stata\0_AI\Graph.png", ///
      as(png) name("Graph") replace

/* The end */	  