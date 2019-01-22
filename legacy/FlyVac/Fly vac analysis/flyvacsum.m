function out=flyvacsum(data)
 
sums=zeros(size(data,1),size(data,2));

for i=1:size(data,1)
    for j=1:size(data,2)
   
        sums(i,j)=nansum(data(i,1:j));
        
    end
end

figure;
hold on;

for i=1:size(data,1)
   plot(sums(i,:)); 
end

plot(nanmean(sums),'r')
plot(40*nanmean(data),'g')

ylim([-40 40]);

out=sums;