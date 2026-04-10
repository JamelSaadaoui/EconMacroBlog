% =========================================================================
% Replication of Fig. A3 in "Do Geopolitical Risks Raise or Lower
% Inflation?" Robustness Check: Extended Model with FX and Interest Rates
% =========================================================================
% Date:     10/10/2025
%
% Description:
%   This script estimates a pooled panel VAR model using the Empirical Macro
%   toolbox of Canova and Ferroni. Large VAR with FX and interest rates
%
% Steps:
%   1. Estimate pooled VAR
%   2. Compute impulse response functions (IRFs)
%   3. Estimate pooled VAR with FX and interest rates
%   4. Compute impulse response functions (IRFs)
%   5. Generate figure
% =========================================================================

%% ========================================================================
% SECTION 1: BASELINE MODEL (9 VARIABLES)
% =========================================================================

fprintf('\n========================================\n');
fprintf('BASELINE MODEL: 9-Variable VAR\n');
fprintf('========================================\n');

%% ------------------------------------------------------------------------
% SUBSECTION 1.1: Model Configuration
% -------------------------------------------------------------------------
% Use global parameters if available, otherwise set custom parameters here
if ~exist('global_params', 'var')
    options.K = 5000;
    options.hor = 11;
    options.conf_sig = 0.9;
else
    % Extract parameters for this script
    options.K = global_params.K;
    options.hor = global_params.hor;
    options.conf_sig = global_params.conf_sig;
end
% Estimation options
lags             = 1;      % Number of lags in the VAR

% Shock of interest
indx_sho = 1;  % Index for GPR Country shock

% Select model variables by name (baseline 9 variables)
model_vars_baseline = {
    'GPR Country'
    'Inflation (ppt)'
    'GDP (%)'
    'Trade to GDP (ppt)'
    'Shortages Index'
    'Mil. Exp. to GDP (ppt)'
    'Debt to GDP (ppt)'
    'Money Growth (ppt)'
    'Govt Exp. to GDP (ppt)'
};

% Find indices of selected variables (preserving specified order)
[~, variables_sel_baseline] = ismember(model_vars_baseline, variable_labels);

% Store variable names for plotting
options.varnames = variable_labels(variables_sel_baseline);

fprintf('\n%d variables included in baseline model:\n', length(variables_sel_baseline));
for i = 1:length(variables_sel_baseline)
    fprintf('  %d. %s\n', i, options.varnames{i});
end

%% ------------------------------------------------------------------------
% SUBSECTION 1.2: Country Selection and Data Filtering
% -------------------------------------------------------------------------

% Extract selected variables
DATAXtemp = DATAX_demean(:, :, variables_sel_baseline);

% Option to exclude specific countries by name
countries_to_find = "";  % Add country names here if needed
idx = find(ismember(cnames, countries_to_find));
countries_to_exclude = idx;

% Exclude countries with insufficient complete observations
cutoff = 0.95;  % Maximum proportion of missing data allowed
min_obs_threshold = round((1 - cutoff) * T);

fprintf('\nFiltering countries (min. complete obs: %d of %d):\n', ...
        min_obs_threshold, T);

for c = 1:NCountries
    % Extract data for country c: [T x NVars]
    yi = squeeze(DATAXtemp(:, c, :));
    
    % Find rows with complete data (no NaNs in any variable)
    complete_rows = all(~isnan(yi), 2);
    num_complete_obs = sum(complete_rows);
    
    % Exclude if insufficient complete observations
    if num_complete_obs < min_obs_threshold
        fprintf('  Excluding %s: %d complete obs (< %d threshold)\n', ...
                cnames{c}, num_complete_obs, min_obs_threshold);
        countries_to_exclude = [countries_to_exclude, c];
    end
end

% Validate country indices
if any(countries_to_exclude > NCountries) || any(countries_to_exclude < 1)
    error('Invalid country indices detected.');
end

% Create list of countries to keep
countries_to_keep = setdiff(1:NCountries, countries_to_exclude);

fprintf('\nFinal sample: %d countries (excluded %d)\n', ...
        length(countries_to_keep), length(countries_to_exclude));

% Prepare data for pooled estimation
DATAXtemp = DATAX_demean(:, countries_to_keep, variables_sel_baseline);
DATAX_pooled = permute(DATAXtemp, [1, 3, 2]);  % [T x Vars x Countries]

%% ------------------------------------------------------------------------
% SUBSECTION 1.3: Pooled VAR Estimation
% -------------------------------------------------------------------------

fprintf('\nEstimating baseline pooled panel VAR...\n');

% Enable missing data handling
options.handle_missing = 1;

% Estimate VAR
bvar1 = bvar_misspooled(DATAX_pooled, lags, options);

fprintf('Estimation complete.\n');

%% ========================================================================
% SECTION 2: IMPULSE RESPONSE FUNCTIONS
% =========================================================================

