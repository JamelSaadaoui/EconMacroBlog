*Endogenous threshold regressions analyses (robustness without POP)
*-------------------------------------------------------------------------

version 17.0
set more off
*cd "C:\Users\jamel\Dropbox\stata\gcasean" // Set the directory
capture log close
log using logs\endo_threshold_gcasean.log, replace

use data\data_asean_final.dta, clear

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

// Inspect the dataset

xtdes //-> Note 1

des

xtsum //-> Note 2

sum

sum  gdpgpc creditgdp inv gov tot open pop inflation

outreg2 using results\sum, sum(log) tex replace

sum  gdpgpc creditgdp inv gov tot open pop inflation if creditgdp<=96.47

outreg2 using results\sumbelow if creditgdp<=96.47, sum(log) tex replace

sum  gdpgpc creditgdp inv gov tot open pop inflation if creditgdp>96.47

outreg2 using results\sumabove if creditgdp>96.47, sum(log) tex replace

summarize, detail

// Country list

label list cn

// Generate time dummies

forvalue num=1993(1)2019 {
		gen time_`num' = 0
        replace time_`num' = 1 if year==`num'
}

// Cross-sectional averages

foreach v in gdpgpc creditgdp inv gov tot open inflation {
	egen cr_`v'=mean(`v'), by(year)
}

foreach v in gdpgpc creditgdp inv gov tot open inflation {
	gen lcr_`v'=l.cr_`v'
}


*egen cr_creditgdp=mean(creditgdp), by(year)

// After the South East Asian Crisis

*drop if year<=1998

// Apply the Stata Journal scheme

*set scheme sj

// Plotting the Credit-to-GDP ratio

format %ty year

xtline creditgdp, ylabel(, angle(horizontal)) ylabel(, labsize(small)) /// 
tlabel(, grid) tlabel(, labsize(small))

capture graph rename creditgdp, replace
capture graph export figures\creditgdp.png, replace
capture graph export figures\creditgdp.pdf, replace

xtline creditgdp, ylabel(, angle(horizontal)) ylabel(, labsize(small)) /// 
tlabel(, grid) tlabel(, labsize(small)) overlay


capture graph rename creditgdpover, replace
capture graph export figures\creditgdpover.png, replace
capture graph export figures\creditgdpover.pdf, replace

xtline gdpgpc, ylabel(, angle(horizontal)) ylabel(, labsize(small)) /// 
tlabel(, grid) tlabel(, labsize(small)) yline(0) overlay

capture graph rename gdpgpcover, replace
capture graph export figures\gdpgpcover.png, replace
capture graph export figures\gdpgpcover.pdf, replace

// DPD threshold effects model with endogenous regressors


xtendothresdpd gdpgpc l.gdpgpc l(0).inv l(0).gov ///
l(0).tot l(0).open l(0).inflation  ///
, sig(0.05) grid(130) ///
thresv(creditgdp) stub(enr) pivar(creditgdp) ///
dgmmiv(gdpgpc, lagrange(3 4)) ///
fodeviation lagsret(1)

estat sargan

ereturn list

return list

estimate store GCA_1 //-> Note 3

capture graph rename enr_dethgrp endo_thres_gcasean, replace

graph close endo_thres_gcasean

capture graph export figures\endo_thres_gcasean.png, replace
capture graph export figures\endo_thres_gcasean.pdf, replace

graph describe endo_thres_gcasean

twoway line enr_lrofgamma enr_gamma if __000001, ///
xtitle("Threshold Parameter") ///
ytitle("Likelihood Ratio") ///
sort yline(7.352276694155739, lcolor(black) lpattern(longdash)) ///
name(endo_thres_gcasean_fin, replace)

capture graph export figures\endo_thres_gcasean_fin.png, replace
capture graph export figures\endo_thres_gcasean_fin.pdf, replace


// Observation above threshold

sum if creditgdp>=96.4703 

// With banking crises dummies

xtendothresdpd gdpgpc l.gdpgpc l(0).inv l(0).gov ///
l(0).tot l(0).open l(0).inflation  ///
bankingcrisislv currencycrisislv debtcrisislv debtrestruclv ///
, sig(0.05) grid(130) ///
thresv(creditgdp) stub(enr) pivar(creditgdp) ///
dgmmiv(gdpgpc, lagrange(3 4)) ///
fodeviation lagsret(1)

estat sargan

ereturn list

return list

estimate store GCA_2

capture graph rename enr_dethgrp endo_thres_lv_pop, replace

graph describe endo_thres_lv_pop

twoway line enr_lrofgamma enr_gamma if __000001, ///
xtitle("Threshold Parameter") ///
ytitle("Likelihood Ratio") ///
sort yline(7.352276694155739, lcolor(black) lpattern(longdash)) ///
name(endo_thres_lv_pop_fin, replace)

capture graph export figures\endo_thres_lv_pop_fin.png, replace
capture graph export figures\endo_thres_lv_pop_fin.pdf, replace
graph export figures\endo_thres_lv_pop_fin.svg, width(4000) replace

