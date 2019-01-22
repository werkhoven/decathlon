function out=flyVacD2D(data1,labels1,data2,labels2)

d1=[];
d2=[];

for i=1:length(labels1)
    
    if sum(labels2==labels1(i))==1
        
        leng1=sum(isfinite(data1(i,:)));
        leng2=sum(isfinite(data2(labels2==labels1(i),:)));
        leng=min(leng1,leng2);
        d1=[d1;mean(data1(i,1:leng))];
        d2=[d2;mean(data2(labels2==labels1(i),1:leng))];
       
    end
    
end



out.r=corr2(d1,d2);
out.d1=d1;
out.d2=d2;

bootStraps=[];

N=10000;

for i=1:N
    which=ceil(rand(length(d1),1)*length(d1));
    bootStraps=[bootStraps;corr2(d1(which),d2(which))];
end
   
bootStraps=sort(bootStraps);
% hist(bootStraps)

out.CI95=[bootStraps(floor(0.025*N)) bootStraps(ceil(0.975*N))];
out.std=std(bootStraps);