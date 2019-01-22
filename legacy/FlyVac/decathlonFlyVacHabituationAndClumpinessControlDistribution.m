function out=decathlonFlyVacHabituationAndClumpinessControlDistribution(data,nReps,active)

numFlies=size(data,1)/3;
data=cell2mat(data(3*(1:numFlies),7:46))/1000;

out.bootstrap=zeros(nReps,2);

for i=1:nReps;
   
    tempData=zeros(1,40);
    
    for j=1:40
       tempData(j)=data(ceil(rand()*numFlies),j); 
    end
    
    X=1:40;
    nanLoc = find(isnan(tempData)==1);
    X(nanLoc)=[];
    tempData(nanLoc)=[];
    linCoeffs=polyfit(X,tempData,1);
    out.bootstrap(i,1)=linCoeffs(1);
    out.bootstrap(i,2)=mad(tempData)/nanmean(tempData);
end

out.observed=zeros(numFlies,2)

for i=1:numFlies
   
    tempFlyData=data(i,:);
    X=1:40;
    nanLoc = find(isnan(tempData)==1);
    X(nanLoc)=[];
    tempFlyData(nanLoc)=[];
    linCoeffs=polyfit(X,tempFlyData,1);
    out.observed(i,1)=linCoeffs(1);
    out.observed(i,2)=mad(tempFlyData)/nanmean(tempFlyData);
    
end