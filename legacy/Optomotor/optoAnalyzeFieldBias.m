function flyTracks=optoAnalyzeFieldBias(flyTracks)

% Find trials where the stimulus was being displayed
status=flyTracks.stimulusStatus;

for i=1:flyTracks.nFlies
 
% Get angle of the optomotor grating when the fly entered the choice point

enterArms=double(flyTracks.turnData(i).enters);
enterArms(flyTracks.turnData(i).enters==1)=flyTracks.turnData(i).enterArms;
exitArms=double(flyTracks.turnData(i).exits);
exitArms(flyTracks.turnData(i).exits==1)=flyTracks.turnData(i).exitArms;

ang0=boolean((status.*(flyTracks.stimulusAngle(:,i)==0)));
ang60=boolean((status.*(flyTracks.stimulusAngle(:,i)==60)));
ang120=boolean((status.*(flyTracks.stimulusAngle(:,i)==120)));
ang180=boolean((status.*(flyTracks.stimulusAngle(:,i)==180)));
ang240=boolean((status.*(flyTracks.stimulusAngle(:,i)==240)));
ang300=boolean((status.*(flyTracks.stimulusAngle(:,i)==300)));

        % Determine left-right bias during stimulus
        % Throw out trials where stimulus displayed during the entire choice
        enters=find(((enterArms~=0).*status)==1);
        exits=find(((exitArms~=0).*status)==1);
        k=1;
    if ~isempty(exits)&&~isempty(enters)
        % Throw out first exit if it occurs before the first enter
        if exits(1)<enters(1)
            exits(1)=[];
        end

        if length(enters)<=length(exits)
            numTrials=length(enters);
        else
            numTrials=length(exits);
        end

        h=1;
        for j=1:numTrials
            while sum(status(enters(k):exits(j)))~=(exits(j)-enters(k))+1 && k<length(enters)
                if exits(j)>enters(k)
                k=k+1;
                elseif exits(j)<enters(k)
                j=j+1;
                end
            end
            if k<=length(enters)
            enterSequence(h)=enterArms(enters(k));
            exitSequence(h)=exitArms(exits(j));
            h=h+1;
            end
        end

        allturns=enterSequence-exitSequence;
        validturns=allturns(allturns~=0);

        if flyTracks.mazeOri(i)==1
            % 0 for right turn, 1 for left
            validturns(validturns==-1)=0;
            validturns(validturns==2)=0;
            validturns(validturns==1)=1;
            validturns(validturns==-2)=1;
        elseif flyTracks.mazeOri(i)==0
            validturns(validturns==1)=0;
            validturns(validturns==-1)=1;
            validturns(validturns==2)=1;
            validturns(validturns==-2)=0;
        end

        stimRightBias=sum(validturns)/length(validturns);
        optoBias=sum(ang90+ang210+ang330)/sum(flyTracks.turnData(i).exits.*status);
        flyTracks.optoBias(i)=optoBias;
        flyTracks.stimRightBias(i)=stimRightBias;
    else
        flyTracks.optoBias(i)=NaN;
        flyTracks.stimRightBias(i)=NaN;
    end
end