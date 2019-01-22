%% extract circadian metrics separately

circ = [];
del = [];

for i = 1:length(dec)
    
    if strcmp(dec(i).name,'Circadian')
        circ = [circ dec(i)];
        del = [del i];
    end
end

% create copy of original data struct without circadian metrics

dex = dec;
dex(del)=[];

%%

% query max number of data points
nPCs = 0;
for i = 1:length(circ)
    circ(i).n = length(circ(i).ID);
    nPCs = nPCs + circ(i).PCA.nKeep;
end


% initialize data mat (observations x variables) 
dMat = NaN(max([circ.n]),nPCs);
dFields = cell(nPCs,1);
fct = 0;
nDays = max([circ.day]);

for j = 1:3
    for i=1:length(circ)
        fct = fct + 1;
        if i<=length(circ) && ~isempty(circ(i).fields)

            nk = circ(i).PCA.nKeep;
            if j<=nk
                
                dMat(circ(i).ID,fct) = circ(i).PCA.score(:,j);
                dMat(circ(i).ID(~circ(i).data.filter),fct) = NaN;
                dFields(fct) = {[circ(i).name ' PC-' num2str(j) '(' num2str(circ(i).day) ')']};
                
            end

        end

    end
end

del = ~any(~isnan(dMat));
dMat(:,del)=[];
dFields(del)=[];

%%

%%

f = figure();
[r,p] = corrcoef(dMat,'rows','pairwise');
r(isnan(r))=0;
p(isnan(p))=1;
clusteredLabels=dFields;


imh = imagesc(r);
egoalley=interp1([1 52 128 129 164 225 256],...
    [0 1 1; 0 .2 1; 0 .0392 .1961; .1639 .0164 0 ; 1 .1 0; 1 .9 0; 1 1 1],1:256);
nanticoke=interp1([1 52 128 164 225 255 256],[0 1 1; 0 .2 1; 0 0 0; 1 .1 0; 1 .5 0; 1 1 0; 1 1 1],1:256);
colormap(nanticoke);
colorbar
caxis([-1,1]);

hold on
set(gca,'Xtick',1:size(r,1),'Ytick',1:size(r,1),'FontSize',fsz);
for i=1:size(r,1)
    for j=1:size(r,2)
        if i~=j && abs(r(i,j))>0.25
            text(i,j,num2str(r(i,j),2),...
                'HorizontalAlignment','center','FontSize',2.5,'FontUnits','normalized')
        end
    end
end
hold off


% format field labels for display
for i = 1:length(clusteredLabels)
    tmp = clusteredLabels{i};
    tmp(tmp=='_')=' ';
    clusteredLabels(i)={tmp};
end
set(gca,'Ytick',[1:nFields],'YtickLabel', clusteredLabels,'fontsize',10);
set(gca,'XTick',1:length(dFields),'XTickLabel',clusteredLabels,'fontsize',10,'XTickLabelRotation',45);
title('decathlon correlation matrix - circadian PCs only');

%% look at correlation in metric loadings across days

% query max number of data points
nPCs = 0;
for i = 1:length(circ)
    nPCs = nPCs + circ(i).PCA.nKeep;
end


% initialize data mat (observations x variables) 
dMat = NaN(7,nPCs);
dFields = cell(nPCs,1);
fct = 0;
nDays = max([circ.day]);

for j = 1:3
    for i=1:length(circ)
        fct = fct + 1;
        if i<=length(circ) && ~isempty(circ(i).fields)

            nk = circ(i).PCA.nKeep;
            if j<=nk
                
                dMat(:,fct) = circ(i).PCA.coef(:,j);
                dFields(fct) = {[circ(i).name ' PC-' num2str(j) '(' num2str(circ(i).day) ')']};
                
            end

        end

    end
end

del = ~any(~isnan(dMat));
dMat(:,del)=[];
dFields(del)=[];

%%
f = figure();
[r,p] = corrcoef(dMat,'rows','pairwise');
r(isnan(r))=0;
p(isnan(p))=1;
clusteredLabels=dFields;


imh = imagesc(r);
egoalley=interp1([1 52 128 129 164 225 256],...
    [0 1 1; 0 .2 1; 0 .0392 .1961; .1639 .0164 0 ; 1 .1 0; 1 .9 0; 1 1 1],1:256);
nanticoke=interp1([1 52 128 164 225 255 256],[0 1 1; 0 .2 1; 0 0 0; 1 .1 0; 1 .5 0; 1 1 0; 1 1 1],1:256);
colormap(nanticoke);
colorbar
caxis([-1,1]);

