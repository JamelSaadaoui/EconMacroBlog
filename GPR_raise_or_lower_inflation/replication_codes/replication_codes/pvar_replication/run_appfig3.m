% =========================================================================
% Replication of Fig. A3 in "Do Geopolitical Risks Raise or Lower
% Inflation?" Robustness Check: Lag Specification Comparison
% =========================================================================
% Date:     10/10/2025
%
% Description:
%   This script estimates a pooled panel VAR model using the Empirical Macro
%   toolbox of Canova and Ferroni. Lags comparison
%
% Steps:
%   1. Estimate pooled VAR
%   2. Compute impulse response functions (IRFs)
%   3. Estimate pooled VAR 2 lags
%   4. Compute impulse response functions (IRFs)
%   5. Generate figure
% =========================================================================

%% ========================================================================
% SECTION 2: BASELINE MODEL (1 LAG)
% =========================================================================

fprintf('\n========================================\n');
fprintf('BASELINE MODEL: 9-Variable VAR (1 Lag)\n');
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

% Select model variables by name
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
[~, variables_sel] = ismember(model_vars_baseline, variable_labels);

% Store variable names for plotting
options.varnames = variable_labels(variables_sel);

fprintf('\n%d variables included in baseline model:\n', length(variables_sel));
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
cutoff = 0.95;  % Maximum proportion of missing data allowed
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

fprintf('\nEstimating baseline pooled panel VAR (1 lag)...\n');

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
% SECTION 3: TWO-LAG MODEL
% =========================================================================

fprintf('\n========================================\n');
fprintf('TWO-LAG MODEL: 9-Variable VAR (2 Lags)\n');
fprintf('========================================\n');

%% ------------------------------------------------------------------------
% SUBSECTION 3.1: Model Configuration
% -------------------------------------------------------------------------

% Estimation options (same as baseline except for lags)
lags             = 2;      % Two lags

% Shock of interest
indx_sho = 1;

% Use same variables as baseline
fprintf('\n%d variables included in 2-lag model:\n', length(variables_sel));
for i = 1:length(variables_sel)
    fprintf('  %d. %s\n', i, options.varnames{i});
end

%% ------------------------------------------------------------------------
% SUBSECTION 3.2: Country Selection and Data Filtering
% -------------------------------------------------------------------------

% Extract selected variables (reuse from baseline)
DATAXtemp = DATAX_demean(:, :, variables_sel);

% Use same country exclusion criteria
countries_to_exclude_2lag = idx;

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
        countries_to_exclude_2lag = [countries_to_exclude_2lag, c];
    end
end

% Validate country indices
if any(countries_to_exclude_2lag > NCountries) || any(countries_to_exclude_2lag < 1)
    error('Invalid country indices detected.');
end

% Create list of countries to keep
countries_to_keep_2lag = setdiff(1:NCountries, countries_to_exclude_2lag);

fprintf('\nFinal sample: %d countries (excluded %d)\n', ...
        length(countries_to_keep_2lag), length(countries_to_exclude_2lag));

% Prepare data for pooled estimation
DATAXtemp = DATAX_demean(:, countries_to_keep_2lag, variables_sel);
DATAX_pooled_2lag = permute(DATAXtemp, [1, 3, 2]);  % [T x Vars x Countries]

%% ------------------------------------------------------------------------
% SUBSECTION 3.3: Pooled VAR Estimation
% -------------------------------------------------------------------------

fprintf('\nEstimating pooled panel VAR (2 lags)...\n');

% Enable missing data handling
options.handle_missing = 1;

% Estimate VAR
bvar2 = bvar_misspooled(DATAX_pooled_2lag, lags, options);

fprintf('Estimation complete.\n');

%% ========================================================================
% SECTION 4: IMPULSE RESPONSE FUNCTIONS
% =========================================================================

% Extract IRFs for shock of interest
irfs_to_plot_2lags = bvar2.ir_draws(:, 1:options.hor, indx_sho, :);

% Normalize IRFs: scale by initial response of shock variable
scale_factor_2lags = squeeze(irfs_to_plot_2lags(1, 1, 1, :));
scale_factor_matrix_2lags = reshape(scale_factor_2lags, [1, 1, 1, bvar2.ndraws]);
irfs_to_plot_2lags = irfs_to_plot_2lags ./ scale_factor_matrix_2lags;

% Compute moments across posterior draws
mean_irfs_2lags = mean(irfs_to_plot_2lags, 4);  % Mean IRF
std_irfs_2lags = std(irfs_to_plot_2lags, 0, 4);  % Standard deviation

% Construct 90% confidence intervals (normal approximation)
lower_conf_2lags = mean_irfs_2lags - z_score * std_irfs_2lags;
upper_conf_2lags = mean_irfs_2lags + z_score * std_irfs_2lags;

%% ========================================================================
% SECTION 5: VISUALIZATION - BASELINE VS. 2-LAG COMPARISON
% =========================================================================

fprintf('\nGenerating lag specification comparison figure...\n');

% Configure plot appearance
time = 0:(options.hor - 1);  % Time axis (years)
fontnum = 8;                  % Font size
variables_plot_pooled = 1:9;  % Plot all 9 variables
num_vars = length(variables_plot_pooled);

% Create figure
fig = figure('Name', 'Figure A3', 'NumberTitle', 'off');
set(fig, 'Units', 'inches', 'Position', [1, 1, 7.5, 5]);
set(fig, 'PaperSize', [7.5, 5]);
set(fig, 'PaperPosition', [0 0 7.5 5]);
set(gcf, 'Color', 'w');  % White background

% Subplot layout: 3 columns
num_rows = ceil(num_vars / 3);
num_cols = 3;

% Plot IRFs for each variable
for v = 1:num_vars
    subtightplot(num_rows, num_cols, v, [0.1 0.08], [0.08 0.05], [0.07 0.04]);
    hold on;
    
    % Plot baseline (1 lag) IRF - blue line with shading
    h1 = plot(time, squeeze(mean_irfs_pooled(variables_plot_pooled(v), :)), ...
              '-b', 'LineWidth', 1.5);
    fill([time, fliplr(time)], ...
         [squeeze(lower_conf_pooled(variables_plot_pooled(v), :)), ...
          fliplr(squeeze(upper_conf_pooled(variables_plot_pooled(v), :)))], ...
         [0 0 1], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    
    % Plot 2-lag IRF - black line with gray shading
    h2 = plot(time, squeeze(mean_irfs_2lags(variables_plot_pooled(v), :)), ...
              '-k', 'LineWidth', 1.5);
    fill([time, fliplr(time)], ...
         [squeeze(lower_conf_2lags(variables_plot_pooled(v), :)), ...
          fliplr(squeeze(upper_conf_2lags(variables_plot_pooled(v), :)))], ...
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
    title(options.varnames{variables_plot_pooled(v)}, ...
          'FontSize', fontnum, 'FontWeight', 'bold');
    set(gca, 'FontSize', fontnum);
    
    box on;
    grid off;
    
    % Add legend to first subplot only
    if v == 1
        legend([h1 h2], {'Baseline', '2 Lags'}, ...
               'Location', 'northeast', 'FontSize', fontnum - 1);
    end
    
    hold off;
end

% Save figure
fprintf('Saving figure...\n');
print(fig, '.\figurespaper\appfig3.pdf', '-dpdf', '-painters', '-r300');

fprintf('Done! Figure saved to .\\figurespaper\\appfig3.pdf\n');