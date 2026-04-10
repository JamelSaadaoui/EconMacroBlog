% =========================================================================
% Replication of Figures 11, 12, and A6 in "Do Geopolitical Risks Raise 
% or Lower Inflation?"
% =========================================================================
% Date:     101/10/2025
%
% Description:
%   This script estimates a Bayesian VAR model with geopolitical risk 
%   indices and macroeconomic variables.
%
% Figures generated:
%   - Figure 11: Impulse responses of inflation and GDP
%   - Figure 12: Impulse responses of all variables
%   - Figure A6: Robustness check across different lag specifications
%
% Note: This code runs with MATLAB R2019a or later
% =========================================================================

%% ========================================================================
% SECTION 0: HOUSEKEEPING
% =========================================================================

restoredefaultpath
clear; clc; close all;

% Add path to auxiliary functions
addpath('./auxfiles')

% Figure display settings
set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'DefaultFigureColor', 'remove')

fprintf('\n%s\n', repmat('=', 1, 75));
fprintf('VAR Estimation: Geopolitical Risk and Inflation\n');
fprintf('%s\n\n', repmat('=', 1, 75));

%% ========================================================================
% SECTION 1: GENERAL SETTINGS
% =========================================================================

% Data file settings
data_file = 'vardata_replication.csv';
data_spreadsheet = 'vardata_replication';
str_sample_end = '2023-12-01';

% Plotting option
do_plot_data = 1;  % Set to 1 to plot raw data (generates Figure 101)

% IRF computation
do_irf = 1;

% Load raw data from CSV
fprintf('Loading data from: %s\n', data_file);
[Y0, text0, raw0] = xlsread(data_file, data_spreadsheet);

%% ------------------------------------------------------------------------
% Estimation Settings
% -------------------------------------------------------------------------

% Number of Monte Carlo draws
% SS.ndraws = 5000;  % Use this for final results (paper version)
SS.ndraws = 500;     % Use this for faster computation

% Data frequency
Tdelta = 1/12;  % Monthly data

% Model specification
model_vec = {'z1_level'};  % Model to estimate

fprintf('Monte Carlo draws: %d\n', SS.ndraws);
fprintf('Data frequency: Monthly\n');

%% ========================================================================
% SECTION 2: MODEL SPECIFICATION AND DATA LOADING
% =========================================================================

fprintf('\n%s\n', repmat('-', 1, 75));
fprintf('Model Specification and Data Preparation\n');
fprintf('%s\n', repmat('-', 1, 75));

% Loop over models (currently only one model)
for mCounter = 1:size(model_vec, 2)
    
    % Select current model
    mmodel = model_vec(mCounter);
    
    % Set random seed for reproducibility
    rng default
    stream = RandStream('mt19937ar', 'Seed', 0);
    
    %% --------------------------------------------------------------------
    % Model: z1_level
    % --------------------------------------------------------------------
    if strcmp(mmodel, 'z1_level')
        
        fprintf('\nModel: %s\n', mmodel{1});
        
        % Variable names included in the VAR
        % GPRA: Geopolitical Risk Acts
        % GPRT: Geopolitical Risk Threats
        % MWRDPPP_GDP_DET: World GDP (PPP, detrended)
        % GFDWLDINF: World Inflation
        % RPZTEXP: Export Prices
        % RGSCOMM: Commodity Prices
        % FXTWBDI: Exchange Rate Index
        % RGFDFTWORLD: World Stock Prices
        % CCI_OECDE: Consumer Confidence Index (OECD)
        
        i_var_str = {'GPRA', 'GPRT', 'MWRDPPP_GDP_DET', 'GFDWLDINF', ...
                     'RPZTEXP', 'RGSCOMM', 'FXTWBDI', 'RGFDFTWORLD', 'CCI_OECDE'};
        
        % Match variable names to column indices in data
        match_string
        
        % Define variable transformations
        ilevdem = [igpra igprt iwrdcpi icci];  % Variables in levels (demeaned)
        ilogdet0 = [iwrdpppgdpdet icomm ioil ifx istock];  % Log with linear detrending
        ilogdet1 = [];   % Log with quadratic detrending
        ilogdet2 = [];   % Log with cubic detrending
        ilevdiff = [];   % Variables in first differences
        ilogdiff = [];   % Log differences
        ilevdet1 = [];   % Levels with quadratic trend
        ilevdet2 = [];   % Levels with cubic trend
        iloghp = [];     % Log HP-filtered
        ihp = [];        % HP-filtered
        
        % Store key variable indices
        SS.igpra = igpra;  % Geopolitical Risk Acts index
        SS.igprt = igprt;  % Geopolitical Risk Threats index
        SS.do_acts_threats = 1;  % Flag for active/inactive shock periods
        
        % Lag structure
        nlags = 3;
        
        % Sample period
        str_sample_init = '1974-01-01';  % Starting date (includes pre-sample for lags)
        
        % % Variables for impulse response analysis
        % imp_select = [igprt igpra];  % Shocks to analyze
        
        fprintf('Number of variables: %d\n', length(i_var_str));
        fprintf('Lag length: %d\n', nlags);
        fprintf('Sample: %s to %s\n', str_sample_init, str_sample_end);
        
    end
    
    %% --------------------------------------------------------------------
    % Load and Transform Data
    % --------------------------------------------------------------------
    fprintf('\nLoading and transforming data...\n');
    vm_loaddata  % Loads data and applies transformations
    fprintf('Data preparation complete.\n');
    
