% =========================================================================
% Replication of Fig. 9 & 10 in "Do Geopolitical Risks Raise or Lower
% Inflation?"
% =========================================================================
% Date:     10/10/2025
%
% Description:
%   This script estimates a pooled panel VAR model using the Empirical Macro
%   toolbox of Canova and Ferroni. Country-by-country estimation.
%
% Steps:
%   1. Estimate pooled VAR 4-eq specification
%   2. Compute impulse response functions (IRFs)
%   3. Estimate country-by-country VAR spillovers (using 1000 draws, see
%   line 163)
%   4. Generate figure (impulse responses)
%   5. Generate figure (scatter)
% =========================================================================

%% ========================================================================
% SECTION 1: POOLED SPILLOVER MODEL (4 VARIABLES)
% =========================================================================

fprintf('\n========================================\n');
fprintf('POOLED SPILLOVER MODEL: 4-Variable VAR\n');
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

% Shock of interest (Foreign GPR shock, ordered second)
indx_sho = 2;

% Select model variables by name
% Ordering: GPR Country, GPR Foreign, Inflation, GDP
model_vars_spillover = {
    'GPR Country'
    'GPR Foreign'
    'Inflation (ppt)'
    'GDP (%)'
};

% Find indices of selected variables (preserving specified order)
[~, variables_sel] = ismember(model_vars_spillover, variable_labels);

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

fprintf('\nEstimating pooled spillover VAR...\n');

% Enable missing data handling
options.handle_missing = 1;

% Estimate VAR
bvar1 = bvar_misspooled(DATAX_pooled, lags, options);

fprintf('Estimation complete.\n');

%% ========================================================================
% SECTION 2: IMPULSE RESPONSE FUNCTIONS
% =========================================================================

% Extract IRFs for shock of interest (Foreign GPR shock)
irfs_to_plot = bvar1.ir_draws(:, 1:options.hor, indx_sho, :);

% Do NOT normalize - keep responses in original units for spillover analysis
irfs_to_plot_pooled = irfs_to_plot;

% Compute moments across posterior draws
mean_irfs_pooled = mean(irfs_to_plot_pooled, 4);  % Mean IRF
std_irfs_pooled = std(irfs_to_plot_pooled, 0, 4);  % Standard deviation

% Construct 90% confidence intervals (normal approximation)
z_score = 1.645;  % 90% CI
lower_conf_pooled = mean_irfs_pooled - z_score * std_irfs_pooled;
upper_conf_pooled = mean_irfs_pooled + z_score * std_irfs_pooled;

%% ========================================================================
% SECTION 3: COUNTRY-BY-COUNTRY SPILLOVER ESTIMATION
% =========================================================================

fprintf('\n========================================\n');
fprintf('COUNTRY-BY-COUNTRY SPILLOVER ESTIMATION\n');
fprintf('========================================\n');

%% ------------------------------------------------------------------------
% SUBSECTION 3.1: Configure and Estimate Individual Country VARs
% -------------------------------------------------------------------------
% Configure options for country-by-country estimation
options.K = 1000;  % Fewer draws for individual country VARs

% Set up options structure for bvar_countries_spillovers function
opt_units.cutoff = cutoff;
opt_units.NCountries = NCountries;
opt_units.idx = idx;
opt_units.lags = lags;
opt_units.indx_sho = indx_sho;
opt_units.cnames = cnames;
opt_units.variables_sel = variables_sel;

fprintf('\n4-variable spillover model:\n');
for i = 1:length(variables_sel)
    fprintf('  %d. %s\n', i, options.varnames{i});
end

[valid_countries_1, irfs_mean_to_plot_1, irfs_std_to_plot_1] = ...
    bvar_countries_spillovers(DATAX_demean, options, opt_units);

cnamesvalid_1 = cnames(valid_countries_1);

%% ------------------------------------------------------------------------
% SUBSECTION 3.2: Compute Weighted and Unweighted Averages
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

%% ========================================================================
% SECTION 4: VISUALIZATION - WEIGHTED VS. UNWEIGHTED VS. POOLED
% =========================================================================

fprintf('\nGenerating spillover comparison figure...\n');

% Configure plot appearance
time = 0:(options.hor - 1);
fontnum = 8;
num_vars = size(irfs_mean_to_plot_1, 1);

% Create figure
fig = figure(9);
set(fig, 'Units', 'inches', 'Position', [1, 1, 7.5, 4.5]);
set(fig, 'PaperUnits', 'inches', 'PaperSize', [7.5, 4.5]);
set(fig, 'PaperPosition', [0, 0, 7.5, 4.5]);
set(gcf, 'Color', 'w');

% Subplot layout: 2 columns
num_rows = ceil(num_vars / 2);
num_cols = 2;

for v = 1:num_vars
    subtightplot(num_rows, num_cols, v, [0.15 0.06], [0.05 0.02], [0.02 0.02]);
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
    xlabel('Year', 'FontSize', fontnum, 'FontWeight', 'bold');
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
print(fig, '.\figurespaper\fig9.pdf', '-dpdf', '-painters', '-r300', '-bestfit');

