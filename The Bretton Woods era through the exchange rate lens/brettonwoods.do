****************************************************************
************** BW era through the XR lens **********************
****************************************************************
****************************************************************

version 17.0
set more off
cd "C:\Users\jamel\Documents\GitHub"
cd "EconMacroBlog\The Bretton Woods era through the exchange rate lens" 
// Set the directory

cls
clear

capture log close _all                            
log using bw, name(bw) text replace

// Apply the s2color scheme

set scheme s2color

// Importation of the data from fred

set fredkey ce2e515a7aeee4ac49e688f09efe4c69, permanently
// The key is obtained on the website of FRED

fredsearch Exchange Rate (market+estimated)

*import fred XRNCUSATA618NRUG, clear 

foreach iso in AT BE CY FR FI EE DE GR IE IT LV LT LU NL PT SK SI ///
               ES MT {
					import fred XRNCUS`iso'A618NRUG, clear
					save data\XRNCUS`iso'A618NRUG, replace
}

use data\XRNCUSATA618NRUG, clear

foreach iso in BE CY FR FI EE DE GR IE IT LV LT LU NL PT SK SI ///
               ES MT {
		     merge 1:1 daten using data\XRNCUS`iso'A618NRUG.dta, nogen
} 

gen datayear = yofd(daten)

tsset datayear

foreach iso in AT BE CY FR FI EE DE GR IE IT LV LT LU NL PT SK SI ///
               ES MT {
label variable XRNCUS`iso'A618NRUG `iso'
}


global countrylist ///
XRNCUSSKA618NRUG XRNCUSSIA618NRUG XRNCUSPTA618NRUG ///
XRNCUSNLA618NRUG XRNCUSMTA618NRUG XRNCUSLVA618NRUG ///
XRNCUSLUA618NRUG XRNCUSLTA618NRUG XRNCUSITA618NRUG ///
XRNCUSIEA618NRUG XRNCUSGRA618NRUG XRNCUSFRA618NRUG ///
XRNCUSFIA618NRUG XRNCUSESA618NRUG XRNCUSEEA618NRUG ///
XRNCUSDEA618NRUG XRNCUSCYA618NRUG XRNCUSBEA618NRUG ///
XRNCUSATA618NRUG

tsline $countrylist, legend(on pos(3) col(1) size(small) ) ///
ylabel(, angle(horizontal)) ylabel(, labsize(small)) ///
tlabel(, grid) tlabel(, labsize(small)) ///
xlabel(1950(10)2020, labsize(small)) ///
title("National Currency Units per US Dollar, NSA") ///
xtitle("") ytitle("") note("") // recast(connected) msymbol(O)
graph rename brettonwoods, replace
graph export figures\brettonwoods.png, replace
graph export figures\brettonwoods.pdf, replace

// Save the data
save data\brettonwoods.dta, replace

log close bw
exit

Description
-----------

This file aims at 

Notes :
-------

1) 