end  % End of model loop

%% ========================================================================
% SECTION 3: BASELINE VAR ESTIMATION
% =========================================================================

fprintf('\n%s\n', repmat('-', 1, 75));
fprintf('Baseline VAR Estimation and IRF Computation\n');
fprintf('%s\n', repmat('-', 1, 75));

% % Scaling factor for IRFs
% scalefactor_irf = 1;

%% ------------------------------------------------------------------------
% Create Dummy Observations (Minnesota Prior)
% -------------------------------------------------------------------------

MP = 0;  % Hyperparameter setting for Minnesota prior
vm_dummy  % Creates dummy observations XXdum, YYdum

%% ------------------------------------------------------------------------
% Prepare Objects for Estimation
% -------------------------------------------------------------------------

SS.nlags = nlags;
SS.nv = nv;
SS.XXdum = XXdum;
SS.YYdum = YYdum;
SS.XXact = XXact;
SS.YYact = YYact;
SS.ilogdiff = ilogdiff;
SS.ilevdiff = ilevdiff;
SS.Horizon = 24;  % IRF horizon (months)
SS.ptileVEC = [0.05 0.15 0.50 0.85 0.95];  % Percentiles for confidence bands

% Confidence interval level
confidence_interval = 90;

fprintf('Number of variables: %d\n', nv);
fprintf('Number of lags: %d\n', nlags);
fprintf('IRF horizon: %d months\n', SS.Horizon);

%% ------------------------------------------------------------------------
% Active/Inactive Shock Periods
% -------------------------------------------------------------------------
% For modeling periods when geopolitical shocks are "active" or "inactive"
% Useful for handling structural breaks (e.g., Russia-Ukraine conflict)

SS.do_acts_threats = 1;  % Enable active/inactive shock modeling

% Number of recent periods to consider for shock activity
% For VAR estimated until 2023M12, set to 24
SS.npers = 24;

% Periods among the recent ones that are NOT active
% Example: [1 5:24] means periods 2-4 (Feb-Apr 2022) are active
% [1:24] = no shocks active in recent periods
% [6:24] = first 5 months active
SS.inonactive = [1 5:24];

%% ------------------------------------------------------------------------
% Estimate VAR Model
% -------------------------------------------------------------------------

fprintf('\nEstimating VAR model...\n');
[IRFRESP, IRFSIM, IRFFIX, NN] = estimate_var_gpr(SS);
fprintf('Estimation complete.\n');

% Variables for impulse response plots
imp_select = [igpra igprt];  % Impulse variables
resp_select = 1:nv;          % Response variables (all)

%% ------------------------------------------------------------------------
% Generate Figure 11: Simulation-Based Confidence Bands
% -------------------------------------------------------------------------

fprintf('\nGenerating Figure 11...\n');
plot_impresp_sim
saveas(gcf, 'output\fig11.pdf')
fprintf('Saved: output\\fig11.pdf\n');