hold on
set(gca,'Xtick',1:size(r,1),'Ytick',1:size(r,1),'FontSize',fsz);
for i=1:size(r,1)
    for j=1:size(r,2)
        if i~=j && abs(r(i,j))>0.25
            text(i,j,num2str(r(i,j),2),...
                'HorizontalAlignment','center','FontSize',2.5,'FontUnits','normalized')
        end
    end
end
hold off


% format field labels for display
for i = 1:length(clusteredLabels)
    tmp = clusteredLabels{i};
    tmp(tmp=='_')=' ';
    clusteredLabels(i)={tmp};
end
set(gca,'Ytick',[1:nFields],'YtickLabel', clusteredLabels,'fontsize',10);
set(gca,'XTick',1:length(dFields),'XTickLabel',clusteredLabels,'fontsize',10,'XTickLabelRotation',45);
title('day to day correlation in circadian metric loadings');

hold on
plot([0 length(dMat)+0.5],[10.5 10.5],'-k','Linewidth',2);
plot([10.5 10.5],[0 length(dMat)+0.5],'-k','Linewidth',2);
plot([19.5 19.5],[0 length(dMat)+0.5],'-k','Linewidth',2);
plot([0 length(dMat)+0.5],[19.5 19.5],'-k','Linewidth',2);
hold off

%% plot non-circadian metrics separately

% query max number of data points
nPCs = 0;
for i = 1:length(dex)
    dex(i).n = length(dex(i).ID);
    nPCs = nPCs + dex(i).PCA.nKeep;
end

% initialize data mat (observations x variables) 
dMat = NaN(max([dex.n]),nPCs);
dFields = cell(nPCs,1);
fct = 0;
nDays = max([dex.day]);

for i=1:length(dex)
    
    if i<=length(dex) && ~isempty(dex(i).fields)

        nk = dex(i).PCA.nKeep;
        dMat(dex(i).ID,fct+1:fct+nk) = dex(i).PCA.score(:,1:nk);
        dMat(dex(i).ID(~dex(i).data.filter),fct+1:fct+nk) = NaN;
        
        for j=1:nk
            fct=fct+1;
            dFields(fct) = {[dex(i).name ' PC-' num2str(j) '(' num2str(dex(i).day) ')']};
        end
        
    end
    
    
end

% calculate number of samples for each pairwise comparison
n = NaN(nPCs);
for i=1:nPCs
    for j=1:nPCs       
        if i~=j
            n(i,j) = sum(~isnan(dMat(:,i)) & ~isnan(dMat(:,j)));
        end
    end
end

%%

f = figure();
[r,p] = corrcoef(dMat,'rows','pairwise');
r(isnan(r))=0;
p(isnan(p))=1;
Z=linkage(r,'single','spearman');
[ZH, ZT, Zoutperm]=dendrogram(Z,length(r));
r=r(Zoutperm,Zoutperm);
p=p(Zoutperm,Zoutperm);
n=n(Zoutperm,Zoutperm);
clusteredLabels=dFields(Zoutperm);


imh = imagesc(r);
egoalley=interp1([1 52 128 129 164 225 256],...
    [0 1 1; 0 .2 1; 0 .0392 .1961; .1639 .0164 0 ; 1 .1 0; 1 .9 0; 1 1 1],1:256);
nanticoke=interp1([1 52 128 164 225 255 256],[0 1 1; 0 .2 1; 0 0 0; 1 .1 0; 1 .5 0; 1 1 0; 1 1 1],1:256);
colormap(nanticoke);
colorbar
caxis([-1,1]);

hold on
set(gca,'Xtick',1:size(r,1),'Ytick',1:size(r,1),'FontSize',fsz);
for i=1:size(r,1)
    for j=1:size(r,2)
        if i~=j && abs(r(i,j))>0.25
            text(i,j-0.22,num2str(r(i,j),2.5),...
                'HorizontalAlignment','center','FontSize',2,'FontUnits','normalized')
            text(i,j+0.2,[num2str(p(i,j),'%2.1e')],...
                'HorizontalAlignment','center','FontSize',1.5,'FontUnits','normalized');
        end
    end
end
hold off


% format field labels for display
for i = 1:length(clusteredLabels)
    tmp = clusteredLabels{i};
    tmp(tmp=='_')=' ';
    clusteredLabels(i)={tmp};
end
set(gca,'Ytick',[1:nFields],'YtickLabel', clusteredLabels,'fontsize',10);
set(gca,'XTick',1:length(dFields),'XTickLabel',clusteredLabels,'fontsize',10,'XTickLabelRotation',45);
title('decathlon correlation matrix - hierachically clustered assay PCs');