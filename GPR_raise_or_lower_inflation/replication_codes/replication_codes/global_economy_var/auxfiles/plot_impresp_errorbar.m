% Start with IRFSIM

% Variable names stored

clear RR VAR VARNM

i_var_str2 = i_var_str;

i_var_str2(contains(i_var_str,'MWRDPPP_GDP_DET')) = {'World GDP'};
i_var_str2(contains(i_var_str,'RGFDFTWORLD')) = {'Stock Prices'};
i_var_str2(contains(i_var_str,'CCI')) = {'Consumer Confidence'};
i_var_str2(contains(i_var_str,'FXTWBDI')) = {'Dollar Index'};
i_var_str2(contains(i_var_str,'RPZTEXP')) = {'Oil Prices'};
i_var_str2(contains(i_var_str,'GFDWLDINF')) = {'World Inflation'};
i_var_str2(contains(i_var_str,'RGSCOMM')) = {'Commodity Prices'};

resp_select = [ 1 : 9 ] ;
HHH = 12;
N = 1:numel(resp_select) ;

for ii = resp_select % Variable
    
    if abs(max(IRFSIM(ii,1:HHH,3)))>abs(min(IRFSIM(ii,1:HHH,3)))
    RR(ii,:) =  max(IRFSIM(ii,1:HHH,3)) ;
    LR(ii,:) = max(IRFSIM(ii,1:HHH,pctsel(1))) ;
    UR(ii,:) = max(IRFSIM(ii,1:HHH,pctsel(2)))  ;
    end
  
    if abs(max(IRFSIM(ii,1:HHH,3)))<=abs(min(IRFSIM(ii,1:HHH,3)))
    RR(ii,:) =  min(IRFSIM(ii,1:HHH,3)) ;
    LR(ii,:) = min(IRFSIM(ii,1:HHH,pctsel(1))) ;
    UR(ii,:) = min(IRFSIM(ii,1:HHH,pctsel(2)))  ;
    end
    
    
    VAR{ii} = strcat(i_var_str2(:,ii)) ;
    VARNM(ii) =(i_var_str2(:,ii)) ;
    

end

macrovar = [ 4 3 ] ;
finvar1 = [ 7 9 ] ;
finvar2 = [ 8 6 5 ] ;

fig = figure('Name', 'Figure 12', 'NumberTitle', 'off');
subplot(4,1,1)
h = ploterr(RR(macrovar),1:numel(macrovar),{UR(macrovar),LR(macrovar)},[], '.');
set(gca,'ytick',1:numel(macrovar),'fontsize',10,'yticklabel',VARNM(macrovar),'fontsize',10)
xline(0)
ylim([0.8 2.2])
xlim([-2 2])
box on

subplot(4,1,2)
h = ploterr(RR(finvar1),1:numel(finvar1),{UR(finvar1),LR(finvar1)},[],'.');
set(gca,'ytick',1:numel(finvar1),'fontsize',10,'yticklabel',VARNM(finvar1),'fontsize',10)
xline(0)
ylim([0.8 2.2])
xlim([-3.5 3.5])
box on

subplot(4,1,3)
h = ploterr(RR(finvar2),1:numel(finvar2),{UR(finvar2),LR(finvar2)},[],'.');
set(gca,'ytick',1:numel(finvar2),'fontsize',10,'yticklabel',VARNM(finvar2),'fontsize',10)
xline(0)
xlabel('Impact in 2022 of Higher Geopolitical Risk (%)','Fontsize',11)
ylim([0.7 3.3])
xlim([-25 25])
box on

set(gcf,'color','w');


set(gcf, 'PaperUnits', 'inches');
x_width=5 ;y_width= 6
set(gcf, 'PaperPosition', [0 0 x_width y_width], 'PaperSize', [x_width y_width]); %




