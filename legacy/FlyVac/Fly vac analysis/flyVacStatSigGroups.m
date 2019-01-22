function out=flyVacStatSigGroups(means, SEs)

N=size(means,1);

pValMatrix=zeros(N,N);

for i=1:N
    i
    for j=1:N
        
        if means(i) < means(j)
            pTemp=flyVacPersMetricPValue(means(i),SEs(i),means(j),SEs(j));
        else
            pTemp=flyVacPersMetricPValue(means(j),SEs(j),means(i),SEs(i));
        end
        pValMatrix(i,j)=pTemp;
        
    end
end

out.pMat=pValMatrix;