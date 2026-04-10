***************************************************
***************************************************
* Run Cross-Country Figures for GPR+Inflation
* Date: May 11 2023
***************************************************
***************************************************
window manage close graph _all 
set scheme s1color, permanently

********************************************
********************************************
* Preliminaries 
********************************************
********************************************

use CICP_JIE.dta, clear



global first_year = 1900 //what is start year of our sample that we want to set?
global last_year = 2024 //what is the end year of our sample that we want to set?


set graphics on

sort country year

// Scale GDP for regressions
gen gdpvar = 100*lngdp



// GENERATE YEAR DUMMIES 
 
sort iso year
gen dum_1 = 0
replace dum_1 = 1 if year <= 1945
gen dum_2 = 0
replace dum_2 = 1 if year >= 1946 & year <= 1972
gen dum_3 = 0
replace dum_3 = 1 if year >= 1973
gen dum_4 = 0
replace dum_4 = 1 if year >= 1946

label var dum_1 "Dummy Pre-1946"
label var dum_2 "Dummy 1946-1972"
label var dum_3 "Dummy Post-1972"
label var dum_4 "Dummy Post-WWII"



************************************************
* GENERATE TABLE 1
************************************************

label variable inflation_sig "Inflation (%)"
label variable ggdp "GDP Growth (%)"
label variable gtogdp "Govt. Spending to GDP (%)"
label variable milit_exp_share "Military Spending to GDP (%)"
label variable debttogdp "Public Debt to GDP (%)"  
label variable impexp_gdp_ratio "Trade to GDP (%)"
label variable gmoney_sig "Money Growth (%)"
label variable sgprco "Country GPR Index"
label variable std_shortages "Country Shortages Index"


gen inflation_sig_afe = inflation_sig if afe==1
gen inflation_sig_eme = inflation_sig if afe==0

label variable inflation_sig_afe "Advanced Economies"
label variable inflation_sig_eme "Emerging Economies"






//***************************************************
// TABLE 1
//***************************************************

replace sgprco = sgprco+0.01
replace std_shortages = std_shortages+0.02

// Alternative approach using estpost and esttab
estpost summarize inflation_sig inflation_sig_afe inflation_sig_eme ggdp gtogdp milit_exp_share debttogdp impexp_gdp_ratio gmoney_sig sgprco std_shortages if tin(1900,2023), detail

estout using output\table1.txt, replace ///
    title("Summary Statistics for the Annual Dataset") ///
    cells("mean(fmt(1)) sd(fmt(1)) p5(fmt(1)) p50(fmt(1)) p95(fmt(1)) count(fmt(%9.0fc))") ///
    style(tex) ///
    varlabels(inflation_sig "Inflation (\%)" ///
             inflation_sig_afe "  Advanced Economies " ///
             inflation_sig_eme "  Emerging Economies " ///
             ggdp "GDP Growth (\%)" ///
             gtogdp "Govt. Spending to GDP (\%)" ///
             milit_exp_share "Military Spending to GDP (\%)" ///
             debttogdp "Public Debt to GDP (\%)" ///
             impexp_gdp_ratio "Trade to GDP (\%)" ///
             gmoney_sig "Money Growth (\%)" ///
             sgprco "Country GPR Index" ///
             std_shortages "Country Shortages Index") ///
    varwidth(30) ///
    modelwidth(10)

replace sgprco = sgprco-0.01
replace std_shortages = std_shortages-0.02


centile inflation inflation_sig, centile(1 97.5)
centile gmoney gmoney_sig, centile(1 97.5)


 




varabbrev summarize inflation_sig inflation_sig_afe inflation_sig_eme ggdp gtogdp milit_exp_share debttogdp impexp_gdp_ratio gmoney_sig sgprco std_shortages if tin(1900,2023)




******************************************
******** FIG 1   - GLOBAL          *******
******************************************

  
// replace rgdppc_weo = rgdppc_weo*1000 if iso=="USA"


