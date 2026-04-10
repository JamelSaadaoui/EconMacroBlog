if confidence_interval == 70
    pctsel = [2 4];
elseif confidence_interval == 90
    pctsel = [1 5];
end

graph_opt.linW = 2;                     % Line Width IRF
graph_opt.font_num = 11;                % Font size IRF plots

transp90 = 0.1;
transp68 = 0.2;


IRFresp = IRFRESP;
ishocks_irf = imp_select;
H = SS.Horizon;

save(strcat('ResultsPlot_',string(model_vec)),'IRFresp','i_var_str','ishocks_irf','H');

SCALE = 1 ;


for i=1:numel(ishocks_irf)
    
    
    colore='k'; 
    
    if nv<=6
        nr=2;
        nc=3;
    end
    if nv>=7
        nr=3;
        nc=3;
    end
    if nv>9
        nr=4;
        nc=3;
    end
    if nv==4
        nr=2;
        nc=2;
    end
    
    
    
    
    fig=figure('Name','Figure','NumberTitle','off');
    
    
    for ii = 1:nv % Variable
        subplot(nr,nc,ii)
        plot(0:1:H,0*IRFresp(ii,:,3,ishocks_irf(i)),'color',colore,'LineWidth',0.5);
        hold on
        a = squeeze(SCALE*IRFresp(ii,:,1,ishocks_irf(i)));
        b = squeeze(SCALE*IRFresp(ii,:,5,ishocks_irf(i)));
        [~,~]=jbfill(0:1:H,a,b,'b','none',1,transp90);
        a = squeeze(SCALE*IRFresp(ii,:,2,ishocks_irf(i)));
        b = squeeze(SCALE*IRFresp(ii,:,4,ishocks_irf(i)));
        [~,~]=jbfill(0:1:H,a,b,'b','none',1,transp68);
        hold on
        plot(0:1:H,IRFresp(ii,:,3,ishocks_irf(i)),'color',colore,'LineWidth',2);
        title(strcat(i_var_lab(:,ii)),'FontSize',graph_opt.font_num,'FontWeight','bold')
        axis([0 H ylim])
        set(gca,'XTick',0:12:H)
        if exist('annualflag','var')
            set(gca,'XTick',0:2:H)
        end
    end
    
    figSize = [4,14]';
    graph_extended
    
    if strcmp(mmodel, 'z5_level')
    print(fig,'-dpdf','irf_monthly_baseline');
    end
    if strcmp(mmodel, 'z1_annual')
    print(fig,'-dpdf','irf_annual_baseline');
    end
    
    
end