% Extract IRFs for shock of interest
irfs_to_plot = bvar1.ir_draws(:, 1:options.hor, indx_sho, :);

% Normalize IRFs: scale by initial response of shock variable
scale_factor = squeeze(irfs_to_plot(1, 1, 1, :));
scale_factor_matrix = reshape(scale_factor, [1, 1, 1, bvar1.ndraws]);
irfs_to_plot_pooled = irfs_to_plot ./ scale_factor_matrix;

% Compute moments across posterior draws
mean_irfs_pooled = mean(irfs_to_plot_pooled, 4);  % Mean IRF
std_irfs_pooled = std(irfs_to_plot_pooled, 0, 4);  % Standard deviation

% Construct 90% confidence intervals (normal approximation)
z_score = 1.645;  % 90% CI
lower_conf_pooled = mean_irfs_pooled - z_score * std_irfs_pooled;
upper_conf_pooled = mean_irfs_pooled + z_score * std_irfs_pooled;

%% ========================================================================
% SECTION 3: EXTENDED MODEL (12 VARIABLES)
% =========================================================================

fprintf('\n========================================\n');
fprintf('EXTENDED MODEL: 12-Variable VAR (+ FX & Rates)\n');
fprintf('========================================\n');

%% ------------------------------------------------------------------------
% SUBSECTION 3.1: Model Configuration
% -------------------------------------------------------------------------

% Estimation options (same as baseline)
lags             = 1;

% Shock of interest
indx_sho = 1;

% Select model variables by name (12 variables: baseline + FX + rates)
model_vars_extended = {
    'GPR Country'
    'Inflation (ppt)'
    'GDP (%)'
    'Trade to GDP (ppt)'
    'Shortages Index'
    'Mil. Exp. to GDP (ppt)'
    'Debt to GDP (ppt)'
    'Money Growth (ppt)'
    'Govt Exp. to GDP (ppt)'
    'Exchange Rate Depreciation (ppt)'
    'ST Interest Rate (ppt)'
    'LT Interest Rate (ppt)'
};

% Find indices of selected variables (preserving specified order)
[~, variables_sel_extended] = ismember(model_vars_extended,variable_labels);

% Store variable names for plotting (customize exchange rate label)
options.varnames = variable_labels(variables_sel_extended);
options.varnames{10} = 'Exchange Rate Depr. vs $ (ppt)';

fprintf('\n%d variables included in extended model:\n', length(variables_sel_extended));
for i = 1:length(variables_sel_extended)
    fprintf('  %d. %s\n', i, options.varnames{i});
end

%% ------------------------------------------------------------------------
% SUBSECTION 3.2: Country Selection and Data Filtering
% -------------------------------------------------------------------------

% Extract selected variables
DATAXtemp = DATAX_demean(:, :, variables_sel_extended);

% Use more lenient cutoff for extended model (more variables = more missingness)
countries_to_find = "";
idx = find(ismember(cnames, countries_to_find));
countries_to_exclude_ext = idx;

cutoff_ext = 0.89;  % More lenient threshold
min_obs_threshold_ext = round((1 - cutoff_ext) * T);

fprintf('\nFiltering countries (min. complete obs: %d of %d):\n', ...
        min_obs_threshold_ext, T);

for c = 1:NCountries
    % Extract data for country c: [T x NVars]
    yi = squeeze(DATAXtemp(:, c, :));
    
    % Find rows with complete data (no NaNs in any variable)
    complete_rows = all(~isnan(yi), 2);
    num_complete_obs = sum(complete_rows);
    
    % Exclude if insufficient complete observations
    if num_complete_obs < min_obs_threshold_ext
        fprintf('  Excluding %s: %d complete obs (< %d threshold)\n', ...
                cnames{c}, num_complete_obs, min_obs_threshold_ext);
        countries_to_exclude_ext = [countries_to_exclude_ext, c];
    end
end

% Validate country indices
if any(countries_to_exclude_ext > NCountries) || any(countries_to_exclude_ext < 1)
    error('Invalid country indices detected.');
end

% Create list of countries to keep
countries_to_keep_ext = setdiff(1:NCountries, countries_to_exclude_ext);

fprintf('\nFinal sample: %d countries (excluded %d)\n', ...
        length(countries_to_keep_ext), length(countries_to_exclude_ext));

% Prepare data for pooled estimation
DATAXtemp = DATAX_demean(:, countries_to_keep_ext, variables_sel_extended);
DATAX_pooled_ext = permute(DATAXtemp, [1, 3, 2]);  % [T x Vars x Countries]

%% ------------------------------------------------------------------------
% SUBSECTION 3.3: Pooled VAR Estimation
% -------------------------------------------------------------------------

fprintf('\nEstimating extended pooled panel VAR...\n');

