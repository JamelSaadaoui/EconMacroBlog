**#******** Download the map files *****************************

/*

https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places.zip

*/

spshape2dta data\ne_10m_populated_places, replace

// Sort ID in the SHP file

use ne_10m_populated_places_shp.dta, replace

/*
https://www.statalist.org/forums/forum/
general-stata-discussion/general/
1583924-very-weird-spmap-problem-master-data-not-sorted
*/

sort _ID

save ne_10m_populated_places_shp.dta, replace

use ne_10m_populated_places.dta, replace

keep if ISO_A2 == "CN"

sort POP_MAX

/*
grmap POP_MAX using ne_10m_populated_places_shp.dta ///
 if ISO_A2 == "CN", id(_ID) ///
 fcolor(Blues)  ///
 osize(vvthin vvthin vvthin vvthin) ///
 ndsize(vvthin) ///
 ndfcolor(gray) clmethod(quantile) ///
 title("Populated Places")
*/

geoframe create towns ///
 ne_10m_populated_places.dta, id(_ID) ///
 coord(_CX _CY) ///
 shpfile(ne_10m_populated_places_shp.dta) ///
 replace
 
 
geoplot ///
 (point towns if ISO_A2 == "CN" ///
  & POP_MAX>1000000, color(black)) ///
 (label towns NAME if POP_MAX>5000000 & ///
  ISO_A2 == "CN", color(red) size(small)) ///
  , legend compass
  
rename ISO_A2 iso_a2

save ne_10m_populated_places.dta, replace
  
// Merge Provinces data and Towns data

use ne_10m_admin_1_states_provinces.dta, replace

merge m:m iso_a2 using "ne_10m_populated_places.dta", nogenerate

keep if iso_a2 == "CN"

// Create two geoframes

geoframe create towns ///
 ne_10m_populated_places.dta, id(_ID) ///
 coord(_CX _CY) ///
 shpfile(ne_10m_populated_places_shp.dta) ///
 replace
  
geoplot ///
 (point towns if iso_a2 == "CN" ///
  & POP_MAX>1000000, color(black)) ///
 (label towns NAME if POP_MAX>5000000 & ///
  iso_a2 == "CN", color(red) size(small)) ///
  , legend compass
  
geoframe create regions ///
 ne_10m_admin_1_states_provinces.dta, id(_ID) ///
 coord(_CX _CY) ///
 shpfile(ne_10m_admin_1_states_provinces_shp.dta) ///
 replace
 
keep if iso_a2 == "CN" & name != "Paracel Islands" 

merge 1:1 _ID using "Regional_GDP.dta", nogenerate

format GDP_* %4.0f

// Draw the map with two layers

geoplot ///
 (area regions GDP_2021, color(Reds) ///
   label("@lb-@ub (N=@n)") ///
   levels(5, quantile weight(GDP_2021))) ///
 (line regions, lwidth(vvthin)) ///
 (point towns if iso_a2 == "CN" ///
  & POP_MAX>2000000, color(black)) ///
 (label towns NAME if POP_MAX>5000000 & ///
  iso_a2 == "CN", color(blue) size(small)) /// 
  , ///
  legend(position(sw)) compass ///
  title("GDP per cap. in thousands of Chinese Yuan (2021)") ///
  note(Dots: Towns with > 2 millions of inhab. ///
  Names: Towns with > 5 millions of inhab.)
  
graph rename Graph map_china_regions_frame, replace

graph export figures\map_china_regions_frame.png, as(png) ///
 width(4000) replace
graph export figures\map_china_regions_frame.pdf, as(pdf) ///
 replace
 
frame dir

frames save myframeset, ///
 frames(regions towns regions_shp towns_shp) replace

save data/maps_regions_towns.dta, replace

****************************************************************