/// Scale GDP per capita using actual GDP from WDI
// For actual GDP, use population from Maddison, and GDP from weo
gen totgdp_weo = rgdppc_weo*pop/1000000
list iso totgdp_weo if year==2006
label var totgdp_weo "Total GDP, Weo+Maddison, 2017$, bn$"
egen mtotgdp_weo_temp = mean(totgdp_weo) if year==2006, by(country)
egen mtotgdp_weo = mean(mtotgdp_weo_temp), by(country)
gen gdp_weighed = gdp*mtotgdp_weo/100

sort country year
gen ln_gdp_weighed = log(gdp_weighed)
by country: ipolate ln_gdp_weighed year, gen(ln_gdp_weighed_interpol) epolate
gen gdp_weighed_interpol = exp(ln_gdp_weighed_interpol)


// Declare variable used for weighting
gen share_var = gdp_weighed_interpol

// GLOBAL INFLATION
bys year: egen den_inflation = total(share_var) if inflation~=.
gen share_inflation = share_var/den_inflation if inflation~=.
bys year: egen inflation_world = total(inflation_sig*share_inflation) 


// GLOBAL GDP
bys year: egen den_gdp = total(share_var) if ggdp~=.
gen share_gdp = share_var/den_gdp if ggdp~=.
bys year: egen ggdp_world = total(ggdp*share_gdp) 

gen gdp_world = 100 if year==1900
sort country year
replace gdp_world = L.gdp_world*(1+ggdp_world/100) if year>1900
sum gdp_world if year==2006
replace gdp_world = 100*gdp_world/`r(mean)'


// GLOBAL TRADE
bys year: egen den_trade = total(share_var) if impexp_gdp_ratio~=.
gen share_trade = share_var/den_trade if impexp_gdp_ratio~=.
bys year: egen trade_world = total(impexp_gdp_ratio*share_trade)  

bys year: egen den_trade2 = total(share_var) if impexp_gdp_ratio~=. & iso~="USA"
gen share_trade2 = share_var/den_trade2 if impexp_gdp_ratio~=. & iso~="USA"
bys year: egen trade_world_exus = total(impexp_gdp_ratio*share_trade2)  


tabulate country, summarize(trade_world)
tabulate country, summarize(gdp_world)
tabulate country, summarize(inflation_world)





sum gprh if year>=1900 & year<=2019 & countrylong=="United States" 
global GPRCF = `r(mean)'
gen GPR100 = gprh/$GPRCF*100



//Time series
twoway ///
(line  inflation_world year if year >= 1900 & year <= 2023 & countrylong=="United States", ///
ylabel(, angle(horizontal) format(%5.0f) labcolor(red))  ///
 yaxis(1) lcolor(red) ytitle("") ysc(r(0 1)) lwidth(.70))  ///
(line  GPR100 year if year >= 1900 & year <= 2023 & countrylong=="United States", ///
yaxis(2) ysc(r(30 500) axis(2) log) xlab(1900(10)2010 2023) ///
ylab(30 60 100(100)400, axis(2)) lcolor(blue) lwidth(.60) xtitle("") ytitle("", axis(2)) ///
ylabel(, axis(2) labcolor(blue) angle(horizontal) format(%5.0f))  ///
legend( ring(0) position(2) bmargin(vsmall) order(1 "World Inflation" "(Left)" 2 "GPR Index" "(1900-2019=100)" "(Right)") c(1) size(small) bm(tiny) symx(5))),  ///
name(infl_gpr, replace) graphregion(fcolor(white)) title("") nodraw

//Bar plot version
eststo clear
gen high_inf = .
areg inflation_sig  dum_1##afe dum_2##afe dum_3##afe if year >= 1900 & sgpr != ., a(countrycode)


predict inflation_hat, resid

sum inflation_hat
replace high_inf = (inflation_hat >= 3 & sgpr != .)
bysort year: egen ann_high_inf = mean(100 * high_inf)
replace ann_high_inf = . if year < 1900

