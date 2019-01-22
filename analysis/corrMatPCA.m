function corrMatPCA(data,labels)

for i = 1:length(labels)
    tmp = labels{i};
    tmp(tmp=='_')=' ';
    labels(i) = {tmp};
end


%% normalize values in the data matrix

mus = NaN(length(labels),1);
sigma = mus;
cMat = data;

for i = 1:length(mus)
    mus(i) = nanmean(data(:,i));
    sigma(i) = nanstd(data(:,i));
    cMat(~isnan(data(:,i)),i) = (data(~isnan(data(:,i)),i) - mus(i))./sigma(i);
end

cMat = fillWithRegressedValues(cMat);

%%
[coef,sc,lat] = pca(cMat);
lat = lat./sum(lat);

% bootstrap resample data for PCA
rawPCA=decathlonpcaresamp(cMat);
zPlotRaw = sum(rawPCA.zMatrix);

% bootstrap resample shuffled data for PCA null model
nReps = 15;
zPlotShuf = NaN(nReps,length(zPlotRaw));
for i = 1:nReps
    
    shufMat = NaN(size(cMat));
    for k = 1:size(cMat,2)
        shufMat(:,k) = cMat(randperm(size(cMat,1)),k);
    end
    
    shufPCA=decathlonpcaresamp(shufMat);
    zPlotShuf(i,:) = sum(shufPCA.zMatrix);
    
end


figure();
plot(sum(rawPCA.zMatrix),'k','Linewidth',2);
hold on
[mu,~,ci95,~]=normfit(zPlotShuf);
plot(mu,'Color',[.5 .5 .5],'Linewidth',2);
vx = [1:length(mu) fliplr(1:length(mu))];
vy = [ci95(1,:) fliplr(ci95(2,:))];
hold on
ph=patch(vx,vy,[0.8 0.8 0.8]);
uistack(ph,'bottom');


hold on
plot(log(median(slat,2)),'ro','MarkerFaceColor',[1 0 0],'MarkerSize',2);
nKeep = sum((lat-median(slat,2))>0.00001);
plot(1:nKeep,log(lat(1:nKeep)),'bo','Linewidth',1,'MarkerFaceColor',[0 0 1],'MarkerSize',2.5);
plot(nKeep+1:length(lat),log(lat(nKeep+1:end)),'ko','Linewidth',1,'MarkerFaceColor',[0.75 .75 .75],'MarkerSize',2.5);


xlabel('no. of eigenvalues');
ylabel('log(eigenvalue)');
legend({'shuffled data',['PCs above shuffled (n=' num2str(nKeep) ')']});

%% show ranked loadings for each PC

rank = NaN(length(labels));
loading = rank;

for i = 1:length(labels)
    [v,p] = sort(coef(:,i));
    rank(:,i) = fliplr(p');
    loading(:,i) = fliplr(v');
end

%%
range = 1:length(loading);

for idx=1:5
    
    figure();
    plot(loading(range,idx),'ko','Linewidth',2,'MarkerFaceColor',[.7 .7 .7]);
    hold on
    plot([0 length(range)],[0 0],'r--');
    ylabel('coefficient value');
    set(gca,'XTick',1:length(range),'XTickLabel',labels(rank(range,idx)),'XTickLabelRotation',45);
    title(['Metric loadings for PC no. ' num2str(idx)]);

end

%%

D = NaN(size(data,1));

for i = 1:size(D,1)
    for j = 1:size(D,2)
        
        if i~=j
            D(i,j) = sqrt(sum((cMat(i,:) - cMat(j,:)).^2));
        else
            D(i,j) = 0;
        end
    end
end
    
    