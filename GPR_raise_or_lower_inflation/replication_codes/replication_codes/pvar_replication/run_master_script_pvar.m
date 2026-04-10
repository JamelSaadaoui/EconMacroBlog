% =========================================================================
% Master Replication Script
% "Do Geopolitical Risks Raise or Lower Inflation?"
% =========================================================================
% Date: 10/10/2025
%
% Description:
% This master script runs all replication codes for the paper. It:
% 1. Sets up paths and loads data
% 2. Prepares and transforms data
% 3. Runs selected figure replication scripts
% 4. Provides options for batch processing or individual figures
%
% Usage:
%   - Run entire script to generate all figures
%   - Set flags below to run specific figures only
%   - Modify global parameters in Section 2 if needed
% =========================================================================

close all;
clc;
clear;

%% ========================================================================
% SECTION 1: USER CONFIGURATION
% =========================================================================

fprintf('\n=======================================================\n');
fprintf('REPLICATION SCRIPT LAUNCHER\n');
fprintf('Do Geopolitical Risks Raise or Lower Inflation?\n');
fprintf('=======================================================\n\n');

% Build dataset or load existing mat file (set to true/false)
RUN_DATA_BUILD = true;

% Which figures to generate (set to true/false)
% Main text figures
RUN_FIG3    = true;   % Baseline 9-variable model
RUN_FIG4    = true;   % Acts vs. Threats
RUN_FIG5    = true;   % Global vs. Country GPR
RUN_FIG6    = true;   % Narrative
RUN_FIG7_8  = true;   % Country--by-country analysis (IRFs + Scatter)
RUN_FIG9_10 = true;   % Spillover analysis (IRFs + Scatter)

% Appendix figures
RUN_APPFIG3 = true;   % Two lags specification
RUN_APPFIG4 = true;   % Trimmed inflation & money
RUN_APPFIG5 = true;   % Extended model with FX & interest rates

%% ========================================================================
% SECTION 2: GLOBAL PARAMETERS
% =========================================================================

% Set these parameters once - they will be used across all scripts
global_params.K = 5000;            % Posterior draws
global_params.hor = 11;            % IRF horizon (years)
global_params.conf_sig = 0.9;      % Confidence level (90%)

fprintf('Global Parameters:\n');
fprintf('  Posterior draws: %d\n', global_params.K);
fprintf('  IRF horizon: %d years\n', global_params.hor);
fprintf('  Confidence level: %.0f%%\n', global_params.conf_sig * 100);
fprintf('\n');

%% ========================================================================
% SECTION 3: SETUP PATHS
% =========================================================================

fprintf('Setting up paths...\n');

% Add toolbox paths
addpath .\BVAR_\cmintools\
addpath .\BVAR_\bvartools\

% Create output directory if it doesn't exist
if ~exist('figurespaper', 'dir')
    mkdir('figurespaper');
    fprintf('  Created output directory: figurespaper\n');
end

fprintf('  Paths configured successfully.\n\n');

%% ========================================================================
% SECTION 4: LOAD AND PREPARE DATA
% =========================================================================

fprintf('Loading and preparing data...\n');

if RUN_DATA_BUILD
    % Build panel dataset
    prepare_data_for_pvars
    fprintf('✓ Dataset built successfully.\n');
end

% Load panel data
load datapanelGPR.mat
fprintf('✓ Data loaded successfully.\n');

% Get data dimensions
[T, NCountries, Nvariables] = size(DATAX);
fprintf('  Panel dimensions: T=%d, Countries=%d, Variables=%d\n', ...
        T, NCountries, Nvariables);

% Verify variable labels
if length(variable_labels) ~= Nvariables
    error('Variable labels (%d) do not match data dimensions (%d)', ...
          length(variable_labels), Nvariables);
end

% Transform GDP to percentage points
[~, idx_gdp] = ismember({'GDP (%)'}, variable_labels);
DATAX(:,:,idx_gdp) = 100 * DATAX(:,:,3);

% Define variables to demean
vars_to_demean_names = {
    'GPR Country'
    'Inflation (ppt)'
    'GDP (%)'
    'Trade to GDP (ppt)'
    'Shortages Index'
    'Mil. Exp. to GDP (ppt)'
    'Debt to GDP (ppt)'
    'Money Growth (ppt)'
    'Govt Exp. to GDP (ppt)'
    'GPA Country'
    'GPT Country'
    'ST Interest Rate (ppt)'
    'Exchange Rate Depreciation (ppt)'
    'GPR Global'
    'GPR Foreign'
    'GPR Narrative'
    'LT Interest Rate (ppt)'
    'Inflation Trim. (ppt)'
    'Money Growth Trim. (ppt)'
};

% Find indices
vars_to_demean = find(ismember(variable_labels,vars_to_demean_names));

% Initialize demeaned data
DATAX_demean = DATAX;

% Find positions of variables to standardize
vars_to_standardize = find(ismember(variable_labels, {'GPR Global', 'GPR Foreign'}));

