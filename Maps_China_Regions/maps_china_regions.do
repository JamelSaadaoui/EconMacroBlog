**#******** Download the map files *****************************

/*
https://www.naturalearthdata.com/
http//www.naturalearthdata.com/download/10m/cultural/
ne_10m_admin_1_states_provinces.zip
*/

spshape2dta data\ne_10m_admin_1_states_provinces, replace

// Download Regional GDP for China and merge it


import excel data\Regional_GDP.xlsx, sheet("Feuil1") ///
 cellrange(B1:G32) firstrow clear

save Regional_GDP.dta, replace 

use ne_10m_admin_1_states_provinces.dta, replace

merge 1:1 _ID using "Regional_GDP.dta", nogenerate

**#*** Generate a variable with the length of the name *********

generate length = length(name)

*format LPOP %4.2f

order name length GDP_*, first

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

// Run everything between preserve and restore

preserve

keep if iso_a2 == "CN" & name != "Paracel Islands"

grmap length using ne_10m_admin_1_states_provinces_shp.dta ///
 if iso_a2 == "CN", id(_ID) ///
 fcolor(Blues)  ///
 osize(vvthin vvthin vvthin vvthin) ///
 ndsize(vvthin) ///
 ndfcolor(gray) clmethod(quantile) ///
 title("Region name length") label(xcoord(_CX) ycoord(_CY) ///
 label(name_zht) size(*.5) length(50))

// use osize(vvthin vvthin vvthin vvthin) if you have 4 classes
// add more vvthin if you have more classes
 
graph rename Graph map_china_regions_cn, replace

graph export figures\map_china_regions_cn.png, as(png) ///
 width(4000) replace
graph export figures\map_china_regions_cn.pdf, as(pdf) ///
 replace
 
restore

// Run everything between preserve and restore

preserve

format GDP_* %4.2f

keep if iso_a2 == "CN" & name != "Paracel Islands"

grmap GDP_2021 using ne_10m_admin_1_states_provinces_shp.dta ///
 if iso_a2 == "CN", id(_ID) ///
 fcolor(YlOrRd)  ///
 osize(vvthin vvthin vvthin vvthin) ///
 ndsize(vvthin) ///
 ndfcolor(gray) clmethod(quantile) ///
 title("GDP per capita in thousands of Chinese Yuan (2021)") ///
 label(xcoord(_CX) ycoord(_CY) ///
 label(name) size(*.5) length(50))

// use osize(vvthin vvthin vvthin vvthin) if you have 4 classes
// add more vvthin if you have more classes
 
graph rename Graph map_china_regions_gdp, replace

graph export figures\map_china_regions_gdp.png, as(png) ///
 width(4000) replace
graph export figures\map_china_regions_gdp.pdf, as(pdf) ///
 replace
 
restore

**#*** Use Geoplot for Chinese regions *************************

/*
ssc install palettes, replace
ssc install colrspace, replace
ssc install moremata, replace
net install geoplot, replace ///
 from(https://raw.githubusercontent.com/benjann/geoplot/main/)
*/

*help colorpalette

preserve

geoframe create regions ///
 ne_10m_admin_1_states_provinces.dta, id(_ID) ///
 coord(_CX _CY) ///
 shpfile(ne_10m_admin_1_states_provinces_shp.dta) ///
 replace
 
keep if iso_a2 == "CN" & name != "Paracel Islands" 

merge 1:1 _ID using "Regional_GDP.dta", nogenerate

**#*** Generate a variable with the length of the name *********

generate length = length(name)

*format LPOP %4.2f

order name length GDP_*, first

format GDP_* %4.0f

geoplot ///
 (area regions GDP_2021, color(Blues) ///
 label("@lb-@ub (N=@n)")) ///
 (label regions name, size(vsmall) color(black)) ///
 (line regions, lwidth(vvthin)), clegend(position(sw)) ///
 zlabel(40(40)200) ///
 title("GDP per capita in thousands of Chinese Yuan (2021)")
 
graph rename Graph map_china_regions_geoplot, replace

graph export figures\map_china_regions_geoplot.png, as(png) ///
 width(4000) replace
graph export figures\map_china_regions_geoplot.pdf, as(pdf) ///
 replace
 
restore

**#*** Draw the map for Austrian regions ************************

// Run everything between preserve and restore

generate length2 = floor(100/length)

// Inverse the colors, bc Wien is inside Niederoesterreich... 

preserve

keep if iso_a2 == "AT"

grmap length2 using ne_10m_admin_1_states_provinces_shp.dta ///
 if iso_a2 == "AT", id(_ID) ///
 fcolor(Blues)  ///
 ndfcolor(gray) clmethod(quantile) ///
 title("Region name length [(Inverted - floor(100/length)]") ///
 label(xcoord(_CX) ycoord(_CY) ///
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

capture drop gn_a1_code1  gn_a1_code2  gn_a1_code3

split gn_a1_code, parse(.)

rename gn_a1_code2 dept

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
 label(dept) size(*.5) length(10))
 
graph rename Graph map_france_regions, replace

graph export figures\map_france_regions.png, as(png) ///
 width(4000) replace
graph export figures\map_france_regions.pdf, as(pdf) ///
 replace

/*
https://www.wikiwand.com/en/Departments_of_France
#Current_departments 
*/
 
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

preserve

keep if iso_a2 == "TN"

grmap length using ne_10m_admin_1_states_provinces_shp.dta ///
 if iso_a2 == "TN", id(_ID) ///
 fcolor(Blues)  ///
 ndfcolor(gray) ///
 title("Region name length") label(xcoord(_CX) ycoord(_CY) ///
 label(name_ar) size(*.75) length(30))
 
graph rename Graph map_tunisia_regions_ar, replace

graph export figures\map_tunisia_regions_ar.png, as(png) ///
 width(4000) replace
graph export figures\map_tunisia_regions_ar.pdf, as(pdf) ///
 replace

restore

**#*** Draw the map for Ghana's regions ***********************

// Run everything between preserve and restore

preserve

keep if iso_a2 == "GH"

grmap length using ne_10m_admin_1_states_provinces_shp.dta ///
 , id(_ID) ///
 fcolor(Blues)  ///
 osize(vvthin vvthin vvthin vvthin) ///
 ndsize(vvthin) ///
 ndfcolor(gray) ///
 title("Region name length") label(xcoord(_CX) ycoord(_CY) ///
 label(name) size(*.5) length(30)) clmethod(custom) /// 
 clbreaks(0 5 10 20) 
 
// Use custom break if some regions are not displayed with the
// quantile method

graph export figures\map_ghana_regions.png, as(png) ///
 width(4000) replace
graph export figures\map_ghana_regions.pdf, as(pdf) ///
 replace 
 
restore
 
save data\maps_region.dta, replace 
 
***************************************************************