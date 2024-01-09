**# **** Maps with GADM data ***********************************

cd C:\Users\jamel\Dropbox\stata\blog\Maps_Austria\

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

grmap length using data\gadm41_AUT_1_shp.dta, id(_ID) ///
 fcolor(Blues)  ///
 ndfcolor(gray) clmethod(quantile) ///
  polygon(data(data\gadm41_AUT_1_shp.dta) select(keep if ///
  _ID==9 | _ID==1) fc(red) os(vvthin)) ///
 os(vvthin vvthin vvthin vvthin) ndsize(vvthin) //////
 title("Region name length [length]") ///
 label(xcoord(_CX) ycoord(_CY) select(keep if _ID==9 | ///
  _ID==1 |_ID==2 | _ID==7) ///
  label(NAME_1) size(5) length(22) pos(11) angle(340) ///
  gap(-3)) ///
 legend(pos(11) size(5)) legcount 
 
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

grmap length using data\gadm41_AUT_2_shp.dta, id(_ID) ///
 fcolor(Blues)  ///
 ndfcolor(gray) clmethod(quantile) ///
  polygon(data(data\gadm41_AUT_2_shp.dta) ///
   select(keep if _ID==94 | ///
  _ID==2) fc(red) os(vvthin)) ///
 os(vvthin vvthin vvthin vvthin) ndsize(vvthin) ///
 title("Region name length [length]") ///
 label(xcoord(_CX) ycoord(_CY) select(keep if _ID==94 | ///
  _ID==2 | _ID==83)  ///
  label(NAME_2) size(5) length(22) pos(11) angle(340) ///
  gap(-3)) ///
 legend(pos(11) size(5)) legcount 
 
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

grmap length using data\gadm41_AUT_3_shp.dta, id(_ID) ///
 fcolor(Reds)  ///
 ndfcolor(gray) clmethod(quantile) ///
  polygon(data(data\gadm41_AUT_3_shp.dta) ///
   select(keep if _ID==24 | ///
  _ID==2100 | _ID==1814) fc(yellow) os(vvthin)) ///
 os(vvthin vvthin vvthin vvthin) ndsize(vvthin) ///
 title("Region name length [length]") ///
 label(xcoord(_CX) ycoord(_CY) select(keep if _ID==24 | ///
  _ID==2100 | _ID==1814) ///
 label(NAME_3) size(5) length(22) pos(11) angle(340) ///
  gap(-3)) ///
 legend(pos(11) size(5)) legcount 
 
graph rename Graph map_austria_3, replace
graph export figures\map_austria_3.png, as(png) ///
 width(4000) replace
graph export figures\map_austria_3.pdf, as(pdf) ///
 replace
 
/*
spshape2dta data\gadm41_AUT_shp\gadm41_AUT_4, ///
 saving(gadm41_AUT_4) replace

clear
*/

use gadm41_AUT_4.dta, clear

generate length = length(NAME_4)

grmap length using data\gadm41_AUT_4_shp.dta, id(_ID) ///
 fcolor(Blues)  ///
 ndfcolor(gray) clmethod(quantile) ///
  polygon(data(data\gadm41_AUT_4_shp.dta) select(keep if ///
  _ID==7810 | _ID==25 | _ID==7406) fc(red) os(vvthin)) ///
 os(vvthin vvthin vvthin vvthin) ndsize(vvthin) //////
 title("Region name length [length]") ///
 label(xcoord(_CX) ycoord(_CY) select(keep if _ID==7810 | ///
  _ID==7810 | _ID==25 | _ID==7406) ///
  label(NAME_4) size(5) length(13) pos(8) angle(340) ///
  gap(0) color(black)) ///
 legend(pos(11) size(5)) legcount 
 
graph rename Graph map_austria_4, replace
graph export figures\map_austria_4.png, as(png) ///
 width(4000) replace
graph export figures\map_austria_4.pdf, as(pdf) ///
 replace

grmap length using data\gadm41_AUT_4_shp.dta if ///
  _ID>=7762, id(_ID) ///
 fcolor(Blues)  ///
 ndfcolor(gray) clmethod(quantile) ///
  polygon(data(data\gadm41_AUT_4_shp.dta) select(keep if ///
  _ID==7810 | _ID==7791) fc(red) os(vvthin)) ///
 os(vvthin vvthin vvthin vvthin) ndsize(vvthin) //////
 title("Region name length [length]") ///
 label(xcoord(_CX) ycoord(_CY) select(keep if _ID==7810 | ///
  _ID==7810 | _ID==7791) ///
  label(NAME_4) size(5) length(13) pos(8) angle(340) ///
  gap(0) color(black)) ///
 legend(pos(11) size(5)) legcount 

graph rename Graph map_austria_4bis, replace
graph export figures\map_austria_4bis.png, as(png) ///
 width(8000) replace
graph export figures\map_austria_4bis.pdf, as(pdf) ///
 replace
 
**# **** China *************************************************
 
/*
spshape2dta data\gadm41_CHN_shp\gadm41_CHN_3, ///
 saving(gadm41_CHN_3) replace
*/
 
clear

use gadm41_CHN_3.dta, clear

generate length = length(NAME_1)

grmap length using data\gadm41_CHN_3_shp.dta, id(_ID) ///
 fcolor(Blues)  ///
 ndfcolor(gray) clmethod(quantile) ///
 polygon(data(data\gadm41_CHN_3_shp.dta) select(keep if _ID==78) ///
 fc(maroon) os(vvthin)) ///
 os(vvthin vvthin vvthin vvthin) ndsize(vvthin) ///
 title("Region name length [length]") ///
 label(xcoord(_CX) ycoord(_CY) select(keep if _ID==78) ///
 label(NAME_1) size(3) length(22) pos(3) angle(340) ///
  gap(1) color(maroon)) ///
 legend(pos(11) size(3)) legcount

graph rename Graph map_china, replace
graph export figures\map_china.png, as(png) ///
 width(4000) replace
graph export figures\map_china.pdf, as(pdf) ///
 replace
 
****************************************************************