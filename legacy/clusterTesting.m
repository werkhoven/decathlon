%Cluster Testing

nData=300;
data=zeros(20,nData);

for i=1:5
    for j=1:nData
        random=rand();
        data(i,j)=random+rand()*0.5-rand()*0.5;
        if data(i,j)>1
            data(i,j)=1;
        end
        data(i+5,j)=random*100+rand()*50-rand()*50;
        if data(i+5,j)>100
            data(i+5,j)=100;
        end
    end
end

for i=11:15
    for j=1:nData
        random=rand();
        data(i,j)=random;
        if data(i,j)>1
            data(i,j)=1;
        end
        data(i+5,j)=random*100;
    end
end


for j=1:nData
    for i=2:20
        sign=rand();
            if sign>0.5
                sign=-1;
            else
                sign=1;
            end
        data(1,j)=(data(1,j)+data(i,j)*rand()*5);
        data(6,j)=(data(6,j)-data(i,j)*rand()*5);
    end
end

data=sqrt(data.^2);
Z=linkage(data,'ward','seuclidean');
figure();
[ZH, ZT, Zoutperm]=dendrogram(Z);
corr=corrcoef(data','rows','complete');
figure();
imagesc(corr(Zoutperm,Zoutperm))
set(gca,'Ytick',[1:size(data,1)],'YtickLabel', Zoutperm,'fontsize',14)
set(gca,'Xtick',[1:size(data,1)],'XtickLabel', Zoutperm,'fontsize',14)
set(gcf,'color','w')
caxis([-1 1])
colorbar