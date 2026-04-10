% =========================================================================
% Replication of Figs. 7 & 8 in "Do Geopolitical Risks Raise or Lower
% Inflation?"
% =========================================================================
% Date:     10/10/2025
%
% Description:
%   This script estimates a pooled panel VAR model using the Empirical Macro
%   toolbox of Canova and Ferroni. Country-by-country estimation.
%
% Steps:
%   1. Estimate pooled 3-equation VAR
%   2. Compute impulse response functions (IRFs)
%   3. Estimate country-by-country VARs (using 1000 draws, see line 163)
%   4. Generate figure (impulse responses)
%   5. Generate figure (scatter)
% =========================================================================


%% ========================================================================
% SECTION 1: POOLED BASELINE MODEL (3 VARIABLES)
% =========================================================================

fprintf('\n========================================\n');
fprintf('POOLED BASELINE MODEL: 3-Variable VAR\n');
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

% Select model variables by name (baseline 3-variable model)
model_vars_baseline = {
    'GPR Country'
    'Inflation (ppt)'
    'GDP (%)'
};

% Find indices of selected variables (preserving specified order)
[~, variables_sel] = ismember(model_vars_baseline, variable_labels);

% Store variable names for plotting
options.varnames = variable_labels(variables_sel);

fprintf('\n%d variables included in pooled model:\n', length(variables_sel));
for i = 1:length(variables_sel)
    fprintf('  %d. %s\n', i, options.varnames{i});
end

%% ------------------------------------------------------------------------
% SUBSECTION 1.2: Country Selection and Data Filtering
% -------------------------------------------------------------------------

% Extract selected variables
DATAXtemp = DATAX_demean(:, :, variables_sel);

% Option to exclude specific countries by name
countries_to_find = "";  % Add country names here if needed
idx = find(ismember(cnames, countries_to_find));
countries_to_exclude = idx;

% Exclude countries with insufficient complete observations
cutoff = 0.52;  % Maximum proportion of missing data allowed
min_obs_threshold = round((1 - cutoff) * T);

fprintf('\nFiltering countries (min. valid obs: %d of %d):\n', ...
        min_obs_threshold, T);

for c = 1:NCountries
    % Extract data for country c: [T x NVars]
    yi = squeeze(DATAXtemp(:, c, :));
    
    % Count non-missing observations per variable
    valid_obs = sum(~isnan(yi), 1);
    
    % Exclude if any variable has insufficient data
    if min(valid_obs) < min_obs_threshold
        fprintf('  Excluding %s: Min valid obs = %d (< %d threshold)\n', ...
                cnames{c}, min(valid_obs), min_obs_threshold);
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
DATAXtemp = DATAX_demean(:, countries_to_keep, variables_sel);
DATAX_pooled = permute(DATAXtemp, [1, 3, 2]);  % [T x Vars x Countries]

%% ------------------------------------------------------------------------
% SUBSECTION 1.3: Pooled VAR Estimation
% -------------------------------------------------------------------------

fprintf('\nEstimating pooled panel VAR...\n');

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
% SECTION 3: COUNTRY-BY-COUNTRY ESTIMATION
% =========================================================================

fprintf('\n========================================\n');
fprintf('COUNTRY-BY-COUNTRY ESTIMATION\n');
fprintf('========================================\n');

%% ------------------------------------------------------------------------
% SUBSECTION 3.1: Baseline 3-Variable Model
% -------------------------------------------------------------------------

% Configure options for country-by-country estimation
options.K = 1000;  % Fewer draws for individual country VARs

% Set up options structure for bvar_countries function
opt_units.cutoff = cutoff;
opt_units.NCountries = NCountries;
opt_units.idx = idx;
opt_units.lags = lags;
opt_units.indx_sho = indx_sho;
opt_units.cnames = cnames;

% Model 1: Baseline 3-variable model (GPR, Inflation, GDP)
model_vars_1 = {'GPR Country', 'Inflation (ppt)', 'GDP (%)'};
[~, variables_sel_1] = ismember(model_vars_1, variable_labels);
opt_units.variables_sel = variables_sel_1;
options.varnames = variable_labels(variables_sel_1);

