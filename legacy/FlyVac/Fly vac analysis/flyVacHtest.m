function out=flyVacHtest(data,numIter)

dataConcat=[];
numExperiments=size(data,2);
numTrials=40;

for i=1:numExperiments
    dataConcat=[dataConcat;data{i}];
end



SDRmetricList=zeros(numIter,1);
VBEmetricList=zeros(numIter,1);

for j=1:numIter
    j
    
    dataConcatShuffle=dataConcat(randperm(size(dataConcat,1)),:);
    
    currentRow=1;
    SDRList=zeros(numExperiments,1);
    VBEList=zeros(numExperiments,1);
    for i=1:numExperiments
        
        numRows=size(data{i},1)-1;
        dataTemp=dataConcatShuffle(currentRow:currentRow+numRows,:);
        currentRow=currentRow+numRows+1;
        resultsTemp=flyVacAnalysis(dataTemp,1,0);
        SDRList(i)=log2(resultsTemp.obStd/resultsTemp.expStd);
        VBEList(i)=log2((resultsTemp.obsIQR(2)-resultsTemp.obsIQR(1))/(resultsTemp.expIQR(2)-resultsTemp.expIQR(1)));
        
    end
    
    SDRmetric=sum(abs(SDRList-mean(SDRList)));
    SDRmetricList(j)=SDRmetric;
    VBEmetric=sum(abs(VBEList-mean(VBEList)));
    VBEmetricList(j)=VBEmetric;
    
end


SDRList=zeros(numExperiments,1);
VBEList=zeros(numExperiments,1);
for i=1:numExperiments
    dataTemp=data{i};
    resultsTemp=flyVacAnalysis(dataTemp,1,0);
    SDRList(i)=log2(resultsTemp.obStd/resultsTemp.expStd);
    VBEList(i)=log2((resultsTemp.obsIQR(2)-resultsTemp.obsIQR(1))/(resultsTemp.expIQR(2)-resultsTemp.expIQR(1)));
end
obsSDRMetric=sum(abs(SDRList-mean(SDRList)));
obsVBEMetric=sum(abs(VBEList-mean(VBEList)));


out.SDRp=sum(SDRmetricList>=obsSDRMetric)/numIter;
out.VBEp=sum(VBEmetricList>=obsVBEMetric)/numIter;
out.SDRmetrics=SDRmetricList;
out.VBEmetrics=VBEmetricList;