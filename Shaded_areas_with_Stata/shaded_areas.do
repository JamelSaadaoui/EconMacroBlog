**# ****** Shaded areas for recessions *************************

/*
https://blog.stata.com/2020/02/13/adding-recession-
shading-to-time-series-graphs/
*/

/*
set fredkey 01b83643a9864a8f910a499e5022b2d6, permanently
*/

/*
fredsearch sahm rule
*/

import fred SAHMREALTIME SAHMCURRENT, clear

display=td(01jan2000)

keep if daten>=td(01jan2000)

generate datem = mofd(daten)

tsset datem, monthly

label variable SAHMREALTIME ///
 "Real-time Sahm Rule"

label variable SAHMCURRENT ///
 "Current Sahm Rule"
 
label variable datem ///
 "Time"

// Description:
/*
https://research.stlouisfed.org/publications/research-news/
fred-adds-sahm-rule-recession-indicators
*/

/*
Econbrowser blog: https://econbrowser.com/archives/2024/01/are-we-in-recession-the-sahm-rule-now-2007
*/

* Recession dates
display tm(2001m3) 
display tm(2001m11) 
display tm(2007m12) 
display tm(2009m6)
display tm(2020m2) 
display tm(2020m4)

tsset datem

tsline SAHMCURRENT SAHMREALTIME, tlabel(, format(%tmCCYY))
graph rename sahm, replace

display tm(2001m1) tm(2024m1)

generate REC = 0
replace REC = 1 if datem>=tm(2001m3) & datem<=tm(2001m11) | ///
                   datem>=tm(2007m12) & datem<=tm(2009m6) | ///
				   datem>=tm(2020m2) & datem<=tm(2020m4)

gen REC13=REC*13				   

label variable REC13 ///
 "NBER recessions"

				   
set scheme white_jet				   
				   
twoway (bar REC13 datem, color(gs14) lstyle(none) ///
 barwidth(2)) ///
 (tsline SAHMCURRENT SAHMREALTIME, lcolor(gold blue) ///
  xlabel(482 542 602 666 726 776) ///
  tlabel(482 542 602 666 726 776, ///
  format(%tmCCYY))), yline(0.5) legend(pos(2) col(1)) ///			   
 text(14 508 "{bf:Internet Krach}" "{it:NBER dates}", ///
  size(small)) ///
 text(14 590 "{bf:Global Financial Crisis}" ///
  "{it:NBER dates}", size(small)) ///
 text(14 722 "{bf:Pandemic Crisis}" "{it:NBER dates}", ///
  size(small)) ///
 text(1.5 770 "{bf:Dec. 2023}""{it:0.23}", size(small)) ///
 note("Recession = 3-month average UR rises a 0.5 point above prior 12 months lower point.", size(small)) ///
 graphregion(margin(l+2 r+2))
 

// Export the graph in two different formats 

graph rename sahmrule, replace
graph export figures\sahmrule.png, as(png) ///
 width(4000) replace
graph export figures\sahmrule.pdf, as(pdf) ///
 replace
 
// Run everthing between preserve and restore 
***
preserve

keep if datem>=tm(2007m1) & datem<=tm(2008m12)

generate Rec = 0
replace Rec = 2.1 if datem>=tm(2008m1) & datem<=tm(2008m12)

twoway (area Rec datem if datem>=tm(2008m1) & ///
        datem<=tm(2008m12), color(gs14%25)) ///
 (tsline SAHMCURRENT SAHMREALTIME, lcolor(gold blue) ///
  xlabel()), yline(0.5, lcolor(red)) legend(off) ///	
 text(0.6 566 "{bf:Threshold = 0.5}", size(small) /// 
      color(red)) ///
 text(0.7 576 "{bf:Jan. 2008}""{it:0.47}", size(small)) ///
 text(1.5 582 "{bf:Sahm Rule Current}", size(small) ///
      color(gold)) ///
 text(1 586 "{bf:Sahm Rule Real Time}", size(small) ///
      color(blue)) ///	  
 note("Sahm Rule in % = 3-month average UR rises a 0.5 point above prior 12 months lower point.", size(vsmall)) ///
 graphregion(margin(l+2 r+2))

