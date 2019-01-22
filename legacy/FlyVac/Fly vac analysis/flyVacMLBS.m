function out=flyVacMLBS(data)

MLs=zeros(1,1000);
numFlies=size(data,1);

for i=1:3000
    which=ceil(rand(numFlies,1)*numFlies);
    resample=data(which);
    temp=flyVacML(resample);
    MLs(i)=temp.ML;
end

temp=flyVacML(data);

out.ML=temp.ML;
out.MLstd=std(MLs);
