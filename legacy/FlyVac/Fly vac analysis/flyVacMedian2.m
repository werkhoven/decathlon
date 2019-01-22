function out=flyVacMedian2(Prob,X,Median)

Xtemp=abs((X-Median));
ProbTemp=[Prob Xtemp];
ProbTemp=sortrows(ProbTemp,2);

choices=Xtemp;
cumdata=zeros(size(ProbTemp,1),1);
for i=1:size(ProbTemp,1)
    cumdata(i)=sum(ProbTemp(1:i,1));
end

% [ProbTemp cumdata]

for i=1:size(ProbTemp,1)-1
    
    if cumdata(i) <= 0.5 && cumdata(i+1)> 0.5
        q2=i;
        break;
    end
    
    
end


    alpha=(0.5-cumdata(q2))/(cumdata(q2+1)-cumdata(q2));

Q2=ProbTemp(q2,2)+alpha*(ProbTemp(q2+1,2)-ProbTemp(q2,2));
out=Q2;
