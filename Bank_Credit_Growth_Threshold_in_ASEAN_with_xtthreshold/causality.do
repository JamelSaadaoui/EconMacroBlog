*Save the database in Stata format
*-------------------------------------------------------------------------

version 16.1
set more off
*cd "C:\Users\jamel\stata\gcasean" // Set the directory
capture log close
log using logs\causality.log, replace

// Use data in Stata format

use data\data_asean_final.dta, clear

// Install useful packages

*ssc install xtgcause, replace

// Prepare the panel data

rename cn country

encode country, generate(cn)

drop country

order cn code year, first

xtset cn year 

// Exploring causality in panel data 

xtgcause creditgdp gdpgpc, lags(aic)

xtgcause creditgdp gdpgpc, lags(bic)

xtgcause creditgdp gdpgpc, lags(hqic)

xtgcause creditgdp gdpgpc, lags(aic) bootstrap //-> Note 1

// Save the data
save data\causality.dta, ///
replace

log close
exit
 
Description
-----------

This file aims at running some causality tests.


Notes :
-------

1) GDP per capita does not Granger cause Banking credit since we accept the
   null. The p-values has been computed using 1000 bootstrap replications.