****************************************************************
************** Drawing maps with stata *************************
****************************************************************
****************************************************************

version 16.1
set more off
cd "C:\Users\jamel\Documents\GitHub"
cd "EconMacroBlog\Drawing Maps with Stata" 
// Set the directory

cls
clear

capture log close _all                            
log using maps, name(maps) text replace

// Required packages to draw maps (only once)

ssc install spmap
ssc install shp2dta
ssc install mif2dta

// Step 1: Convert shapefile to Stata format
*https://huebler.blogspot.com/2012/08/stata-maps.html

// Download maps (Admin 0 - Countries - Version 4.1.0) (unzip the folder)
*http://www.naturalearthdata.com/downloads/10m-cultural-vectors/

shp2dta using data\ne_10m_admin_0_countries, data(data\worlddata) ///
coor(data\worldcoor) genid(id) replace

// Step 2: Draw map with Stata

use data\worlddata.dta, replace

generate LPOP = ln(POP_EST)

format LPOP %4.2f

order id LPOP REGION_UN, first

spmap LPOP using data\worldcoor.dta if ADMIN!="Antarctica", id(id) ///
fcolor(Blues) clnumber(5) legend(symy(*2) symx(*2) size(*2)) legorder(lohi)

graph rename Graph map_world, replace
graph export figures\map_world.png, replace
graph export figures\map_world.pdf, replace


// Regional maps
*https://www.stathelp.se/en/spmap_world_en.html

use data\idfile.dta, replace

generate length = length(ADMIN)

spmap length using "data\coord_mercator_world.dta", id(na_id_world) ///
fcolor(RdYlGn)

spmap length using "data\coord_mercator_world.dta", id(na_id_world) ///
fcolor(RdYlGn) osize(vvthin vvthin vvthin vvthin) ndsize(vvthin)   ///
title("Length")

spmap length using "data\coord_lambert_europe.dta", id(na_id_world) ///
fcolor(RdYlGn) ///
osize(vvthin vvthin vvthin vvthin) ndsize(vvthin) ndfcolor(gray) ///
title("length")

spmap length using "data\coord_mercator_europe.dta", id(na_id_world) /// fcolor(RdYlGn) ///
osize(vvthin vvthin vvthin vvthin) ndsize(vvthin) ndfcolor(gray) ///
title("length")

graph rename Graph map_euro, replace
graph export figures\map_euro.png, replace
graph export figures\map_euro.pdf, replace

// Democracy index
*https://www.v-dem.net/en/data/data/v-dem-dataset-v111/

/*
use "data\V-Dem-CY-Core-v11.1.dta", clear
keep if year==2018
merge 1:m country_id using "data\idfile.dta", nogenerate

save "data\V-Dem-CY-Core-v11.1.dta", replace
*/

use "data\V-Dem-CY-Core-v11.1.dta", clear

spmap v2x_libdem using "data\coord_mercator_world.dta", id(na_id_world) ///
fcolor(RdYlGn) osize(vvthin vvthin vvthin vvthin) ndsize(vvthin)   ///
title("V-Dem Liberal democracy index")

spmap v2x_libdem using "data\coord_mercator_europe.dta", ///
id(na_id_world) ///
fcolor(RdYlGn) osize(vvthin vvthin vvthin vvthin) ndsize(vvthin)   ///
title("V-Dem Liberal democracy index")

graph rename Graph map_euro_demo, replace
graph export figures\map_euro_demo.png, replace
graph export figures\map_euro_demo.pdf, replace

/*
https://datahelpdesk.worldbank.org/knowledgebase/articles/889464
-wbopendata-stata-module-to-access-world-bank-data

ssc install wbopendata // Only once
db wbopendata

wbopendata, language(en - English) country() ///
topics(3 - Economy & Growth) /// 
indicator() long clear

// Save the data
save "data\wb_topics_3.dta", replace
*/

/*
use data\wb_topics_3, replace

keep if year==2016
keep if indic==178

save "data\wb_topics_3", replace
*/

use "data\wb_topics_3", clear

rename countryname country_name

replace country_name = "Russia" in 201
replace country_name = "Slovakia" in 213
replace country_name = "Macedonia" in 179

merge 1:m country_name using "data\idfile.dta", nogenerate

format value %5.0f

spmap value using "data\coord_mercator_europe.dta", id(na_id_world) ///
fcolor(RdYlGn) osize(vvthin vvthin vvthin vvthin vvthin vvthin) ///
ndsize(vvthin) clmethod(quantile) clnumber(6) ///
title("Income per capita (Current USD)")

capture graph rename Graph map_euro_wb, replace
capture graph export figures\map_euro_wb.png, replace
capture graph export figures\map_euro_wb.pdf, replace

// Save the data
save data\maps.dta, replace

log close maps
exit

Description
-----------

This file aims at drawing maps with Stata

Notes :
-------

1) 