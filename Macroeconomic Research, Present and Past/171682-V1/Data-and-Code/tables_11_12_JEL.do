
*cd "C:\Replication"
clear all
set more off
use "JEL_codes_Econlit.dta"

*Set file name for collection of Stata output
local excelout Tabledata

* Keep only recent articles
keep if inlist(year, 2016, 2017, 2018)

** Order journal labels as desired for table
label define jorder 1 "JME"  2 "JMCB"  3 "AEJ"  4 "JEDC" 5 "RED" 6 "AER" 7 "ECMTA" 8 "JPE" 9 "QJE" 10 "ReStud" 
encode journal, gen(journal2) label(jorder)

** Create new variables
*Has a JEL code? and number of unique JEL codes
gen jel_binary = JELcodes!=""

* Has non-macro JEL code?
egen nonmacro_jel = rowtotal(jel_A-jel_Z)
replace nonmacro_jel = nonmacro_jel - jel_E
replace nonmacro_jel = 1 if nonmacro_jel >0&nonmacro!=.
sum nonmacro_jel


**** Table 12 Macro and Money papers with other topics
*tabstat nonmacro jel_G jel_D jel_C jel_J jel_O jel_F if jel_binary==1 & jel_E==1, by(journal2) s(mean)
table ( journal2 ) () () if jel_binary==1 & jel_E==1, ///
statistic(mean nonmacro jel_G jel_D jel_C jel_J jel_O jel_F) name(Table12i)

collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'.xlsx", as(xlsx) sheet(sheet1) cell(P196) modify

*tabstat nonmacro jel_G jel_D jel_C jel_J jel_O jel_F if jel_binary==1 & jel_E==1, by(GI) s(mean)
table ( GI ) () () if jel_binary==1 & jel_E==1, ///
statistic(mean nonmacro jel_G jel_D jel_C jel_J jel_O jel_F) name(Table12ii)

collect style header, title(hide)
collect style cell, border( right, pattern(nil) )
collect export "`excelout'.xlsx", as(xlsx) sheet(sheet1) cell(Y196) modify

************************************
**** Table 11 Distribution of topics
************************************

* Create sample
keep if GI==0

* List of JEL codes included individually in table
local jel_list jel_E jel_G jel_D jel_C jel_F jel_O jel_J jel_H jel_L

* Create additional variables
gen articles = 1
egen total = rowtotal(jel_A - jel_R)
egen listed = rowtotal(`jel_list')
gen anyother = total>listed

collapse total (sum) jel_A-jel_R jel_binary anyother (count) articles, by(journal2 journal)

rename jel_bin hasjel
rename total average

*Collapse to create table data
order journal jel_E jel_G jel_D jel_C jel_F jel_O jel_J jel_H jel_L anyother has average
keep journal - average
compress

export excel using "`excelout'.xlsx", sheet("sheet1") sheetmodify cell(P178) firstrow(variables)


