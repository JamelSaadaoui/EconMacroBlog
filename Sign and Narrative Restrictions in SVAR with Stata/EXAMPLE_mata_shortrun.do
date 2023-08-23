/* Short-run Zero Restrictions */

clear *
use data_shortrun
tsset date

// estimate var
var Inflat Unempl FedFunds, lags(1/2) exog(trend trendsq)
var_nr oir, varname("VAR") optname("opts") lintr(trend) quadtr(trendsq)

// estimate var
var Inflat Unempl FedFunds, lags(1/2) exog(trend trendsq)
var_nr oir, varname("VAR") optname("opts") lintr(trend) quadtr(trendsq)

mata
// IRF
IRF = irf_funct(VAR,opts)
IRFB = irf_bands_funct(VAR,opts)

// FEVD
FEVD = fevd_funct(VAR,opts)
FEVDB = fevd_bands_funct(VAR,opts)

// HD
HD = hd_funct(VAR,opts)

// plot all of the above
irf_plot(IRF,IRFB,VAR,opts)
fevd_plot(FEVD,FEVDB,VAR,opts)
hd_plot(HD,VAR,opts)
end