fprintf('\nModel 1 - Baseline 3-variable:\n');
for i = 1:length(variables_sel_1)
    fprintf('  %d. %s\n', i, options.varnames{i});
end

[valid_countries_1, irfs_mean_to_plot_1, irfs_std_to_plot_1] = ...
    bvar_countries(DATAX_demean, options, opt_units);

%% ------------------------------------------------------------------------
% SUBSECTION 3.2: Extended Models with Additional Variables
% -------------------------------------------------------------------------

% Model 2: Add Military Spending
model_vars_2 = {'GPR Country', 'Inflation (ppt)', 'GDP (%)', 'Mil. Exp. to GDP (ppt)'};
[~, variables_sel_2] = ismember(model_vars_2, variable_labels);
opt_units.variables_sel = variables_sel_2;
options.varnames = variable_labels(variables_sel_2);

fprintf('\nModel 2 - With Military Spending:\n');
for i = 1:length(variables_sel_2)
    fprintf('  %d. %s\n', i, options.varnames{i});
end

[valid_countries_2, irfs_mean_to_plot_2, irfs_std_to_plot_2] = ...
    bvar_countries(DATAX_demean, options, opt_units);

% Model 3: Add Money Growth
model_vars_3 = {'GPR Country', 'Inflation (ppt)', 'GDP (%)', 'Money Growth (ppt)'};
[~, variables_sel_3] = ismember(model_vars_3, variable_labels);
opt_units.variables_sel = variables_sel_3;
options.varnames = variable_labels(variables_sel_3);

fprintf('\nModel 3 - With Money Growth:\n');
for i = 1:length(variables_sel_3)
    fprintf('  %d. %s\n', i, options.varnames{i});
end

[valid_countries_3, irfs_mean_to_plot_3, irfs_std_to_plot_3] = ...
    bvar_countries(DATAX_demean, options, opt_units);

% Model 4: Add Trade
model_vars_4 = {'GPR Country', 'Inflation (ppt)', 'GDP (%)', 'Trade to GDP (ppt)'};
[~, variables_sel_4] = ismember(model_vars_4, variable_labels);
opt_units.variables_sel = variables_sel_4;
options.varnames = variable_labels(variables_sel_4);

fprintf('\nModel 4 - With Trade:\n');
for i = 1:length(variables_sel_4)
    fprintf('  %d. %s\n', i, options.varnames{i});
end

[valid_countries_4, irfs_mean_to_plot_4, irfs_std_to_plot_4] = ...
    bvar_countries(DATAX_demean, options, opt_units);

%% ------------------------------------------------------------------------
% SUBSECTION 3.3: Compute Weighted and Unweighted Averages
% -------------------------------------------------------------------------

fprintf('\nComputing weighted and unweighted averages...\n');

% Compute Swamy's weights (inverse variance weighting)
country_var = irfs_std_to_plot_1 .^ 2;
country_var(1, 1, 1, :) = 1;  % Normalize first element
weights = 1 ./ country_var;

% Weighted mean and standard deviation
weighted_mean_sum = sum(weights .* irfs_mean_to_plot_1, 4);
weighted_std_sum = sum(weights .* irfs_std_to_plot_1, 4);
total_weight = sum(squeeze(weights), 3);
irf_weighted_mean = weighted_mean_sum ./ total_weight;
irf_weighted_std = weighted_std_sum ./ total_weight;

% Unweighted mean and standard deviation (equal country weights)
irf_unweighted_mean = mean(irfs_mean_to_plot_1, 4);
irf_unweighted_std = mean(irfs_std_to_plot_1, 4);

% Compute 90% confidence intervals
irf_weighted_ci_lower = irf_weighted_mean - z_score * irf_weighted_std;
irf_weighted_ci_upper = irf_weighted_mean + z_score * irf_weighted_std;
irf_unweighted_ci_lower = irf_unweighted_mean - z_score * irf_unweighted_std;
irf_unweighted_ci_upper = irf_unweighted_mean + z_score * irf_unweighted_std;

