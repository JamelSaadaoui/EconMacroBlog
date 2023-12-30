**# *** Merge UN votes and Ideal Points ************************

cd C:\Users\jamel\Documents\GitHub\EconMacroBlog\
cd Maps_Political_Ties\data

import delimited "UNVotes.csv", clear 

// Numeric value for the votes
destring ccode v1 abstain yes no importantvote, force replace

// Extract the date into Stata format
split    date, parse(-)
gen      string = date3 + ///
         "/" + date2 + ///
         "/" + date1
gen      date_ = date(string, "DMY")
format   date_ %td
generate mth = month(date_)
generate period_ = mofd(date_)
format   period_ %tm

// Ordering the variables
order country ccode period_ session rcid resid vote abstain ///
 yes no importantvote

** NOTE THAT YEARS RESPOND TO SESSIONS RATHER THAN CALENDAR ///
YEARS. OCCASIONALLY SOME VOTES TAKE PLACE THAT RUN INTO ///
JANUARY OR EVEN THE SPRING OF THE NEXT CALENDAR YEAR. ///
MOST VOTES OCCUR IN THE FALL OF A CALENDAR YEAR. 
 
sort ccode period_

// Generating IMF country codes

kountry  ccode, from(cown) to(imfn) m

rename _IMFN_ IFScode
rename ccode COWcode

order COWcode IFScode, first

drop date1 date2 date3 string date_ mth MARKER

// Save the data in Stata format

save UNvotesRAW_Stata.dta, replace

**# *** Ideal Points *******************************************

import delimited "IdealpointestimatesAll_Jul2023.csv", clear 

rename ccode COWcode

xtset COWcode session 

xtdes

*nbvotesall == number of rows in a particular session in
*UNVotes

save IdealpointestimatesAll_Jul2023.dta, replace

**# *** Merge with UNVotes *************************************

use UNvotesRAW_Stata.dta, clear

merge m:1 COWcode session using  ///
 IdealpointestimatesAll_Jul2023.dta, keep(1 3)
 
des

sum ideal

save IdealpointestimatesAll_Jul2023_merged.dta, replace

**# *** End of the program *************************************
