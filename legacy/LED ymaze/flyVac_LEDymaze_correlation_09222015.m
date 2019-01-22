numFlies=length(flyData);

lightProbMat=NaN(numFlies,2);

for i=1:numFlies
    if ~isempty(flyData(i).photo2)
        lightProbMat(i,1)=flyData(i).lightProb;
        lightProbMat(i,2)=flyData(i).photo2.p_lightprob;
    end
end

[corr_mat p_values]=corrcoef(lightProbMat,'rows','pairwise');