/*
// Bootstrap test for nonlinearity

xtendothresdpdtest, comdline(`e(cmdline)') reps(50)

ereturn list

matrix list e(b)

save boottest.dta, replace
*/

/*
use data_asean_final.dta, clear

capture drop cn
encode code, generate(cn)

xtset cn year  
*/

/*
// Generate time dummies

forvalue num=1993(1)2019 {
		gen time_`num' = 0
        replace time_`num' = 1 if year==`num'
}

// Cross-sectional averages

foreach v in gdpgpc creditgdp inv gov tot open inflation {
	egen cr_`v'=mean(`v'), by(year)
}

foreach v in gdpgpc creditgdp inv gov tot open inflation {
	gen lcr_`v'=l.cr_`v'
}
*/

// With banking crises and time dummies

xtendothresdpd gdpgpc l.gdpgpc l(0).inv l(0).gov ///
l(0).tot l(0).open l(0).inflation  ///
bankingcrisislv currencycrisislv debtcrisislv debtrestruclv ///
time_1997 time_2009 time_2010 ///
, sig(0.05) grid(130) ///
thresv(creditgdp) stub(enr) pivar(creditgdp) ///
dgmmiv(gdpgpc, lagrange(3 4)) ///
fodeviation lagsret(1)

estat sargan

ereturn list

return list

estimate store GCA_3

capture graph rename enr_dethgrp endo_thres_lv_time, replace

local switches "dec(4) excel se"

outreg2 [GCA*] using results\HJ_threshold.xml, replace `switches'


*Mian et al. (2015) - Instruments 3 and 4 lags for the credit-to-GDP ratio

/*
xtendothresdpd gdpgpc l.gdpgpc l(0).inv l(0).gov ///
l(0).pop l(0).tot l(0).open l(0).inflation  ///
bankingcrisislv currencycrisislv debtcrisislv debtrestruclv ///
year2009 year2010 ///
, sig(0.05) grid(130) ///
thresv(creditgdp) stub(enr) pivar(creditgdp) ///
dgmmiv(creditgdp, lagrange(3 4)) ///
vce(robust) fodeviation //-> Note 4
 */
 
**# Robustness check for the International Economics referee's reports

**OLS, FE, RE

*OLS

reg gdpgpc creditgdp inv gov tot open time_* bankingcrisislv currencycrisislv debtcrisislv debtrestruclv if creditgdp<=96.47
reg gdpgpc creditgdp inv gov tot open inflation time_* bankingcrisislv currencycrisislv debtcrisislv debtrestruclv if creditgdp>96.47

*FE

*without time dummies

xtreg gdpgpc creditgdp inv gov tot open inflation bankingcrisislv currencycrisislv debtcrisislv debtrestruclv if creditgdp<=96.47, fe

estimate store ROB_BELOW

*with time dummies

xtreg gdpgpc creditgdp inv gov tot open inflation time_* bankingcrisislv currencycrisislv debtcrisislv debtrestruclv if creditgdp<=96.47, fe

estimate store ROB_FE_BELOW

*without time dummies

xtreg gdpgpc creditgdp inv gov tot open inflation bankingcrisislv currencycrisislv debtcrisislv debtrestruclv if creditgdp>96.47, fe

estimate store ROB_ABOVE

*with time dummies

xtreg gdpgpc creditgdp inv gov tot open inflation time_* bankingcrisislv currencycrisislv debtcrisislv debtrestruclv if creditgdp>96.47, fe

estimate store ROB_FE_ABOVE

*gen lgdpgpc = l1.gdpgpc

**# Autocorrelation

**Serial correlation is avoided by the forward orthogonal deviation transformation (see page 864 of Kremer 2013).

// https://journals.sagepub.com/doi/pdf/10.1177/1536867X1801800106

xtreg gdpgpc creditgdp inv gov tot open inflation time_1997 time_2009 ///
 time_2010 *lv, fe
*xtqptest
xthrtest
*xtistest

xtreg gdpgpc creditgdp inv gov tot open inflation time_1997 time_2009 ///
 time_2010 *lv if creditgdp<=96.47, fe
 *xtqptest, lag(1)
 xthrtest
 *xtistest

xtreg gdpgpc creditgdp inv gov tot open inflation time_1997 time_2009 ///
 time_2010 *lv if creditgdp>96.47, fe
 *xtqptest, lag(1)
 xthrtest
 *xtistest

*RE

xtreg gdpgpc creditgdp inv gov tot open time_* bankingcrisislv currencycrisislv debtcrisislv debtrestruclv if creditgdp<=96.47, re
xtreg gdpgpc creditgdp inv gov tot open inflation time_* bankingcrisislv currencycrisislv debtcrisislv debtrestruclv if creditgdp>96.47, re

// Install the packages (only once)
/*
net from http://www.stata-journal.com/software
net cd sj15-1
net install st0373.pkg
*/

**Single threshold model (Hansen 1999)

*PTR

xthreg gdpgpc inv gov tot open time_* bankingcrisislv currencycrisislv debtcrisislv debtrestruclv, rx(creditgdp) qx(creditgdp) thnum(1) grid(400) 

*without time dummies

xthreg gdpgpc inv gov tot open inflation bankingcrisislv currencycrisislv debtcrisislv debtrestruclv, rx(creditgdp) qx(creditgdp) thnum(1) grid(100) trim(0.01) bs(100)

estimate store ROB_PTR

*with time dummies

xthreg gdpgpc inv gov tot open inflation time_* bankingcrisislv currencycrisislv debtcrisislv debtrestruclv, rx(creditgdp) qx(creditgdp) thnum(1) grid(100) trim(0.01) bs(300)

estimate store ROB_TE_PTR

local switches "dec(4) excel se"

outreg2 [ROB_*] using results\HJ_threshold_ROB.xml, replace `switches'

