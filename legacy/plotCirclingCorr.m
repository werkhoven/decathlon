function plotCirclingCorr(data)

%% Plot correlation matrix
[corrMat,p_values]=corrcoef(data','rows','pairwise');
imagesc(corrMat);
nanticoke=interp1([1 52 103 164 225 256],[0 1 1; 0 .2 1; 0 0 0; 1 .1 0; 1 .9 0; 1 1 1],1:256);
colormap(nanticoke);
colorbar
caxis([-1,1])
title(['day 1 to day ' num2str(size(data,1)) ' handedness correlation (n=' num2str(size(data,2)) ')'])

% Create scatter plots
nPlots=size(data,1)^2/2-size(data,1)/2;
dim1=ceil(nPlots/2);
dim2=ceil(nPlots/dim1);
figure();
ct=1;
lim=double(max(max((abs(data)))));

hold on
for i=1:size(data,1)
    for j=i:size(data,1)

    if i~=j
    subplot(dim1,dim2,ct);
    scatter(data(i,:),data(j,:),'r.','Linewidth',3);
    f = polyfit(data(i,:),data(j,:),1);
    xlabel(['day ' num2str(i) ' \mu'])
    ylabel(['day ' num2str(i+1) ' \mu'])
    hold on
    plot(-lim:lim/10:lim,polyval(f,-lim:lim/10:lim),'k-');
    axis([-lim lim -lim lim]);
    text(-lim+0.1*lim,lim-0.1*lim,['r=' num2str(round(corrMat(i,j)*100)/100)]);
    ct=ct+1;
    end

    end
end

h=gcf;
mtit(h,['day 1 to day ' num2str(size(data,1)) ' handedness correlation'])