fprintf('Done! Figure saved to .\\figurespaper\\fig9.pdf\n');

%% ========================================================================
% SECTION 5: SCATTER PLOT - INFLATION VS. GDP SPILLOVER RESPONSES
% =========================================================================

fprintf('\nGenerating spillover scatter plot...\n');

% Configuration
x_var = 4;        % GDP response
y_var = 3;        % Inflation response
horizon = 3;      % 3 years ahead
shock = 1;        % Foreign GPR shock
fontnum = 10;

% Extract data
x_data = squeeze(irfs_mean_to_plot_1(x_var, horizon, shock, :));
y_data = squeeze(irfs_mean_to_plot_1(y_var, horizon, shock, :));

% Remove NaN values
valid_idx = ~isnan(x_data) & ~isnan(y_data);
x_data_valid = x_data(valid_idx);
y_data_valid = y_data(valid_idx);
cnames_valid = cnamesvalid_1(valid_idx);

% Identify countries to label (top/bottom 3 on each axis)
[~, top_x_idx] = maxk(x_data_valid, 3);
[~, bot_x_idx] = maxk(-x_data_valid, 3);
[~, top_y_idx] = maxk(y_data_valid, 3);
[~, bot_y_idx] = maxk(-y_data_valid, 3);
us_idx = find(strcmp(cnames_valid, 'United States'));

label_idx = unique([top_x_idx; bot_x_idx; top_y_idx; bot_y_idx]);

% Create figure
fig = figure(10);
set(fig, 'Units', 'inches', 'Position', [1, 1, 7.5, 4]);
set(fig, 'PaperUnits', 'inches', 'PaperSize', [7.5, 4]);
set(fig, 'PaperPosition', [0, 0, 7.5, 4]);
set(fig, 'Color', 'w');

hold on;

% Plot all data points
for i = 1:length(x_data_valid)
    if strcmp(cnames_valid{i}, 'United States')
        scatter(x_data_valid(i), y_data_valid(i), 8, 'g', 'filled');
    else
        scatter(x_data_valid(i), y_data_valid(i), 6, 'b', 'filled');
    end
end

% Fit and plot regression line
p = polyfit(x_data_valid, y_data_valid, 1);
fitted_y = polyval(p, x_data_valid);
plot(x_data_valid, fitted_y, 'r', 'LineWidth', 1.2);

% Label selected countries
for j = 1:length(label_idx)
    idx = label_idx(j);
    if idx ~= us_idx
        % Determine vertical alignment
        if ismember(idx, top_y_idx)
            v_align = 'bottom';
        elseif ismember(idx, bot_y_idx)
            v_align = 'top';
        else
            v_align = 'middle';
        end
        
        text(x_data_valid(idx), y_data_valid(idx), cnames_valid{idx}, ...
             'FontSize', fontnum, 'Color', 'black', ...
             'HorizontalAlignment', 'right', 'VerticalAlignment', v_align);
    end
end

% Label United States separately
if ~isempty(us_idx)
    us_x = x_data_valid(us_idx);
    us_y = y_data_valid(us_idx);
    text(us_x + 0.02, us_y + 0.02, 'U.S.', ...
         'FontSize', fontnum, 'Color', 'red', 'FontWeight', 'bold');
end

% Format axes
pad_x = 0.05 * (max(x_data_valid) - min(x_data_valid));
pad_y = 0.05 * (max(y_data_valid) - min(y_data_valid));
xlim([min(x_data_valid) - pad_x, max(x_data_valid) + pad_x]);
ylim([min(y_data_valid) - pad_y, max(y_data_valid) + pad_y]);

xlabel('GDP Response to Foreign GPR (%)', 'FontSize', fontnum);
ylabel('Inflation Response to Foreign GPR (ppt)', 'FontSize', fontnum);
set(gca, 'FontSize', fontnum);

box on;
grid on;
hold off;

% Save figure
fprintf('Saving scatter plot...\n');
print(fig, '.\figurespaper\fig10.pdf', '-dpdf', '-painters', '-r300');
fprintf('Done! Scatter plot saved to .\\figurespaper\\fig10.pdf\n');

%% ========================================================================
% LOCAL FUNCTION: COUNTRY-BY-COUNTRY SPILLOVER VAR ESTIMATION
% =========================================================================

function [valid_countries, irfs_mean_to_plot, irfs_std_to_plot] = ...
    bvar_countries_spillovers(DATAX_demean, options, opt_units)
% BVAR_COUNTRIES_SPILLOVERS Estimate individual country spillover VARs
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
%
% Note: Unlike bvar_countries, this function does NOT normalize IRFs
%       to preserve spillover magnitudes in original units

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
        
        % Extract IRFs (do NOT normalize for spillover analysis)
        ir_draws = bvar0.ir_draws(:, 1:options.hor, indx_sho, :);
        
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