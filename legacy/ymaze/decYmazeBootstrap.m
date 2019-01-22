function out=decYmazeBootstrap(data,nReps)

numFlies = size(data,1);
TurnSequence = data(:,14);
tStamps = data(:,15);

%% Observed switchiness and clumpiness

for i = 1:numFlies
    
    %Clumpiness
    ITI = diff(cell2mat(tStamps(i)));
    ITI = ITI/(1000*60);                %Convert to minutes
    out.observed(i,1) = mad(ITI)/nanmean(ITI);
    
    %Switchiness
    tSeq = cell2mat(TurnSequence(i));
    numLR = length(find(diff(tSeq)==1));    % Number of left turns followed by a right
    numRL = length(find(diff(tSeq)==-1));   % Number of right turns followed by a left
    numL = length(find(tSeq==0));
    numR = length(find(tSeq==1));
    out.observed(i,2) = (numLR+numRL)/(2*numL*numR/length(tSeq));
    
    %{
    runs0 = runlength(tSeq,0);
    runs1 = runlength(tSeq,1);
    numruns = length(runs0) + length(runs1);
    
    
    if tSeq(1) == 0
        totalruns(1:2:numruns)=runs0;
        totalruns(2:2:numruns)=runs1;
    elseif tSeq(1) == 1
        totalruns(1:2:numruns)=runs1;
        totalruns(2:2:numruns)=runs0;
    end
    
    out.observed(i,2) = mad(totalruns);
    %}
    
end

%% Record run lengths for each fly

for i = 1:numFlies
    
    tSeq = cell2mat(TurnSequence(i));
        runs0 = runlength(tSeq,0);
        runs1 = runlength(tSeq,1);
        numruns = length(runs0) + length(runs1);
    if tSeq(1) == 0
        totalruns(1:2:numruns)=runs0;
        totalruns(2:2:numruns)=runs1;
    elseif tSeq(1) == 1
        totalruns(1:2:numruns)=runs1;
        totalruns(2:2:numruns)=runs0;
    end
    
    obsRuns(i) = {totalruns};
    
end

%% Bootstrapped switchiness and clumpiness

%Simulate inter-trial intervals and turn sequences for each fly

for i = 1:nReps
    
    elapsedTime = 0;
    j=1;
    
    while elapsedTime < 7200000
    %Choose a fly and then choose an ITI for that fly
    flyNum = ceil(rand()*numFlies);
    obs_ITI = diff(cell2mat(tStamps(flyNum)));
    sim_ITI(j)= obs_ITI(ceil(rand()*length(obs_ITI)));
    elapsedTime = sum(sim_ITI);
    
    if elapsedTime >= 7200000
        sim_ITI(j) = [];
    end
    
    j = j+1;
    end
    
    sim_ITI = sim_ITI/(1000*60);    %Convert to minutes
    out.BS(i,1) = mad(sim_ITI)/nanmean(sim_ITI);
    
    % Choose the total number of simulated turns at random and simulate
    % sequence of turns
    numTurns = cell2mat(data((ceil(rand()*numFlies)),12));
    k=1;
    sim_numTurns = 0;

    while sim_numTurns < numTurns
        flyNum = ceil(rand()*numFlies);
        flyRuns = cell2mat(obsRuns(flyNum));
        sim_runs(k) = flyRuns(ceil(rand()*length(flyRuns)));
        sim_numTurns = sum(sim_runs);
        
        % Cut the last run length off at the total number of turns
        if sim_numTurns > numTurns
            sim_runs(k) = sim_runs(k) - (sim_numTurns-numTurns);
        end
        k = k+1;
    end
    
    out.BS(i,2) = length(sim_runs)/(2*sum(sim_runs(1:2:length(sim_runs)))*sum(sim_runs(2:2:length(sim_runs)))/sum(sim_runs));
    
end

%% Plot distributions

clumpmin = min([min(out.BS(:,1)) min(out.observed(:,1))]);
clumpmax = max([max(out.BS(:,1)) max(out.observed(:,1))]);
clumpBins = linspace(clumpmin,clumpmax,30);

switchmin = min([min(out.BS(:,2)) min(out.observed(:,2))]);
switchmax = max([max(out.BS(:,2)) max(out.observed(:,2))]);
switchBins = linspace(switchmin,switchmax,30);

figure();
hold on
title('Y-Maze Clumpiness')
plot(clumpBins,hist(out.observed(:,1),clumpBins)/length(out.observed(:,1)),'r');
plot(clumpBins,hist(out.BS(:,1),clumpBins)/length(out.BS(:,1)),'b');

figure();
hold on
title('Y-Maze Switchiness')
plot(switchBins,hist(out.observed(:,2),switchBins)/length(out.observed(:,2)),'r');
plot(switchBins,hist(out.BS(:,2),switchBins)/length(out.BS(:,2)),'b');

end
        
    
    