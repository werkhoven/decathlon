function out=flyVacD2DSim(mu, var)

N=100000;

Data=zeros(N,2);

for i=1:N
    
    p=randn()*sqrt(var)+mu;
    
    D1=sum(rand(40,1)<p)/40;
    D2=sum(rand(40,1)<p)/40;
    
    Data(i,:)=[D1 D2];
end

out=corr2(Data(:,1),Data(:,2));