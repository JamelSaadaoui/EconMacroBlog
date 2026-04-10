version 18.0

capture log close _f4
log using "$JIE_LOG/21_figure4_acts_threats.log", replace text ///
    name(_f4)

use "$JIE_DER/annual_panel.dta", clear
sort country_id year
xtset country_id year

local yraw ///
    gpa_country ///
    gpt_country ///
    inflation_ppt ///
    gdp_pct ///
    trade_to_gdp_ppt ///
    shortages_index ///
    milit_exp_to_gdp_ppt ///
    debt_to_gdp_ppt ///
    money_growth_ppt ///
    govt_exp_to_gdp_ppt

egen __rowmiss_f4 = rowmiss(`yraw')
gen byte sample_f4 = (__rowmiss_f4 == 0)
drop __rowmiss_f4

count if sample_f4
display as text "Figure 4 raw complete-case observations: " r(N)

qui levelsof country if sample_f4, local(countries_f4)
local ncountry : word count `countries_f4'
display as text "Figure 4 countries: `ncountry'"

foreach v of local yraw {
    by country_id: egen mean_`v'_f4 = mean(cond(sample_f4, `v', .))
    gen dm_`v'_f4 = cond(sample_f4, `v' - mean_`v'_f4, .)
}

local ydm
foreach v of local yraw {
    local ydm `ydm' dm_`v'_f4
}

mata: jie_bvar_pooled_summary( ///
    "`ydm'", "country_id", "year", "sample_f4", ///
    $JIE_P, $JIE_H, $JIE_NDRAWS, 1, 1, ///
    "F4A_Q05", "F4A_Q50", "F4A_Q95", ///
    "F4A_MEAN", "F4A_VAR", "F4A_Neff" ///
)

mata: jie_bvar_pooled_summary( ///
    "`ydm'", "country_id", "year", "sample_f4", ///
    $JIE_P, $JIE_H, $JIE_NDRAWS, 2, 2, ///
    "F4T_Q05", "F4T_Q50", "F4T_Q95", ///
    "F4T_MEAN", "F4T_VAR", "F4T_Neff" ///
)

display as text "Figure 4 lag-valid pooled rows (acts): " ///
    %9.0g scalar(F4A_Neff)

display as text "Figure 4 lag-valid pooled rows (threats): " ///
    %9.0g scalar(F4T_Neff)

local cnA05
local cnA50
local cnA95
local cnT05
local cnT50
local cnT95

foreach v of local yraw {
    local cnA05 `cnA05' acts_q05_`v'
    local cnA50 `cnA50' acts_q50_`v'
    local cnA95 `cnA95' acts_q95_`v'
    local cnT05 `cnT05' threats_q05_`v'
    local cnT50 `cnT50' threats_q50_`v'
    local cnT95 `cnT95' threats_q95_`v'
}

matrix colnames F4A_Q05 = `cnA05'
matrix colnames F4A_Q50 = `cnA50'
matrix colnames F4A_Q95 = `cnA95'
matrix colnames F4T_Q05 = `cnT05'
matrix colnames F4T_Q50 = `cnT50'
matrix colnames F4T_Q95 = `cnT95'

