**#******** Download the map files *****************************

/*
https://www.naturalearthdata.com/
http//www.naturalearthdata.com/download/10m/cultural/
ne_10m_admin_1_states_provinces.zip
*/

spshape2dta data\ne_10m_admin_1_states_provinces, replace

use ne_10m_admin_1_states_provinces.dta, replace


**#*** Generate a variable with the lenght of the name *********

generate length = length(name)

*format LPOP %4.2f

order name length, first

**#*** Draw the map for Chinese regions ************************

grmap, activate

grmap length using ne_10m_admin_1_states_provinces_shp.dta ///
 if iso_a2 == "CN", id(_ID) ///
 fcolor(Blues)  ///
 osize(vvthin vvthin vvthin vvthin) ///
 ndsize(vvthin) ///
 ndfcolor(gray) clmethod(quantile) ///
 title("Region name length")
 
graph rename Graph map_china_regions, replace

graph export figures\map_china_regions.png, as(png) ///
 width(4000) replace
graph export figures\map_china_regions.pdf, as(pdf) ///
 replace

**#*** Draw the map for Austrian regions ************************

grmap length using ne_10m_admin_1_states_provinces_shp.dta ///
 if iso_a2 == "AT", id(_ID) ///
 fcolor(Blues)  ///
 osize(vvthin vvthin vvthin vvthin) ///
 ndsize(vvthin) ///
 ndfcolor(gray) ///
 title("Region name length")
 
graph rename Graph map_austria_regions, replace

graph export figures\map_austria_regions.png, as(png) ///
 width(4000) replace
graph export figures\map_austria_regions.pdf, as(pdf) ///
 replace

**#*** Draw the map for French regions *************************

grmap length using ne_10m_admin_1_states_provinces_shp.dta ///
 if iso_a2 == "FR" & name != "Guyane française" ///
 & name != "Guadeloupe" & name != "La Réunion" ///
 & name != "Martinique" & name != "Mayotte", id(_ID) ///
 fcolor(Blues)  ///
 osize(vvthin vvthin vvthin vvthin) ///
 ndsize(vvthin) ///
 ndfcolor(gray) ///
 title("Region name length")
 
graph rename Graph map_france_regions, replace

graph export figures\map_france_regions.png, as(png) ///
 width(4000) replace
graph export figures\map_france_regions.pdf, as(pdf) ///
 replace

**#*** Draw the map for Tunisian regions ***********************

grmap length using ne_10m_admin_1_states_provinces_shp.dta ///
 if iso_a2 == "TN", id(_ID) ///
 fcolor(Blues)  ///
 osize(vvthin vvthin vvthin vvthin) ///
 ndsize(vvthin) ///
 ndfcolor(gray) ///
 title("Region name length")
 
graph rename Graph map_tunisia_regions, replace

graph export figures\map_tunisia_regions.png, as(png) ///
 width(4000) replace
graph export figures\map_tunisia_regions.pdf, as(pdf) ///
 replace
 
save data\maps_region.dta, replace 
 
***************************************************************