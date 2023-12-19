**#***** Convert COW into IFS ********************************** 

clear
cls

capture log close _all                            
log using map_again, name(map_again) text replace

use data\map.dta, clear

*drop if country==""

sort COWcode

kountry COWcode, from(cown) to(imfn)

rename _IMFN_ IFScode
order IFScode COWcode, first

save data\maps_again.dta, replace

**#****** Generate Average Financial openness ******************

use data\kaopen_2021.dta, clear

rename cn IFScode

keep if year>=2011

by IFScode: egen mean_ka_open=mean(ka_open) 

keep if year==2021

save data\kaopen_again.dta, replace

**#****** Merge and draw the Maps ******************************

use data\maps_again.dta, clear

duplicates list IFScode

*drop if IFScode==.

drop ccode

merge m:1 IFScode using data\kaopen_again.dta, nogenerate

format mean_ka_open %12.2f

spmap mean_ka_open using data\coord_mercator_world.dta, ///
id(na_id_world) fcolor(Blues2) ///
osize(vvthin vvthin vvthin vvthin) ndsize(vvthin) ///
ndfcolor(gray) clmethod(custom) /// 
clbreaks(0 0.17 0.5 0.97 1) ///
title("Financial openness (average 2011-2021)")

graph rename Graph map_ka_open, replace

graph export figures\map_ka_open.png, as(png) width(4000) replace
graph export figures\map_ka_open.pdf, as(pdf) replace

format mean_debt %12.0f

spmap mean_debt using data\coord_mercator_world.dta, ///
id(na_id_world) fcolor(YlOrRd) ///
osize(vvthin vvthin vvthin vvthin) ///
ndsize(vvthin) ndfcolor(gray) clmethod(custom) /// 
clbreaks(0 38 52 97 300) ///
title("Central government debt (average 2015-2023)")

graph rename Graph map_debt, replace

graph export figures\map_debt.png, as(png) width(4000) replace
graph export figures\map_debt.pdf, as(pdf) replace

sum mean_debt mean_ka_open, detail

pwcorr mean_debt mean_ka_open if mean_ka_open>=0.97, obs sig
pwcorr mean_debt mean_ka_open if mean_ka_open<=0.17, obs sig

// Save the data
save data\map_again_final.dta, replace

log close map_again
exit

****************************************************************