twoway bar ann_high_inf year if year >= 1900 & year <= 2023, barw(.1) ytitle("", axis(1)) bcolor(red)  || ///
(line  GPR100 year if year >= 1900 & year <= 2023 & countrylong=="United States", ///
yaxis(2)  ysc(r(30 500) axis(2) log) ///
ylab(30 60 100(100)400, axis(2)) ///
 ylabel(, axis(1) angle(horizontal) format(%5.0f) labcolor(red)) ///
 ylabel(, axis(2) angle(horizontal) format(%5.0f) labcolor(blue)) ///
xlab(1900(10)2010 2023) bcolor(green) lcolor(blue) lwidth(.60) xtitle("") ytitle("", axis(2)) ///
legend( ring(0) position(1) bmargin(vsmall) order(1 "Share of Countries" "with High Inflation (Left)" 2 "GPR Index" "(Right)") c(1) size(small) symx(5))),  ///
name(bar, replace) graphregion(fcolor(white)) title("") nodraw



gr combine infl_gpr bar, name(infl_gpr_bar, replace) rows(2) scheme(s1color)
gr export output/fig1.pdf, name(infl_gpr_bar) as(pdf) replace



 format inflation_sig* %5.1f
 format sgprco* %5.1f

 










******************************************
******** FIG 2 - COUNTRY PANEL     *******
******************************************

sort country year



// Generate label for outliers
gen label_outlier = "*" if inflation_sig~=. & inflation_trim==.

// USA
twoway ///
(line inflation year if iso == "USA", ///
cmissing(n) ylabel(, angle(horizontal) format(%5.0f) labcolor(red)) ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70)) ///
(scatter inflation_sig year if iso == "USA" & inflation_sig~=. & inflation_trim==., ///
msymbol(none) mlabel(label_outlier) mlabposition(0) mlabsize(medium) mlabcolor(maroon) yaxis(1)) ///
(line sgprco year if iso == "USA", ///
yaxis(2) xlab(1900(20)2024) lcolor(blue) lwidth(.55) xtitle("") ytitle("", axis(2)) ///
ylabel(-2(2)4, axis(2) labcolor(blue) angle(horizontal) format(%5.0f))), ///
legend(off) plotregion(margin(-2 -2 -2 -2)) ///
name(i1, replace) graphregion(fcolor(white)) title("United States") nodraw

// GBR
twoway ///
(line inflation_sig year if iso == "GBR", ///
cmissing(n) ylabel(, angle(horizontal) format(%5.0f) labcolor(red)) ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70)) ///
(scatter inflation_sig year if iso == "GBR" & inflation_sig~=. & inflation_trim==., ///
msymbol(none) mlabel(label_outlier) mlabposition(0) mlabsize(medium) mlabcolor(maroon) yaxis(1)) ///
(line sgprco year if iso == "GBR", ///
yaxis(2) xlab(1900(20)2024) lcolor(blue) lwidth(.55) xtitle("") ytitle("", axis(2)) ///
ylabel(-1(1)4, axis(2) labcolor(blue) angle(horizontal) format(%5.0f))), ///
legend(off) plotregion(margin(-2 -2 -2 -2)) ///
name(i2, replace) graphregion(fcolor(white)) title("United Kingdom") nodraw

// DEU
twoway ///
(line inflation_sig year if iso == "DEU", ///
cmissing(n) ylabel(, angle(horizontal) format(%5.0f) labcolor(red)) ///
ylabel(-30 0(30)150) ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70)) ///
(scatter inflation_sig year if iso == "DEU" & inflation_sig~=. & inflation_trim==., ///
msymbol(none) mlabel(label_outlier) mlabposition(0) mlabsize(medium) mlabcolor(maroon) yaxis(1)) ///
(line sgprco year if iso == "DEU", ///
yaxis(2) xlab(1900(20)2024) lcolor(blue) lwidth(.55) xtitle("") ytitle("", axis(2)) ///
ylabel(-2(2)8, axis(2) labcolor(blue) angle(horizontal) format(%5.0f))), ///
legend(ring(0) position(2) rowgap(*0.3) order(1 "Inflation (Left)" 3 "GPR (Right)") c(1) size(small)) ///
name(i3, replace) graphregion(fcolor(white)) title("Germany") nodraw