%% ------------------------------------------------------------------------
% SUBSECTION 3.4: Find Common Countries Across All Models
% -------------------------------------------------------------------------

% Find intersection of valid countries across all four models
common_countries = intersect(valid_countries_1, valid_countries_2);
common_countries = intersect(common_countries, valid_countries_3);
common_countries = intersect(common_countries, valid_countries_4);

fprintf('\nCommon countries across all models: %d\n', length(common_countries));

% Filter IRF matrices to include only common countries
irfs_mean_filtered = cell(1, 4);
irfs_std_filtered = cell(1, 4);

for x = 1:4
    % Select the correct valid_countries and IRF matrices
    valid_countries_x = eval(sprintf('valid_countries_%d', x));
    irfs_mean_x = eval(sprintf('irfs_mean_to_plot_%d', x));
    irfs_std_x = eval(sprintf('irfs_std_to_plot_%d', x));
    
    % Find indices of common countries in current model
    [~, idx] = ismember(common_countries, valid_countries_x);
    idx = idx(idx > 0);
    
    % Extract only common countries
    irfs_mean_filtered{x} = irfs_mean_x(:, :, :, idx);
    irfs_std_filtered{x} = irfs_std_x(:, :, :, idx);
end

% Get country names for common countries
cnamesvalid = cnames(common_countries);
excluded_idx = setdiff(1:length(cnames), common_countries);
excluded_countries = cnames(excluded_idx);

fprintf('\nExcluded countries (not common across all models):\n');
disp(excluded_countries);

%% ========================================================================
% SECTION 4: VISUALIZATION - WEIGHTED VS. UNWEIGHTED VS. POOLED
% =========================================================================

fprintf('\nGenerating comparison figure...\n');

% Configure plot appearance
time = 0:(options.hor - 1);
fontnum = 8;
num_vars = size(irfs_mean_to_plot_1, 1);

% Create figure
fig = figure(7);
set(fig, 'Units', 'inches', 'Position', [1, 1, 7.5, 3]);
set(fig, 'PaperSize', [7.5, 3]);
set(fig, 'PaperPosition', [0 0 7.5 3]);
set(gcf, 'Color', 'w');

% Subplot layout
num_rows = ceil(num_vars / 3);
num_cols = 3;

% Reset options.varnames to baseline 3-variable model
options.varnames = variable_labels(variables_sel_1);

