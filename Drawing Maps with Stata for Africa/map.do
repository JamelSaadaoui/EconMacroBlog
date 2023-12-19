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