// CHE
twoway ///
(line inflation_sig year if iso == "CHE", ///
cmissing(n) ylabel(, angle(horizontal) format(%5.0f) labcolor(red)) ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70)) ///
(scatter inflation_sig year if iso == "CHE" & inflation_sig~=. & inflation_trim==., ///
msymbol(none) mlabel(label_outlier) mlabposition(0) mlabsize(medium) mlabcolor(maroon) yaxis(1)) ///
(line sgprco year if iso == "CHE", ///
yaxis(2) xlab(1900(20)2024) lcolor(blue) lwidth(.55) xtitle("") ytitle("", axis(2)) ///
ylabel(-2(2)6, axis(2) labcolor(blue) angle(horizontal) format(%5.0f))), ///
legend(off) plotregion(margin(-2 -2 -2 -2)) ///
name(i4, replace) graphregion(fcolor(white)) title("Switzerland") nodraw

// KOR
twoway ///
(line inflation_sig year if iso == "KOR", ///
cmissing(n) ylabel(, angle(horizontal) format(%5.0f) labcolor(red)) ///
ylabel(-25 0(25)125) ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70)) ///
(scatter inflation_sig year if iso == "KOR" & inflation_sig~=. & inflation_trim==., ///
msymbol(none) mlabel(label_outlier) mlabposition(0) mlabsize(medium) mlabcolor(maroon) yaxis(1)) ///
(line sgprco year if iso == "KOR", ///
yaxis(2) xlab(1900(20)2024) lcolor(blue) lwidth(.55) xtitle("") ytitle("", axis(2)) ///
ylabel(-2(2)8, axis(2) labcolor(blue) angle(horizontal) format(%5.0f))), ///
legend(off) plotregion(margin(-2 -2 -2 -2)) ///
name(i5, replace) graphregion(fcolor(white)) title("Korea") nodraw

// VNM
twoway ///
(line inflation_sig year if iso == "VNM", ///
cmissing(n) ylabel(, angle(horizontal) format(%5.0f) labcolor(red)) ///
ylabel(-25 0(25)125) ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70)) ///
(scatter inflation_sig year if iso == "VNM" & inflation_sig~=. & inflation_trim==., ///
msymbol(none) mlabel(label_outlier) mlabposition(0) mlabsize(medium) mlabcolor(maroon) yaxis(1)) ///
(line sgprco year if iso == "VNM", ///
yaxis(2) xlab(1900(20)2024) lcolor(blue) lwidth(.55) xtitle("") ytitle("", axis(2)) ///
ylabel(-2(2)6, axis(2) labcolor(blue) angle(horizontal) format(%5.0f))), ///
legend(off) plotregion(margin(-2 -2 -2 -2)) ///
name(i6, replace) graphregion(fcolor(white)) title("Vietnam") nodraw

// IDN
twoway ///
(line inflation_sig year if iso == "IDN", ///
cmissing(n) ylabel(, angle(horizontal) format(%5.0f) labcolor(red)) ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70)) ///
(scatter inflation_sig year if iso == "IDN" & inflation_sig~=. & inflation_trim==., ///
msymbol(none) mlabel(label_outlier) mlabposition(0) mlabsize(medium) mlabcolor(maroon) yaxis(1)) ///
(line sgprco year if iso == "IDN", ///
yaxis(2) xlab(1900(20)2024) lcolor(blue) lwidth(.55) xtitle("") ytitle("", axis(2)) ///
ylabel(-1(1)5, axis(2) labcolor(blue) angle(horizontal) format(%5.0f))), ///
legend(off) plotregion(margin(-2 -2 -2 -2)) ///
name(i7, replace) graphregion(fcolor(white)) title("Indonesia") nodraw

// CHL
twoway ///
(line inflation_sig year if iso == "CHL", ///
cmissing(n) ylabel(, angle(horizontal) format(%5.0f) labcolor(red)) ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70)) ///
(scatter inflation_sig year if iso == "CHL" & inflation_sig~=. & inflation_trim==., ///
msymbol(none) mlabel(label_outlier) mlabposition(0) mlabsize(medium) mlabcolor(maroon) yaxis(1)) ///
(line sgprco year if iso == "CHL", ///
yaxis(2) xlab(1900(20)2024) lcolor(blue) lwidth(.55) xtitle("") ytitle("", axis(2)) ///
ylabel(-2(2)4, axis(2) labcolor(blue) angle(horizontal) format(%5.0f))), ///
legend(off) plotregion(margin(-2 -2 -2 -2)) ///
name(i8, replace) graphregion(fcolor(white)) title("Chile") nodraw

