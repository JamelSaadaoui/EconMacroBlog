**# ** Dates and time on Excel and Stata ***********************

// Download: https://fred.stlouisfed.org/series/SAHMCURRENT

// Prepare the Excel file with two columns

// Launch the Do file from the directory

import excel SAHMCURRENT.xls, sheet("FRED Graph") ///
 cellrange(A11:F908) firstrow clear

// Drop unnecessary columns 
 
drop C E 

// Generate the month of the data with a Stata function 

gen      month=mofd(Numberofdays)

// Format the month of the day

format   %tm month

// Keep the desired series

keep SAHMCURRENT month
order month SAHMCURRENT

// Declare time series

tsset month

// Draw a time series graph

format SAHMCURRENT %4.2f

label variable SAHMCURRENT "Sahm Rule (Recession if >= 0.5)"
label variable month "Date"

* Recession dates
display tm(2001m3) 
display tm(2001m11) 
display tm(2007m12) 
display tm(2009m6)
display tm(2020m2) 
display tm(2020m4)

tsline SAHMCURRENT if month>=tm(2000m1), yline(0.5) ///
 xline(494 502 575 593 721 723, lpattern(solid)) ///
 ylabel(,format(%4.2fc)) ///
 text(10 532 "{bf:Internet Krach}" "{it:NBER dates}") ///
 text(10 640 "{bf:Global Financial Crisis}" "{it:NBER dates}") ///
 text(10 758 "{bf:Pandemic Crisis}" "{it:NBER dates}") ///
 text(1 770 "{bf:Nov. 2023}""{it:0.30}") ///
 note("Recession = 3-month average UR rises a 0.5 point above prior 12 months lower point.", size(vsmall))

// Export the graph in two different formats 

graph export figures\sahmrule.png, as(png) ///
 width(4000) replace
graph export figures\sahmrule.pdf, as(pdf) ///
 replace
 
// Save data

save sahmrule.dta, replace

**# ** The end of program ************************************** 