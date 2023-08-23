/* Short-run Zero Restrictions */

clear *
use data_shortrun
tsset date

// estimate var
var Inflat Unempl FedFunds, lags(1/2) exog(trend trendsq)
var_nr oir, varname("VAR") optname("opts") lintr(trend) quadtr(trendsq)

// IRF
var_nr_irf, var("VAR") opt("opts") out("IRF") statamatrix("mymat_irf")
var_nr_irf_bands, var("VAR") opt("opts") out("IRFB")
mat list mymat_irf

// FEVD
var_nr_fevd, var("VAR") opt("opts") out("FEVD") statamatrix("mymat_fevd")
var_nr_fevd_bands, var("VAR") opt("opts") out("FEVDB")
mat list mymat_fevd

// HD
var_nr_hd, var("VAR") opt("opts") out("HD")

// plot all of the above
var_nr_irf_plot, irf("IRF") irfbands("IRFB") var("VAR") opt("opts")
var_nr_fevd_plot, fevd("FEVD") fevdbands("FEVDB") var("VAR") opt("opts")
var_nr_hd_plot, hd("HD") var("VAR") opt("opts")