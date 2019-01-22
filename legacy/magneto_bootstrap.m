% Bootstrap resampling preliminary magnetotaxis experiment


numFlies=length(observedDATA);
numTrials=20;
flyTurns=zeros(numFlies,numTrials);
flyMag=zeros(numFlies,numTrials);
delFlies=[];
keepFlies=[];

% Calculate observed biases

for i = 1:numFlies;
nBias(i)=observedDATA(i,1)/sum(observedDATA(i,1:2));
ltBias(i)=observedDATA(i,3)/sum(observedDATA(i,3:4));

    if sum(observedDATA(i,1:2))<15
    delFlies=[delFlies i];
    else
    keepFlies=[keepFlies i];
    end
end

nBias(delFlies)=[];
ltBias(delFlies)=[];

obsMAD(1)=mad(nBias);
obsMAD(2)=mad(ltBias);

% Simulate observed biases

nSims = 15000;
total_nBias=sum(observedDATA(keepFlies,1))/(sum(observedDATA(keepFlies,1))+sum(observedDATA(keepFlies,2)));
total_ltBias=sum(observedDATA(keepFlies,3))/(sum(observedDATA(keepFlies,3))+sum(observedDATA(keepFlies,4)));
sim_nMAD=zeros(1,nSims);
sim_ltMAD=zeros(1,nSims);

for i = 1:nSims;
    
    vals=zeros(numFlies,2);
    for j = 1:numFlies;
    
    simMag=zeros(1,numTrials);
    simTurns=zeros(1,numTrials);
    
        for k=1:numTrials;
            random=rand();
            if random>total_nBias
                simMag(k)=0;
            else
                simMag(k)=1;
            end
            random=rand();
            if random>total_ltBias
                simTurns(k)=0;
            else
                simTurns(k)=1;
            end
        end
        
    %{
    if j==1||j==2
        simMag(4:numTrials)=[];
        simTurns(4:numTrials)=[];
    else if j == 3
            simMag(5:numTrials)=[];
            simTurns(5:numTrials)=[];
        else if j==4
                simMag(8:numTrials)=[];
                simTurns(8:numTrials)=[];
            else if j==5
                    simMag(9:numTrials)=[];
                    simTurns(9:numTrials)=[];
                else if j==6
                        simMag(11:numTrials)=[];
                        simTurns(11:numTrials)=[];
                    else if j==7
                            simMag(14:numTrials)=[];
                            simTurns(14:numTrials)=[];
                        end
                    end
                end
            end
        end
    end
    %}
        
    vals(j,1)=sum(simMag)/length(simMag);
    vals(j,2)=sum(simTurns)/length(simTurns);
    
    end

    sim_nMAD(i)=mad(vals(:,1));
    sim_ltMAD(i)=mad(vals(:,2));
end

nSubs=10;

figure();
hold on    
nMAD_max=max(sim_nMAD);
nMAD_min=min(sim_nMAD);
magBins = linspace(nMAD_min,nMAD_max,10);
magCounts=histc(sim_nMAD,magBins);
magCounts=magCounts/sum(magCounts);
plot(magCounts,'b')
set(gca,'Xtick',[1:round(length(magBins)/nSubs):length(magBins)],'XtickLabel',magBins(1:round(length(magBins)/nSubs):length(magBins)))


figure();
hold on
ltMAD_max=max(sim_ltMAD);
ltMAD_min=min(sim_ltMAD);
turnBins=linspace(ltMAD_min,ltMAD_max,10);
turnCounts=histc(sim_ltMAD,turnBins);
turnCounts=turnCounts/sum(turnCounts);
plot(turnCounts,'r')
set(gca,'Xtick',[1:round(length(turnBins)/nSubs):length(turnBins)],'XtickLabel',turnBins(1:round(length(turnBins)/nSubs):length(turnBins)))

   