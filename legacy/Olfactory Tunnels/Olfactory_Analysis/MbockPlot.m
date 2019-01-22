function flyTracks = MbockPlot(flyTracks)

flyTracks = removeOutliers(flyTracks);

figure;
nFrames = size(flyTracks.positions,1);
rate = nFrames/flyTracks.duration;
%time = 1:y;

tunnelLength = size(flyTracks.bg,1);
nBins = 20;
edges = 0:tunnelLength/nBins:tunnelLength;

subplot('Position',[0.05 0.05 .75 0.9])
for i=1:size(flyTracks.positions,3)
    plot(flyTracks.positions(:,2,i)+(250*i),flyTracks.times,'k')
    hold on
    plot(repmat(max(flyTracks.positions(:,2,i)+(250*i)),nFrames,1),flyTracks.times,'--b')
    plot(repmat(min(flyTracks.positions(:,2,i)+(250*i)),nFrames,1),flyTracks.times,'--b')
end

hold on
ct=0;

temp={};
ctr=0;

for q=1:size(flyTracks.stim,2)
    tmp=flyTracks.stim{2,q};
    
    for qq=1:size(tmp,1)
        ctr = ctr+1;
        mins(ctr) = min(tmp(qq,:));
        temp{1,ctr} = flyTracks.stim{1,q};
        temp{2,ctr} = tmp(qq,:);
    end
end

[x idx]=sort(mins);


flyTracks.stim = temp;

for i=idx %1:length(flyTracks.stim)
    
    eventTimes = flyTracks.stim{2,i};
    eventLabels{i} = flyTracks.stim{1,i};
    
    for ii=1:size(eventTimes,1)
        
        ct = ct+1;
        
        eventOn = min(eventTimes(ii,:));
        eventOff = max(eventTimes(ii,:));
        
        eventOnFrame = find(round(flyTracks.times) == eventOn, 1);
        eventOffFrame = find(round(flyTracks.times) == eventOff, 1);
        
        subplot('Position',[0.05 0.05 .75 0.9])
        
        %color=[0.6,0.6,1]; %light blue
        color=[0.5,0.5,0.5]; %gray

        ptch=patch([1, 4000, 4000, 1],...
           [eventOn,eventOn,eventOff,eventOff], 0);
        set(ptch,'edgecolor','none','facecolor',color, 'faceAlpha', 0.5)
    
        
        %plot(repmat(eventOn,4000,1),'r')
        %plot(repmat(eventOff,4000,1),'r')
        
        subplot('Position',[0.85 0.05 .1 0.9])
        
        for k=1:size(flyTracks.positions,3)
            flyTracks.occ(k,:)=histc(flyTracks.positions(...
                eventOnFrame:eventOffFrame,2,k),edges)/length(...
                flyTracks.positions(eventOnFrame:eventOffFrame));
            
            flyTracks.PI(k)=sum(flyTracks.occ(k,1:nBins/2))-sum(...
                flyTracks.occ(k,(nBins/2+1):20));
            
            flyTracks.indPIs(k,ct) = flyTracks.PI(k);
            
            %        %flyTracks.dTraveled(k)=sum(abs(diff(flyTracks.positions(:,2,k))))/(235/77); %Distance traveled in cm
            %        %flyTracks.velocity=abs(diff(baselineFixed.positions(:,2,k)));
        end
        
        
        mu=squeeze(mean(flyTracks.occ,1));
        
        muPI=mean(flyTracks.PI,1);
        sdPI=std(flyTracks.PI,1);
        
        left=sum(mu(1:10));
        right=sum(mu(11:20));
        barData(ct,:) = [left right];
        
        eventPI(ct) = left-right;
        eventSD(ct) = mean(sdPI);
        
        eventLabel{ct} = eventLabels{i};
        eventMids(ct) = mean([eventOnFrame eventOffFrame]);
       
    end
    
end

subplot('Position',[0.05 0.05 .75 0.9])
set(gca,'ydir','rev')
set(gca,'YTick',1:60:flyTracks.duration+1)
set(gca,'YTickLabel',0:60:flyTracks.duration)
axis([200 4000 1 flyTracks.duration+1])
box off

subplot('Position',[0.85 0.05 .1 0.9])
colormap winter
h=barh(barData,'stacked');
set(h,'XData',eventMids)
set(gca,'YTick',sort(round(eventMids),'ascend'))
set(gca,'YTickLabel',eventLabel)
axis([0 1 1 nFrames+1])
hold on
plot(repmat(0.5,nFrames,1),flyTracks.times,'k')

for i=1:length(eventPI)
    %eventLabel = ['Mean PI: ' sprintf('%5.2f',eventPI(i)) ' (' sprintf('%5.2f',eventSD(i)) ')'];
    %text(0, eventMids(i), eventLabel, 'FontName', 'Arial', 'FontSize', 14,
    %'FontWeight', 'bold', 'color', 'white');
    eventLabel = [sprintf('%5.2f',eventPI(i)) ' (' sprintf('%5.2f',eventSD(i)) ')'];
    text(1, eventMids(i), eventLabel, 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold', 'color', 'white');
end

set(gca,'ydir','rev')
box off


%title(['Mean PI: ' sprintf('%5.2f',muPI) ' ± ' sprintf('%5.2f',sdPI)]);
%axis([0 nBins+1 0 0.5])


