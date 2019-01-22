%% extract opto data

fields = {'Optomotor';'Speed'};
[pooldat,optoLabels]=extractField_multiFile({fields{:};'labels_table'});

nf = length(pooldat(1).Optomotor.index);

%% extract circadian data

[circ,circLabels]=extractField_multiFile({'Circadian';'labels_table'});

%%



% pre-allocate large arragy for storage
corrdat = NaN(length(pooldat)+length(circ),nf*length(pooldat)+length(circ));

for i = 1:length(pooldat)+length(circ)

    % grab pooldat data
    if i<=length(pooldat)

        tmp = pooldat(i).Optomotor.index;
        act = pooldat(i).Optomotor.active;
        tmp=-tmp;

        tmp(~act) = NaN;

        day = pooldat(i).labels_table.Day(1);
        ids = pooldat(i).labels_table.ID;

        corrdat(day*stp-(stp-1),ids) = tmp;

    end

    % grab circ data
    if i<=length(circ)

        tmp = circ(i).Circadian.avg;
        act = circ(i).Circadian.avg > 0.1;

        tmp(~act) = NaN;

        day = circ(i).labels_table.Day(1);
        ids = circ(i).labels_table.ID;

        corrdat(day*stp-(stp-2),ids) = tmp;

    end

end

%% remove empty rows and columns
delRows = find(any(~isnan(corrdat),2),1,'last') + 1;
corrdat(delRows:end,:)=[];
emptyCols=sum(~isnan(corrdat),1)<1;
corrdat(:,emptyCols)=[];


perm = [1:2:size(corrdat,1) 2:2:size(corrdat,1)];
corrdat=corrdat(perm,:);



%% plot correlation matrix

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

%% SPEED correlation

% pre-allocate large arragy for storage
corrdat = NaN(length(pooldat)+length(circ),nf*length(pooldat)+length(circ));

for i = 1:length(pooldat)+length(circ)

    % grab pooldat data
    if i<=length(pooldat)

        tmp = nanmean(pooldat(i).Speed.data);
        act = tmp > 0.1;

        tmp(~act) = NaN;

        day = pooldat(i).labels_table.Day(1);
        ids = pooldat(i).labels_table.ID;

        corrdat(day*stp-(stp-1),ids) = tmp;

    end

    % grab circ data
    if i<=length(circ)

        tmp = circ(i).Circadian.avg;
        act = circ(i).Circadian.avg > 0.1;

        tmp(~act) = NaN;

        day = circ(i).labels_table.Day(1);
        ids = circ(i).labels_table.ID;

        corrdat(day*stp-(stp-2),ids) = tmp;

    end

end

%% remove empty rows and columns
delRows = find(any(~isnan(corrdat),2),1,'last') + 1;
corrdat(delRows:end,:)=[];
emptyCols=sum(~isnan(corrdat),1)<1;
corrdat(:,emptyCols)=[];


perm = [1:2:size(corrdat,1) 2:2:size(corrdat,1)];
corrdat=corrdat(perm,:);



%% plot correlation matrix

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

% create scatter plot