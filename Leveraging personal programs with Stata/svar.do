cap program drop svarjamel // Delete previous running program

cd "C:\Users\jamel\Dropbox\Documents\blog-data" // Choose the current directory
qui do "svarjamel.ado" // Quietly run the program 

use database_pri_gpr.dta, clear // Use the database in Mignon and Saadaoui (2024)

global X lpri lpro ldem lrpo // Store the vector of variable in a macro

svarjamel // Execute the code