%%% Load processed flyTracks data file master flyData file
%{
[fName,fDir,fFilter] = uigetfile('*.mat;*','Open data file','C:\Users\debivort\Desktop\Decathlon Data Files');
load('-mat',fName);
%}
data = flyTracks;

load flyData

clear fDir fName fFilter

numFlies = data.nFlies;

%% Record odor preference, occupancy, and distance traveled

for i = 1:numFlies
    olfData(i).olfaction.o_odorbias = data.probA(i);
    olfData(i).olfaction.o_avg_velocity = data.dist(i)/data.duration;
    olfData(i).olfaction.o_occupancy = data.occupancy(i);
end

%% Find Pauses away from choice point and tunnel ends


% Find all pauses
intPause = diff(data.pauses);

for i = 1:size(data.pauses,2)
    pauses = find(intPause(:,i) == 1);
    pauses = pauses + 1;                                 % Shift index for offset
    
    % Find logical vector for number pauses 15 pixels away from center
    % and ends and sum to find numPauses
    pCoords = (data.centroidLocal(pauses,2,i)>15 ...
        & data.centroidLocal(pauses,2,i)<85) ...
        | (data.centroidLocal(pauses,2,i)>115 & ...
        data.centroidLocal(pauses,2,i)<165);
    numPauses = sum(pCoords);
    olfData(i).olfaction.o_pauseRate = numPauses/(data.duration/60);   % Convert to pause/min
end

clear pCoords numPauses pauses intPause

%%  Analyze turn handedness

centers = (max(data.headLocal(:,1,:))+min(data.headLocal(:,1,:)))/2;
range = 3;

for i = 1:numFlies
    
    Rturns = data.turns(i).right;
    Lturns = data.turns(i).left;
    
    % Only consider turns where they're away from the walls
    
    posR = data.centroidLocal(Rturns,1,i) > centers(i)-range & ...
        data.centroidLocal(Rturns,1,i) < centers(i)+range;
    numRturns(i) = sum(posR);
    posL = data.centroidLocal(Lturns,1,i) > centers(i)-range & ...
        data.centroidLocal(Lturns,1,i) < centers(i)+range;
    numLturns(i) = sum(posL);
    
    % Record fraction of right turns, number turns right, and total turns
    olfData(i).olfaction.o_Rturnbias(1) = numRturns(i)/(numRturns(i)+numLturns(i));
    %deca(i).olfaction.Rturnbias(2) = numRturns(i);
    %deca(i).olfaction.Rturnbias(3) = numRturns(i) + numLturns(i);
    
end
    
clear Rturns Lturns posR posL numRturns numLturns flyTracks centers range

%% Save to master flyData file


for i = 1:numFlies
    flylabel = data.ID(i);
    flylabel = strrep(flylabel,'_','-');
    flylabel = cell2mat(flylabel);
    datIndex = find(cellfun(@(x)isequal(x,flylabel), {flyData.ID}));
    flyData(datIndex).olfaction = olfData(i).olfaction;
end


    