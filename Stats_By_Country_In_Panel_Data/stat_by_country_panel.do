**# **** Stats by country in a panel ***************************

cd C:\Users\jamel\Documents\GitHub\EconMacroBlog\
cd Stats_By_Country_In_Panel_Data

/*
Use the data in this paper: 
Title: Sanctions and the Exchange Rate in Time
Authors: Barry Eichengreen, Massimo Ferrari Minesso, Arnaud Mehl, 
Isabel Vansteenkiste, Roger Vicquéry
DOI: https://doi.org/10.1093/epolic/eiad034
Mendeley: https://data.mendeley.com/datasets/8526jpm6ct/1
*/

use data\swissdata.dta, clear

xtset mycountry myweek

xtdes

keep mycountry myweek fx lfx
order mycountry myweek fx lfx

label variable mycountry "Country name"
label variable myweek "Date - current week"
label variable fx "Currency i units per unit of US dollar"
label variable lfx "Natural logarithm of 1 + fx"

by mycountry: gen period = tw(1913w52) + _n

format %tw period

drop if period>tw(1945w52)
drop if mycountry==.

xtset mycountry period
tsfill, full

xtset mycountry period
xtdes

// Drop countries without observations
cap egen mean_fx = mean(fx), by(mycountry)
cap drop if mean_fx == .

// Draw some graphs

decode mycountry, generate(names)

xtline fx if names=="GBR", name(GBR, replace)
graph export figures\GBR.png, as(png) width(4000) replace
graph export figures\GBR.png, as(pdf) replace

xtline fx if names=="ARG", name(ARG, replace)
graph export figures\ARG.png, as(png) width(4000) replace
graph export figures\ARG.png, as(pdf) replace

/*
xtline fx if names=="AUT", name(AUT, replace)
graph export figures\AUT.png, as(png) width(4000) replace
graph export figures\AUT.png, as(pdf) replace
xtline fx if names=="FRA", name(FRA, replace)
graph export figures\FRA.png, as(png) width(4000) replace
graph export figures\FRA.png, as(pdf) replace
xtline fx if names=="GBR", name(GBR, replace)
graph export figures\GBR.png, as(png) width(4000) replace
graph export figures\GBR.png, as(pdf) replace
xtline fx if names=="DEU", name(DEU, replace)
graph export figures\DEU.png, as(png) width(4000) replace
graph export figures\DEU.png, as(pdf) replace
*/

**# ****** Descriptive statistics ******************************

// Insert an observation to keep the first country
// Thanks to Katharina Priedl for making me think of this trick

insobs 1, before(1)

replace names = "AAAA" in 1

encode names, generate(names2)

xtset names2 period

xtdes

label list names2

tabstat fx, ///
 statistics(count) ///
 by(names) format(%4.2f) save
putexcel set "tabstat", replace sheet(Stats)
return list
putexcel (B1) = "count"
forvalues v=2(1)35 {
          capture putexcel (A`v') = (r(name`v'))
		  capture putexcel (B`v') = matrix(r(Stat`v'))
		}

tabstat fx, ///
 statistics(mean) ///
 by(names) format(%4.2f) save
putexcel (C1) = "mean"
putexcel set "tabstat", modify sheet(Stats)
forvalues v=2(1)35 {
          capture putexcel (A`v') = (r(name`v'))
		  capture putexcel (C`v') = matrix(r(Stat`v'))
		}

tabstat fx, ///
 statistics(median) ///
 by(names) format(%4.2f) save
putexcel (D1) = "median"
putexcel set "tabstat", modify sheet(Stats)
forvalues v=2(1)35 {
          capture putexcel (A`v') = (r(name`v'))
		  capture putexcel (D`v') = matrix(r(Stat`v'))
		}

tabstat fx, ///
 statistics(sd) ///
 by(names) format(%4.2f) save
putexcel (E1) = "sd"
putexcel set "tabstat", modify sheet(Stats)
forvalues v=2(1)35 {
          capture putexcel (A`v') = (r(name`v'))
		  capture putexcel (E`v') = matrix(r(Stat`v'))
		}

tabstat fx, ///
 statistics(min) ///
 by(names) format(%4.2f) save
putexcel (F1) = "min" 
putexcel set "tabstat", modify sheet(Stats)
forvalues v=2(1)35 {
          capture putexcel (A`v') = (r(name`v'))
		  capture putexcel (F`v') = matrix(r(Stat`v'))
		}
		
tabstat fx, ///
 statistics(max) ///
 by(names) format(%4.2f) save
putexcel (G1) = "max"
putexcel set "tabstat", modify sheet(Stats)
forvalues v=2(1)35 {
          capture putexcel (A`v') = (r(name`v'))
		  capture putexcel (G`v') = matrix(r(Stat`v'))
		}
		
drop in 1/1

save data\fx_histo.dta, replace

**# **** End of the program ************************************