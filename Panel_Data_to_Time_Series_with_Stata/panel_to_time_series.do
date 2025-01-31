**# ********* Panel Data to Time series ************************

cd C:\Users\jamel\Documents\GitHub\

cd EconMacroBlog\Panel_Data_to_Time_Series_with_Stata

import excel data\Merged-Database.xls, sheet("Sheet1") ///
 firstrow clear

encode ref_area, gen(ISO2) 

drop if ISO2==.
 
xtset ISO2 period

xtdes

by ISO2: gen period_abs = 0 + _n 

keep period ref_area fd // Keep the variables for the merge

reshape wide fd, i(period) j(ref_area) string

tsset period

save fd_timeseries.dta, replace

export excel fd_timeseries.xlsx, firstrow(variables) ///
 keepcellfmt replace


reshape long fd, i(period) j(ref_area) string

encode(ref_area), generate(ISO2)

xtset ISO2 period

save fd_paneldata.dta, replace

export excel fd_paneldata.xlsx, firstrow(variables) ///
 keepcellfmt replace

**#************ The end of program *****************************