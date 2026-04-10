% =========================================================================
% Replication of Fig. 5 in "Do Geopolitical Risks Raise or Lower
% Inflation?"
% =========================================================================
% Date:     10/10/2025
%
% Description:
%   This script estimates a pooled panel VAR model using the Empirical Macro
%   toolbox of Canova and Ferroni. Global vs Country Shocks.
%
% Steps:
%   1. Estimate pooled VAR
%   2. Compute impulse response functions (IRFs)
%   3. Generate figure
% =========================================================================

%% ========================================================================
% SECTION 1: MODEL 1 - GLOBAL GPR ORDERED FIRST
% =========================================================================

fprintf('\n========================================\n');
fprintf('MODEL 1: Global GPR vs. Country GPR\n');
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

% Shocks of interest
indx_sho = [1 2];  % Indices for Global GPR and Country GPR shocks

% Select model variables by name
% Ordering: GPR Global, GPR Country, followed by macro variables
model_vars_names = {
    'GPR Global'
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
[~, variables_sel] = ismember(model_vars_names, variable_labels);

% Store variable names for plotting
options.varnames = variable_labels(variables_sel);

fprintf('\n%d variables included in Model 1:\n', length(variables_sel));
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

fprintf('\nEstimating pooled panel VAR (Model 1)...\n');

% Enable missing data handling
options.handle_missing = 1;

% Estimate VAR
bvar3 = bvar_misspooled(DATAX_pooled, lags, options);

fprintf('Estimation complete.\n');

%% ========================================================================
% SECTION 2: IMPULSE RESPONSE FUNCTIONS
% =========================================================================

% Extract IRFs for both shocks of interest
irfs_to_plot_gc = bvar3.ir_draws(:, 1:options.hor, indx_sho, :);

% Normalize IRFs: scale by initial response of each shock variable
% Global GPR shock (shock 1): scale by initial response of Global GPR
scale_factor_glob = squeeze(irfs_to_plot_gc(1, 1, 1, :));
scale_factor_matrix_glob = reshape(scale_factor_glob, [1, 1, 1, bvar3.ndraws]);
irfs_to_plot_gc(:, :, 1, :) = irfs_to_plot_gc(:, :, 1, :) ./ scale_factor_matrix_glob;

% Country GPR shock (shock 2): scale by initial response of Country GPR
scale_factor_countr = squeeze(irfs_to_plot_gc(2, 1, 2, :));
scale_factor_matrix_countr = reshape(scale_factor_countr, [1, 1, 1, bvar3.ndraws]);
irfs_to_plot_gc(:, :, 2, :) = irfs_to_plot_gc(:, :, 2, :) ./ scale_factor_matrix_countr;

% Compute moments across posterior draws for each shock
% Global GPR shock
mean_irfs_glob = mean(irfs_to_plot_gc(:, :, 1, :), 4);
std_irfs_glob = std(irfs_to_plot_gc(:, :, 1, :), 0, 4);

% Country GPR shock
mean_irfs_countr = mean(irfs_to_plot_gc(:, :, 2, :), 4);
std_irfs_countr = std(irfs_to_plot_gc(:, :, 2, :), 0, 4);

% Construct 90% confidence intervals (normal approximation)
z_score = 1.645;  % 90% CI

% Global GPR confidence intervals
lower_conf_glob = mean_irfs_glob - z_score * std_irfs_glob;
upper_conf_glob = mean_irfs_glob + z_score * std_irfs_glob;

% Country GPR confidence intervals
lower_conf_countr = mean_irfs_countr - z_score * std_irfs_countr;
upper_conf_countr = mean_irfs_countr + z_score * std_irfs_countr;

%% ========================================================================
% SECTION 3: VISUALIZATION - GLOBAL VS. COUNTRY COMPARISON
% =========================================================================

fprintf('\nGenerating global vs. country comparison figure...\n');

% Configure plot appearance
time = 0:(options.hor - 1);  % Time axis (years)
fontnum = 8;                  % Font size
variables_plot = 1:10;        % Plot all 10 variables
num_vars = length(variables_plot);

% Create figure with custom 3x6 layout
fig = figure(5);
set(fig, 'Units', 'inches', 'Position', [1, 1, 8.5, 7.5]);
set(fig, 'PaperSize', [8.5, 7.5]);
set(fig, 'PaperPosition', [0 0 8.5 7.5]);
set(gcf, 'Color', 'w');  % White background

% Define manual subplot mapping (3 rows x 6 columns)
% First two variables take single columns, remaining 8 take double columns
subplot_map = {
    [1];       % Var 1: GPR Global
    [2];       % Var 2: GPR Country
    [3 4];     % Var 3: Inflation
    [5 6];     % Var 4: GDP
    [7 8];     % Var 5: Trade to GDP
    [9 10];    % Var 6: Shortages Index
    [11 12];   % Var 7: Mil. Exp. to GDP
    [13 14];   % Var 8: Debt to GDP
    [15 16];   % Var 9: Money Growth
    [17 18]    % Var 10: Govt Exp. to GDP
};

% Plot IRFs for each variable
for v = 1:num_vars
    subplot(3, 6, subplot_map{v});
    hold on;
    
    % Plot Global GPR shock - blue line with shading
    h1 = plot(time, squeeze(mean_irfs_glob(v, :)), '-b', 'LineWidth', 1.5);
    fill([time, fliplr(time)], ...
         [squeeze(lower_conf_glob(v, :)), fliplr(squeeze(upper_conf_glob(v, :)))], ...
         [0 0 1], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    
    % Plot Country GPR shock - black line with gray shading
    h2 = plot(time, squeeze(mean_irfs_countr(v, :)), '-k', 'LineWidth', 1.5);
    fill([time, fliplr(time)], ...
         [squeeze(lower_conf_countr(v, :)), fliplr(squeeze(upper_conf_countr(v, :)))], ...
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
        legend([h1 h2], {'Global GPR Shock', 'Country GPR Shock'}, ...
               'Location', 'northeast', 'FontSize', fontnum - 1);
    end
    
    hold off;
end

% Save figure
fprintf('Saving figure...\n');
print(fig, '.\figurespaper\fig5.pdf', '-dpdf', '-painters', '-r300');

fprintf('Done! Figure saved to .\\figurespaper\\fig5.pdf\n');