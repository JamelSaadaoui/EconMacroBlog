// Clear the console and the data

cls
clear
graph drop _all // + Drop the previous PNG graph

// Change the folder for the current directory

cd "C:\Users\jamel\Dropbox\stata\hdidweb"

// Open a log to produce a PDF file at the end

capture log close                               
log using hdidweb.log, replace

// Use the data in the folder

use minwage

describe
xtdescribe

sum
xtsum

// use local/global for the control variables

global covars i.region pop medinc white hs pov c.pop#c.pop  ///
c.medinc#c.medinc

// Estimates with the AIPW

xthdidregress aipw (lemp $covars) (treat $covars), group(state)

// Plot the Average Treatment Effect on the Treated group (ATET)

estat atetplot, sci name(atet, replace)
graph export "figures\atetplot.png", as(png) name("atet") replace

// Event study (length of exposure to the treatment)

estat aggregation, dynamic graph(name(d1, replace))
graph export "figures\event.png", as(png) name("d1") replace

// ATETs over cohort

estat aggregation, cohort graph(name(c1, replace))
graph export "figures\cohort.png", as(png) name("c1") replace

// ATETs across time

estat aggregation, time graph(name(t1, replace))
graph export "figures\time.png", as(png) name("t1") replace

log close _all