// ZAF
twoway ///
(line inflation_sig year if iso == "ZAF", ///
cmissing(n) ylabel(, angle(horizontal) format(%5.0f) labcolor(red)) ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70)) ///
(scatter inflation_sig year if iso == "ZAF" & inflation_sig~=. & inflation_trim==., ///
msymbol(none) mlabel(label_outlier) mlabposition(0) mlabsize(medium) mlabcolor(maroon) yaxis(1)) ///
(line sgprco year if iso == "ZAF", ///
yaxis(2) xlab(1900(20)2024) lcolor(blue) lwidth(.55) xtitle("") ytitle("", axis(2)) ///
ylabel(-2(2)6, axis(2) labcolor(blue) angle(horizontal) format(%5.0f))), ///
legend(off) plotregion(margin(-2 -2 -2 -2)) ///
name(i9, replace) graphregion(fcolor(white)) title("South Africa") nodraw

gr combine ///
i1 i2 i3 ///
i4 i5 i6 ///
i7 i8 i9, ///
imargin(0.25 0.25 2 2) ///
rows(3) ysize(9) xsize(14) graphregion(fcolor(white)) name(infl_gpr_ts_country, replace)

gr export output/fig2.pdf, name(infl_gpr_ts_country) as(pdf) replace



******************************************
******** FIG A.1 - DATA COVERAGE *********
******************************************



twoway ///
(scatter countrycode year if year==2019, ///
msize(0) mlabel(country) mlabcolor("red") mlabsize(3.7)  ysc(rev r(1 44)) xsc(r(2019(1)2021)) ylab(1 5(5)40 44, angle(horizontal))   xlab(2019(0)2019, angle(0) labcolor("white") tlc("white"))), title("Country") legend(off) ytitle("") xtitle("    ")  name(cname, replace) nodraw