% Demean and standardize
for i = 1:length(vars_to_demean)
        v = vars_to_demean(i);
    for c = 1:NCountries
        data_series = DATAX(:, c, v);
        mean_value = mean(data_series, 'omitnan');
        DATAX_demean(:, c, v) = data_series - mean_value;
        
        % Standardize GPR Global and GPR Foreign
        if ismember(v, vars_to_standardize)
            std_value = std(DATAX_demean(:, c, v), 'omitnan');
            DATAX_demean(:, c, v) = DATAX_demean(:, c, v) / std_value;
        end
    end
end

fprintf('  Data preparation complete.\n\n');

%% ========================================================================
% SECTION 5: RUN REPLICATION SCRIPTS
% =========================================================================

fprintf('=======================================================\n');
fprintf('RUNNING REPLICATION SCRIPTS\n');
fprintf('=======================================================\n\n');

% Track execution time
tic;
figures_generated = 0;

%% ------------------------------------------------------------------------
% Main Text Figures
%--------------------------------------------------------------------------

if RUN_FIG3
    fprintf('\n--- Figure 3: Baseline Model ---\n');
    try
        run_fig3;
        figures_generated = figures_generated + 1;
        fprintf('✓ Figure 3 completed successfully.\n');
    catch ME
        fprintf('✗ Error in Figure 3: %s\n', ME.message);
    end
end

if RUN_FIG4
    fprintf('\n--- Figure 4: Acts vs. Threats ---\n');
    try
        run_fig4;
        figures_generated = figures_generated + 1;
        fprintf('✓ Figure 4 completed successfully.\n');
    catch ME
        fprintf('✗ Error in Figure 4: %s\n', ME.message);
    end
end

if RUN_FIG5
    fprintf('\n--- Figure 5: Global vs. Country GPR ---\n');
    try
        run_fig5;
        figures_generated = figures_generated + 1;
        fprintf('✓ Figure 5 completed successfully.\n');
    catch ME
        fprintf('✗ Error in Figure 5: %s\n', ME.message);
    end
end

if RUN_FIG6
    fprintf('\n--- Figure 6: Narrative Identification ---\n');
    try
        run_fig6;
        figures_generated = figures_generated + 1;
        fprintf('✓ Figure 6 completed successfully.\n');
    catch ME
        fprintf('✗ Error in Figure 6: %s\n', ME.message);
    end
end

if RUN_FIG7_8
    fprintf('\n--- Figure 7 and 8: Country-by-Country Estimation ---\n');
    try
        run_fig7_fig8;
        figures_generated = figures_generated + 2;
        fprintf('✓ Figures 7 and 8 completed successfully.\n');
    catch ME
        fprintf('✗ Error in Figure 7 and 8: %s\n', ME.message);
    end
end

if RUN_FIG9_10
    fprintf('\n--- Figure 7: Country-by-Country Estimation ---\n');
    try
        run_fig9_fig10;
        figures_generated = figures_generated + 2;
        fprintf('✓ Figures 9 and 10 completed successfully.\n');
    catch ME
        fprintf('✗ Error in Figure 9 and 10: %s\n', ME.message);
    end
end

%% ------------------------------------------------------------------------
% Appendix Figures (Robustness Checks)
%--------------------------------------------------------------------------

if RUN_APPFIG3
    fprintf('\n--- Appendix Figure A3: Two Lags ---\n');
    try
        run_appfig3;
        figures_generated = figures_generated + 1;
        fprintf('✓ Appendix Figure A3 completed successfully.\n');
    catch ME
        fprintf('✗ Error in Appendix Figure A3: %s\n', ME.message);
    end
end

if RUN_APPFIG4
    fprintf('\n--- Appendix Figure A4: Trimmed Variables ---\n');
    try
        run_appfig4;
        figures_generated = figures_generated + 1;
        fprintf('✓ Appendix Figure A4 completed successfully.\n');
    catch ME
        fprintf('✗ Error in Appendix Figure A4: %s\n', ME.message);
    end
end

if RUN_APPFIG5
    fprintf('\n--- Appendix Figure A5: FX & Interest Rates ---\n');
    try
        run_appfig5;
        figures_generated = figures_generated + 1;
        fprintf('✓ Appendix Figure A5 completed successfully.\n');
    catch ME
        fprintf('✗ Error in Appendix Figure A5: %s\n', ME.message);
    end
end

%% ========================================================================
% SECTION 6: SUMMARY
% =========================================================================

total_time = toc;

fprintf('\n=======================================================\n');
fprintf('REPLICATION COMPLETE\n');
fprintf('=======================================================\n');
fprintf('Figures generated: %d\n', figures_generated);
fprintf('Total execution time: %.1f minutes\n', total_time / 60);
fprintf('Output directory: .\\figurespaper\\\n');
fprintf('=======================================================\n\n');

% Clean up global variables if needed
% clearvars -except DATAX DATAX_demean variable_labels cnames global_params