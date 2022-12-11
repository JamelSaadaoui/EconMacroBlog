****************************************************************
************** Correlation between test and cases **************
****************************************************************
****************************************************************

version 15.1
set more off
cd "C:\Users\jamel\Documents\GitHub"
cd "EconMacroBlog\Does testing more lead to finding more cases" 
// Set the directory

cls
clear

capture log close _all                            
log using covid, name(covid) text replace

// Apply the s2color scheme

set scheme s2color

// Importation of the data

import excel covid-testing-under-1M.xlsx, ///
sheet("Feuil1") cellrange(G1:I74) firstrow

encode G, generate(ISO3)

label variable ISO3 "country"
label variable pcr "Total tests per million people (PCR)"
label variable cases ///
"Total cases per million as of July 15, 2020"

rename G countrycode
order ISO3, first

// All the countries

pwcorr pcr cases, sig star(.05) obs

gen lpcr = log(pcr)
gen lcases = log(cases)

pwcorr lpcr lcases, sig star(.05) obs

tw (scatter pcr cases, title(Linear scale) xtitle(Cases per million)) ///
(lfit pcr cases, legend(label(1 "PCR tests") ///
label(2 "Linear fit") order(1 2)) ///
text(420000 30000 "{bf:Pearson's corr. = 0.4290*}" "{it:N=73}") ), ///
name(covid_testing, replace) ysize(8)

capture graph export figures\covid_testing.png, replace

label variable lcases "Cases in log"

tw (scatter lpcr lcases, title(Logarithmic scale)) ///
(lfit lpcr lcases, legend(label(1 "PCR tests in log") /// 
label(2 "Linear fit") order(1 2)) ///
text(13.75 8 "{bf:Pearson's corr. = 0.6749*}" "{it:N=73}") ), ///
name(covid_testing_log, replace) ysize(8)

capture graph export figures\covid_testing_log.png, replace

graph combine covid_testing covid_testing_log, ///
title(Testing more do lead to discover more cases) ///
subtitle(Source: ourworldindata.org) /// 
note(As of July 15 2020 - countries with less 1M inhabitants removed) ///
altshrink ///
name(covid_testing_gathered, replace)

capture graph export figures\covid_testing_gathered.png, replace

// Regression analysis

regress cases pcr
estimates store PCR_LEVEL

regress lcases lpcr
estimates store PCR_LOG

local switches "dec(4) word se e(rmse)"
outreg2 [PCR_*] using tables\covid-july-2020.doc, ///
append `switches' replace

// Save the data
save data\covid.dta, replace

log close covid
exit

Description
-----------

This file aims at 

Notes :
-------

1) 