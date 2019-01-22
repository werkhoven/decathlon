%%
f={'handedness_Blank';'handedness_Light';'handedness_First';'handedness_Second'};
sf='mu';
[pooldat,labels]=extractField_multiFile(f,'Subfield',sf);

%%

ntot = 0;
for i=1:length(pooldat)
    ntot = ntot + length(pooldat(i).handedness_Light.mu);
end

dark = NaN(ntot,1);
light = NaN(ntot,1);
first = NaN(ntot,1);
second = NaN(ntot,1);

for i=1:length(pooldat)
    n=length(pooldat(i).(f{1}).mu);
    dark((i-1)*n+1:i*n)=pooldat(i).(f{1}).mu;
    light((i-1)*n+1:i*n)=pooldat(i).(f{2}).mu;
    first((i-1)*n+1:i*n)=pooldat(i).(f{3}).mu;
    second((i-1)*n+1:i*n)=pooldat(i).(f{4}).mu;
end

%% plot result

f=figure(); 
[r,p]=corrcoef([dark light],'rows','pairwise');
sh=scatter(dark,light,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.5 0.5 0.5]);
sh.Parent.XLim = [-1 1];
sh.Parent.YLim = [-1 1];
xlabel('stimulus OFF \mu');
ylabel('stimulus ON \mu');
dim = [.65 .78 .1 .1];
str = ['r = ' num2str(round(r(2,1)*100)/100) ', p = ' num2str(round(p(2,1)*10000)/10000)...
    ' (n=' num2str(ntot) ')'];
ah=annotation('textbox',dim,'String',str,'FitBoxToText','on');
ah.BackgroundColor=[1 1 1];
uistack(ah,'top');
title('slow phototaxis - handedness');

%% plot result

f=figure(); 
[r,p]=corrcoef([first second],'rows','pairwise');
sh=scatter(first,second,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.5 0.5 0.5]);
sh.Parent.XLim = [-1 1];
sh.Parent.YLim = [-1 1];
xlabel('first half \mu');
ylabel('second half \mu');
dim = [.65 .78 .1 .1];
str = ['r = ' num2str(round(r(2,1)*100)/100) ', p = ' num2str(round(p(2,1)*10000)/10000)...
    ' (n=' num2str(ntot) ')'];
ah=annotation('textbox',dim,'String',str,'FitBoxToText','on');
ah.BackgroundColor=[1 1 1];
uistack(ah,'top');
title('slow phototaxis - handedness');



