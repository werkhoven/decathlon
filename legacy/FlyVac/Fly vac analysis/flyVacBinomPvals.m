function out=flyVacBinomPvals(data)

temp=data(:);
p=(nanmean(temp)+1)/2;

Nvector=sum(not(isnan(data')))';
Kvector=sum(data'>0)';

N=size(data,1);

PVvector=zeros(N,1);

for i=1:N
    k=Kvector(i);
    n=Nvector(i);
    d=abs(k-n*p);
    m=n*p;
    if k <= n*p
        PVvector(i)=min([2*binocdf(k+1,n,p) 1]);
    else
        PVvector(i)=min([2*(1-binocdf(k-1,n,p)) 1]);
    end

end

size(Nvector)
size(PVvector)
size(Kvector)
out=[PVvector Nvector Kvector];