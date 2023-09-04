
*The code below can be used to set drive root and save location
*local root "C:\Replication\"
*Optionally specifiy another folder for saving figures
*local savefolder `root'
*set current working dircectory
*cd "`root'"
clear all
set more off
set graphics off

***********************************************************************
****  Figures 1 & 2    Evolution of Epistemology and Methodology  *****
***********************************************************************

**Create relevant sample
use "main_data", clear
keep if inlist(journal, "JME", "JMCB", "AER", "JPE", "ReStud", "QJE", "ECMTA")

** Create dummies for epistemology and methodology
local epist description causal falsification model_fit abduction quantification ///
theory methodology other 

foreach n of local epist {
	gen `n' = epist_new == "`n'"
	}

local method theory both econometric

foreach n of local method {
	gen m_`n' = theory_emp == "`n'"
	}
	
** Treat off decade years as on decade years to simplify figures
** So, eg, 2010 is the average of 2006, 2008, 2010
replace year = 2010 if inlist(year, 2006, 2008)
replace year = 2018 if inlist(year, 2016, 2017)


** Collapse data into time series for area charts
collapse `epist' m_*, by(year)


**************************************
* Figure 1: Evolution of Epistemology 
**************************************

** Create cumulative epistemology values to plot
replace desc = desc*100
forvalues i = 2(1)9 {

	local j =`i'-1
	local var1: word `i' of `epist'
	local var0: word `j' of `epist'
	replace `var1' = `var1'*100+`var0'
	}

** Create variable labels for use in figure
* Note: Methodology and other are combined

*Parallel lists of variables and labels
local epist description causal falsification model_fit abduction quantification ///
theory other
local labels "Description" "Causal Inference" "Falsification" "Model Fitting" "Abduction" "Quantification" ///
"Non-quantitative Theory" "Methodology and Other"

*specify location of labels to be called by loop
local yloc = (0+description[_N])*0.5
local xloc = 2017
local call text(`yloc' `xloc' " Description", size(small) place(l))

*The following loop generates the local macro `call' which contains all the 
* label commands used in the figure
forvalues i = 2(1)9 {
	local j =`i'-1
	local var1: word `i' of `epist'
	local var0: word `j' of `epist'
	local label: word `i' of `labels'
	local yloc = (`var0'[_N]+`var1'[_N])*0.5
	local xloc = 2017
	local call `call' text(`yloc' `xloc' "  `label'", size(small) place(l))   
	}
	
local colors gs8 navy navy*0.6 navy*0.4 navy*0.2 emerald*0.60 emerald*0.75 emerald
	
twoway (area other theory quantification abduction model_fit falsification ///
causal descr year, color(`colors')),  legend(off) xtitle("") ///
 xlabel(1980 (10) 2010) ylabel(0 (25) 100, angle(0) nogrid val) graphregion(color(white)) `call'

graph export "`savefolder'Fig1_Evolution.pdf", as(pdf) replace


********************************************
*** Figure 2: Evolution of Methodology 
********************************************

replace m_econometric = m_econometric*100
replace m_both = m_both*100
replace m_theory = m_theory*100

** create cumulative values to plot
replace m_both = m_both + m_econometric 
replace m_theory = m_theory + m_both

local colors emerald*0.4 emerald navy  

twoway (area m_* year, color(`colors')), xtitle("") ///
xlabel(1980 (10) 2010) ylabel(0 (25) 100, nogrid val) graphregion(color(white)) ///
legend(off) text(80 `xloc' "Theory", size(small) place(l)) text(43 `xloc' "Both", size(small) place(l)) ///
text(20 `xloc' "Econometric", place(l) size(small)) name(methodology, replace)

graph export "`savefolder'Fig2_ev_methodology.pdf", as(pdf) name(methodology) replace



********************************************
****  Figure 3: Scope of Equilibrium   *****
********************************************
clear

*create relevant sample
use "main_data.dta", clear
keep if inlist(journal, "JME", "JMCB", "AER", "JPE", "ReStud", "QJE", "ECMTA")
keep if inlist(theory_emp, "theory", "both")
drop if thgeneral==""

*create dummy variables
gen DSGE = thgeneral=="dsge"
gen General = thgeneral=="ge"
gen Partial = thgeneral=="pe"

* Treat off decade years as on decade years to simplify figures
* So, eg, 2010 is the average of 2006, 2008, 2010
replace year = 2010 if inlist(year, 2006, 2008)
replace year = 2018 if inlist(year, 2016, 2017)

*collapse into annual averages
collapse DSGE General Partial, by(year)

replace DSGE = DSGE*100
replace General = DSGE +General*100
replace Partial = General + Partial*100

*Specify chart colors
local colors emerald emerald*0.4 navy

twoway (area Partial General DSGE year, color(`colors')), xtitle("") ///
xlabel(1980 (10) 2010) ylabel(0 (25) 100, angle(0) nogrid val) graphregion(color(white)) ///
legend(off) text(85 2010 " Partial Equilibrium", place(c)) ///
text(50 2010 "General Equilibrium", place(c)) text(16 2010 "DSGE", place(c)) name(scope, replace)

graph export "`savefolder'Fig3_Scope.pdf", name(scope) as(pdf) replace


**************************************************
**** Figure 4 - Financial Market Imperfections  **
**************************************************

*create relevant sample
use "main_data", clear
keep if inlist(journal, "JME", "JMCB", "AER", "JPE", "ReStud", "QJE", "ECMTA")
keep if inlist(theory_emp, "theory", "both")
*the next line is to get rid of methodology only papers
drop if inlist(epist_new, "methodology")


** Treat off decade years as on decade years to simplify figures
** So, eg, 2010 is the average of 2006, 2008, 2010
replace year = 2010 if inlist(year, 2006, 2008)
replace year = 2018 if inlist(year, 2016, 2017)

*create dummy variables
gen fin_GI = intermediation=="yes" & GI==1
gen fin_Field = intermediation=="yes" & GI==0

gen field_articles = GI==0


*collapse into annual averages
collapse fin_* (rawsum) field_articles GI, by(year)
replace fin_GI = fin_GI*100
replace fin_Field = fin_Field*100
*gen no_fin = 100

label var fin_Field "JME and JMCB"
label var fin_GI "General Interest Journals"


** Create cumulative total for area chart
replace fin_GI = fin_Field + fin_GI

*Specify chart details
local colors emerald*0.9 navy*0.9
	
*label locations
local xloc 2018

su fin_Field if year == 2018, meanonly
local fyloc = `r(mean)'/2

su fin_GI if year==2018, meanonly
local gyloc = (`r(mean)'+`fyloc'*2)/2 - 8
local nofyloc = `gyloc'+30

twoway (area fin_GI fin_Field year, color(`colors')), legend(off) graphregion(color(white)) ///
xlabel(1980 (10) 2010) ylabel(0 (10) 50, angle(0) nogrid val)  xtitle("") ///
text(`fyloc' `xloc' "Field Journals ", size(small) place(l)) ///
text(`gyloc' `xloc' "General Interest ", size (small) place(l))
graph export "`savefolder'Fig4_Intermediation.pdf", as(pdf) replace







