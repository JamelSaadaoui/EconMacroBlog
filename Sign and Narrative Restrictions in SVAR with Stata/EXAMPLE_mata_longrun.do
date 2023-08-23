/* Long-run Zero Restrictions */

clear *
use data_longrun
tsset date

// estimate var
var GDPGrowth Unemployment, lags(1/4)
var_nr bq, var("VAR") opt("opts")

mata
// only plot GDP growth
opts.shck_plt = "GDPGrowth"

// compute IRF, bands, plot
IRF = irf_funct(VAR,opts)
IRFB = irf_bands_funct(VAR,opts)
irf_plot(IRF,IRFB,VAR,opts)

// compute FEVD, bands, plot
FEVD = fevd_funct(VAR,opts)
FEVDB = fevd_bands_funct(VAR,opts)
fevd_plot(FEVD,FEVDB,VAR,opts)

// compute HD, plot
HD = hd_funct(VAR,opts)
hd_plot(HD,VAR,opts)
end