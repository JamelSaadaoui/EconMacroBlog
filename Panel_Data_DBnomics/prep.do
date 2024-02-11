// PANEL DATASET WITH DBNOMICS

cls

clear

global Proj = "C:\Users\jamel\Dropbox\stata\prep\"
cd "${Proj}"

// SH.XPD.CHEX.GD.ZS
// Current health expenditure (% of GDP)

dbnomics import, provider(WB) dataset(WDI)      ///
         indicator("SH.XPD.CHEX.GD.ZS") clear
rename   value HEALTH
destring HEALTH, replace force 
split    series_name, parse(–)
encode   series_name3, generate(cn)
keep     cn country period HEALTH
order    cn country period HEALTH
kountry  country, from(iso3c) to(imfn) m
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn country imfcode period
drop     if imfcode==. 
xtset    imfcode period
*xtdes

save     data\HEALTH_wdi.dta, replace

// SP.DYN.TFRT.IN
// Fertility rate, total (births per woman)

dbnomics import, provider(WB) dataset(WDI)      ///
         indicator("SP.DYN.TFRT.IN") clear
rename   value FERT
destring FERT, replace force 
split    series_name, parse(–)
encode   series_name3, generate(cn)
keep     cn country period FERT
order    cn country period FERT
kountry  country, from(iso3c) to(imfn) m
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn country imfcode period
drop     if imfcode==. 
xtset    imfcode period
*xtdes

save     data\FERT_wdi.dta, replace
			 
// SP.DYN.IMRT.IN
// Mortality rate, infant (per 1,000 live births)

dbnomics import, provider(WB) dataset(WDI)      ///
         indicator("SP.DYN.IMRT.IN") clear
rename   value INFM
destring INFM, replace force 
split    series_name, parse(–)
encode   series_name3, generate(cn)
keep     cn country period INFM
order    cn country period INFM
kountry  country, from(iso3c) to(imfn) m
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn country imfcode period
drop     if imfcode==. 
xtset    imfcode period
*xtdes

save     data\INFM_wdi.dta, replace

// Merge

use data\health_wdi, clear

// Run together 'local' and the subsequent commands
local Data = "data\"
cd "${Proj}"
cd "${Data}"

*xtdes

foreach v in FERT_wdi INFM_wdi {
		     merge 1:1 imfcode period using `v'.dta, ///
			 keep(1 3) nogen 
}

lab var HEALTH "Fertility rate, total (births per woman)"
lab var FERT "Fertility rate, total (births per woman)"
lab var INFM "Mortality rate, infant (per 1,000 live births)"

save panel_data.dta, replace

export excel using "panel_data", firstrow(variables) replace

cd "${Proj}"

