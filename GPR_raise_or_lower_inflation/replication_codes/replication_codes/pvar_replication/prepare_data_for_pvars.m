%--------------------------------------------------------------------------
%               LOAD DATA AND COUNTRY LABELS AND ENTER LABELS
%--------------------------------------------------------------------------
function prepare_data_for_pvars
    country_sel = {''}; 
    
    cnames = readcell(char(strcat('.\sourcedata\countrynames.txt')));
    
    DATA_VAR1 = csvread(char(strcat('.\sourcedata\data_sgprco.txt')));
    DATA_VAR2 = csvread(char(strcat('.\sourcedata\data_inflation_sig.txt')));
    DATA_VAR3 = csvread(char(strcat('.\sourcedata\data_lngdp_detrend.txt')));
    DATA_VAR4 = csvread(char(strcat('.\sourcedata\data_impexp_gdp_ratio_detrend.txt')));
    DATA_VAR5 = csvread(char(strcat('.\sourcedata\data_std_shortages_c.txt')));
    DATA_VAR6 = csvread(char(strcat('.\sourcedata\data_milit_exp_share.txt')));
    DATA_VAR7 = csvread(char(strcat('.\sourcedata\data_debttogdp.txt')));
    DATA_VAR8 = csvread(char(strcat('.\sourcedata\data_gmoney_sig.txt')));
    DATA_VAR9 = csvread(char(strcat('.\sourcedata\data_gtogdp.txt')));
    DATA_VAR10 = csvread(char(strcat('.\sourcedata\data_sgpaco.txt')));
    DATA_VAR11 = csvread(char(strcat('.\sourcedata\data_sgptco.txt')));
    DATA_VAR12 = csvread(char(strcat('.\sourcedata\data_gmd_strate_win.txt')));
    DATA_VAR13 = csvread(char(strcat('.\sourcedata\data_gmd_dusdfx_win.txt')));
    DATA_VAR14 = csvread(char(strcat('.\sourcedata\data_gprh.txt')));
    DATA_VAR15 = csvread(char(strcat('.\sourcedata\data_gprco_others.txt')));
    DATA_VAR16 = csvread(char(strcat('.\sourcedata\data_gpr_narrative_ai.txt')));
    DATA_VAR17 = csvread(char(strcat('.\sourcedata\data_gmd_ltrate_win.txt')));
    DATA_VAR18 = csvread(char(strcat('.\sourcedata\data_inflation_trim.txt')));
    DATA_VAR19 = csvread(char(strcat('.\sourcedata\data_gmoney_trim.txt')));
    
    
    
    label_var1 = 'GPR Country' ;
    label_var2 = 'Inflation (ppt)' ;
    label_var3 = 'GDP (%)' ;
    label_var4 = 'Trade to GDP (ppt)' ;
    label_var5 = 'Shortages Index' ;
    label_var6 = 'Mil. Exp. to GDP (ppt)' ;
    label_var7 = 'Debt to GDP (ppt)' ;
    label_var8 = 'Money Growth (ppt)' ;
    label_var9 = 'Govt Exp. to GDP (ppt)' ;
    label_var10 = 'GPA Country' ;
    label_var11 = 'GPT Country' ;
    label_var12 = 'ST Interest Rate (ppt)' ;
    label_var13 = 'Exchange Rate Depreciation (ppt)' ;
    label_var14 = 'GPR Global' ;
    label_var15 = 'GPR Foreign' ;
    label_var16 = 'GPR Narrative' ;
    label_var17 = 'LT Interest Rate (ppt)' ;
    label_var18 = 'Inflation Trim. (ppt)' ;
    label_var19 = 'Money Growth Trim. (ppt)' ;
    
    NPOTVAR = 19;
    variable_labels = {};
    variable_labels_short = {};
    
    for iii=1:NPOTVAR
        eval([ 'variable_labels = [ variable_labels; label_var' num2str(iii) ' ];' ])
        eval([ 'variable_labels_short = [ variable_labels_short; label_var' num2str(iii) '(1:3) ];' ])
        eval([ 'DATA_VAR' num2str(iii) '(DATA_VAR' num2str(iii) '==9999)=NaN;' ]);  % 9999 is missing data code
        eval([ 'DATA_ORIG(:,:,' num2str(iii) ') = [ DATA_VAR' num2str(iii) '];']);
        eval([ 'DATAX(:,:,' num2str(iii) ') = [ DATA_VAR' num2str(iii) '];']);
    end
    T = size(DATAX,1);
    
    save datapanelGPR DATAX variable_labels variable_labels_short cnames
end
