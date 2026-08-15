//  Analyses for Ho/Saadaoui 
//  Bank Credit Threshold in Growth in ASEAN

cls
clear

// Set the directory
// Open the file in your own folder
*cd C:\Users\jamel\Dropbox\stata\gcasean	 

// Import database 
do database_import
                           
// Threshold regressions 
do endo_thresh
               
// Causality tests 
do causality  
                               
// Put results in Excel
do results_putexcel

// Import database (M2) 
do database_import_m2
                           
// Threshold regressions (M2) 
do endo_thresh_m2                          

save final_dataset.dta, replace

exit
