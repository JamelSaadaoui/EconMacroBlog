*! version 1.0.0  29jan2025
program define svarjamel
 version 18.5 // or desired version
	
	matrix A = (1,0,0,0\.,1,0,0\.,.,1,0\.,.,.,1)
	matlist A

	matrix B = (.,0,0,0\0,.,0,0\0,0,.,0\0,0,0,.) 
	matlist B

	varsoc $X, maxlag(12)

	svar $X, aeq(A) beq(B) ///
	lags(1/12) 

	/* compute the inv(B)*A matrix */
	matrix A=e(A)
	matrix B=e(B)
	matrix BA = inv(B)*A
	/* compute reduced form epsilon_t residuals */
	var $X
	capture drop epsilon*
	predict double epsilon1,residual eq(#1)
	predict double epsilon2,residual eq(#2)
	predict double epsilon3,residual eq(#3)
	predict double epsilon4,residual eq(#4)
	/* store the epsilon* variables in the epsilon matrix */
	mkmat epsilon*, matrix(epsilon) 
	/* compute e_t matrix of structural shocks */
	matrix e = (BA*epsilon')'
	/* store columns of e as variables e1, e2, and e3 */  
	svmat double e

	label variable epsilon1 "Reduced-form shocks"
	label variable e1 "Structural shocks"

	twoway (tsline e1 if Period>tm(2000m1)) (tsline epsilon1 ///
	if Period>tm(2000m1), yaxis(1)), ///
	name(G, replace) legend(position(6)) graphregion(margin(r+5))

end
