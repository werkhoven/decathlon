function out=decCorrBootstrap(processed_data_mat,nReps)

data=processed_data_mat.data;
numFlies=length(data);
numParameters=size(data,1);
avgCorr=zeros(nReps,1);

for k=1:nReps

simMat=zeros(numParameters,numFlies);

    for i=1:numFlies
        for j=1:numParameters
            
            index=ceil(rand()*numFlies);
            simMat(j,i)=data(j,index);
            
        end
    end
    
    corr=corrcoef(simMat','rows','pairwise');
    %corr=sqrt(corr.^2);
    corr(corr==1)=[];
    avgCorr(k)=mean(mean(corr));
    
end

mini=min(avgCorr);
maxi=max(avgCorr);
bins=linspace(-.1,.1,71);
plot(hist(avgCorr,bins)/length(avgCorr))
bins
set(gca,'Xtick',[1:2:71],'XtickLabel',bins(1:2:71))

% Plot observed
hold on
observed_corr=corrcoef(data','rows','pairwise');
%observed_corr=sqrt(observed_corr.^2);
observed_corr(observed_corr==1)=[];
observed_corr=mean(mean(observed_corr))
index=ceil(observed_corr/(max(bins)-min(bins))*length(bins));
d=observed_corr-bins(index);
add=d/((max(bins)-min(bins))/length(bins));
observed_corr=add+index
plot([observed_corr observed_corr observed_corr],[0 0.5 1],'r')

histogram=histc(avgCorr,bins)/length(avgCorr);
cumulative=cumsum(histogram);
percentile=cumulative(floor(observed_corr))

out.corr=avgCorr;
out.percentiles=cumulative;
out.bins=bins;
    