function Zoutperm=decPlotClusteredCorr(dataMat)

%Note: dataMat is the numFlies x numParameters matrix generated
% by the processed and filtered master data struct

data = dataMat.data;
dataLabels = dataMat.fields(:,1);
dataLabels = strrep(dataLabels,'_','-');
numLabels=length(dataLabels);

% Determine where draw lines on plot to box in values from the same assays

c(1)=0;
j=2;

for i=1:length(dataLabels)
    
    tempString = cell2mat(dataLabels(i));
    char1(i) = sum(double(tempString(1:2)));
    
    if i ~= 1 && char1(i)~=char1(i-1)
        c(j) = i;
        j=j+1;
    end
end

c(j)=length(dataLabels)+1;

datAve=repmat(nanmean(data,2),1,length(data));
datTemp=data;
datTemp(isnan(datTemp))=datAve(isnan(datTemp));
%Z=linkage(datTemp,'average','correlation');


[corr_mat p_values]=corrcoef(data','rows','pairwise');
%corr_mat=sqrt(corr_mat.^2);
Z=linkage(corr_mat,'single','spearman');
[ZH, ZT, Zoutperm]=dendrogram(Z);
p_values=p_values(Zoutperm,Zoutperm);
clusteredLabels=dataLabels(Zoutperm);

for i=1:numLabels
    for j=1:numLabels
    labelCoords(i*numLabels-(numLabels-j),1)=i;
    labelCoords(i*numLabels-(numLabels-j),2)=j;
    end
end

% Generate plot, colormap, axis labels and rotate x-labels 45deg.
figure()
imagesc(corr_mat(Zoutperm,Zoutperm))
colormap(gcf,'jet')
xticklabel_rotate([1:size(data,1)],45,clusteredLabels(1:size(data,1)),'fontsize',10)
set(gca,'Ytick',[1:size(data,1)],'YtickLabel', clusteredLabels,'fontsize',10)
set(gcf,'color','w')
%{
for i=1:numLabels
    for j=1:numLabels
        if p_values(i,j)<=0.05
            p=p_values(i,j);
            power=floor(log10(p));
            p=round(p*10^(-power))/10^(-power);
            text(labelCoords((i-1)*numLabels+1,1),labelCoords((i-1)*numLabels+j,2),num2str(p),'HorizontalAlignment','center','fontsize',7)
        end
    end
end
%}
title('Clustered Correlation Coefficients')
colorbar

% Draw rectangles around parameters belonging to the same assay
% Rectangle coordinates are given by [xCorner yCorner width height]
%{
for i =1:length(c)-1
rectangle('position',[c(i)-0.5 c(i)-0.5 c(i+1)-c(i) c(i+1)-c(i)],...
    'facecolor','none','linewidth',0.75)
end
%}

caxis([-1,1])