graph rename sahmruleGFC, replace
graph export figures\sahmruleGFC.png, as(png) ///
 width(4000) replace
graph export figures\sahmruleGFC.pdf, as(pdf) ///
 replace
 
 
restore 
***

// Run everthing between preserve and restore 
***
preserve

keep if datem>=tm(2022m1) & datem<=tm(2023m12)

generate Rec = 0
replace Rec = 2.1 if datem>=tm(2022m1) & datem<=tm(2023m12)

twoway (area Rec datem if datem>=tm(2022m1) & ///
        datem<=tm(2023m12), color(white%25)) ///
 (tsline SAHMCURRENT SAHMREALTIME, lcolor(blue gold) ///
  xlabel()), yline(0.5, lcolor(red)) legend(off) ///	
 text(0.6 747 "{bf:Threshold = 0.5}", size(small) /// 
      color(red)) ///
 text(0.7 767 "{bf:Dec. 2023}""{it:0.23}", size(small)) ///
 text(0 764 "{bf:Sahm Rule Current}", size(small) ///
      color(blue)) ///
 text(0.3 760 "{bf:Sahm Rule Real Time}", size(small) ///
      color(gold)) ///	  
 note("Sahm Rule in % = 3-month average UR rises a 0.5 point above prior 12 months lower point.", size(vsmall)) ///
 graphregion(margin(l+2 r+2))

graph rename sahmruleNow, replace
graph export figures\sahmruleNow.png, as(png) ///
 width(4000) replace
graph export figures\sahmruleNow.pdf, as(pdf) ///
 replace
 
 
restore 
***

// Save data

save data\sahmrule.dta, replace

**# *********** Current account balance ************************

fredsearch USAB6BLTT02STSAQ

import fred USAB6BLTT02STSAQ, clear

*display=td(01jan2000)

*keep if daten>=td(01jan2000)

generate datem = mofd(daten)

generate dateq = qofd(daten)

tsset dateq, quarterly

label variable USAB6BLTT02STSAQ ///
"US current account balance in percent"
 
label variable dateq ///
 "Time"
 
*keep if dateq>=tq(2000q1)

capture drop REC
generate REC = 0
replace REC = 1 if datem>=tm(1960m4) & datem<=tm(1961m2)  | ///
                   datem>=tm(1969m12) & datem<=tm(1970m11) | ///
				   datem>=tm(1973m11) & datem<=tm(1975m3) | ///
				   datem>=tm(1980m1) & datem<=tm(1980m7)  | ///
                   datem>=tm(1981m7) & datem<=tm(1982m11) | ///
				   datem>=tm(1990m7) & datem<=tm(1991m3)  | ///
				   datem>=tm(2001m3) & datem<=tm(2001m11) | ///
                   datem>=tm(2007m12) & datem<=tm(2009m6) | ///
				   datem>=tm(2020m2) & datem<=tm(2020m4)

summarize USAB6BLTT02STSAQ
generate recession = 2 if REC == 0
replace  recession = r(min) if REC == 1
*local max = r(max) 

label variable recession ///
 "NBER Recession dates"

twoway (bar recession dateq, color(gs14) lstyle(none) ///
 barwidth(2) base(2)) /// max = 1.21
 (tsline USAB6BLTT02STSAQ, lcolor(blue) ///
  , yline(0) legend(pos(1)) xsize(8) ///
   tlabel(#11 , format(%tqCCYY))), ///
   text(1 156 "{bf:Internet Krach}" "{it:NBER dates}", ///
    size(small)) ///
   text(1 196 "{bf:Financial Crisis}" "{it:NBER dates}", ///
    size(small)) ///
   text(1 240 "{bf:Pandemic Crisis}" "{it:NBER dates}", ///
    size(small))

// Export the graph in two different formats 

graph rename uscab, replace
graph export figures\uscab.png, as(png) ///
 width(4000) replace
graph export figures\uscab.pdf, as(pdf) ///
 replace
 
save data\uscab.dta, replace
 
 
**# ** The end of program ************************************** 