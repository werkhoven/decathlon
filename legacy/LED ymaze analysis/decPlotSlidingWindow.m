function plotData=decPlotSlidingWindow(choiceData,interval,numFlies,stepSize)

% Interval specifies the length of the sliding window in minutes and must
% be converted to milliseconds
interval=interval*60*1000;

% First point should be from first index to t = interval
firstIndex=sum(choiceData(:,1)<interval);
numSteps=floor((size(choiceData,1)-firstIndex)/stepSize);

plotData=zeros(numSteps,numFlies);
figure();

for i=1:numFlies   
    tempSeq=~isnan(choiceData(:,2));
    for j=1:numSteps
        Q=zeros(size(tempSeq));
        Q(j*stepSize:j*stepSize+firstIndex)=1;
        tempTrials=boolean(tempSeq.*Q);
        plotData(j,i)=sum(choiceData(tempTrials,i+1))/length(choiceData(tempTrials,i+1));
    end
    
    hold on
    plot(plotData(:,i),'Color',rand(1,3))
    hold off
    
end
        
        