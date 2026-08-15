*Save the database in Stata format
*-------------------------------------------------------------------------

version 16.1
set more off
*cd "C:\Users\jamel\stata\gcasean" // Set the directory
capture log close
log using logs\database_import.log, replace

// Import data from Excel

import excel data\data_asean.xlsx, ///
sheet("Feuil1") firstrow case(lower) clear

list cn

drop if cn=="Lao PDR" | cn=="Cambodia" | cn=="Myanmar" //-> Note 1

list cn

*drop if year<=1997 //-> Note 2

// Export to Excel

export excel using data\data_asean_final, ///
 sheetreplace firstrow(variables)

// Save the data
save ///
data\data_asean_final.dta, ///
replace

log close
exit
 
Description
-----------

This file aims at preparing the final database for the regression analyses.


Notes :
-------

1) Lao PDR, Cambodia and Myanmar are removed due to missing observations.
2) If we want to investigate the relation between credit and growth after 
   the 1997 Asian financial crisis.