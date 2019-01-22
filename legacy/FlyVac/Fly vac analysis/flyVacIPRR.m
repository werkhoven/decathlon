function out=flyVacIPRR(data)

warning off MATLAB:nchoosek:LargeCoefficient;

temp=data(:);
p=(nanmean(temp)+1)/2;

% numData=length(data)/3;
numData=size(data,1);
nVector=zeros(numData,1);

for i=1:numData
    n=length(data(i,:))-sum(isnan(data(i,:)));
    nVector(i)=n;    
end

numBins=max(nVector)+1;
bins=zeros(numBins,1);
stds=zeros(numBins,1);


histData=histc(nanmean(data,2),([-inf,-1:2/(numBins-1):1]+1/(100*numBins)))';
N=sum(histData);

for i=1:length(nVector)
    
    n=nVector(i);
   
    y=zeros(n+1,1);
    for j=0:n
        y(j+1)=nchoosek(n,j)*p^j*(1-p)^(n-j);    %binom calculation
    end
    
    for j=0:n           %binom binning
        for k=0:numBins-1
            if j/n >= k/(numBins-1) && j/n < (k+1)/(numBins-1)
                bins(k+1)=bins(k+1)+y(j+1);
                P=y(j+1)/n;
                stds(k+1)=stds(k+1)+n*P*(1-P);
            end
        end
    end
end

meanProbs=bins;

histData=histData(1:end-1)/N;
histData=histData';

probs=meanProbs/N;


IPRTemp=flyVacIQR(probs,'pdf', 'IPR');
numPercs=length(IPRTemp);
expIPR=mean(flipud(IPRTemp(((numPercs-1)/2+2):numPercs))-IPRTemp(1:((numPercs-1)/2)));
IPRTemp=flyVacIQR(histData,'pdf', 'IPR');
obsIPR=mean(flipud(IPRTemp(((numPercs-1)/2+2):numPercs))-IPRTemp(1:((numPercs-1)/2)));
IPRR=log2(obsIPR/expIPR);

out=IPRR;