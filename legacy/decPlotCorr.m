function out=decPlotCorr(dataMat)

%Note: dataMat is the numFlies x numParameters matrix generated
% by the processed and filtered master data struct

dataStruct = dataMat.data;
dataLabels = dataMat.fields(:,1);
dataLabels = strrep(dataLabels,'_','-');

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
[corr_mat p_values]=corrcoef(dataStruct','rows','pairwise');
   
% Generate plot, colormap, axis labels and rotate x-labels 45deg.
figure()
imagesc(corr_mat)
colormap(gcf,'jet')
xticklabel_rotate([1:size(dataStruct,1)],45,dataLabels(1:size(dataStruct,1)),'fontsize',14)
set(gca,'Ytick',[1:size(dataStruct,1)],'YtickLabel', dataLabels,'fontsize',14)

title('Decathlon Correlation Coefficients')
colorbar

% Draw rectangles around parameters belonging to the same assay
% Rectangle coordinates are given by [xCorner yCorner width height]
for i =1:length(c)-1
rectangle('position',[c(i)-0.5 c(i)-0.5 c(i+1)-c(i) c(i+1)-c(i)],...
    'facecolor','none','linewidth',0.75)
end

caxis([-1,1])




