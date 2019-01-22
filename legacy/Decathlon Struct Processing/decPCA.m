function out=decPCA(dataMat)

%Note: dataMat is the struct containtaing the numFlies x numParameters matrix generated
% by the processed and filtered master data struct

data = dataMat.data;
dataLabels=dataMat.fields;

% Replace NaNs with the mean to introduce no additional variance
dmeans = nanmean(data,2);
mean_mat=repmat(dmeans,1,293);
datafilled=data;
datafilled(isnan(datafilled))=mean_mat(isnan(datafilled));
[coeff, score, latent] = pca(zscore(datafilled'));
latent=latent/sum(latent);
numEigenVectors95 = size(data,1)-length(cumsum(latent/sum(latent))>=0.95);
disp(strcat('95% variance captured by',num2str(numEigenVectors95),'eigenvectors'))

dataSorted = cell(size(coeff,1),size(coeff,1)*2);

for i=1:length(latent) 
    lamda=coeff(:,i);
    tempSort=cell(length(latent),2);
    tempSort(:,1)=num2cell(lamda);
    tempSort(:,2)=dataLabels;
    tempSort=sortrows(tempSort,1);
    dataSorted(:,[i*2-1 i*2])=tempSort;
end

colors(:,1,1:3) = coeff(:,1:3);
image(colors);
axis tight

out.eigenVectors = latent;
out.eigenValues = coeff;
out.dataSorted = dataSorted;
out.colors=colors;