foreach ii of numlist 1/9 {

	if `ii'==1 {
	global YVAL "sgprco"
	global YVALTITLE "GPR COUNTRY"
	}
	if `ii'==2 {
	global YVAL "inflation"
	global YVALTITLE "INFLATION"
	}
	if `ii'==3 {
	global YVAL "lngdp"
	global YVALTITLE "GDP"
	}
	if `ii'==4 {
	global YVAL "milit_exp_share"
	global YVALTITLE "MILITARY SPENDING"
	}
	if `ii'==5 {
	global YVAL "debttogdp"
	global YVALTITLE "DEBT TO GDP"
	}
	if `ii'==6 {
	global YVAL "impexp_gdp_ratio"
	global YVALTITLE "TRADE TO GDP"
	}
	if `ii'==7 {
	global YVAL "gmoney"
	global YVALTITLE "MONEY GROWTH"
	}
	if `ii'==8 {
	global YVAL "gtogdp"
	global YVALTITLE "GOVT SPENDING"
	}
	if `ii'==9 {
	global YVAL "st_rate"
	global YVALTITLE "INTEREST RATE"
	}

	gen iival = 1 if $YVAL~=.

	twoway ///
	(scatter countrycode year if iival==1 & year<=$last_year, ///
	msymbol(square) msize(.6) xline(1900(20)2020, lcolor(gray)) ylab(1 5(5)40 44, angle(horizontal)) ysc(rev r(1 44))  xlab(1900(40)2023, angle(0))), name($YVAL, replace) title($YVALTITLE) ytitle("") xtitle("  ") nodraw

	drop iival
}

graph combine ///
cname ///
sgprco ///
inflation ///
lngdp ///
milit_exp_share ///
cname ///
debttogdp ///
impexp_gdp_ratio ///
gmoney ///
gtogdp, ///
cols(5) rows(2) iscale(*.6) name(data_coverage, replace) imargin(1.5 1.5 1.5 1.5) ysize(8) xsize(7) ycommon

graph export output/appfig1.pdf, name(data_coverage) as(pdf) replace











******************************************
*** FIG A.2 - SHORTAGES BY COUNTRIES  ****
******************************************

// USA
 twoway ///
(line  std_shortages_c year if iso == "USA", ///
ylabel(, angle(horizontal) format(%5.0f))  ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70) ///  
xlab(1900(20)2024) lcolor(blue) xtitle("") ytitle("") ///
legend(off)),  ///
plotregion(margin(-1 -1 -1 -1)) ///
name(i1, replace) graphregion(fcolor(white)) title("United States") nodraw
 

// GBR
 twoway ///
(line  std_shortages_c year if iso == "GBR", ///
ylabel(, angle(horizontal) format(%5.0f))  ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70) ///  
xlab(1900(20)2024) lcolor(blue) xtitle("") ytitle("") ///
legend(off)),  ///
plotregion(margin(-1 -1 -1 -1)) ///
name(i2, replace) graphregion(fcolor(white)) title("United Kingdom") nodraw
 

// DEU
 twoway ///
(line  std_shortages_c year if iso == "DEU", ///
ylabel(, angle(horizontal) format(%5.0f))  ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70) ///  
xlab(1900(20)2024) lcolor(blue) xtitle("") ytitle("") ///
legend(off)),  ///
plotregion(margin(-1 -1 -1 -1)) ///
name(i3, replace) graphregion(fcolor(white)) title("Germany") nodraw
 

// CHE
 twoway ///
(line  std_shortages_c year if iso == "CHE", ///
ylabel(, angle(horizontal) format(%5.0f))  ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70) ///  
xlab(1900(20)2024) lcolor(blue) xtitle("") ytitle("") ///
legend(off)),  ///
plotregion(margin(-1 -1 -1 -1)) ///
name(i4, replace) graphregion(fcolor(white)) title("Switzerland") nodraw
 

// KOR
 twoway ///
(line  std_shortages_c year if iso == "KOR", ///
ylabel(, angle(horizontal) format(%5.0f))  ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70) ///  
xlab(1900(20)2024) lcolor(blue) xtitle("") ytitle("") ///
legend(off)),  ///
plotregion(margin(-1 -1 -1 -1)) ///
name(i5, replace) graphregion(fcolor(white)) title("Korea") nodraw
 


// VNM
 twoway ///
(line  std_shortages_c year if iso == "VNM", ///
ylabel(, angle(horizontal) format(%5.0f))  ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70) ///  
xlab(1900(20)2024) lcolor(blue) xtitle("") ytitle("") ///
legend(off)),  ///
plotregion(margin(-1 -1 -1 -1)) ///
name(i6, replace) graphregion(fcolor(white)) title("Vietnam") nodraw
 

// IDN
 twoway ///
(line  std_shortages_c year if iso == "IDN", ///
ylabel(, angle(horizontal) format(%5.0f))  ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70) ///  
xlab(1900(20)2024) lcolor(blue) xtitle("") ytitle("") ///
legend(off)),  ///
plotregion(margin(-1 -1 -1 -1)) ///
name(i7, replace) graphregion(fcolor(white)) title("Indonesia") nodraw
 

// CHL
 twoway ///
(line  std_shortages_c year if iso == "CHL", ///
ylabel(, angle(horizontal) format(%5.0f))  ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70) ///  
xlab(1900(20)2024) lcolor(blue) xtitle("") ytitle("") ///
legend(off)),  ///
plotregion(margin(-1 -1 -1 -1)) ///
name(i8, replace) graphregion(fcolor(white)) title("Chile") nodraw
 

// ZAF
 twoway ///
(line  std_shortages_c year if iso == "ZAF", ///
ylabel(, angle(horizontal) format(%5.0f))  ///
yaxis(1) lcolor(red) ytitle("") lwidth(.70) ///  
xlab(1900(20)2024) lcolor(blue) xtitle("") ytitle("") ///
legend(off)),  ///
plotregion(margin(-1 -1 -1 -1)) ///
name(i9, replace) graphregion(fcolor(white)) title("South Africa") nodraw
 

gr combine ///
i1 i2 i3 ///
i4 i5 i6 ///
i7 i8 i9, ///
imargin(0.4 0.4 0.4 0.4) ///
rows(3) ysize(9) xsize(14) graphregion(fcolor(white)) iscale(0.6) name(shortages, replace)
 
 
graph export output/appfig2.pdf, name(shortages) replace logo(off) mag(100) 













