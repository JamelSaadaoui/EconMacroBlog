clear

*cd "C:\Users\joseph.gagnon\Peter G. Peterson Institute for International Economics\Research - Documents\Gagnon-Data\Tariff"

cap log close _all

set scheme s1mono

graph set window fontface "Palatino" 

log using Figures1-3.txt, replace text

import excel using "WDI Tariff 20250214.xlsx", sheet("Data") firstrow clear

destring CABP GDPD EXGD IMGD IMMERD EXMERD FISCP TARS TARW TARMS TARMW COSTDOC COSTBOR TIMEDOC TIMEBOR NODAD RESG RESXG NXGD NXGSD, replace force
drop if YEAR==.
encode CODE, gen(CTRY)
sort CTRY YEAR
xtset CTRY YEAR

*Get the imfcode
*ssc install kountry
kountry CODE, from(iso3c) to(imfn)
rename _IMFN_ imfcode

*Create US variable to make marker a different color
gen USCOLOR = 0
replace USCOLOR = 1 if CODE=="USA"

*Create net exports and change in reserves as percent of GDP
gen NXGP = 100*NXGD/GDPD
gen DRESP = 100*(D.RESXG/GDPD)

*Create 10-year moving averages
tssmooth ma NXGPMA10 = NXGP if L9.NXGP~=., window(9 1 0)
tssmooth ma CABPMA10 = CABP if L9.CABP~=., window(9 1 0)
tssmooth ma TARSMA10 = TARS if L9.TARS~=., window(9 1 0)
tssmooth ma TARWMA10 = TARW if L9.TARW~=., window(9 1 0)
tssmooth ma DRESPMA10 = DRESP if L9.DRESP~=., window(9 1 0)
tssmooth ma FISCPMA10 = FISCP if L9.FISCP~=., window(9 1 0)

*Create 20-year averages
gen NXGPMA20 = (NXGPMA10+L10.NXGPMA10)/2
gen CABPMA20 = (CABPMA10+L10.CABPMA10)/2
gen TARSMA20 = (TARSMA10+L10.TARSMA10)/2
gen TARWMA20 = (TARWMA10+L10.TARWMA10)/2
gen DRESPMA20 = (DRESPMA10+L10.DRESPMA10)/2
gen FISCPMA20 = (FISCPMA10+L10.FISCPMA10)/2

label variable CABPMA20 "Current account balance, percent of GDP"
label variable NXGPMA20 "Net exports of goods, percent of GDP"
label variable TARSMA20 "Average tariff rate"
label variable TARWMA20 "Effective tariff rate"
label variable FISCPMA20 "Fiscal balance, percent of GDP"
label variable DRESPMA20 "Annual change in foreign exchange reserves, percent of GDP"

*Inspect the data
sum NXGPMA20 CABPMA20 TARSMA20 TARWMA20 DRESPMA20 FISCPMA20
xtsum NXGPMA20 CABPMA20 TARSMA20 TARWMA20 DRESPMA20 FISCPMA20
xtdes

*Regress balances on tariffs, with and without outliers
*Create fitted values
reg NXGPMA20 TARSMA20 if YEAR==2022&TARSMA20<25
reg NXGPMA20 TARSMA20 if YEAR==2022
predict NXGPSP
reg NXGPMA20 TARWMA20 if YEAR==2022&TARWMA20<25
reg NXGPMA20 TARWMA20 if YEAR==2022
predict NXGPWP
reg CABPMA20 TARSMA20 if YEAR==2022&TARSMA20<25
reg CABPMA20 TARSMA20 if YEAR==2022
predict CABPSP
reg CABPMA20 TARWMA20 if YEAR==2022&TARWMA20<25
reg CABPMA20 TARWMA20 if YEAR==2022
predict CABPWP

gen CODEALT=CODE if imfcode==111 

*FIGURE ONE
scatter CABPMA20 TARSMA20 if YEAR==2022, colorvar(USCOLOR) clegend(off) || line CABPSP TARSMA20 if YEAR==2022, ytitle("Current account balance, percent of GDP") legend(off) saving("FIGURE1.gph",replace) name(FIGURE1, replace) || (scatter CABPMA20 TARSMA20 if YEAR == 2022, msymbol(none) mlabel(CODEALT) mlabpos(6) mlabcolor(black))
scatter CABPMA20 TARWMA20 if YEAR==2022, colorvar(USCOLOR) clegend(off) || line CABPWP TARWMA20 if YEAR==2022, ytitle("Current account balance, percent of GDP") legend(off) saving("CABWMA20.gph",replace) name(CABWMA20, replace)
scatter NXGPMA20 TARSMA20 if YEAR==2022, colorvar(USCOLOR) clegend(off) || line NXGPSP TARSMA20 if YEAR==2022, ytitle("Net exports of goods, percent of GDP") legend(off) saving("NXGSMA20.gph",replace) name(NXGSMA20, replace)
scatter NXGPMA20 TARWMA20 if YEAR==2022, colorvar(USCOLOR) clegend(off) || line NXGPWP TARWMA20 if YEAR==2022, ytitle("Net exports of goods, percent of GDP") legend(off) saving("NXGWMA20.gph",replace) name(NXGWMA20, replace)

*Regress trade balances on fiscal balance and on change in reserves
*Create fitted values
reg NXGPMA20 FISCPMA20 if YEAR==2022
predict NXGPFP
reg NXGPMA20 DRESPMA20 if YEAR==2022
predict NXGPRP
reg CABPMA20 FISCPMA20 if YEAR==2022
predict CABPFP
reg CABPMA20 DRESPMA20 if YEAR==2022
predict CABPRP

*FIGURE TWO
scatter CABPMA20 FISCPMA20 if YEAR==2022, colorvar(USCOLOR) clegend(off) || line CABPFP FISCPMA20 if YEAR==2022, ytitle("Current account balance, percent of GDP") legend(off) saving("FIGURE2.gph",replace) name(FIGURE2, replace) || (scatter CABPMA20 FISCPMA20 if YEAR == 2022, msymbol(none) mlabel(CODEALT) mlabpos(6) mlabcolor(black))
scatter NXGPMA20 FISCPMA20 if YEAR==2022, colorvar(USCOLOR) clegend(off) || line NXGPFP FISCPMA20 if YEAR==2022, ytitle("Net exports of goods, percent of GDP") legend(off) saving("NXGFMA20.gph",replace) name(NXGFMA20, replace)

*Drop observations not in figure because they distort the x-axis range
cap drop if DRESPMA20>10

scatter NXGPMA20 DRESPMA20 if YEAR==2022, colorvar(USCOLOR) clegend(off) || line NXGPRP DRESPMA20 if YEAR==2022, ytitle("Net exports of goods, percent of GDP") legend(off) saving("NXGRMA20.gph",replace) name(NXGRMA20, replace)
*FIGURE THREE
scatter CABPMA20 DRESPMA20 if YEAR==2022, colorvar(USCOLOR) clegend(off) || line CABPRP DRESPMA20 if YEAR==2022, ytitle("Current account balance, percent of GDP") legend(off) saving("FIGURE3.gph",replace) name(FIGURE3, replace) || (scatter CABPMA20 DRESPMA20 if YEAR == 2022, msymbol(none) mlabel(CODEALT) mlabpos(6) mlabcolor(black))

graph close _all

graph replay FIGURE*, noclose

log close

