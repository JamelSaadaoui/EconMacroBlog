*cd "C:\Users\jamel\Dropbox\Latex\PROJECTS\23-09-finance-research-letters\Data and command\Regression_data_EMR\Map"


dbnomics import, pr(IMF) d(WEO:2023-10) ///
sdmx(.GGXWDG_NGDP.pcent_gdp) clear

destring value, force replace

rename value debt

order period weo_country debt 

split series_name, parse(–)

rename series_name1 country

keep period weo_country debt country

kountry weo_country, from(iso3c) to(cown)

rename _COWN_ COWcode

drop if COWcode==.

xtset COWcode period

isid COWcode period

bysort COWcode period: assert _N == 1 

drop if period<2015

by COWcode: egen mean_debt=mean(debt) 

keep if period==2022

merge 1:m COWcode using "idfile.dta", nogenerate

format mean_debt %12.2f

spmap mean_debt using "coord_mercator_afr.dta", id(na_id_world) fcolor(YlOrRd) ///
osize(vvthin vvthin vvthin vvthin) ndsize(vvthin) ndfcolor(gray) 

///
// title("Average central government debt as a percentage of GDP in Africa (2015-2023)", size(small)) // clmethod(custom) clbreaks(0 100 150 200 250 300)

graph rename Graph map_Africa, replace

graph export map_Africa.png, as(png) width(4000) replace
graph export map_Africa.pdf, as(pdf) replace

save map, replace

*Special Thanks to: https://www.stathelp.se/en/spmap_world_en.html

****************************************************************

use map.dta, clear

drop if country==""

sort COWcode

kountry COWcode, from(cown) to(imfn)

rename _IMFN_ IFScode
order IFScode COWcode, first

save maps_again.dta, replace

****************************************************************

use kaopen_2021.dta, clear

rename cn IFScode

keep if year>=2011

by IFScode: egen mean_ka_open=mean(ka_open) 

keep if year==2021

save kaopen_again.dta, replace

****************************************************************

use maps_again.dta, clear

duplicates list IFScode

drop if IFScode==.

drop ccode

merge m:1 IFScode using "kaopen_again.dta", nogenerate

format mean_ka_open %12.2f

spmap mean_ka_open using "coord_mercator_world.dta", ///
id(na_id_world) fcolor(Blues2) ///
osize(vvthin vvthin vvthin vvthin) ndsize(vvthin) ///
ndfcolor(gray) clmethod(custom) /// 
clbreaks(0 0.25 0.5 0.75 1) ///
title("Financial openness (average 2011-2021)")

graph rename Graph map_ka_open, replace

graph export map_ka_open, as(png) width(4000) replace
graph export map_ka_open.pdf, as(pdf) replace

format mean_debt %12.0f

spmap mean_debt using "coord_mercator_world.dta", ///
id(na_id_world) fcolor(YlOrRd) ///
osize(vvthin vvthin vvthin vvthin) ///
ndsize(vvthin) ndfcolor(gray) clmethod(custom) /// 
clbreaks(0 50 100 300) ///
title("Central government debt (average 2015-2023)")

graph rename Graph map_debt, replace

graph export map_debt, as(png) width(4000) replace
graph export map_debt.pdf, as(pdf) replace

****************************************************************