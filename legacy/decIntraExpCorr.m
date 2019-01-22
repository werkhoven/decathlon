function corrMat=decIntraExpCorr(flyTracks,interval,field)
% This function calculates the correlation in turn or light choice
% probability over the interval (in minutes) specified in the input

interval=interval*60;                               % Convert from min to sec
data=flyTracks.(field);                             % Data specified in field

% If the data is turn probability, convert from maze arms to right/left
% turns
if strcmp(field,'rightTurns')
rights=mazeArms2rightTurns(flyTracks);
data=rights;
end

choiceThresh=40;
active=flyTracks.numTurns>choiceThresh;                       % Remove data from flies that make less than 40 turns
data(:,~active)=[];
expDuration=sum(diff(flyTracks.tStamps));           % Length of the experiment in sec
tStamps=flyTracks.tStamps-flyTracks.tStamps(1);     % Normalize time stamps to 0
numBlocks=round(expDuration/interval);              % Number of blocks that will be correlated to one another

if iscellstr(flyTracks.labels{1,1})
    strain=flyTracks.labels{1,1}{:};
else
    strain='';
end
if iscellstr(flyTracks.labels{1,3})
    treatment=flyTracks.labels{1,3}{:};
else
    treatment='';
end

% Find the indices that best fit the start of each interval
startTimes=0:interval:expDuration;
startInd=zeros(length(startTimes),1);

for i=1:length(startInd)
    tmpT=abs(tStamps-startTimes(i));
    [v j]=min(tmpT);
    startInd(i)=j;
end

% Segment data into interval blocks
datBlocks=NaN(length(startInd),size(data,2));
active=ones(1,size(data,2));


for i=1:length(startInd)
    if i~=length(startInd)
    tDat=data(startInd(i):startInd(i+1),:);
    else
    tDat=data(startInd(i):end,:);  
    end
    
    % Filter out flies that don't make enough choices in each block
    tmpChoiceNum=sum(~isnan(tDat));
    active=active&tmpChoiceNum>(choiceThresh/length(startInd));
    
    datBlocks(i,:)=sum(tDat==1)./tmpChoiceNum;
    
end

datBlocks(:,~active)=[];
corrMat=corrcoef(datBlocks','rows','pairwise');
imagesc(corrMat)
colormap(gcf,'jet')
colorbar
caxis([-1,1])
title(['Intra-experiment correlation: ',strain,' ',treatment,' ',field,' (n=',num2str(size(datBlocks,2)),')']);
shg