clear

cd "C:\Users\jamel\Dropbox\Latex\PROJECTS\"
cd "24-11-xr-trump-election\Jupyter\"

graph set window fontface "Times New Roman"


import excel "BIS_exchange_rates.xlsx", sheet("Sheet1") firstrow

des

kountry   REF_AREA, from(iso2c)
rename    NAMES_STD country
kountry   REF_AREA, from(iso2c) to(imfn)
rename    _IMFN_ imfcode

replace   country = "United Arab Emirates" if REF_AREA == "AE"
replace   country = "Euro Area" if REF_AREA == "XM"

drop if imfcode==.

split    TIME_PERIOD, parse(-)
gen      string = TIME_PERIOD3 + ///
         "/" + TIME_PERIOD2 + ///
         "/" + TIME_PERIOD1
gen      date = date(string, "DMY")
format   date %td

split    TITLE, parse(-)
rename   TITLE2 UNITS

rename   OBS_VALUE XR

order imfcode date XR country REF_AREA UNITS 

replace imfcode=999 if country=="Euro Area"
labmask imfcode, value(REF_AREA)

xtset imfcode date
tsfill, full
xtset imfcode date
xtdes

lab var XR "Bilateral Exchange rates"

rename imfcode cn
group_dummy
rename cn imfcode

gen XRDAY = XR if date==td(20jan2025)

by imfcode: egen TR = mean(XRDAY)

replace DXR = 100*(XR-TR)/TR

lgraph DXR date if date>=td(20jan2025) ///
 & imfcode!=111 & DXR!=. & DXR!=0, ///
 err(semean) yline(0) xlab(,angle(90)) ///
 xti("") ti("Exchange rate variation")

label variable DXR "Bilateral Exchange Rate"

xtline DXR if idc==1 & date>=td(20jan2025) ///
 & imfcode!=111 & DXR!=. & DXR!=0, yline(0) ///
overlay title("Industrial Countries") ///
note("Data from the Bank for International Settlements")
graph rename idc, replace
graph export idc.png, as(png) width(4000) replace

xtline DXR if emg2==1 & date>=td(20jan2025) ///
 & imfcode!=111 & DXR!=. & DXR!=0, yline(0) ///
overlay title("Emerging Countries") ///
note("Data from the Bank for International Settlements")
graph rename emg2, replace
graph export emg2.png, as(png) width(4000) replace

xtline DXR if eap==1 & date>=td(20jan2025) ///
 & imfcode!=111 & DXR!=., yline(0) ///
overlay title("East Asia Pacific") ///
note("Data from the Bank for International Settlements")
graph rename eap, replace
graph export eap.png, as(png) width(4000) replace

xtline DXR if eca==1 & date>=td(20jan2025) ///
 & imfcode!=111 & DXR!=., yline(0) ///
overlay title("Europe and Central Asia") ///
note("Data from the Bank for International Settlements")
graph rename eca, replace
graph export eca.png, as(png) width(4000) replace

xtline DXR if lac==1 & date>=td(20jan2025) ///
 & imfcode!=111 & DXR!=., yline(0) ///
overlay title("Latin America") ///
note("Data from the Bank for International Settlements")
graph rename lac, replace
graph export lac.png, as(png) width(4000) replace

xtline DXR if we==1 & date>=td(20jan2025) ///
 & imfcode!=111 & DXR!=., yline(0) ///
overlay title("Western Europe") ///
note("Data from the Bank for International Settlements")
graph rename we, replace
graph export we.png, as(png) width(4000) replace

xtline DXR if fc==1 & date>=td(20jan2025) ///
 & imfcode!=111 & DXR!=., yline(0) ///
overlay title("Financial Centers") ///
note("Data from the Bank for International Settlements")
graph rename oil, replace
graph export oil.png, as(png) width(4000) replace

save dailyXR31jan.dta, replace