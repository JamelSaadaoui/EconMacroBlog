use "C:\Users\jamel\Dropbox\Currency_Database\10.2. Gold as international reserves (198 countries) 1980-2021 - panel_data.dta", clear

xtdes

*ssc install labmask

labmask num, values(country)

set scheme Cleanplots
graph set window fontface "Palatino Linotype"

gen GOLD = 100*gold_val_market
format GOLD  %4.2f

*ssc install heatplot

kountry country, from(other) stuck marker

rename _ISO3N_ iso3c
drop MARKER
kountry iso3c, from(iso3n) to(iso2c)
rename _ISO2C_ iso2c

kountry iso3c, from(iso3n) to(imfn)
rename _IMFN_ imfcode
drop if imfcode==.

// Create the country groups (requires the ado-file 'group_dummy')
rename imfcode cn
group_dummy
rename cn imfcode 

summ GOLD if idc==1

heatplot GOLD country yr if idc==1 ///
    , ///
    cuts(0(10)90) ///
	color(plasma) ///
	ti("Gold share in international reserves - market value") ///
	xti("") yti("") ///
    ylabel(, angle(horizontal)) ///
    xlabel(, angle(vertical)) ///
	ramp(format(%4.0f) label(0(10)90) subtitle("")) ///
	name(GOLD_RODGER, replace) 
graph export GOLD_IDC.png, as(png) width(3000) replace

summ GOLD if eca==1 & yr>2000, detail

heatplot GOLD country yr if eca==1 & yr>1990 ///
    , ///
    cuts(0(5)40) ///
	color(plasma) ///
	ti("Gold share in international reserves - market value") ///
	subtitle("Europe and Central Asia") ///
	xti("") yti("") ///
    ylabel(, angle(horizontal) labsize(small)) ///
    xlabel(, angle(vertical)) ///
	ramp(format(%4.0f) label(0(5)40) subtitle("")) ///
	name(GOLD_MONKEYD, replace) 
graph export GOLD_ECA.png, as(png) width(3000) replace

keep if yr==2021
save gold2021.dta, replace