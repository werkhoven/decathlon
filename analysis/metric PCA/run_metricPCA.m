%% Get parent directory of all decathlon files

[fDir] = uigetdir('C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data',...
    'Select directory containing expmt structs to be analyzed');
keyargs = {'_Y-maze';'LED Y-maze';'Slow Phototaxis';'Optomotor';'Circadian';'Olfaction';'Arena Circling'};

% prompt user to select save path
[sd] = uigetdir('C:\Users\debivort\Documents\MATLAB\Decathlon Raw Data',...
'Select directory for PCA figures to save');
sd = [sd '\'];
%%
dec=[];
for i = 6:length(keyargs)
    datstruct = decMetricPCA('Dir',fDir,'Keyword',keyargs{i},'SaveDir',[sd keyargs{i}]);  
    dec = [dec datstruct'];
end


%% create data matrix of PCA data and create labels array

% query max number of data points
nPCs = 0;
for i = 1:length(dec)
    dec(i).n = length(dec(i).ID);
    nPCs = nPCs + dec(i).PCA.nKeep;
end

% initialize data mat (observations x variables) 
dMat = NaN(max([dec.n]),nPCs);
dFields = cell(nPCs,1);
fct = 0;
nDays = max([dec.day]);

for i=1:length(dec)
    
    if i<=length(dec) && ~isempty(dec(i).fields)

        nk = dec(i).PCA.nKeep;
        dMat(dec(i).ID,fct+1:fct+nk) = dec(i).PCA.score(:,1:nk);
        dMat(dec(i).ID(~dec(i).data.filter),fct+1:fct+nk) = NaN;
        
        for j=1:nk
            fct=fct+1;
            dFields(fct) = {[dec(i).name ' PC-' num2str(j) '(' num2str(dec(i).day) ')']};
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

%% create plot for number of samples

figure();
imh = imagesc(n);
egoalley=interp1([1 52 128 129 164 225 256],...
    [0 1 1; 0 .2 1; 0 .0392 .1961; .1639 .0164 0 ; 1 .1 0; 1 .9 0; 1 1 1],1:256);
colormap('cool');
colorbar
%caxis([-1,1]);

fsz = 10;
hold on
set(gca,'Xtick',1:size(r,1),'Ytick',1:size(r,1),'FontSize',fsz);
for i=1:size(n,1)
    for j=1:size(n,2)
        if i~=j
            text(i,j-0.2,num2str(n(i,j)),...
                'HorizontalAlignment','center','FontSize',3,'FontUnits','normalized');
        end
    end
end
hold off
set(gca,'fontsize', fsz);
set(gca,'Ytick',[1:nFields],'YtickLabel', clusteredLabels,'fontsize',10);
set(gca,'XTick',1:length(dFields),'XTickLabel',clusteredLabels,'fontsize',10,'XTickLabelRotation',45);
title('decathlon pairwise sample num - hierachically clustered assay PCs');
