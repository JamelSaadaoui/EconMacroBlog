*Save the database in Stata format
*-------------------------------------------------------------------------

version 17.0
set more off
capture log close
log using logs\database_import_m2.log, replace

// Import data from Excel

import excel data\data_asean_final_m2.xls, ///
sheet("Sheet1") firstrow case(lower) clear

list cn

*drop if cn=="Lao PDR" | cn=="Cambodia" | cn=="Myanmar" //-> Note 1

*list cn

*drop if year<=1997 //-> Note 2

// Save the data
save data\data_asean_final_m2.dta, ///
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