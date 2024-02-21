
cls

clear

global Docs = "C:\Users\jamel\Documents\GitHub\"
global Proj = "EconMacroBlog\DBnomics_NUTS2"
 
cd "${Docs}"
cd "${Proj}"

**#*** Compensation of employees by NUTS 2 regions *************

dbnomics import, provider(Eurostat) dataset(nama_10r_2coe)   ///
         sdmx(A.MIO_EUR.TOTAL.) clear
rename   value COMP
destring COMP, replace force 
split    series_name, parse(–)
encode   series_name4, generate(cn)
keep     cn geo period COMP
order    cn geo period COMP
gen      CN = substr(geo,1,2)
encode   geo, generate(GEO)
xtset    GEO period
xtdes

tsfill,  full

drop if period<2000
drop if period>2019

tsfill,  full

xtdes

gen      COUNT=length(geo)

label var COMP "Compensation of employees in Millions of EUR"

// Run everything between preserve and restore 
preserve
keep     if COUNT==2
tsfill,  full
xtdes
save     comp_eurostat_NUTS_0.dta, replace
restore

// Run everything between preserve and restore 
preserve
keep     if COUNT==3
tsfill,  full
xtdes
save     comp_eurostat_NUTS_1.dta, replace
restore

// Run everything between preserve and restore 
preserve
keep     if COUNT==4
tsfill,  full
xtdes
save     comp_eurostat_NUTS_2.dta, replace
restore

save     comp_eurostat.dta, replace

**#*** Employment (thousand hours worked) by NUTS 2 regions ****

dbnomics import, provider(Eurostat) dataset(nama_10r_2emhrw) ///
         sdmx(A.THS.EMP.TOTAL.) clear
rename   value HOURS
destring HOURS, replace force 
split    series_name, parse(–)
encode   series_name4, generate(cn)
keep     cn geo period HOURS
order    cn geo period HOURS
gen      CN = substr(geo,1,2)
encode   geo, generate(GEO)
xtset    GEO period
xtdes

tsfill,  full

drop if period<2000
drop if period>2019

tsfill,  full

xtdes

gen      COUNT=length(geo)

label var HOURS "Employment (thousand hours worked)"

// Run everything between preserve and restore 
preserve
keep     if COUNT==2
tsfill,  full
xtdes
save     hours_eurostat_NUTS_0.dta, replace
restore

// Run everything between preserve and restore 
preserve
keep     if COUNT==3
tsfill,  full
xtdes
save     hours_eurostat_NUTS_1.dta, replace
restore

// Run everything between preserve and restore 
preserve
keep     if COUNT==4
tsfill,  full
xtdes
save     hours_eurostat_NUTS_2.dta, replace
restore

save     hours_eurostat.dta, replace

**# Merge ******************************************************

use comp_eurostat.dta, replace

xtdes

foreach v in hours_eurostat  {
		     merge 1:1 GEO period using `v'.dta, ///
			 keep(1 3) nogen 
}

order cn geo GEO CN period COMP HOURS, first

label var COUNT "Length of the geo code"

// Run everything between preserve and restore 
preserve
keep     if COUNT==2
tsfill,  full
xtdes
save     dataset_eurostat_NUTS_0.dta, replace
restore

// Run everything between preserve and restore 
preserve
keep     if COUNT==3
tsfill,  full
xtdes
save     dataset_eurostat_NUTS_1.dta, replace
restore

// Run everything between preserve and restore 
preserve
keep     if COUNT==4
tsfill,  full
xtdes
save     dataset_eurostat_NUTS_2.dta, replace
restore

**# *** End of the program *************************************