function [ IRFRESP, IRFSIM, IRFFIX, NN ] = estimate_var_gpr(SS)
% The function estimate_var_gpr takes as an input a structure SS
% containing
%               SS.igpra : scalar with index for gpr acts
%               SS.igprt : .... threats
%     SS.do_acts_threats : 0 1 dummy to do acts/threats special experiment
%               SS.nlags : number of lags
%                  SS.nv : number of variables
%               SS.XXdum : [] dummy observations (keep it empty)
%               SS.YYdum : [] dummy observations (keep it empty)
%               SS.XXact = [576×10 double] (stacked matrix of observations for VAR)               for VAR
%               SS.YYact = [576×3 double]
%            SS.ilogdiff = scalar with index(es) for amy variable entering in log difference
%            SS.ilevdiff = see above
%             SS.Horizon = horizon for impulse responses
%              SS.ndraws = number of draws for calculating confidence intervals
%            SS.ptileVEC = percentiles for confidence intervals (vector)
%
%       EXAMPLE
%               SS.igpra = 1
%               SS.igprt = 2
%     SS.do_acts_threats = 0
%               SS.nlags = 3
%                  SS.nv = 3
%               SS.XXdum = []
%               SS.YYdum = []
%               SS.XXact = [576×10 double] % for 3 lags this is 3x3+1 for the constant
%               SS.YYact = [576×3 double]
%            SS.ilogdiff = 3
%            SS.ilevdiff = []
%             SS.Horizon = 24
%              SS.ndraws = 100
%            SS.ptileVEC = [0.05 0.15 0.50 0.85 0.95]
% 
% The function output contains
% IRFRESP = A 4-D array containing
% ishock x horizon x percentiles x iresponse
% IRFRESP(1,7,3,2) is the response of 2nd variable to 1st shock in 7th
% period at the 3rd percentile chosen 
%
% IRFSIM : A 3-D array containing response of all variables to given shock
% inside the function
% iresponse x horizon x percentiles
%
% IRFFIX : A different impulse response ...


nv = SS.nv;
npers = SS.npers;

p = SS.nlags;
n = nv;
nshocks=n;
XXact=SS.XXact;
YYact=SS.YYact;
XXdum=SS.XXdum;
YYdum=SS.YYdum;
Horizon=SS.Horizon;
ndraws = SS.ndraws;
ptileVEC = SS.ptileVEC ;
bburn = 0.1*ndraws;  


if SS.do_acts_threats==1
    igpra = SS.igpra;
    igprt = SS.igprt;
end




e = eye(n); % create identity matrix
aalpha_index = 2:n;
a = cell(p,1);

% Define matrices to compute IRFs
J = [eye(n);repmat(zeros(n),p-1,1)]; % Page 12 RWZ
F = zeros(n*p,n*p);    % Matrix for Companion Form
I  = eye(n);
for i=1:p-1
    F(i*n+1:(i+1)*n,(i-1)*n+1:i*n) = I;
end

% Estimation Preliminaries
X = [XXdum; XXact];
Y = [YYdum; YYact];
T = size(X, 1);
TT = size(XXact,1);
ndum = size(XXdum, 1);
nex = 1; % Constant

% Compute OLS estimates
B = (X'*X)\(X'*Y); % Point estimates
U = Y-X*B;         % Residuals
Sigmau = U'*U/(T-p*n-1);   % Covariance matrix of residuals
S0 = Sigmau;
F(1:n,1:n*p)    = B(1:n*p,:)';
LC = chol(Sigmau,'Lower');
Omega1 = [LC(:,1:nshocks); zeros((p-1)*n,nshocks)];
IRF_T_OLS    = vm_irf(F,J,LC,Horizon+1,n,Omega1);


%------------------------------------------------------------
% Historical Decomposition
%------------------------------------------------------------

Utilde = YYact-XXact*B;
epsHisOLS   = LC\Utilde';
epsHisOLS   = epsHisOLS(:,1:end);

