**#****** On the use of labmask ********************************

cd C:\Users\jamel\Documents\GitHub\EconMacroBlog\Labmask

// Use dbnomics to import data

dbnomics import, pr(WB) d(WDI) ///
         indicator("SP.DYN.IMRT.IN") clear
rename   value INF_MORT
destring INF_MORT, replace force 
split    series_name, parse(–)
encode   series_name3, generate(cn)
keep     cn country period INF_MORT
order    cn country period INF_MORT
kountry  country, from(iso3c) to(imfn) m
list     cn country _IMFN_ MARKER /// 
         if period == 2020 & MARKER == 0
drop     if MARKER == 0
drop     NAMES_STD MARKER
rename   _IMFN_ imfcode
order    cn country imfcode period
drop     if imfcode==. 
xtset    imfcode period
xtdes

// Without labmask

label variable INF_MORT ///
 "Mortality rate, infant (per 1,000 live births)" 

xtline INF_MORT if imfcode==111 | imfcode==922, ///
 overlay xline(2017) note(series: SP.DYN.IMRT.IN)
 
// Export the graph in two different formats 

graph rename withoutlab, replace
graph export figures\without.png, as(png) ///
 width(4000) replace
graph export figures\without.pdf, as(pdf) ///
 replace

// With labmask


labmask imfcode, values(country)

label variable INF_MORT ///
 "Mortality rate, infant (per 1,000 live births)" 

xtline INF_MORT if imfcode==111 | imfcode==922, ///
 overlay xline(2017) note(series: SP.DYN.IMRT.IN)
 
// Export the graph in two different formats 

graph rename withlab, replace
graph export figures\with.png, as(png) ///
 width(4000) replace
graph export figures\with.pdf, as(pdf) ///
 replace

// Save the data

save data\labmask.dta, replace

**#***** End of the program ************************************