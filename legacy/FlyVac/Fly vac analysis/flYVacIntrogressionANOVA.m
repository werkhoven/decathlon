function out=flYVacIntrogressionANOVA(data,nList,iters)

numGroups=length(nList);
numData=size(data,1);

metricHist=zeros(iters,1);
probHist=zeros(iters,1);

for i=1:iters
    
    IPRRList=zeros(numGroups,1);
    ProbList=zeros(numGroups,1);
   
    for j=1:numGroups
        
        which=randperm(numData);
        which=which(1:nList(j));
        tempData=data(which,:);             
        temp=flyVacAnalysis(tempData,1,0);
        
        IPRRList(j)=temp.IPRR;
        ProbList(j)=temp.P;
    end
    
    metricHist(i)=sum(abs(IPRRList-mean(IPRRList)));
    probHist(i)=sum(abs(ProbList-mean(ProbList)));
    disp([i metricHist(i) probHist(i)]);
    
end


out.m=metricHist;
out.p=probHist;