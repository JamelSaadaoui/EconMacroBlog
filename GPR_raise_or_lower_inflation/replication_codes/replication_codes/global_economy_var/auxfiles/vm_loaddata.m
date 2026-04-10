% newData1 = importdata(strcat('vardata_works','.txt'));
% % Create new variables in the base workspace from those fields.
% vars = fieldnames(newData1);
% for i = 1:length(vars)
%     assignin('base', vars{i}, newData1.(vars{i}));
% end
% YYdata = newData1.data;
% text = newData1.textdata;
% clear data textdata
% nDate = datenum(text(2:end,1));
% [~,i_var] = ismember(i_var_str,text(1,2:end));
% % 

T = nperiods(str_sample_init,str_sample_end,Tdelta,nlags);




nDate = datenum(text0(2:end,1));


[~,i_var] = ismember(i_var_str,(text0(1,2:end)));
YYdata = Y0;




%************************************************/
% RETRIEVE POSITION OF FIRST AND LAST OBSERVATION/
%************************************************/

sample_init = datenum(str_sample_init, 'yyyy-mm-dd');
sample_end = datenum(str_sample_end, 'yyyy-mm-dd');

[~, sample_init_row] = ismember(sample_init,nDate,'rows');
[~, sample_end_row] = ismember(sample_end,nDate,'rows');



%****************************************************/
% SELECT APPROPRIATE ROWS AND COLUMNS OF DATA MATRIX /
%****************************************************/
YYorig = YYdata(sample_init_row:sample_end_row,i_var);
nDateSel = nDate(sample_init_row:sample_end_row);
TT=sample_end_row-sample_init_row+1;





%************************************************
% Removes trend from selected variables
%************************************************


cconst = ones(size(YYorig,1),1);
ttrend = cumsum(cconst);
xdet0 = [cconst ];
xdet1 = [cconst ttrend];
xdet2 = [cconst ttrend ttrend.*ttrend ];

demeanYY = demean(YYorig);


betalog0 = (xdet0'*xdet0)\(xdet0'*log(YYorig));      % Compute OLS estimates
logtrends0 = xdet0*betalog0;
detlogYY0 = log(YYorig)-logtrends0;

betalog1 = (xdet1'*xdet1)\(xdet1'*log(YYorig));      % Compute OLS estimates
logtrends1 = xdet1*betalog1;
detlogYY1 = log(YYorig)-logtrends1;

betalog2 = (xdet2'*xdet2)\(xdet2'*log(YYorig));      % Compute OLS estimates
logtrends2 = xdet2*betalog2;
detlogYY2 = log(YYorig)-logtrends2;

betalev0 = (xdet0'*xdet0)\(xdet0'*(YYorig));      % Compute OLS estimates
levtrends0 = xdet0*betalev0;
detlevYY0 = (YYorig)-levtrends0;

betalev1 = (xdet1'*xdet1)\(xdet1'*(YYorig));      % Compute OLS estimates
levtrends1 = xdet1*betalev1;
detlevYY1 = (YYorig)-levtrends1;

betalev2 = (xdet2'*xdet2)\(xdet2'*(YYorig));      % Compute OLS estimates
levtrends2 = xdet2*betalev2;
detlevYY2 = (YYorig)-levtrends2;

betalogdiff = (xdet0'*xdet0)\(xdet0'*(diff1zero(log(YYorig),1)));      % Compute OLS estimates
difflogtrend0 = xdet0*betalogdiff;
detlogdiffYY0 = diff1zero(log(YYorig),1)-difflogtrend0;

betalevdiff = (xdet0'*xdet0)\(xdet0'*(diff1zero((YYorig),1)));      % Compute OLS estimates
difflevtrend0 = xdet0*betalevdiff;
detlevdiffYY0 = diff1zero((YYorig),1)-difflevtrend0;


% Need to reset YY before running loop
YY=[];
trends=[];

YY(:,ilevdem) = demeanYY(:,ilevdem);
trends(:,ilevdem) = YYorig(:,ilevdem)-demeanYY(:,ilevdem);

YY(:,ilevdet1) = detlevYY1(:,ilevdet1);
trends(:,ilevdet1) = levtrends1(:,ilevdet1);

YY(:,ilevdet2) = detlevYY2(:,ilevdet2);
trends(:,ilevdet2) = levtrends2(:,ilevdet2);

YY(:,ilogdet0) = 100*detlogYY0(:,ilogdet0);
trends(:,ilogdet0) = exp(logtrends0(:,ilogdet0));

YY(:,ilogdet1) = 100*detlogYY1(:,ilogdet1);
trends(:,ilogdet1) = exp(logtrends1(:,ilogdet1));

YY(:,ilogdet2) = 100*detlogYY2(:,ilogdet2);
trends(:,ilogdet2) = exp(logtrends2(:,ilogdet2));

YY(:,ilogdiff) = detlogdiffYY0(:,ilogdiff);
trends(:,ilogdiff) = exp(logtrends0(:,ilogdiff));

YY(:,ilevdiff) = detlevdiffYY0(:,ilevdiff);
trends(:,ilevdiff) = levtrends0(:,ilevdiff);


if numel(iloghp)>0
    for i=iloghp
        [logtrendhp(:,iloghp), YY(:,iloghp) ]=one_sided_hp_filter_kalman(100*log(YYorig(:,iloghp)),1000000);
    end
    trends(:,iloghp) = exp(logtrendhp(:,iloghp)/100);
end

if numel(ihp)>0
    for i=ihp
        [trendhp(:,ihp), YY(:,ihp) ]=one_sided_hp_filter_kalman(YYorig(:,ihp),1000000); 
    end
    trends(:,ihp) = trendhp(:,ihp);
end

% if fflag_spike==1 
%     [spikes_GPR, DGPR_just_spikes, iS, nS, nT ] = get_spikes(YYorig(:,1),0,0) ;
%     % test = zeros(size(YY,1),1);
%     % test(iS) = YY(iS,1);
%     YY(:,1)= DGPR_just_spikes;
% end

warning off


if Tdelta==1/12
Tvec0 = str2num(str_sample_init(1:4))+(str2num(str_sample_init(6:7))-1)*Tdelta;
end
if Tdelta==1/4
Tvec0 = str2num(str_sample_init(1:4))+(str2num(str_sample_init(6:7))-3)*Tdelta;
end

tt=Tvec0:Tdelta:Tvec0+(TT-1)*Tdelta;
NN=size(YYorig,2);

if do_plot_data==1
    
for i=1:NN

    figure(1+mCounter*100)
    
    if NN>=8
        JJ=ceil(NN/2);
        KK=2;
    else
        JJ=NN;
        KK=1;
    end
    
    subplot(JJ,2*KK,2*i-1)
    plot(tt,[ YYorig(:,i) trends(:,i) ],'Linewidth',2) 
    ylabel(i_var_str(:,i),'Interpreter','none')
    axis tight
    grid on
%     if i==1
%         title('Original variable and trend')
%     end
    
    subplot(JJ,2*KK,2*i)
    plot(tt,[ YY(:,i) ],'Linewidth',2) 
    axis tight
    grid on
%     if i==1
%         title('Detrended Variable entering the VAR')
%     end
    
end

end

% 
% 
% 
% 
% if do_plot_data_original==1
%     
% for i=1:NN
% 
%     figure(2+mCounter*100)
%     subplot(round(NN/2),2,i)
%     plot(tt,[ YYorig(:,i) ],'Linewidth',2) 
%     ylabel(i_var_str(:,i),'Interpreter','none')
%     axis tight
%     grid on
%         
% end
% 
% end
