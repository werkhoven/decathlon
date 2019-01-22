function meanLightProb=ledPlotMeanLightProb(flyLights,interval)

%% Crop frames at the end to match data points to the smallest frame number
numFlies=size(flyLights,2);
frameNum=NaN(numFlies,1);

for i=1:numFlies
    frameNum(i)=size(flyLights(i).lightProbTrace,2);
end

frameNum=min(frameNum);
allLightProb=NaN(frameNum,numFlies);

for i=1:numFlies
    allLightProb(:,i)=flyLights(i).lightProbTrace(1:frameNum);
end

%% Calculate time Averaged Light Choice Probability
meanLightProb=nanmean(allLightProb,2);

%% Plot
figure();
plot(meanLightProb);
title('Mean Light Choice Probability in 20 min. Window');
expDuration=120;
minPerTick=(expDuration-interval)/frameNum;
tickSize=5;
stepsPerTick=floor(tickSize/minPerTick);
set(gca,'Xtick',[1:stepsPerTick:frameNum],'XtickLabel',[interval:tickSize:expDuration]);
xlabel('Time (min)');
ylabel('Mean Light Choice Probability');
axis([interval expDuration 0 1])

end