/* Narrative Sign Restrictions */

clear *
use data_narrsignrestrict
tsset date

// estimate var
var lninflat lnunempl lnfedfunds, lags(1/2) exog(trend)
var_nr sr, varname("v") opt("opts") lintrend(trend)

// supply, demand, and monetary policy sign restrictions
var_nr_shock_create, varname("v") srname("s")
var_nr_shock_name, labels("Supply,Demand,Monetary Policy") srname("s")

var_nr_shock_set, sr("s") shock("Supply") affecting(lninflat) start(1) neg
var_nr_shock_set, sr("s") shock("Supply") affecting(lnunempl) start(1) neg
var_nr_shock_set, sr("s") shock("Supply") affecting(lnfedfunds) start(1) neg

var_nr_shock_set, sr("s") shock("Demand") affecting(lninflat) start(1) pos
var_nr_shock_set, sr("s") shock("Demand") affecting(lnunempl) start(1) neg
var_nr_shock_set, sr("s") shock("Demand") affecting(lnfedfunds) start(1) pos

var_nr_shock_set, sr("s") shock("Monetary Policy") affecting(lninflat) start(1) neg
var_nr_shock_set, sr("s") shock("Monetary Policy") affecting(lnunempl) start(1) pos
var_nr_shock_set, sr("s") shock("Monetary Policy") affecting(lnfedfunds) start(1) pos

// narrative restriction: positive Oct 79 (q4 '79)
var_nr_narr_create, varname("v") nsrname("ns")
loc vd = yq(1979,4)
var_nr_narr_set, nsr("ns") startpd(`vd') shock("Monetary Policy") positive

// set options
var_nr_options, opt("opts") ndraws(1000) updt("yes") updtfrqcy(10000)
var_nr_options_display, opt("opts") ndraws updt updtfrqcy

// run sign restrictions routine
set seed 123456
var_nr_sign_restrict, var("v") sr("s") nsr("ns") opt("opts") outname("SR")

// get irfs, fevds, hds
var_nr_irf, var("v") sr("SR") opt("opts") outname("IRF_set")
var_nr_fevd, var("v") sr("SR") opt("opts") outname("FEVD_set")
var_nr_hd, var("v") sr("SR") opt("opts") outname("HD_set")

// plot specified shocks/vars, save in stata gph format
var_nr_options, opt("opts") shckplt("Monetary Policy") savefmt("gph")
var_nr_irf_plot, irf("IRF_set") var("v") sr("SR") opt("opts")
var_nr_options, opt("opts") shckplt("lnfedfunds")
var_nr_fevd_plot, fevd("FEVD_set") var("v") sr("SR") opt("opts")
var_nr_options, opt("opts") shckplt("lninflat")
var_nr_hd_plot, hd("HD_set") var("v") sr("SR") opt("opts")