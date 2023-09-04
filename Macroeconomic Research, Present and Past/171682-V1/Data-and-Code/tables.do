clear all
set more off

use "main_data"

*Set file name for collection of Stata output
local excelout Tabledata

***********************************************************************
****  Table 1 - Articles  *****
***********************************************************************

*Set up label to order values in the table as desired
label define jorder 1 "JME"  2 "JMCB"  3 "AEJ"  4 "JEDC" 5 "RED" 6 "AER" 7 "ECMTA" 8 "JPE" 9 "QJE" 10 "ReStud" 
encode journal, gen(journal2) label(jorder) 

* Create table 1 data
table ( year[2018 2017 2016 2010 2008 2006 2000 1990 1980 .m] ) (journal2) (), name(Table1)

*export to excel
collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'", as(xlsx) sheet(sheet1) cell(P4) modify


***********************************************************************
****  Tables 2 and 3 Epistemology and Methodology *****
***********************************************************************

*Keep only 2016 - 2018 data for tables 2 - 4, 6 & 9
keep if year>2015

*Set up label to order values in the table as desired
label define eorder 1 "description"  2 "causal"  ///
3 "falsification" 4 "model_fit"  5 "abduction"  ///
6 "quantification" 7 "theory" 8 "methodology" 9 "other" 
encode epist_new, gen(epist2) label(eorder)

**** Table 2 - cross tab epistemology and theory/econometric

*Set up label to order theory-econometric values in the table as desired
label define th_e_order 1 "theory"  3 "both"  2 "econometric" 
encode theory_emp, gen(theory_metric) label(th_e_order)

**Change labels for presentation
label define th_e_order 1 "Theory" 3 "Both" 2 "Econmetric", replace
label values theory_metric th_e_order

*** Table 2 - Epistemology and Methodology
table ( epist2 ) ( theory_metric ) (), name(Table2) replace

collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'", as(xlsx) sheet(sheet1) cell(P31) modify


**** Table 3 - Epistemological Approaches by Journal
*Field journals
table (epist2) (journal2) if inlist(journal, "JME", "JMCB", "RED", "AEJ", "JEDC"), ///
name(Table3A)
collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'", as(xlsx) sheet(sheet1) cell(P45) modify

*GI journals
table (epist2) (journal2) () if GI==1, name(Table3Bi)
collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'", as(xlsx) sheet(sheet1) cell(P59) modify

*Only JEL code E by journal type
table (epist2) (GI) if jel_e==1, name(Table3bii) 
collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'", as(xlsx) sheet(sheet1) cell(X45) modify

**********************************************************************
*** Table 4 Scope of Equilibrium
**********************************************************************

** Note: only include non-methodology "theory" or "both" papers 
*Panel A
table thgeneral journal2 if GI==0 & inlist(theory_emp, "theory", "both")&epist_new!="methodology", name(Table4ai)
collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'", as(xlsx) sheet(sheet1) cell(P75) modify


table thgeneral GI if jel_e==1 & inlist(theory_emp, "theory", "both")&epist_new!="methodology", name(Table4aii)
collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'", as(xlsx) sheet(sheet1) cell(X75) modify


*Panel B
table thgeneral journal2 if GI==1 & inlist(theory_emp, "theory", "both")&epist_new!="methodology", name(Table4b)
collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'", as(xlsx) sheet(sheet1) cell(P83) modify


**********************************************************************
*** Table 6 DSGE Genres
**********************************************************************

*create variable lables to order as desired
label define order_thspec  1 nk  2 rbc 3 "asset pricing"  4 growth 5 monetary  6 "olg/lifecycle" 7 "search/matching" 8 trade 9 other
encode thspecific, gen(dsge_genre) label(order_thspec)

*Table 6A
table dsge_genre journal2 if GI==0 &(thgeneral=="dsge"), name(Table6A)
collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'", as(xlsx) sheet(sheet1) cell(P116) modify


table dsge_genre GI if jel_e==1 &(thgeneral=="dsge"), name(Table6Bi)
collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'", as(xlsx) sheet(sheet1) cell(X116) modify


table dsge_genre journal2 if GI==1 &(thgeneral=="dsge"), name(Table6bii)
collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'", as(xlsx) sheet(sheet1) cell(P130) modify



**********************************************************************
**** Table 9 data and empirical methods  ******
**********************************************************************
* Create indicators for each atribute
gen appliedmicro= emgeneral=="applied micro"
gen tss = emgeneral=="time series"

gen proprietarydata = inlist(source, "proprietary", "lab/survey")
gen microdata = inlist(unitofobs, "individual", "household", "firm", "asset", "subsidiary", "product")


