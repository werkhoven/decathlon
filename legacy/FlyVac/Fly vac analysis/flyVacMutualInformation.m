function out=flyVacMutualInformation(data,iterations)

pairList=[];

prob=sum(nansum(data))/sum(sum(not(isnan(data))));
prob=(prob+1)/2;

for i=1:size(data,1)
    
    
    ni=sum(not(isnan(data(i,:))));
    %     pairList=[pairList;[data(i,1:(ni-1))' data(i,2:ni)']];
    pairList=[data(i,1:(ni-1))' data(i,2:ni)'];
    
    px1=sum(pairList(:,1)==1)/size(pairList,1);
    px0=1-px1;
    py1=sum(pairList(:,2)==1)/size(pairList,1);
    py0=1-py1;
    
    pairID=pairList(:,1)+0.5*pairList(:,2);
    
    listN=size(pairList,1);
    
    px1y1=sum(pairID==1.5)/listN;
    px1y0=sum(pairID==0.5)/listN;
    px0y1=sum(pairID==-0.5)/listN;
    px0y0=sum(pairID==-1.5)/listN;
    
    MI=px1y1*log2(px1y1/(px1*py1))+px1y0*log2(px1y0/(px1*py0));
    MI=MI+px0y1*log2(px0y1/(px0*py1))+px0y0*log2(px0y0/(px0*py0));
    
    MIList(i)=MI;
    
    chi2=(px1y1-listN*prob^2)^2/listN*prob^2 + (px1y0-listN*prob*(1-prob))^2/(listN*prob*(1-prob))^2;
    chi2=(px0y0-listN*(1-prob)^2)^2/listN*(1-prob)^2 + (px0y1-listN*prob*(1-prob))^2/(listN*prob*(1-prob))^2+chi2;
    
    
end

out=MIList;

% % pairList=zeros(10000,2);
% % pairList=[(pairList-1);(1+zeros(10000,2))];
% % pairList=[pairList;[-1 1;1 -1]];
%
% px1=sum(pairList(:,1)==1)/size(pairList,1)
% px0=1-px1;
% py1=sum(pairList(:,2)==1)/size(pairList,1)
% py0=1-py1;
%
% pairID=pairList(:,1)+0.5*pairList(:,2);
%
% px1y1=sum(pairID==1.5)/size(pairList,1)
% px1y0=sum(pairID==0.5)/size(pairList,1)
% px0y1=sum(pairID==-0.5)/size(pairList,1)
% px0y0=sum(pairID==-1.5)/size(pairList,1)
%
% MI=px1y1*log2(px1y1/(px1*py1))+px1y0*log2(px1y0/(px1*py0));
% MI=MI+px0y1*log2(px0y1/(px0*py1))+px0y0*log2(px0y0/(px0*py0))

if iterations > 0
    
    MIList=zeros(iterations,1);
    
    for i=1:iterations;
        which=ceil(rand(size(pairList,1),1)*size(pairList,1));
        resample=pairList(which,:);
        
        px1=sum(pairList(:,1)==1)/size(pairList,1);
        px0=1-px1;
        py1=sum(pairList(:,2)==1)/size(pairList,1);
        py0=1-py1;
        
        pairID=pairList(:,1)+0.5*pairList(:,2);
        
        px1y1=sum(pairID==1.5)/size(pairList,1);
        px1y0=sum(pairID==0.5)/size(pairList,1);
        px0y1=sum(pairID==-0.5)/size(pairList,1);
        px0y0=sum(pairID==-1.5)/size(pairList,1);
        
        MI=px1y1*log2(px1y1/px1*py1)+px1y0*log2(px1y0/px1*py0);
        MI=MI+px0y1*log2(px0y1/px0*py1)+px0y0*log2(px0y0/px0*py0);
        MIList(i)=MI;
        
    end
    
    mean(MIList)
    std(MIList)
    
end