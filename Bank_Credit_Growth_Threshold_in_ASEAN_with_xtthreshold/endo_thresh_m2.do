*Endogenous threshold regressions analyses
*-------------------------------------------------------------------------

version 17.0
set more off
capture log close
log using logs\endo_thres_m2.log, replace

use data\data_asean_final_m2.dta, clear

// Install useful packages

*capture ssc install xtendothresdpd
*capture ssc install outreg2

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
label variable m2gdp "M2-to-GDP ratio"


// Inspect the dataset

xtdes //-> Note 1

des

xtsum //-> Note 2

/*
sum

sum  gdpgpc creditgdp inv gov tot open pop inflation

outreg2 using sum, sum(log) tex replace

sum  gdpgpc creditgdp inv gov tot open pop inflation if creditgdp<=96.47

outreg2 using sumbelow if creditgdp<=96.47, sum(log) tex replace

sum  gdpgpc creditgdp inv gov tot open pop inflation if creditgdp>96.47

outreg2 using sumabove if creditgdp>96.47, sum(log) tex replace

summarize, detail
*/

// Country list

label list cn

// Generate time dummies

forvalue num=1993(1)2019 {
		gen time_`num' = 0
        replace time_`num' = 1 if year==`num'
}

// After the South East Asian Crisis

*drop if year<=1998

// Apply the Stata Journal scheme

set scheme sj

// Plotting the Credit-to-GDP ratio

format %ty year

xtline m2gdp, ylabel(, angle(horizontal)) ylabel(, labsize(small)) /// 
tlabel(, grid) tlabel(, labsize(small))

capture graph rename m2gdp, replace
capture graph export figures\m2gdp.png, replace
capture graph export figures\creditgdp.pdf, replace

xtline m2gdp, ylabel(, angle(horizontal)) ylabel(, labsize(small)) /// 
tlabel(, grid) tlabel(, labsize(small)) overlay


capture graph rename m2gdpover, replace
capture graph export figures\m2gdpover.png, replace
capture graph export figures\m2gdpover.pdf, replace

/*
xtline gdpgpc, ylabel(, angle(horizontal)) ylabel(, labsize(small)) /// 
tlabel(, grid) tlabel(, labsize(small)) yline(0) overlay

capture graph rename gdpgpcover, replace
capture graph export gdpgpcover.png, replace
capture graph export gdpgpcover.pdf, replace
*/

// OLS, FE, RE

*OLS

reg gdpgpc m2gdp inv gov tot open time_* bankingcrisislv currencycrisislv debtcrisislv debtrestruclv if creditgdp<=96.47
reg gdpgpc m2gdp inv gov tot open inflation time_* bankingcrisislv currencycrisislv debtcrisislv debtrestruclv if creditgdp>96.47

*FE

xtreg gdpgpc m2gdp inv gov tot open inflation time_* bankingcrisislv currencycrisislv debtcrisislv debtrestruclv, fe

*without time dummies

xtreg gdpgpc m2gdp inv gov tot open inflation bankingcrisislv currencycrisislv debtcrisislv debtrestruclv if creditgdp<=96.47, fe

estimate store M2_FE_BELOW

*with time dummies

xtreg gdpgpc m2gdp inv gov tot open inflation time_* bankingcrisislv currencycrisislv debtcrisislv debtrestruclv if creditgdp<=96.47, fe

estimate store M2_FE_TE_BELOW

*without time dummies

xtreg gdpgpc m2gdp inv gov tot open inflation bankingcrisislv currencycrisislv debtcrisislv debtrestruclv if creditgdp>96.47, fe

estimate store M2_FE_ABOVE

*with time dummies

xtreg gdpgpc m2gdp inv gov tot open inflation time_* bankingcrisislv currencycrisislv debtcrisislv debtrestruclv if creditgdp>96.47, fe

estimate store M2_FE_TE_ABOVE

// PTR

**Single threshold model (Hansen 1999)

*without time dummies

xthreg gdpgpc inv gov tot open inflation bankingcrisislv currencycrisislv debtcrisislv debtrestruclv, rx(m2gdp) qx(creditgdp) thnum(1) grid(400) trim(0.01) bs(150)

estimate store M2_PTR

*with time dummies

xthreg gdpgpc inv gov tot open inflation time_* bankingcrisislv currencycrisislv debtcrisislv debtrestruclv, rx(m2gdp) qx(creditgdp) thnum(1) grid(400) trim(0.01) bs(400)

estimate store M2_TE_PTR

local switches "dec(4) excel se"

outreg2 [M2_*] using results\HJ_threshold_M2.xml, replace `switches'

_matplot e(LR), yline(7.35, lpattern(dash)) connect(direct) msize(small) mlabp(0) mlabs(zero) ytitle("LR Statistics") xtitle("Threshold") recast(line)

// local switches "dec(4) excel se"

// outreg2 [M2_*] using "HJ_threshold.xml", replace `switches'

// Save the data
save data\data_endothres_gcasean_m2.dta, ///
replace

log close
exit
 
Description
-----------

This file aims at investigating the nonlinear relationship between bank
credit and short-run economic growth thank to dynamic panel data threshold
effects model with endogenous regressors.

Notes :
-------

1) The panel is strongly balance (the time span is the same for each 
   member of the panel). We have 189 observations (n==7 & T==27).
2) The mean of credit-to-GDP ratio is 81.77 (overall).
3) The results are robust to the inclusion of banking crises dummies (LV).
4) The non-significant time dummies has been removed with a general to 
   specific approach.