% Enable missing data handling
options.handle_missing = 1;

% Estimate VAR
bvar2 = bvar_misspooled(DATAX_pooled_ext, lags, options);

fprintf('Estimation complete.\n');

%% ========================================================================
% SECTION 4: IMPULSE RESPONSE FUNCTIONS
% =========================================================================

% Extract IRFs for shock of interest
irfs_to_plot_12eq = bvar2.ir_draws(:, 1:options.hor, indx_sho, :);

% Normalize IRFs: scale by initial response of shock variable
scale_factor_ext = squeeze(irfs_to_plot_12eq(1, 1, 1, :));
scale_factor_matrix_ext = reshape(scale_factor_ext, [1, 1, 1, bvar2.ndraws]);
irfs_to_plot_12eq = irfs_to_plot_12eq ./ scale_factor_matrix_ext;

% Compute moments across posterior draws
mean_irfs_12eq = mean(irfs_to_plot_12eq, 4);  % Mean IRF
std_irfs_12eq = std(irfs_to_plot_12eq, 0, 4);  % Standard deviation

% Construct 90% confidence intervals (normal approximation)
lower_conf_12eq = mean_irfs_12eq - z_score * std_irfs_12eq;
upper_conf_12eq = mean_irfs_12eq + z_score * std_irfs_12eq;

%% ========================================================================
% SECTION 5: VISUALIZATION - BASELINE VS. EXTENDED COMPARISON
% =========================================================================

fprintf('\nGenerating baseline vs. extended model comparison figure...\n');

% Configure plot appearance
time = 0:(options.hor - 1);  % Time axis (years)
fontnum = 8;                  % Font size
variables_plot_pooled = 1:9;  % Baseline variables
variables_plot_12eq = 1:12;   % All extended variables
num_vars = length(variables_plot_12eq);

% Create figure
fig = figure('Name', 'Figure A5', 'NumberTitle', 'off');
set(fig, 'Units', 'inches', 'Position', [1, 1, 7.5, 5]);
set(fig, 'PaperSize', [7.5, 5]);
set(fig, 'PaperPosition', [0 0 7.5 5]);
set(gcf, 'Color', 'w');  % White background

% Subplot layout: 3 columns x 4 rows
num_rows = ceil(num_vars / 3);
num_cols = 3;

% Plot IRFs for each variable
for v = 1:num_vars
    subtightplot(num_rows, num_cols, v, [0.1 0.08], [0.08 0.05], [0.07 0.04]);
    hold on;
    
    % Plot baseline IRF (only for first 9 variables) - blue line with shading
    if v < 10
        h1 = plot(time, squeeze(mean_irfs_pooled(variables_plot_pooled(v), :)), ...
                  '-b', 'LineWidth', 1.5);
        fill([time, fliplr(time)], ...
             [squeeze(lower_conf_pooled(variables_plot_pooled(v), :)), ...
              fliplr(squeeze(upper_conf_pooled(variables_plot_pooled(v), :)))], ...
             [0 0 1], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    end
    
    % Plot extended model IRF - black line with gray shading
    h2 = plot(time, squeeze(mean_irfs_12eq(variables_plot_12eq(v), :)), ...
              '-k', 'LineWidth', 1.5);
    fill([time, fliplr(time)], ...
         [squeeze(lower_conf_12eq(variables_plot_12eq(v), :)), ...
          fliplr(squeeze(upper_conf_12eq(variables_plot_12eq(v), :)))], ...
         [0.8 0.8 0.8], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
    
    % Add zero line
    yline(0, 'k', 'LineWidth', 0.5);
    
    % Adjust axis limits
    axis tight;
    yLimits = ylim();
    yMin = min(yLimits(1), 0);
    yMax = max(yLimits(2), 0);
    ylim_buffer = 0.05 * (yMax - yMin);
    ylim([yMin - ylim_buffer, yMax + ylim_buffer]);
    xlim([min(time) - 0.2, max(time) + 0.2]);
    
    % Configure x-axis
    xticks(0:2:time(end));
    xticklabels(arrayfun(@num2str, xticks, 'UniformOutput', false));
    
    % Labels and title
    xlabel('Year', 'FontSize', fontnum - 1);
    title(options.varnames{v}, 'FontSize', fontnum, 'FontWeight', 'bold');
    set(gca, 'FontSize', fontnum);
    
    box on;
    grid off;
    
    % Add legend to first subplot only
    if v == 1
        legend([h1 h2], {'Baseline', 'FX + Rates'}, ...
               'Location', 'northeast', 'FontSize', fontnum - 1);
    end
    
    hold off;
end

% Save figure
fprintf('Saving figure...\n');
print(fig, '.\figurespaper\appfig5.pdf', '-dpdf', '-painters', '-r300');
fprintf('Done! Figure saved to .\\figurespaper\\appfig5.pdf\n');