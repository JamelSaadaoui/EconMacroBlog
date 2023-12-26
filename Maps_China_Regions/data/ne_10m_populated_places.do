cd C:\Users\jamel\Dropbox\PC\Downloads

spshape2dta data\ne_10m_populated_places, replace

use ne_10m_populated_places_shp.dta, replace

sort _ID

save ne_10m_populated_places_shp.dta, replace

use ne_10m_populated_places.dta, replace

keep if ISO_A2 == "CN"

sort POP_MAX

grmap POP_MAX using ne_10m_populated_places_shp.dta ///
 if ISO_A2 == "CN", id(_ID) ///
 fcolor(Blues)  ///
 osize(vvthin vvthin vvthin vvthin) ///
 ndsize(vvthin) ///
 ndfcolor(gray) clmethod(quantile) ///
 title("Populated Places")

geoframe create towns ///
 ne_10m_populated_places.dta, id(_ID) ///
 coord(_CX _CY) ///
 shpfile(ne_10m_populated_places_shp.dta) ///
 replace
 
 
geoplot ///
    (point towns if ISO_A2 == "CN" ///
	 & POP_MAX>1000000, color(black)) ///
	(label towns NAME if POP_MAX>5000000 & ///
	ISO_A2 == "CN", color(red) size(large)) ///
    , legend compass 
	
	