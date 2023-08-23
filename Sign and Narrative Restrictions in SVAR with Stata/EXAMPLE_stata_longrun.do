/* Long-run Zero Restrictions */

clear *
use data_longrun
tsset date

// estimate var
var GDPGrowth Unemployment, lags(1/4)
var_nr bq, var("VAR") opt("opts")

// only plot GDP growth
var_nr_options, opt("opts") shckplt("GDPGrowth")

// compute IRF, bands, plot
var_nr_irf, var("VAR") opt("opts") out("IRF")
var_nr_irf_bands, var("VAR") opt("opts") out("IRFB")
var_nr_irf_plot, irf("IRF") irfbands("IRFB") var("VAR") opt("opts")

// compute FEVD, bands, plot
var_nr_fevd, var("VAR") opt("opts") out("FEVD")
var_nr_fevd_bands, var("VAR") opt("opts") out("FEVDB")
var_nr_fevd_plot, fevd("FEVD") fevdbands("FEVDB") var("VAR") opt("opts")

// compute HD, bands, plot
var_nr_hd, var("VAR") opt("opts") out("HD")
var_nr_hd_plot, hd("HD") var("VAR") opt("opts")