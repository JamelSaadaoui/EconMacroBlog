******** Estimating a Nonlinear New Classical model ************

cd "C:\Users\jamel\Dropbox\stata\dsgenl"   // Set the directory

// Download, save data and describe data

use https://www.stata-press.com/data/r18/usmacro2

save usmacro2.dta, replace

describe

// Set the constraints

constraint 1 _b[alpha] = 0.33
constraint 2 _b[beta] = 0.99
constraint 3 _b[delta] = 0.025
constraint 4 _b[chi] = 2

// Estimate the remaining parameters

dsgenl (0 = {beta}*(c/F.c)*(1+F.r-{delta}) - 1)              ///
			(h = (1/{chi})*(w/c))						     ///
			(y = c + i)                                      ///
			(y = z*k^{alpha}*h^(1-{alpha}))                  ///
			(r = {alpha}*y/k)                                ///
			(w = (1-{alpha})*y/h)                            ///
			(F.k = i + (1-{delta})*k)                        ///
			(ln(F.z) = {rho}*ln(z))                          /// 
			, observed(y) unobserved(c i r w h) exostate(z)  ///
			endostate(k) constraint(1/4) tech(nr)
			
// Solving the model and finding the steady states

estat steady

// Generate model implied covariance between variables

estat covariance

// Impulse response function

irf set rbcirf, replace

irf create est, step(20) replace

irf graph irf, impulse(z) response(y c i h w z)              ///
  byopts(yrescale) ttitle(Effects of a Productivity shock (z))
  
graph rename prod, replace
graph export prod.png, replace  

// Sentivity analyses (a higher rate for depreciation)

ereturn list

matrix list	e(b)

matrix b2 = e(b)

matrix b2[1,2] = 0.08
  
dsgenl (0 = {beta}*(c/F.c)*(1+F.r-{delta}) - 1)              ///
			(h = (1/{chi})*(w/c))		     ///
			(y = c + i)                                      ///
			(y = z*k^{alpha}*h^(1-{alpha}))                  ///
			(r = {alpha}*y/k)                                ///
			(w = (1-{alpha})*y/h)                            ///
			(F.k = i + (1-{delta})*k)                        ///
			(ln(F.z) = {rho}*ln(z))                          /// 
			, observed(y) unobserved(c i r w h) exostate(z)  ///
		    endostate(k) constraint(1 2 4) tech(nr) from(b2) ///
			solve
			
irf create counterfactual, step(20) replace
irf ograph (est z c irf) (counterfactual z c irf),           ///
  title("Effect of a higher rate for depreciation")

graph rename counterfactual, replace
graph export counterfactual.png, replace  

****************************************************************