for v = 1:num_vars
    subtightplot(num_rows, num_cols, v, [0.07 0.06], [0.2 0.2], [0.06 0.04]);
    hold on;
    
    % Plot weighted mean - red line
    plot(time, squeeze(irf_weighted_mean(v, :)), '-r', 'LineWidth', 1.5);
    
    % Plot unweighted mean - green dashed line
    plot(time, squeeze(irf_unweighted_mean(v, :)), '--', ...
         'LineWidth', 1.5, 'Color', [0 0.5 0]);
    
    % Plot pooled estimator - blue line (thicker)
    plot(time, squeeze(mean_irfs_pooled(v, :)), '-b', 'LineWidth', 2.5);
    
    % Add confidence interval shading for weighted mean
    fill([time, fliplr(time)], ...
         [squeeze(irf_weighted_ci_lower(v, :)), ...
          fliplr(squeeze(irf_weighted_ci_upper(v, :)))], ...
         [1 0.6 0.6], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    
    % Add zero line
    plot(xlim, [0 0], 'k-', 'LineWidth', 0.5);
    
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
    
    % Add legend to first subplot
    if v == 1
        legend({'Variance Weighted', 'Equally Weighted', 'Pooled / Baseline'}, ...
               'Location', 'northeast', 'FontSize', fontnum - 1);
    end
    
    hold off;
end

% Save figure
fprintf('Saving figure...\n');
print(fig, '.\figurespaper\fig7.pdf', '-dpdf', '-painters', '-r300');
fprintf('Done! Figure saved to .\\figurespaper\\fig7.pdf\n');

%% ========================================================================
% SECTION 5: SCATTER PLOTS - INFLATION VS. OTHER RESPONSES
% =========================================================================

fprintf('\nGenerating scatter plots...\n');

% Configuration
y_var = 2;        % Inflation (from model 1)
horizon = 3;      % Selected horizon (3 years ahead)
shock = 1;        % GPR shock
x_vars_per_model = [3, 4, 4, 4];  % X variables: GDP, Mil. Spending, Money, Trade

% Variable names for axes
varnames_x = {
    'GDP Response to GPR (%)'
    'Mil. Spending Response to GPR (ppt)'
    'Money Growth Response to GPR (ppt)'
    'Trade Response to GPR (ppt)'
};
varnames_y = {'Inflation Response to GPR (ppt)'};

num_models = 4;
fontnum = 9;

% Create figure
fig = figure(8);
set(fig, 'Units', 'inches', 'Position', [1, 1, 7.5, 5.5]);
set(fig, 'PaperUnits', 'inches', 'PaperSize', [7.5, 5.5]);
set(fig, 'PaperPosition', [0, 0, 7.5, 5.5]);
set(fig, 'Color', 'w');

% Create scatter plot for each model
for x = 1:num_models
    subtightplot(2, 2, x, [0.1 0.08], [0.08 0.05], [0.07 0.04]);
    hold on;
    
    % Extract data for current model
    x_var = x_vars_per_model(x);
    y_data = squeeze(irfs_mean_filtered{1}(y_var, horizon, shock, :));
    x_data = squeeze(irfs_mean_filtered{x}(x_var, horizon, shock, :));
    
    % Remove NaN values
    valid_idx = ~isnan(x_data) & ~isnan(y_data);
    x_data_valid = x_data(valid_idx);
    y_data_valid = y_data(valid_idx);
    cnames_valid_x = cnamesvalid(valid_idx);
    
    % Identify top and bottom 3 countries by x-axis response
    [~, top_idx] = maxk(x_data_valid, 3);
    [~, bot_idx] = maxk(-x_data_valid, 3);
    
    % Plot all data points
    for i = 1:length(x_data_valid)
        if strcmp(cnames_valid_x{i}, 'United States')
            scatter(x_data_valid(i), y_data_valid(i), 8, 'g', 'filled');
            text(x_data_valid(i) + 0.02, y_data_valid(i) + 0.02, 'U.S.', ...
                 'FontSize', fontnum, 'Color', 'red', 'FontWeight', 'bold');
        elseif strcmp(cnames_valid_x{i}, 'Canada')
            scatter(x_data_valid(i), y_data_valid(i), 6, 'b', 'filled');
            text(x_data_valid(i) + 0.02, y_data_valid(i) + 0.02, 'Canada', ...
                 'FontSize', fontnum, 'Color', 'black', 'FontWeight', 'bold');
        else
            scatter(x_data_valid(i), y_data_valid(i), 6, 'b', 'filled');
        end
    end
    
    % Fit and plot regression line
    p = polyfit(x_data_valid, y_data_valid, 1);
    fitted_y = polyval(p, x_data_valid);
    plot(x_data_valid, fitted_y, 'r', 'LineWidth', 1.2);
    
    % Label top 3 countries
    for j = 1:length(top_idx)
        text(x_data_valid(top_idx(j)), y_data_valid(top_idx(j)), ...
             cnames_valid_x{top_idx(j)}, 'FontSize', fontnum, ...
             'Color', 'black', 'HorizontalAlignment', 'right', ...
             'VerticalAlignment', 'bottom');
    end
    
    % Label bottom 3 countries
    for j = 1:length(bot_idx)
        text(x_data_valid(bot_idx(j)), y_data_valid(bot_idx(j)), ...
             cnames_valid_x{bot_idx(j)}, 'FontSize', fontnum, ...
             'Color', 'black', 'HorizontalAlignment', 'right', ...
             'VerticalAlignment', 'top');
    end
    
    % Axis labels
    xlabel(varnames_x{x}, 'FontSize', fontnum);
    ylabel(varnames_y, 'FontSize', fontnum);
    
    % Adjust axis limits with padding
    pad_x = 0.05 * (max(x_data_valid) - min(x_data_valid));
    pad_y = 0.05 * (max(y_data_valid) - min(y_data_valid));
    xlim([min(x_data_valid) - pad_x, max(x_data_valid) + pad_x]);
    ylim([min(y_data_valid) - pad_y, max(y_data_valid) + pad_y]);
    
    box on;
    grid on;
    set(gca, 'FontSize', fontnum);
    hold off;
end

% NOTE: PLACE COUNTRY LABELS MANUALLY FOR VISUALIZATION
% Save figure
fprintf('Saving scatter plots...\n');
print(fig, '.\figurespaper\fig8.pdf', '-dpdf', '-painters', '-r300');
fprintf('Done! Scatter plots saved to .\\figurespaper\\fig8.pdf\n');

%% ========================================================================
% LOCAL FUNCTION: COUNTRY-BY-COUNTRY VAR ESTIMATION
% =========================================================================

function [valid_countries, irfs_mean_to_plot, irfs_std_to_plot] = ...
    bvar_countries(DATAX_demean, options, opt_units)
% BVAR_COUNTRIES Estimate individual country VARs and collect IRFs
%
% Inputs:
%   DATAX_demean - Panel data array [T x Countries x Variables]
%   options      - Estimation options structure
%   opt_units    - Unit-specific options (cutoff, lags, shock index, etc.)
%
% Outputs:
%   valid_countries     - Indices of countries with successful estimation
%   irfs_mean_to_plot   - Mean IRFs [Variables x Horizons x 1 x Countries]
%   irfs_std_to_plot    - Std IRFs [Variables x Horizons x 1 x Countries]

    % Extract parameters from opt_units structure
    variables_sel = opt_units.variables_sel;
    cutoff = opt_units.cutoff;
    NCountries = opt_units.NCountries;
    idx = opt_units.idx;
    lags = opt_units.lags;
    indx_sho = opt_units.indx_sho;
    cnames = opt_units.cnames;
    
    % Compute minimum required observations
    min_obs_threshold = round((1 - cutoff) * size(DATAX_demean, 1));
    
    % Initialize storage
    valid_countries = [];
    irfs_mean_to_plot = zeros(length(variables_sel), options.hor, 1, NCountries);
    irfs_std_to_plot = zeros(length(variables_sel), options.hor, 1, NCountries);
    
    % Loop over all countries
    for i = 1:NCountries
        % Extract country i data
        yi = squeeze(DATAX_demean(:, i, variables_sel));
        
        % Remove rows with NaN values
        rows_with_nan = any(isnan(yi), 2);
        yi = yi(~rows_with_nan, :);
        
        % Check if sufficient observations remain
        if size(yi, 1) < min_obs_threshold || ismember(i, idx)
            fprintf('  Skipping country %s: Insufficient obs (%d < %d)\n', ...
                    cnames{i}, size(yi, 1), min_obs_threshold);
            continue;
        end
        
        % Estimate VAR for country i
        bvar0 = bvar_(yi, lags, options);
        
        % Extract and normalize IRFs
        ir_draws = bvar0.ir_draws(:, 1:options.hor, indx_sho, :);
        scale_factor = squeeze(ir_draws(1, 1, 1, :));
        scale_factor_matrix = reshape(scale_factor, [1, 1, 1, bvar0.ndraws]);
        ir_draws = ir_draws ./ scale_factor_matrix;
        
        % Compute mean and standard deviation across draws
        irf_mean = mean(squeeze(ir_draws), 3);
        irf_std = std(squeeze(ir_draws), 0, 3);
        
        % Store results
        irfs_mean_to_plot(:, :, 1, i) = irf_mean;
        irfs_std_to_plot(:, :, 1, i) = irf_std;
        
        % Mark country as valid
        valid_countries = [valid_countries, i];
    end
    
    % Display summary
    fprintf('  Final dataset includes %d countries (out of %d)\n', ...
            length(valid_countries), NCountries);
    
    % Keep only valid countries in output arrays
    irfs_mean_to_plot = irfs_mean_to_plot(:, :, :, valid_countries);
    irfs_std_to_plot = irfs_std_to_plot(:, :, :, valid_countries);
end