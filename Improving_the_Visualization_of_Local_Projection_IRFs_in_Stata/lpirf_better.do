
cd "C:\Users\jamel\Documents\GitHub\EconMacroBlog\Improving_the_Visualization_of_Local_Projection_IRFs_in_Stata"

webuse usmacro, clear
tsset

* Estimate local projections
lpirf inflation ogap fedfunds, lags(1/12) step(24)

* Store IRFs
irf set myirfs.irf, replace
irf create model1

* Graph with custom confidence band color
irf graph oirf, yline(0) ///
    ciopts(fcolor(blue%25) lcolor(blue)) xlabel(0(6)24) ///
    xscale(range(0 24)) byopts(note("") ti(, size(small))) xti("") ///
	  subtitle("") ysize(4) xsize(4) legend(cols(2))

graph export G1.png, as(png) width(3000)
	  
* Loop
	  
local impvars "fedfunds inflation ogap"
local resvars "fedfunds inflation ogap"

foreach i of local impvars {
    foreach j of local resvars {

        local gname g_`i'_`j'
        local mytitle ""
        local myytitle ""
        local myxtitle ""

        * column headings: response variables
        if "`i'" == "fedfunds" {
            local mytitle "Response: `j'"
        }

        * row headings: impulse variables
        if "`j'" == "fedfunds" {
            local myytitle "Shock: `i'"
        }

        * x-axis title only on last row
        if "`i'" == "ogap" {
            local myxtitle "Horizon (quarters)"
        }

        irf graph oirf, ///
            impulse(`i') response(`j') ///
            title("`mytitle'", size(large)) ///
            ytitle("`myytitle'") ///
            xtitle("`myxtitle'") ///          
            yline(0, lpattern(dash) lcolor(gs10)) ///
			ciopts(fcolor(blue%25) lcolor(blue)) xlabel(0(6)24) ///
            xscale(range(0 24)) byopts(note("")) ///
	        subtitle("") ysize(4) xsize(4) legend(size(large) col(2)) ///
            name(`gname', replace) nodraw
    }
}

grc1leg2 ///
    g_fedfunds_fedfunds g_fedfunds_inflation g_fedfunds_ogap ///
    g_inflation_fedfunds g_inflation_inflation g_inflation_ogap ///
    g_ogap_fedfunds g_ogap_inflation g_ogap_ogap, ///
    rows(3) cols(3) legendfrom(g_fedfunds_fedfunds) ysize(5) xsize(4) imargin(tiny)
	
graph export G2.png, as(png) width(3000)