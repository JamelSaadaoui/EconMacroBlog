**# Maps

cls

clear

// Start

**# Merge and draw the Maps

use maps_again.dta, clear

duplicates list IFScode

*drop if IFScode==.

drop ccode

rename IFScode imfcode

merge m:1 imfcode using gold2021.dta, nogenerate

spmap GOLD using coord_mercator_world.dta, ///
 id(na_id_world) fcolor(BuYlRd) ///
 osize(vvthin ..) ndsize(vvthin) ///
 ndfcolor(gray%10)  ///
 clnumber(7) ///
 title("Gold share in International Reserves in 2021") ///
note(`"Note: In some countries, the gold share can represent geopolitical alignment."', size(vsmall))

graph rename Graph GOLDMAP, replace

graph export GOLDMAP.png, replace width(4000)

**# End of the Program