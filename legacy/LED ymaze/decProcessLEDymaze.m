%% Import data

[cenDat,ledDat,lightseq,turnseq]=decLEDyGetData;

%% Count Turns and photobias

numFlies=size(lightseq,2)-1;
flyLights=[];
rowOri=[1 0 1 0 1 0 1 0 1 0];
mazeOri=boolean([rowOri 1 rowOri rowOri rowOri rowOri rowOri rowOri 1]);
pData=struct('lightProb',[],'lightChoiceSeq',[],'rightProb',[],'turnChoiceSeq',[],'centroid',[],'LEDsequence',[]);

%{
expStart=find(cenDat(:,1)==0);
cenDat(1:expStart(2)-1,:)=[];
ledDat(1:expStart(2)-1,:)=[];
lightseq(1:expStart(2)-1,:)=[];
turnseq(1:expStart(2)-1,:)=[];
%}

% Save data to master data struct
for i=1:numFlies
    i
    Lseq=lightseq(~isnan(lightseq(:,i+1)),[1 i+1]);
    Tseq=turnseq(~isnan(turnseq(:,i*2)),[1 i*2:i*2+1]);
    tCen=cenDat(:,i*2:i*2+1);
    tLED=ledDat(:,i*3-1:i*3+1);

    % Discard first trial where all lights are on
    if ~isempty(Lseq)
    Lseq(1,:)=[];
    end
    
    if ~isempty(Tseq)
    Tseq(1,:)=[];
    end

    % Calculate right turn probability based on maze orientation
    turnDirection=Tseq(:,2)-Tseq(:,3);
    rightTurn=zeros(size(Tseq,2)-1,1);
        if mazeOri(i)==0
            rightTurn(turnDirection==-2)=1;
            rightTurn(turnDirection==1)=1;
        else
            rightTurn(turnDirection==2)=1;
            rightTurn(turnDirection==-1)=1;
        end
    
    % Plot photobias in sliding 30 min window
    stepSize=100;
    interval=20;
    tempLightData=[lightseq(:,1) lightseq(:,i+1)];
    %plotData=decPlotSlidingWindow(tempLightData,interval,1,stepSize);
    
    % Save to data struct
    pData(i).lightProb=sum(Lseq(:,2))/length(Lseq);
    pData(i).lightChoiceSeq=Lseq;
    pData(i).rawLightSeq=lightseq;
    pData(i).rightProb=sum(rightTurn)/length(rightTurn);
    pData(i).turnChoiceSeq=Tseq;
    pData(i).centroid=tCen;
    pData(i).LEDsequence=tLED;
    %pData(i).lightProbTrace=plotData';
    pData(i).ID={'CsBenzer_'};
    
end

%% Plot maze traces and photobias in sliding 30 min window

ledPlotTraces(cenDat);

%% Append to data struct
load flyLights
flyLights=[flyLights pData];

%[flyLightsOpen2,meanLightPref,numChoices]=ledAnalyzeData(flyLightsOpen2);
%lightProbPlot=ledPlotMeanLightProb(flyLightsOpen2,interval);