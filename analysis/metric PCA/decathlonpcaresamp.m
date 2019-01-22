function out=decathlonPCAResamp(data)

numBSReps=30;
numFlies=size(data,1);
numDims=size(data,2);
maxPCs=25;

matchParams.visBool=0;              
matchParams.shuffleTries=100000;    
matchParams.maxPCs=maxPCs;             
matchParams.swapCount=4;  

scoreMatrices=zeros(numDims,maxPCs,numBSReps);

[coeffFull,~,latentFull]=pca(data);

parfor i=1:numBSReps
    
    fprintf(1,'\t replicate #%4i out of %4i\n',i,numBSReps);
    which=randi(numFlies,numFlies,1);
    dataTemp=data(which,:);
    [coeffTemp,~,~]=pca(dataTemp);
    
    matched=matchCoeffMatrices(coeffFull,coeffTemp,latentFull,matchParams);
    
    scoreMatrices(:,:,i)=matched.bestCoeffMatrix(:,1:maxPCs);
    
end

out.scoreMatrices=scoreMatrices;
out.zMatrix=mean(scoreMatrices,3)./std(scoreMatrices,0,3);

% maxPCs=20;
% swapCount=1;
% 
% shuffleTries=100000;
% 
% out.scoreMatrices=zeros(numDims,maxPCs,numBSReps);
% 
% [coeffFull,scoreFull,latentFull]=pca(data);
% 
% for i=1:numBSReps
%     
%     which=ceil(rand(numFlies,1)*numFlies);
%     dataTemp=data(which,:);
%     
%     [coeffTemp,scoreTemp,latentTemp]=pca(dataTemp);
%     numDimsTemp=size(coeffTemp,2);
%     
%     coeffFullPartial=coeffFull(:,1:maxPCs);
%     coeffTempPartial=coeffTemp(:,1:maxPCs);
%     
%     bestMatchScore=corr2(coeffTempPartial(:),coeffFullPartial(:));
%     bestCoeffMatrix=coeffTemp;
%     
%     tempVec=[];
%     for j=1:shuffleTries
%         
%         permVec=1:numDimsTemp;
%         for k=1:swapCount
%              permTemp=randperm(numDimsTemp,2);
%             A=permVec;
%             permVec(permTemp(1))=A(permTemp(2));
%             permVec(permTemp(2))=A(permTemp(1));
%         end
%         
%         coefTempTempPartial=bestCoeffMatrix(:,permVec(1:maxPCs));
%         currentMatchScore=corr2(coefTempTempPartial(:),coeffFullPartial(:));
%         
%         if currentMatchScore > bestMatchScore
%            bestCoeffMatrix=bestCoeffMatrix(:,permVec);
%            bestMatchScore=currentMatchScore;
%         end
%         
%         tempVec(j)=bestMatchScore;
%         
%     end
%     
%     out.scoreMatrices(:,:,i)=bestCoeffMatrix(:,1:maxPCs);
%     
%     plot(tempVec);
%     drawnow;
% end