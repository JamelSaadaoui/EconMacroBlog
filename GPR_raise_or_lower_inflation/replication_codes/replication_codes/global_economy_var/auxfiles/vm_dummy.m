
% PURPOSE: Generates dummy observations for a Minnesota Prior
% -----------------------------------------------------
% USAGE: vm_dummy
% -----------------------------------------------------
% NOTE: requires to run vm_spec.m
% -----------------------------------------------------
 
% tau    : Overall tightness
% d      : Scaling down the variance for the coefficients of a distant lag
% w      : Number of observations used for obtaining the prior for the 
%          covariance matrix of error terms (usually fixed to 1). 
% lambda : Tuning parameter for coefficients for constant.
% mu     : Tuning parameter for the covariance between coefficients*/


%******************************************************** 
% Import data series                                    *
%*******************************************************/
T0      = nlags;
nv      = size(YY,2);     %* number of variables */
nobs    = size(YY,1)-T0;  %* number of observations */
nex_    = 1; % Constant

%******************************************************** 
% Dummy Observations                                    *
%*******************************************************/

if nlags==1
    MP=0; % need to reset prior with one lag
end

if MP == 1
    
    
    %disp('Use Prior')
    ext_T0  = 0;                   

    tau     =   1;
    d       =   2;
    w       =   1;  
    lambda  =   1;
    mu      =   1;

    YY0     =   YY(1:T0,:);  
    ybar    =   mean(YY0)';
    sbar    =   std(YY0)' ;
    premom  =   [ybar sbar];


    % Generate matrices with dummy observations
    hyp = [tau; d; w; lambda; mu];
    [YYdum, XXdum, breakss] = varprior_h(nv,nlags,nex_,hyp,premom);
end

% Actual observations

YYact = YY(T0+1:T0+nobs,:);
XXact = zeros(nobs,nv*nlags);

i = 1;

while (i <= nlags)
    XXact(:,(i-1)*nv+1:i*nv) = YY(T0-(i-1):T0+nobs-i,:);
    i = i+1;
end

XXact = [XXact ones(nobs,1)];


    % For uninformative prior uncomment the following two lines
    if MP == 0
        
        %disp('Uninformative Prior')
        XXdum = [];
        YYdum = [];
    end