const = XXact(:,end)*B(end,:);
consts0 = repmat(const(1,:)',p,1);
YYactNomean = YYact-const;
s0 = XXact(1,1:end-1)';

ffactor = LC;





%------------------------------------------------------------
% IMPULSE RESPONSES -- MCMC Algorithm
%------------------------------------------------------------

% set preliminaries for priors
N0=zeros(size(X',1),size(X,2));
nnu0=0;
nnuT = T +nnu0;
NT = N0 + X'*X;
BbarT = NT\(N0*B + (X'*X)*B);
ST = (nnu0/nnuT)*S0 + (T/nnuT)*S0 ;
STinv = ST\eye(n);

record=0;
counter = 0;

Ltilde      = nan(ndraws-bburn,Horizon+1,n,nshocks);                    % define array to store IRF of model variables
Ltilde_A      = nan(ndraws-bburn,Horizon+1,n);                          % define array to store IRF of model variables
Ltilde_SIM  = nan(ndraws-bburn,Horizon+1,n);                            % define array to store IRF of model variables
Ltilde_FIX  = nan(ndraws-bburn,Horizon+1,n,2);                          % define array to store IRF of model variables
FF = F;

while record<ndraws
    
    %------------------------------------------------------------
    % Gibbs Sampling Algorithm
    %------------------------------------------------------------
    % STEP ONE: Draw from the B, SigmaB | Y
    %------------------------------------------------------------
    
    % R=mvnrnd(zeros(n,1),STinv/nnuT,nnuT)';
    try
        L = chol(STinv/nnuT, 'lower');
        R = L * randn(n, nnuT);
    catch ME
        warning('Cholesky decomposition failed: %s. Adding regularization.', ME.message);
        L = chol(STinv/nnuT + 1e-10*eye(n), 'lower');
        R = L * randn(n, nnuT);
    end
    Sigmadraw=(R*R')\eye(n);
    
    % Step 2: Taking newSigma as given draw for B using a multivariate normal
    bbeta = B(:);
    SigmaB = kron(Sigmadraw,NT\eye(n*p+nex));
    SigmaB = (SigmaB+SigmaB')/2;
    % Bdraw = mvnrnd(bbeta,SigmaB);

    try
        L = chol(SigmaB, 'lower');
    catch
        % Add regularization if not positive definite
        L = chol(SigmaB + 1e-10*eye(size(SigmaB)), 'lower');
    end
    Bdraw = bbeta + L * randn(length(bbeta), 1);


    % Storing unrestricted draws
    
    Bdraw= reshape(Bdraw,n*p+nex,n);% Reshape Bdraw from vector to matrix
    Udraw = Y-X*Bdraw;      % Store residuals for IV regressions
    
    FF(1:n,1:n*p)    = Bdraw(1:n*p,:)';
    
    LCdraw = chol(Sigmadraw,'Lower');
    Omega1 = [LCdraw(:,1:nshocks); zeros((p-1)*n,nshocks)];
    epsHis   = LC\Udraw';
    epsHis   = epsHis(:,1:end);
    
    record=record+1;
    counter = counter +1;
    if counter==0.25*ndraws
        %                disp(['         DRAW NUMBER:   ', num2str(record)]);
        %                 disp('                                                                  ');
        counter = 0;
        
    end
    
    if record > bburn
        
        IRF_T    = vm_irf(FF,J,LCdraw,Horizon+1,n,Omega1);
        IRF_TA   = NaN*IRF_T(:,:,igpra) + NaN*IRF_T(:,:,igprt); 
        
        
        if SS.do_acts_threats==1
            
            
           
            % CREATE IRFSIM
            IRF_T_SIM = 0*IRF_T(1:end,:,igpra);
            GPRAshock = epsHis(igpra,end-npers+1:end);
            GPRTshock = epsHis(igprt,end-npers+1:end);
            GPRAshock(SS.inonactive)=0;
            GPRTshock(SS.inonactive)=0;
            for j=1:npers
            IRF_T_SIM(j:end,:) = IRF_T_SIM(j:end,:) + GPRAshock(j)*IRF_T(1:end-j+1,:,igpra) + GPRTshock(j)*IRF_T(1:end-j+1,:,igprt); 
            end
            
            
            % CREATE IRFFIX
            IRFActNoThreat = squeeze(IRF_T(:,:,igpra));
            IRFThreatNoAct = squeeze(IRF_T(:,:,igprt));
            
            for ii = 1:Horizon
                scale4Act      = IRFActNoThreat(ii,igprt)/IRF_T(1,igprt,igprt);
                scale4Threat   = IRFThreatNoAct(ii,igpra)/IRF_T(1,igpra,igpra);
                IRFActNoThreat(ii:Horizon+1,:) = IRFActNoThreat(ii:Horizon+1,:) - IRF_T(1:Horizon+2-ii,:,igprt)*scale4Act;
                IRFThreatNoAct(ii:Horizon+1,:) = IRFThreatNoAct(ii:Horizon+1,:) - IRF_T(1:Horizon+2-ii,:,igpra)*scale4Threat;
            end
            
            
            
            % Cumulate IRF variables in first differences
            for i=1:length(SS.ilogdiff)
                IRF_T_SIM(:,SS.ilogdiff(i),:) = 100*cumsum(IRF_T_SIM(:,SS.ilogdiff(i),:));
                IRF_T(:,SS.ilogdiff(i),:) = 100*cumsum(IRF_T(:,SS.ilogdiff(i),:));
                IRF_TA(:,SS.ilogdiff(i),:) = 100*cumsum(IRF_TA(:,SS.ilogdiff(i),:));
                IRFActNoThreat(:,SS.ilogdiff(i)) = 100*cumsum(IRFActNoThreat(:,SS.ilogdiff(i)));
                IRFThreatNoAct(:,SS.ilogdiff(i)) = 100*cumsum(IRFThreatNoAct(:,SS.ilogdiff(i)));
            end
            
            for i=1:length(SS.ilevdiff)
                IRF_T(:,SS.ilevdiff(i),:) = cumsum(IRF_T(:,SS.ilevdiff(i),:));
                IRF_TA(:,SS.ilevdiff(i),:) = cumsum(IRF_TA(:,SS.ilevdiff(i),:));
                IRF_T_SIM(:,SS.ilevdiff(i),:) = 100*cumsum(IRF_T_SIM(:,SS.ilevdiff(i),:));
                IRFActNoThreat(:,SS.ilevdiff(i)) = 100*cumsum(IRFActNoThreat(:,SS.ilevdiff(i)));
                IRFThreatNoAct(:,SS.ilevdiff(i)) = 100*cumsum(IRFThreatNoAct(:,SS.ilevdiff(i)));
            end
            
            Ltilde_SIM(record-bburn,:,:,:) = IRF_T_SIM(1:Horizon+1,:);
            Ltilde_FIX(record-bburn,:,:,1) = IRFActNoThreat;
            Ltilde_FIX(record-bburn,:,:,2) = IRFThreatNoAct;
            
        else
            
            for i=1:length(SS.ilogdiff)
                IRF_T(:,SS.ilogdiff(i),:) = 100*cumsum(IRF_T(:,SS.ilogdiff(i),:));
                IRF_TA(:,SS.ilogdiff(i),:) = 100*cumsum(IRF_TA(:,SS.ilogdiff(i),:));
            end
            for i=1:length(SS.ilevdiff)
                IRF_T(:,SS.ilevdiff(i),:) = cumsum(IRF_T(:,SS.ilevdiff(i),:));
                IRF_TA(:,SS.ilevdiff(i),:) = cumsum(IRF_TA(:,SS.ilevdiff(i),:));
            end
            
        end
        
        Ltilde(record-bburn,:,:,:) = IRF_T(1:Horizon+1,:,:);
        Ltilde_A(record-bburn,:,:,:) = IRF_TA(1:Horizon+1,:);
        
    end
    
    
end

IRFRESP = quantile(Ltilde_A,ptileVEC);
IRFRESP = permute(IRFRESP,[3,2,1,4]);

IRFSIM = quantile(Ltilde_SIM,ptileVEC);
IRFSIM = permute(IRFSIM,[3,2,1]);

Ltilde_FIX(abs(Ltilde_FIX)<10^-10)=0;
IRFFIX = quantile(Ltilde_FIX,ptileVEC);
IRFFIX = permute(IRFFIX,[3,2,1,4]);

NN.B = B;
NN.Sigmau = Sigmau;
NN.U = U;
NN.epsHisOLS = epsHisOLS ;
NN.ffactor = ffactor;
NN.F = F;

end
