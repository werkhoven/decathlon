function out=flyVacStreakAnalysis(all_data)

numData=size(all_data,1);
nVector=zeros(numData,1);
for i=1:numData
    n=length(all_data(i,:))-sum(isnan(all_data(i,:)));
    nVector(i)=n;
end

all_data=(all_data+1)/2;

bins=40;

streakHisto=zeros(2*bins+1,1);
streakHistoExp=zeros(2*bins+1,1);

for i=1:numData
    
    
    data=all_data(i,1:nVector(i));
    dataLength=length(data);
    
    p=mean(data);
    
    for j=1:bins
        streakHistoExp(bins+1-j)=streakHistoExp(bins+1-j)+dataLength*p*(1-p)^j*p;
        streakHistoExp(bins+1+j)=streakHistoExp(bins+1+j)+dataLength*(1-p)*(p)^j*(1-p);
    end
    
    
    currentStreak=1;
    streakValue=data(1);
    for j=2:length(data)
        if data(j) ~= streakValue
            if streakValue==0
                streakHisto(bins+1-min(currentStreak,bins))=streakHisto(bins+1-min(currentStreak,bins))+1;
            else
                streakHisto(bins+1+min(currentStreak,bins))=streakHisto(bins+1+min(currentStreak,bins))+1;
            end
            currentStreak=1;
            streakValue=data(j);
        else
            currentStreak=currentStreak+1;
        end
    end
    
    
end






out.obsHisto=streakHisto/sum(streakHisto);
out.expHisto=streakHistoExp/sum(streakHistoExp);
figure;
hold on;
plot(streakHisto/sum(streakHisto))
plot(streakHistoExp/sum(streakHistoExp),'r')