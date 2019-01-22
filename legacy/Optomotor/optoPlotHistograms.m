function [histograms]=optoPlotHistograms(arena_Data,flyTracks,ROI_coords,perm)

    numFigures=ceil(flyTracks.nFlies/10);
    bins=linspace(-pi,pi,25);
    histograms.angle0=zeros(length(bins),flyTracks.nFlies);

for i=1:flyTracks.nFlies
    
    % Open new figure window and reset subplot count every 10 flies 
    if mod(i-1,25)==0
       figure()
    end

    %Plot fly trace
    hold on
    subplot(5,5,i);
    
    % Remove data points where centroid is lost
    temp=flyTracks.centroid(:,:,i);
    cenTracked=~isnan(temp(:,1));
    
    % Only keep data points where fly is moving
    moving=arena_Data(i).speed>=nanmedian(arena_Data(i).speed);
    validTrials=boolean(cenTracked.*moving);
    
    tTheta=arena_Data(i).theta(validTrials);
    tAng=flyTracks.stimulusAngle(validTrials);
    tStim=flyTracks.stimulusStatus(validTrials);
    tRad=arena_Data(i).r(validTrials);
    tRad=tRad./max(tRad);
    tTheta=tTheta.*tRad;
    tAng(tStim==0)=NaN;
    
    % Segment circling data by stimulus condition
    angle0 = tTheta(tAng==0);
    angle0=histc(angle0,bins);
    angle0=angle0/sum(angle0);
   
    angle120 = tTheta(tAng==120);
    angle120=histc(angle120,bins);
    angle120=angle120/sum(angle120);
   
    angle240 = tTheta(tAng==240);
    angle240=histc(angle240,bins);
    angle240=angle240/sum(angle240);
   
    angleNoStim = tTheta(isnan(tAng));
    angleNoStim = histc(angleNoStim,bins);
    angleNoStim=angleNoStim/sum(angleNoStim);
    
    % Weight each bin by the average radius during a given condition
    stimAngle=0;
    
    % For each stimulus condition
    for k=1:4
        stimTrials=tAng==stimAngle;
        if stimAngle==360
            stimTrials=isnan(tAng);
        end
        avgR=zeros(length(bins)-1,1);
    
        % For each bin
        for j=1:length(bins)-1
            binTrials=boolean((tTheta>bins(j).*tTheta<bins(j+1)).*stimTrials);
            sum(binTrials)
            avgR(j)=nanmean(tRad(binTrials));
        end
        avgR=[avgR;0];
        
        if k==1
            angle0=angle0.*avgR;
            angle0=angle0/sum(angle0);
        elseif k==2

            angle120=angle120.*avgR;
            angle120=angle120/sum(angle120);
        elseif k==3

            angle240=angle240.*avgR;
            angle240=angle240/sum(angle240);
        elseif k==4

            angleNoStim=angleNoStim.*avgR;
            angleNoStim=angleNoStim/sum(angleNoStim);
        end
        
        stimAngle=stimAngle+120;
    end

    %{
    xCenter=sum(ROI_coords(perm(i),[1,3]))/2;
    yCenter=sum(ROI_coords(perm(i),[2,4]))/2;
    
    Q1=boolean((temp(:,1)<xCenter).*(temp(:,2)<yCenter));
    angle0 = tTheta();
    angle0=histc(angle0,bins);
    angle0=angle0./sum(angle0);
   
    Q2=boolean((temp(:,1)>xCenter).*(temp(:,2)<yCenter));
    angle120 = tTheta(Q2);
    angle120=histc(angle120,bins);
    angle120=angle120./sum(angle120);
   
    Q3=boolean((temp(:,1)<xCenter).*(temp(:,2)>yCenter));
    angle240 = tTheta(Q3);
    angle240=histc(angle240,bins);
    angle240=angle240./sum(angle240);
   
    Q4=boolean((temp(:,1)>xCenter).*(temp(:,2)>yCenter));
    angleNoStim = tTheta(Q4);
    angleNoStim = histc(angleNoStim,bins);
    angleNoStim=angleNoStim./sum(angleNoStim);
    %}
    
    % Assign to output struct
    histograms.angle0(:,i)=angle0;
    histograms.angle120(:,i)=angle120;
    histograms.angle240(:,i)=angle240;
    histograms.angleNoStim(:,i)=angleNoStim;
    
    % Plot histograms
    hold on
    plot(bins,angle0,'r')
    plot(bins,angle120,'g')
    plot(bins,angle240,'b')
    plot(bins,angleNoStim,'k')
    hold off
    
end
end