%% ------------------------------------------------------------------------
% Generate Figure 12: Error Bar Confidence Intervals
% -------------------------------------------------------------------------

fprintf('Generating Figure 12...\n');
plot_impresp_errorbar
saveas(gcf, 'output\fig12.pdf')
fprintf('Saved: output\\fig12.pdf\n');

%% ========================================================================
% SECTION 4: ROBUSTNESS ANALYSIS - ALTERNATIVE LAG SPECIFICATIONS
% =========================================================================

fprintf('\n%s\n', repmat('-', 1, 75));
fprintf('Robustness Analysis: Alternative Lag Specifications\n');
fprintf('%s\n', repmat('-', 1, 75));

% Lag specifications to test
lag_vec = [3 2 4 6 12];

% Loop over different lag lengths
for nlags = lag_vec
    
    fprintf('  Estimating with %d lags...\n', nlags);
    
    % Update settings
    do_plot_data = 0;  % Don't re-plot data
    SS.nlags = nlags;
    
    % Reload data with new lag structure
    vm_loaddata
    
    % Recreate dummy observations
    MP = 0;
    vm_dummy
    
    % Update estimation objects
    SS.nv = nv;
    SS.XXdum = XXdum;
    SS.YYdum = YYdum;
    SS.XXact = XXact;
    SS.YYact = YYact;
    
    % Estimate VAR
    [IRFRESP, IRFSIM, IRFFIX, NN] = estimate_var_gpr(SS);
    
    %% --------------------------------------------------------------------
    % Baseline (3 lags): Create Figure with Confidence Bands
    % --------------------------------------------------------------------
    if nlags == 3
        IRFSIM3 = IRFSIM;
        plot_impresp_sim  % Creates figure with shaded confidence intervals
        % This figure will be the base for overlaying other lag specifications
    end
    
    %% --------------------------------------------------------------------
    % Set Line Colors for Different Lag Specifications
    % --------------------------------------------------------------------
    if nlags == 2
        colore = 'k';       % Black
    elseif nlags == 4
        colore = 'r';       % Red
    elseif nlags == 6
        colore = 'g';       % Green
    elseif nlags == 12
        colore = [0.588, 0.294, 0];  % Brown
    end
    
    %% --------------------------------------------------------------------
    % Overlay Non-Baseline Specifications on Existing Figure
    % --------------------------------------------------------------------
    if nlags ~= 3
        % Subplot 1: Response of variable 3 to shock 3
        subplot(1, 2, 1)
        hold on
        linewidth = graph_opt.linW + 0.5 * sqrt(nlags - 3);
        h1 = plot(TIRF, IRFSIM(3, :, 3), 'Color', colore, 'LineWidth', linewidth);
        
        % Subplot 2: Response of variable 4 to shock 3
        subplot(1, 2, 2)
        hold on
        h1 = plot(TIRF, IRFSIM(4, :, 3), 'Color', colore, 'LineWidth', linewidth);
    end
    
end  % End of robustness loop

%% ------------------------------------------------------------------------
% Overlay Baseline (3 lags) Line on Top in Blue
% -------------------------------------------------------------------------

fprintf('  Finalizing robustness plot...\n');

% Reset nlags to baseline
nlags = 3;

% Plot baseline median line in blue (on top of confidence bands)
subplot(1, 2, 1)
hold on
h1 = plot(TIRF, IRFSIM3(3, :, 3), 'Color', 'b', ...
          'LineWidth', graph_opt.linW + 0.5 * sqrt(nlags - 3));

subplot(1, 2, 2)
hold on
h1 = plot(TIRF, IRFSIM3(4, :, 3), 'Color', 'b', ...
          'LineWidth', graph_opt.linW + 0.5 * sqrt(nlags - 3));

%% ------------------------------------------------------------------------
% Add Legend and Save Figure A6
% -------------------------------------------------------------------------

legend('3 lags + c.i.', '', '', '', '', '', '2 lags', '4 lags', '6 lags', '12 lags')
saveas(gcf, 'output\appfig6.pdf')
fprintf('Saved: output\\appfig6.pdf\n');
