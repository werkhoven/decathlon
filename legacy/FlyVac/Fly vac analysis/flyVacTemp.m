function out=flyVacTemp(data)

for i=2:size(data,1)
    
   out(i)=flyVacPersMetricPValue(data(1,1),data(1,2),data(i,1),data(i,2));
    
    
end