preserve
clear
set obs `= $JIE_H + 1'
gen horizon = _n - 1

svmat double F4A_Q05, names(col)
svmat double F4A_Q50, names(col)
svmat double F4A_Q95, names(col)

svmat double F4T_Q05, names(col)
svmat double F4T_Q50, names(col)
svmat double F4T_Q95, names(col)

replace acts_q05_gdp_pct    = 100 * acts_q05_gdp_pct
replace acts_q50_gdp_pct    = 100 * acts_q50_gdp_pct
replace acts_q95_gdp_pct    = 100 * acts_q95_gdp_pct

replace threats_q05_gdp_pct = 100 * threats_q05_gdp_pct
replace threats_q50_gdp_pct = 100 * threats_q50_gdp_pct
replace threats_q95_gdp_pct = 100 * threats_q95_gdp_pct

save "$JIE_DER/fig4_irf.dta", replace
export delimited using "$JIE_DER/fig4_irf.csv", replace

local gtitle_gpa_country          "GPA Country (Blue)"
local gtitle_gpt_country          "GPT Country (Gray)"
local gtitle_inflation_ppt        "Inflation (ppt)"
local gtitle_gdp_pct              "GDP (%)"
local gtitle_trade_to_gdp_ppt     "Trade to GDP (ppt)"
local gtitle_shortages_index      "Shortages Index"
local gtitle_milit_exp_to_gdp_ppt "Mil. Exp. to GDP (ppt)"
local gtitle_debt_to_gdp_ppt      "Debt to GDP (ppt)"
local gtitle_money_growth_ppt     "Money Growth (ppt)"
local gtitle_govt_exp_to_gdp_ppt  "Govt Exp. to GDP (ppt)"

local yset_gpa_country ///
    "yscale(range(-0.02 1.05)) ylabel(0 .5 1, nogrid labsize(medsmall))"

local yset_gpt_country ///
    "yscale(range(-0.02 1.05)) ylabel(0 .5 1, nogrid labsize(medsmall))"

local yset_inflation_ppt ///
    "yscale(range(0 3)) ylabel(0 .5 1 1.5 2 2.5, nogrid labsize(medsmall))"

local yset_gdp_pct ///
    "yscale(range(-2.5 0.1)) ylabel(-2 -.5 -1 -1.5 0, nogrid labsize(medsmall))"

local yset_trade_to_gdp_ppt ///
    "yscale(range(-1.25 0.55) noextend) ylabel(-1 -.5 0 .5, angle(horizontal) nogrid labsize(medsmall))"

local yset_shortages_index ///
    "yscale(range(0 .5)) ylabel(0 .1 .2 .3 .4, nogrid labsize(medsmall))"

local yset_milit_exp_to_gdp_ppt ///
    "yscale(range(-0.15 1.55)) ylabel(0 .5 1 1.5, nogrid labsize(medsmall))"

local yset_debt_to_gdp_ppt ///
    "yscale(range(-1 4.5)) ylabel(-1 0 1 2 3 4, nogrid labsize(medsmall))"

local yset_money_growth_ppt ///
    "yscale(range(-.5 2.1)) ylabel(-.5 0 .5 1 1.5 2, nogrid labsize(medsmall))"

local yset_govt_exp_to_gdp_ppt ///
    "yscale(range(0 1.4)) ylabel(0 .5 1, nogrid labsize(medsmall))"

local linecolA "blue"
local bandcolA "lavender"

local linecolT "gs5"
local bandcolT "gs12"

local graphs
foreach v of local yraw {
    twoway ///
        rarea acts_q05_`v' acts_q95_`v' horizon, ///
            color(`bandcolA'%65) ///
            lcolor(`bandcolA'%0) || ///
        rarea threats_q05_`v' threats_q95_`v' horizon, ///
            color(`bandcolT'%45) ///
            lcolor(`bandcolT'%0) || ///
        line acts_q50_`v' horizon, ///
            lcolor(`linecolA') lwidth(medthick) || ///
        line threats_q50_`v' horizon, ///
            lcolor(`linecolT') lwidth(medthick) || ///
        , ///
        title("`gtitle_`v''", size(medium) color(black)) ///
        yline(0, lcolor(black%35) lwidth(vthin)) ///
        xtitle("Year", size(medsmall)) ///
        ytitle("") ///
        xlabel(0(2)$JIE_H, labsize(medsmall) nogrid) ///
        `yset_`v'' ///
        legend(off) ///
        graphregion(color(white) margin(small)) ///
        plotregion(color(white) margin(tiny)) ///
        name(gr4_`v', replace)

    local graphs `graphs' gr4_`v'
}

*------------------------------------------------------------*
* IMPORTANT:
* Keep the individual twoway graphs as usual, but REMOVE any
* special xsize() you added by hand to the first two panels.
* The nested combine below will handle the width automatically.
*------------------------------------------------------------*

* First row, left mini-block:
* GPA Country + GPT Country together occupy ONE column
graph combine ///
    gr4_gpa_country ///
    gr4_gpt_country, ///
    cols(2) ///
    imargin(0 0 0 0) ///
    graphregion(color(white) margin(0 0 0 0)) ///
    name(row1_left_f4, replace)

* First row: 3 columns total
*   col 1 = row1_left_f4
*   col 2 = Inflation
*   col 3 = GDP
graph combine ///
    row1_left_f4 ///
    gr4_inflation_ppt ///
    gr4_gdp_pct, ///
    cols(3) ///
    imargin(1 1 1 1) ///
    graphregion(color(white) margin(0 0 0 0)) ///
    name(row1_f4, replace)

* Second row: standard 3-column row
graph combine ///
    gr4_trade_to_gdp_ppt ///
    gr4_shortages_index ///
    gr4_milit_exp_to_gdp_ppt, ///
    cols(3) ///
    imargin(1 1 1 1) ///
    graphregion(color(white) margin(0 0 0 0)) ///
    name(row2_f4, replace)

* Third row: standard 3-column row
graph combine ///
    gr4_debt_to_gdp_ppt ///
    gr4_money_growth_ppt ///
    gr4_govt_exp_to_gdp_ppt, ///
    cols(3) ///
    imargin(1 1 1 1) ///
    graphregion(color(white) margin(0 0 0 0)) ///
    name(row3_f4, replace)

*------------------------------------------------------------*
* Legend graph
* Do NOT use preserve again here if you are already inside a
* preserve block. Just clear the working data with drop _all.
*------------------------------------------------------------*
drop _all
set obs 2
gen x = _n
gen y1 = 1
gen y2 = 2

twoway ///
    line y1 x, lcolor(blue) lwidth(medthick) || ///
    line y2 x, lcolor(gs5)  lwidth(medthick) || ///
    , ///
    legend( ///
        order(1 "GPA Shock" 2 "GPT Shock") ///
        rows(1) ///
        size(tiny) ///
        pos(6) ///
        ring(0) ///
        symxsize(22) ///
        region(fcolor(white) lcolor(black) lwidth(vthin) margin(small)) ///
    ) ///
    xtitle("") ///
    ytitle("") ///
    xlabel(none) ///
    ylabel(none) ///
    xscale(off) ///
    yscale(off) ///
    graphregion(color(white) margin(0 0 0 0)) ///
    plotregion(color(white) margin(0 0 0 0)) ///
    name(fig4_legend, replace)

*------------------------------------------------------------*
* Final stacked figure
*------------------------------------------------------------*
graph combine ///
    row1_f4 ///
    row2_f4 ///
    row3_f4 ///
    , ///
    cols(1) ///
    imargin(zero) ///
    graphregion(color(white) margin(2 2 2 2)) ///
    name(fig4_combined, replace)

graph save "$JIE_FIG/figure4_acts_threats_journalstyle.gph", replace
graph export "$JIE_FIG/figure4_acts_threats_journalstyle.png", ///
    width(2600) replace

restore
log close _f4