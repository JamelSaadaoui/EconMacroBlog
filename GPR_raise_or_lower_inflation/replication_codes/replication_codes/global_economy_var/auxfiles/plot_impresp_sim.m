
if confidence_interval == 70
    pctsel = [2 4];
elseif confidence_interval == 90
    pctsel = [1 5];
end

graph_opt.linW = 3;                     % Line Width IRF
graph_opt.font_num = 50;                % Font size IRF plots
Horizon=SS.Horizon;

nvsel = length(resp_select);

 
    
if mCounter==1; colore='k'; end
if mCounter==2; colore='b'; end
if mCounter==3; colore='r'; end
if mCounter==4; colore='m'; end
if mCounter==5; colore='g'; end
if mCounter==6; colore=[ 0.3 0.3 0.3]; end
if mCounter==7; colore=[ 0.4 0.4 0.4]; end
if mCounter==8; colore=[ 0.5 0.5 0.5]; end
if mCounter==9; colore=[ 0.6 0.6 0.6]; end

if nvsel==2 || nvsel==3 || nvsel==4
nr=2;
nc=2;
end
if nvsel==5
nr=3;
nc=2;
end
if nvsel==6
nr=3;
nc=2;
end
if nvsel>=7
    nr=3;
    nc=3;
end
if nvsel>9
    nr=4;
    nc=3;
end
    
ic=1;
TIRF=0:Horizon;
%%

x_labels = {'', 'Jan', '', '', 'Apr', '', '\newline2022', 'Jul', '', '', 'Oct', '', '', 'Jan', '', '', 'Apr', '', '\newline2023', 'Jul', '', '', 'Oct', '', ''};
fig = figure('Name', 'Figure 11', 'NumberTitle', 'off');
subplot(1,2,1)
h1 = plot(TIRF,IRFSIM(3,:,3),'color','b','LineWidth',graph_opt.linW);       hold on
hold on
shade(TIRF,IRFSIM(3,:,pctsel(1)),TIRF,IRFSIM(3,:,pctsel(2)),...
        'FillType',[1 2;2 1],'Color','b','Linestyle','none');
hline(0,'-k')
title('World GDP (%)','FontSize',16,'FontWeight','bold','Interpreter','None')
ax = gca;
ax.XAxis.FontSize = 15;
ax.YAxis.FontSize = 15;
axis([-1 Horizon -2 0.5])
xticks(-1:1:Horizon)
xticklabels(x_labels)
xtickangle(0)
box on

subplot(1,2,2)
h1 = plot(TIRF,IRFSIM(4,:,3),'color','b','LineWidth',graph_opt.linW);       hold on
    hold on
    shade(TIRF,IRFSIM(4,:,pctsel(1)),TIRF,IRFSIM(4,:,pctsel(2)),...
        'FillType',[1 2;2 1],'Color','b','Linestyle','none');
hline(0,'-k')
title('World Inflation (ppt)','FontSize',16,'FontWeight','bold','Interpreter','None')
ax = gca;
ax.XAxis.FontSize = 15;
ax.YAxis.FontSize = 15;
axis([-1 Horizon -.5 2])
xticks(-1:1:Horizon)
xticklabels(x_labels)
xtickangle(0)

%grid on
%box off
box on
ax = gca;
ax.XTickMode = 'manual';
set(gcf, 'PaperUnits', 'inches');
x_width=13.3; y_width= 3.95;
set(gcf, 'PaperPosition', [0 0 x_width y_width], 'PaperSize', [x_width y_width]); %