gen Panel = structure =="panel"
gen Cross = structure=="css"
gen Time = structure=="tss"

foreach var of varlist Panel Cross Time {
	replace `var'=. if structure==""
	}

*select sample for Table 9
gen emp_table = inlist(theory_emp, "econometric", "both") 
replace emp_table = 0 if inlist(epist_new, "methodology", "other")

table ( journal2 ) () () if emp_table==1, ///
statistic(mean  appliedmicro tss microdata Time Cross Panel proprietarydata) name(Table9)
collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'", as(xlsx) sheet(sheet1) cell(P145) modify


table ( GI ) () () if jel_e==1 & emp_table==1, ///
statistic(mean  appliedmicro tss microdata Time Cross Panel proprietarydata) name(Table9i)
collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'", as(xlsx) sheet(sheet1) cell(P160) modify


*article counts
table ( journal2 ) () () if emp_table==1, name(Table9jcount)
collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'", as(xlsx) sheet(sheet1) cell(Y145) modify

table ( GI ) () () if emp_table==1 & jel_e==1, name(Table9ecount)
collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'", as(xlsx) sheet(sheet1) cell(Y160) modify

*********************************************************************************

****************************************
* Tables 5, 7, & 8: Frictions, features, solution and fitting techniques over time
*****************************************

use "main_data.dta", replace
keep if inlist(journal, "JME", "JMCB", "AER", "JPE", "ReStud", "QJE", "ECMTA")
keep if inlist(theory_emp, "theory", "both")
*keeps only general equilibrium and dsge papers
keep if inlist(thgeneral, "dsge", "ge")


** consolidate years
replace year = 2010 if inlist(year, 2006, 2008)
replace year = 2018 if inlist(year, 2016, 2017)


*Friction dummy variables that apply to GE and DSGE
gen nominal = nominalsticky=="yes"
gen market = marketpower=="yes"
gen fin = financial=="yes"
gen search = searchinformation=="yes"
gen least_one = nominal + market + fin + search >0
drop fin

*Other model features
gen het_a = het_agent=="yes"
gen nrat = non_rat=="yes"
gen num = numerical=="yes"
gen indet = indeterminacy=="yes"

*Model fit
replace modelfit = "optimization" if bayes=="yes"

gen calibration = modelfit=="calibration"
replace calibration = . if modelfit==""

gen optimization = modelfit=="optimization"
replace optimization = . if modelfit==""

gen bayes_est = bayes=="yes"
replace bayes_est=. if modelfit==""

**continuous, finite, bayes
gen cont_time = continuous=="yes"
gen finite_horiz = finite=="yes"

*Exclude non-DSGE from denominator
local vars het_a indet nrat cont_time finite_horiz bayes_est calibrat optimiz
foreach var of local vars {
	replace `var'=. if thgeneral!="dsge"
}

local vars nominal market search least het_a finite_horiz nrat indet cont_time num calibrat optimiz bayes_est
*collapse into annual averages
collapse `vars', by(year)

foreach var of local vars {
replace `var' = `var'*100
}

order year `vars'

export excel using "`excelout'.xlsx", sheet("sheet1") sheetmodify cell(P92) firstrow(variables)
*************************************************

****************************************
* Table 10: Empirical methods over time
*****************************************

use "main_data.dta", replace

keep if inlist(journal, "JME", "JMCB", "AER", "JPE", "ReStud", "QJE", "ECMTA")
keep if inlist(theory_emp, "econometric", "both")
drop if inlist(epist_new, "other", "methodology")

drop if emgeneral==""


** consolidate years
replace year = 2010 if inlist(year, 2006, 2008)
replace year = 2018 if inlist(year, 2016, 2017)

*create dummy variables
gen Panel = structure =="panel"
gen Cross = structure=="css"
gen Time = inlist(structure, "tss", "ts")

foreach var of varlist Panel Cross Time {
	replace `var'=. if structure==""
	}

generate AppliedMicro= emgeneral=="applied micro"
generate TimeSeries= emgeneral=="time series"

generate proprietarydata = inlist(source, "proprietary", "lab/survey")
generate microdata = inlist(unitofobs, "individual", "household", "firm", "asset", "subsidiary", "product")

local vars TimeSeries AppliedMicro microdata Time Cross Panel proprietarydata

*collapse into annual averages
collapse `vars', by(year)

foreach var of local vars {
replace `var' = `var'*100
}

order year `vars'

export excel using "`excelout'.xlsx", sheet("sheet1") sheetmodify cell(P168) firstrow(variables)
*************************************************





