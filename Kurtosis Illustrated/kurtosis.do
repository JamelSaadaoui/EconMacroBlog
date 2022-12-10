****************************************************************
******** Illustrate the Kurtosis with some graphs **************
****************************************************************
****************************************************************

version 15.1
set more off
cd "C:\Users\jamel\Documents\GitHub"
cd "EconMacroBlog\Kurtosis Illustrated" // Set the directory


cls
clear

capture log close _all                            
log using kurtosis, name(kurtosis) text replace

// Apply the s2color scheme

set scheme s2color

// Generate random variables

set obs 10000

// Normal variable

capture gen normal = rnormal()

sum normal, detail

// Uniform variable

capture gen uniform = runiform(-5,5)

sum uniform, detail

// Laplace variable

capture gen laplace = rlaplace(0,1)

sum laplace, detail

/* histogram normal, frequency title("Normal, K=3") ///
subtitle(mesokurtic) kdensity
 */

histogram normal, title("Normal, K=3") ///
subtitle(mesokurtic) kdensity

capture graph rename normal, replace
capture graph export figures\normal.png, replace

/* histogram uniform, frequency title("Uniform, K=1.8") ///
subtitle(platykurtic) kdensity
 */

histogram uniform, title("Uniform, K=1.8") ///
subtitle(platykurtic) kdensity

capture graph rename uniform, replace
capture graph export figures\uniform.png, replace

/* histogram laplace, frequency title("Uniform, K=6") ///
subtitle(platikurtic) kdensity
 */
 
histogram laplace, title("Laplace, K=6") ///
subtitle(leptokurtic) kdensity

capture graph rename laplace, replace
capture graph export figures\laplace.png, replace

graph combine normal uniform laplace, ycommon xcommon imargin(zero) ///
title(Kurtosis) ///
subtitle("Ilustration with Normal, Uniform and Laplace distribution")

capture graph rename kurtosis, replace
capture graph export figures\kurtosis.png, replace

twoway (kdensity normal) (kdensity uniform) (kdensity laplace), ///
title(Kurtosis) ///
subtitle("Ilustration with Normal, Uniform and Laplace distr.")

capture graph rename kurtosis_gathered, replace
capture graph export figures\kurtosis_gathered.png, replace

// Save the data
save data\kurtosis.dta, replace

log close kurtosis
exit

Description
-----------

This file aims at illustrating the Kurtosis formula with strinking graphs

Notes :
-------
1)