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

// Run everything between preserve and restore

*grmap, activate

preserve

keep if iso_a2 == "CN" & name != "Paracel Islands"

grmap length using ne_10m_admin_1_states_provinces_shp.dta ///
 if iso_a2 == "CN", id(_ID) ///
 fcolor(Blues)  ///
 osize(vvthin vvthin vvthin vvthin) ///
 ndsize(vvthin) ///
 ndfcolor(gray) clmethod(quantile) ///
 title("Region name length") label(xcoord(_CX) ycoord(_CY) ///
 label(name) size(*.5))
 
graph rename Graph map_china_regions, replace

graph export figures\map_china_regions.png, as(png) ///
 width(4000) replace
graph export figures\map_china_regions.pdf, as(pdf) ///
 replace

restore

**#*** Draw the map for Austrian regions ************************

// Run everything between preserve and restore

preserve

keep if iso_a2 == "AT"

grmap length using ne_10m_admin_1_states_provinces_shp.dta ///
 if iso_a2 == "AT", id(_ID) ///
 fcolor(Blues)  ///
 ndfcolor(gray) clmethod(quantile) ///
 title("Region name length") label(xcoord(_CX) ycoord(_CY) ///
 label(gn_name) size(*.75) length(22))
 
*Wien is inside Niederoesterreich... 
 
graph rename Graph map_austria_regions, replace

graph export figures\map_austria_regions.png, as(png) ///
 width(4000) replace
graph export figures\map_austria_regions.pdf, as(pdf) ///
 replace

restore
 
**#*** Draw the map for French regions *************************

// Run everything between preserve and restore

preserve

keep if iso_a2 == "FR" & name != "Guyane française" ///
 & name != "Guadeloupe" & name != "La Réunion" ///
 & name != "Martinique" & name != "Mayotte"

grmap length using ne_10m_admin_1_states_provinces_shp.dta ///
 if iso_a2 == "FR" & name != "Guyane française" ///
 & name != "Guadeloupe" & name != "La Réunion" ///
 & name != "Martinique" & name != "Mayotte", id(_ID) ///
 fcolor(Blues)  ///
 osize(vvthin vvthin vvthin vvthin) ///
 ndsize(vvthin) ///
 ndfcolor(gray) ///
 title("Region name length") label(xcoord(_CX) ycoord(_CY) ///
 label(name) size(*.5))
 
graph rename Graph map_france_regions, replace

graph export figures\map_france_regions.png, as(png) ///
 width(4000) replace
graph export figures\map_france_regions.pdf, as(pdf) ///
 replace

restore
 
**#*** Draw the map for Tunisian regions ***********************


/*
https://www.statalist.org/forums/forum/general-stata-discussion/general/1683184-drawing-country-maps-on-stata
*/

// Run everything between preserve and restore

preserve

keep if iso_a2 == "TN"

grmap length using ne_10m_admin_1_states_provinces_shp.dta ///
 if iso_a2 == "TN", id(_ID) ///
 fcolor(Blues)  ///
 ndfcolor(gray) ///
 title("Region name length") label(xcoord(_CX) ycoord(_CY) ///
 label(name) size(*.5))
 
graph rename Graph map_tunisia_regions, replace

graph export figures\map_tunisia_regions.png, as(png) ///
 width(4000) replace
graph export figures\map_tunisia_regions.pdf, as(pdf) ///
 replace

restore 
 
save data\maps_region.dta, replace 
 
***************************************************************