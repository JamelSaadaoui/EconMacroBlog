**# **** Maps with GADM data ***********************************

cd C:\Users\jamel\Dropbox\stata\blog\Maps_Austria

**# **** Source of the Maps ************************************

// https://gadm.org/download_country.html


**# **** Austria ***********************************************

/*
spshape2dta data\gadm41_AUT_shp\gadm41_AUT_1, ///
 saving(gadm41_AUT_1) replace

clear
*/

use gadm41_AUT_1.dta, clear

generate length = length(NAME_1)

grmap length using gadm41_AUT_1_shp.dta, id(_ID) ///
 fcolor(Blues)  ///
 ndfcolor(gray) clmethod(quantile) ///
  polygon(data(gadm41_AUT_1_shp.dta) select(keep if _ID==9 | ///
  _ID==1) fc(red) os(vvthin)) ///
 os(vvthin vvthin vvthin vvthin) ndsize(vvthin) //////
 title("Region name length [length]") ///
 label(xcoord(_CX) ycoord(_CY) select(keep if _ID==9 | ///
  _ID==1) ///
 label(NAME_1) size(3.75) length(22))
 
graph rename Graph map_austria_1, replace
graph export figures\map_austria_1.png, as(png) ///
 width(4000) replace
graph export figures\map_austria_1.pdf, as(pdf) ///
 replace

/*
spshape2dta data\gadm41_AUT_shp\gadm41_AUT_2, ///
 saving(gadm41_AUT_2) replace

clear
*/

use gadm41_AUT_2.dta, clear

generate length = length(NAME_2)

grmap length using gadm41_AUT_2_shp.dta, id(_ID) ///
 fcolor(Blues)  ///
 ndfcolor(gray) clmethod(quantile) ///
  polygon(data(gadm41_AUT_2_shp.dta) ///
   select(keep if _ID==94 | ///
  _ID==2) fc(red) os(vvthin)) ///
 os(vvthin vvthin vvthin vvthin) ndsize(vvthin) ///
 title("Region name length [length]") ///
 label(xcoord(_CX) ycoord(_CY) select(keep if _ID==94 | ///
  _ID==2) ///
 label(NAME_2) size(3.75) length(22))
 
graph rename Graph map_austria_2, replace
graph export figures\map_austria_2.png, as(png) ///
 width(4000) replace
graph export figures\map_austria_2.pdf, as(pdf) ///
 replace 
 
 
/*
spshape2dta data\gadm41_AUT_shp\gadm41_AUT_3, ///
 saving(gadm41_AUT_3) replace

clear
*/

use gadm41_AUT_3.dta, clear

generate length = length(NAME_3)

grmap length using gadm41_AUT_3_shp.dta, id(_ID) ///
 fcolor(Reds)  ///
 ndfcolor(gray) clmethod(quantile) ///
  polygon(data(gadm41_AUT_3_shp.dta) ///
   select(keep if _ID==24 | ///
  _ID==2100) fc(ltbluishgray) os(vvthin)) ///
 os(vvthin vvthin vvthin vvthin) ndsize(vvthin) ///
 title("Region name length [length]") ///
 label(xcoord(_CX) ycoord(_CY) select(keep if _ID==24 | ///
  _ID==2100) ///
 label(NAME_2) size(3.75) length(22))
 
graph rename Graph map_austria_3, replace
graph export figures\map_austria_3.png, as(png) ///
 width(4000) replace
graph export figures\map_austria_3.pdf, as(pdf) ///
 replace
 
**# **** China *************************************************
 
/*
spshape2dta data\gadm41_CHN_shp\gadm41_CHN_3, ///
 saving(gadm41_CHN_3) replace
*/
 
clear

use gadm41_CHN_3.dta, clear

generate length = length(NAME_1)

grmap length using gadm41_CHN_3_shp.dta, id(_ID) ///
 fcolor(Blues)  ///
 ndfcolor(gray) clmethod(quantile) ///
 polygon(data(gadm41_CHN_3_shp.dta) select(keep if _ID==78) ///
 fc(red) os(vvthin)) ///
 os(vvthin vvthin vvthin vvthin) ndsize(vvthin) ///
 title("Region name length [length]") ///
 label(xcoord(_CX) ycoord(_CY) select(keep if _ID==78) ///
 label(NAME_1) size(3.75) length(22))

graph rename Graph map_china, replace
graph export figures\map_china.png, as(png) ///
 width(4000) replace
graph export figures\map_china.pdf, as(pdf) ///
 replace
 
****************************************************************