================================================================================
REPLICATION CODE INSTRUCTIONS: PANEL VAR ANALYSIS
"Do Geopolitical Risks Raise or Lower Inflation?"
================================================================================
Date: October 10, 2025

================================================================================
OVERVIEW
================================================================================

This folder contains replication code for all figures in the paper using 
panel VAR models.

================================================================================
REQUIREMENTS
================================================================================

Software:
  - MATLAB R2019a or later
  
Toolboxes Required (already in the folder):
  - Empirical Macro toolbox (Canova & Ferroni)
    * cmintools
    * bvartools
    * bvar_misspooled.m is a modified version of the original bvar_ function 
      available in the toolbox. It removes time t observations when missing
      data are present.

================================================================================
FILE STRUCTURE
================================================================================

Main Script:
  run_master_script_pvar.m    - Setup script (run this to execute all figures)
  
Figure Replication Scripts:
  run_fig3.m              - Figure 3: Baseline 9-variable model
  run_fig4.m              - Figure 4: Acts vs. Threats (GPA vs. GPT)
  run_fig5.m              - Figure 5: Global vs. Country-Specific GPR
  run_fig6.m              - Figure 6: Narrative identification
  run_fig7_fig8.m         - Figure 7-8: Country-by-country analysis
  run_fig9_fig10.m        - Figures 9-10: Spillovers from Foreign GPR
  run_appfig3.m           - Appendix Figure A3: Two lags specification
  run_appfig4.m           - Appendix Figure A4: Trimmed inflation & money
  run_appfig5.m           - Appendix Figure A5: Extended with FX & rates

Data:
  prepare_data_for_pvars.m - Creates the data file datapanelGPR.mat

Output:
  figurespaper/           - Directory for generated PDF figures
  
================================================================================
HOW TO RUN
================================================================================

OPTION A: Run Figures Automatically
----------------------------------------
1. Open master_script_pvar.m
2. Select figures you want to run 
3. Run master_script_pvar.m

OPTION B: Run Individual Figures 
-----------------------------------------------
1. Run master_script_pvar.m first through section 4 (sets up environment and data)
2. Then run individual figure scripts as needed:
   
   >> run_fig3        % Generate Figure 3
   >> run_fig4        % Generate Figure 4
   etc.

3. Figures are saved as PDFs in figurespaper/ directory

================================================================================
CUSTOMIZATION
================================================================================

Global Parameters:
------------------
You can modify estimation parameters in master_script_pvar.m (lines 27-33):

  global_params.K = 5000;                    % Posterior draws
  global_params.hor = 11;                    % IRF horizon (years)
  global_params.conf_sig = 0.9;              % Confidence level (90%)

Individual scripts will use these parameters automatically.

 Other model parameters, eg. lags, need to be set in the individual files.

================================================================================
OUTPUT FILES
================================================================================

All figures are saved as PDFs in the figurespaper/ directory