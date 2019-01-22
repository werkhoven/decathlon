function out=flyVacCorConv(data)


maxN=size(data,1);
N=20;

results=zeros(N,length(10:5:maxN));

for j=1:N
    
    iTemp=1;
    for i=10:5:maxN
        disp([j i]);
        
%         which=randperm(maxN);
%         which=which(1:i);
which=ceil(rand(i,1)*maxN);
        newData=data(which,:);
        
        temp=flyVacAnalysis(newData,1,0);
        results(j,iTemp)=temp.personalityMetric;
        iTemp=iTemp+1;
    end
    
end

out=results;

errorbar(10:5:maxN,mean(results),std(results));