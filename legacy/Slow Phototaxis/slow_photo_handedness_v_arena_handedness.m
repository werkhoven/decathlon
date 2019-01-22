%% measure correlation between slowphoto handedness and arena circling handedness
[photodat,labelNames]=extractField_multiFile({'handedness';'Light';...
    'labels_table'},'Keyword','Slow Phototaxis');

%%
[arenadat,labelNames]=extractField_multiFile({'handedness';'Speed';...
    'labels_table'},'Keyword','Arena Circling');

%%

for i=1:length(photodat)
    photodat(i).handedness_Light = photodat(i).handedness;
end

maxday=0;
hcount=0;
nf = length(photodat(1).handedness_Light.mu);
corrdat = NaN(length(photodat)+length(arenadat),nf*length(photodat)+length(arenadat));

for i = 1:length(photodat)+length(arenadat)

    % grab photodat data
    if i<=length(photodat)

        tmp = photodat(i).handedness_Light.mu;
        act = nansum(photodat(i).handedness_Light.include)./length(photodat(i).handedness_Light.include) > 0.005;

        tmp(~act) = NaN;

        day = photodat(i).labels_table.Day(1);
        maxday = max([maxday day]);
        ids = photodat(i).labels_table.ID;
        
        corrdat(day,ids) = tmp;

    else

        hcount = hcount+1;
        tmp = arenadat(hcount).handedness.mu;
        act = nansum(arenadat(hcount).handedness.include)./length(arenadat(hcount).handedness.include) > 0.005;

        tmp(~act) = NaN;

        day = arenadat(hcount).labels_table.Day(1);
        ids = arenadat(hcount).labels_table.ID;

        corrdat(day+maxday,ids) = tmp;

    end

end


%% remove empty rows and columns
%corrdat = corrdat(:,1:96);
%corrdat = corrdat(:,97:192);
delRows=sum(~isnan(corrdat),2)<1;
corrdat(delRows,:)=[];
emptyCols=sum(~isnan(corrdat),1)<1;
corrdat(:,emptyCols)=[];

%%

figure();
fsz = 11;
[corrMat,p_values]=corrcoef(corrdat','rows','pairwise');
imagesc(corrMat)
egoalley=interp1([1 52 128 129 164 225 256],...
    [0 1 1; 0 .2 1; 0 .0392 .1961; .1639 .0164 0 ; 1 .1 0; 1 .9 0; 1 1 1],1:256);
colormap(egoalley);
colorbar
caxis([-1,1])
title(['Inter-experiment correlation: (n=',num2str(size(corrdat,2)),')']);


hold on
set(gca,'Xtick',1:size(corrdat,1),'Ytick',1:size(corrdat,1),'FontSize',fsz);
for i=1:size(corrMat,1)
    for j=1:size(corrMat,2)
        if i~=j
            if p_values(i,j)<0.05
            text(i,j-0.2,num2str(corrMat(i,j),2),...
                'HorizontalAlignment','center','FontSize',5,'FontUnits','normalized')
            text(i,j+0.2,['(p=' num2str(p_values(i,j),'%2.1e') ')'],...
                'HorizontalAlignment','center','FontSize',5,'FontUnits','normalized');
            end
        end
    end
end
hold off
set(gca,'fontsize', fsz);