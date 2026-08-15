*Endogenous threshold regressions analyses
*-------------------------------------------------------------------------

version 16.1
set more off
*cd "C:\Users\jamel\stata\gcasean" // Set the directory

use data\data_asean_final.dta, clear

// Prepare the panel data

rename cn country

encode country, generate(cn)

drop country

order cn code year, first

xtset cn year  

*browse

// Label the variables

label variable cn "Country"
label variable year "Date"
label variable gdpgpc "Annual growth rate of GDP per capita"
label variable inv "Annual percentage change in investment"
label variable gov "Annual percentage change in government expenditure"
label variable tot "Terms of trade"
label variable open "Openness ratio"
label variable pop "Annual percentage change of population"
label variable inflation "Annual percentage change of the CPI"
label variable creditgrowth "Annual percentage change of bank credit"
label variable creditgdp "Credit-to-GDP ratio"
label variable bankingcrisislv "Dummy for bank crises"
label variable currencycrisislv "Dummy for currency crises"
label variable debtcrisislv "Dummy for sovereign debt crises"
label variable debtrestruclv "Dummy for debt restructuring"
label variable allyearsbankingcrisis "Dummy for all year bank crises"

// Apply the Stata Journal scheme

set scheme sj

// Putexcel example

xtgcause creditgdp gdpgpc, lags(aic)

*help xtgcause

return list

*putexcel set "causality"

putexcel set results\causality, replace

putexcel B2 = `r(wbar)', nformat(number_d2)
putexcel C2 = `r(zbar)', nformat(number_d2)
putexcel C2 = `r(zbar_pv)', nformat(number_d2)

putexcel E2 = matrix(r(Wi)), colnames
putexcel F2 = matrix(r(PVi)), colnames

putexcel describe

*https://blog.stata.com/2017/01/24/creating-excel-tables-with-putexcel
*-part-2-macro-picture-matrix-and-formula-expressions/

exit
 
Description
-----------


Notes :
-------

1) 