* Prepare the data for analysing the correlation between test and cases
*-------------------------------------------------------------------------

version 15.1
set more off
cd "C:\Users\EconJamel\Documents\Blog\Data"		      // Set the directory
capture log close                               
log using covid_testing.smcl, replace

clear

import ///
excel "C:\Users\EconJamel\Documents\Blog\Data\covid-testing-under-1M.xlsx", ///
sheet("Feuil1") cellrange(G1:I74) firstrow

encode G, generate(ISO)

label variable ISO "country"
label variable pcr "Total tests per million people (PCR)"
label variable cases ///
"Total confirmed cases of COVID-19 per million people (cases per million)"

drop G

order ISO, first

// All the countries

pwcorr pcr cases, sig star(.05) obs

gen lpcr = log(pcr)
gen lcases = log(cases)

pwcorr lpcr lcases, sig star(.05) obs

tw (scatter pcr cases, title(Linear scale) xtitle(Cases per million)) ///
(lfit pcr cases, legend(label(1 "PCR tests") ///
label(2 "Linear fit") order(1 2)) ///
text(420000 30000 "{bf:Pearson's corr. = 0.4290*}" "{it:N=73}") ), ///
name(covid_testing, replace)

capture graph export covid_testing.png, replace

label variable lcases "Cases in log"

tw (scatter lpcr lcases, title(Logarithmic scale)) ///
(lfit lpcr lcases, legend(label(1 "PCR tests in log") /// 
label(2 "Linear fit") order(1 2)) ///
text(13.75 8 "{bf:Pearson's corr. = 0.6749*}" "{it:N=73}") ), ///
name(covid_testing_log, replace)

capture graph export covid_testing_log.png, replace

graph combine covid_testing covid_testing_log, ///
title(Testing more do lead to discover more cases) ///
subtitle(Source: ourworldindata.org) /// 
note(As of July 15 2020 - countries with less 1M inhabitants removed) ///
altshrink ///
name(covid_testing_gathered, replace)

capture graph export covid_testing_gathered.png, replace

// Regression analysis

regress cases pcr

regress lcases lpcr

// Save the data
save ///
"C:\Users\EconJamel\Documents\Blog\Data\covid_testing.dta", ///
replace

log close
exit

Description
-----------

This file aims at 

Notes :
-------

1) 