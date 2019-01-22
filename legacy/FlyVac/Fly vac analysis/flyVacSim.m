function out=flyVacSim(data,iters)

temp=data(:);
p=(nanmean(temp)+1)/2;

% numData=length(data)/3;
 numData=length(data);
nVector=zeros(numData,1);

for i=1:numData

%     n=length(data((i-1)*3+1,2:end))-sum(isnan(data((i-1)*3+1,2:end)));
%     nVector(i)=n;

     n=length(data(i,:))-sum(isnan(data(i,:)));
     nVector(i)=n;

end


iterations=iters;

histos=zeros(iterations,41);

for i=1:iterations

    histo=zeros(41,1);
    
    for j=1:numData
    
        if nVector(j) >0
            index=(sum(rand(nVector(j),1)<p)/nVector(j))*2-1;
            whichBin=round(index*20)/20;
            histo(round(whichBin*20+21))=histo(round(whichBin*20+21))+1;
        end
    end

    histos(i,:)=histo;

end

out=histos;