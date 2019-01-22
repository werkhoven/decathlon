% get led ymaze data
[pooldat,labelNames]=extractField_multiFile({'LightChoice';'Turns'});

%%
pData = NaN(length(pooldat(1).LightChoice.pBias),length(pooldat));
active = false(length(pooldat(1).LightChoice.pBias),length(pooldat));

for i = 1:length(pooldat)
    active(:,i) = pooldat(i).LightChoice.active;
    pData(active(:,i),i) = pooldat(i).LightChoice.pBias(active(:,i));
end

[r,p]=corrcoef(pData,'rows','pairwise');

%% plot result

f=figure(); 
[r,p]=corrcoef([pData(:,1) pData(:,2)],'rows','pairwise');
sh=scatter(pData(:,1),pData(:,2),'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.5 0.5 0.5]);
sh.Parent.XLim = [0 1];
sh.Parent.YLim = [0 1];
xlabel('day 1 light choice probability');
ylabel('day 2 light choice probability');
dim = [.65 .78 .1 .1];
str = ['r = ' num2str(round(r(2,1)*100)/100) ', p = ' num2str(round(p(2,1)*10000)/10000)...
    ' (n=' num2str(sum(~any(~active,2))) ')'];
ah=annotation('textbox',dim,'String',str,'FitBoxToText','on');
ah.BackgroundColor=[1 1 1];
uistack(ah,'top');
title('LED ymaze - light choice probability');


%%

tData = NaN(length(pooldat(1).Turns.rBias),length(pooldat));

for i = 1:length(pooldat)
    tData(active(:,i),i) = pooldat(i).Turns.rBias(active(:,i));
end

[r,p]=corrcoef(tData,'rows','pairwise');

%% plot result

f=figure(); 
[r,p]=corrcoef([tData(:,1) tData(:,2)],'rows','pairwise');
sh=scatter(tData(:,1),tData(:,2),'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.5 0.5 0.5]);
sh.Parent.XLim = [0 1];
sh.Parent.YLim = [0 1];
xlabel('day 1 right turn probability');
ylabel('day 2 right turn probability');
dim = [.65 .78 .1 .1];
str = ['r = ' num2str(round(r(2,1)*100)/100) ', p = ' num2str(round(p(2,1)*10000)/10000)...
    ' (n=' num2str(sum(~any(~active,2))) ')'];
ah=annotation('textbox',dim,'String',str,'FitBoxToText','on');
ah.BackgroundColor=[1 1 1];
uistack(ah,'top');
title('LED ymaze - right turn probability');