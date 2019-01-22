function out=flyVacPersMetricPValue(data, varargin)

if size(data,1)==4 && size(data,2)==1
    mean1=data(1);
    se1=data(2);
    mean2=data(3);
    se2=data(4);
elseif size(data,1)==1 && size(data,2)==4
        mean1=data(1);
    se1=data(2);
    mean2=data(3);
    se2=data(4);
else
        mean1=data;
    se1=varargin{1};
    mean2=varargin{2};
    se2=varargin{3};
end 

if mean1 > mean2
    tempMean=mean1;
    tempSE=se1;
    mean1=mean2;
    se1=se2;
    mean2=tempMean;
    se2=tempSE;
end

max=10;
dx=0.0005;
x=-max:dx:max;

P1=(1/sqrt(2*pi()*se1^2)).*exp(1).^(-(x-mean1).^2/(2*se1^2));
P2=(1/sqrt(2*pi()*se2^2)).*exp(1).^(-(x-mean2).^2/(2*se2^2));

intSum=0;

for i=1:length(x)
    tempVal=P2(i)*sum(P1(i:end))*dx*dx;
    intSum=intSum+tempVal;
end

out=intSum;