_matplot e(LR), yline(7.35, lpattern(dash)) connect(direct) msize(small) mlabp(0) mlabs(zero) ytitle("LR Statistics") xtitle("Threshold") recast(line)

capture graph rename Graph thres_lv_time, replace

ereturn list

return list

capture graph export figures\thres_gcasean_hansen_1999.png, replace
capture graph export figures\thres_gcasean_hansen_1999.pdf, replace

**without the variable population

xtendothresdpd gdpgpc l.gdpgpc l(0).inv l(0).gov ///
l(0).tot l(0).open l(0).inflation  ///
bankingcrisislv currencycrisislv debtcrisislv debtrestruclv ///
time_1997 time_1998 time_2001 time_2009 time_2010 ///
, sig(0.05) grid(130) ///
thresv(creditgdp) stub(enr) pivar(creditgdp) ///
dgmmiv(gdpgpc, lagrange(2 4)) ///
fodeviation lagsret(1)

estat sargan

estimate store GCA_POP

local switches "dec(4) excel se"

outreg2 [GCA_*] using results\HJ_threshold_POP.xml, replace `switches'

**# AR (2)

xtendothresdpd gdpgpc l.gdpgpc l(0).inv l(0).gov ///
l(0).tot l(0).open l(0).inflation  ///
currencycrisislv debtcrisislv debtrestruclv ///
time_1997 time_1998 time_2001 time_2009 time_2010 ///
, sig(0.05) grid(150) ///
thresv(creditgdp) stub(enr) pivar(creditgdp) ///
dgmmiv(creditgdp, lagrange(4 5)) ///
lagsret(1) vce(robust)

estat abond, artests(2)

estimate store ROB_AR2

/*
xtendothresdpd gdpgpc l.gdpgpc l(0).inv l(0).gov ///
l(0).tot l(0).open l(0).inflation  ///
currencycrisislv debtcrisislv debtrestruclv ///
time_1997 time_1998 time_2001 time_2009 time_2010 ///
, sig(0.05) grid(150) ///
thresv(creditgdp) stub(enr) pivar(creditgdp) ///
dgmmiv(creditgdp, lagrange(4 5)) ///
lagsret(1)

estat sargan

estimate store ROB_AR2BIS
*/

local switches "dec(4) word excel se"

outreg2 [ROB_AR2*] using results\HJ_ROB_AR2.xml, replace `switches'

**# Further robustness check


// Slope homogeneity

xthst gdpgpc l.gdpgpc inv gov ///
tot open inflation ///
, comparehac

xthst gdpgpc l.gdpgpc inv gov ///
tot open inflation ///
, cr(gdpgpc L.gdpgpc inv tot inflation, cr_lags(1 1 1 1 1)) ///
comparehac


// DPTR with cross-sectional averages

xtendothresdpd gdpgpc l.gdpgpc inv gov ///
tot open inflation lcr_* ///
bankingcrisislv currencycrisislv debtcrisislv debtrestruclv ///
, sig(0.05) grid(130) ///
thresv(creditgdp) stub(enr) pivar(creditgdp) ///
dgmmiv(gdpgpc, lagrange(2 4)) ///
fodeviation lagsret(1)

estat sargan

// XTPCSE

xtpcse gdpgpc creditgdp inv gov tot open inflation i.cn  ///
time_* *lv if creditgdp<=96.47, noconstant correlation(ar1) 

ereturn list

return list

xtpcse gdpgpc creditgdp inv gov tot open inflation i.cn  ///
if creditgdp<=96.47, noconstant correlation(psar1)

xtpcse gdpgpc creditgdp inv gov tot open inflation i.cn  ///
time_* *lv if creditgdp<=96.47, noconstant correlation(psar1) 

ereturn list

return list

xtpcse gdpgpc creditgdp inv gov tot open inflation i.cn  ///
time_* *lv if creditgdp>96.47, noconstant correlation(ar1)

ereturn list

return list

xtpcse gdpgpc creditgdp inv gov tot open inflation i.cn  ///
if creditgdp>96.47, noconstant correlation(psar1)

xtpcse gdpgpc creditgdp inv gov tot open inflation i.cn  ///
time_* *lv if creditgdp>96.47, noconstant correlation(psar1) 

ereturn list

return list

// Save the data
save data\data_endothres_gcasean.dta, ///
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