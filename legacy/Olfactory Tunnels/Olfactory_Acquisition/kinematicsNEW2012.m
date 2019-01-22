function flyTracks=kinematicsNEW2012(nFlies, aliComm)
%For testing odor preference

clf
NIobject=connectToUSB6501;
runningLength = 500; %grabbed frames for tails
dispRate = 50; %rate (in frames) at which to update tracking display - tradeoff with max attainable frame rate


%%%%%%%%%%%%%%%%%%%% edit here %%%%%%%%%%%%%%%%%%%%%%%%%%
odors = {'airLeft' 'odorBright'};
conc = 0.2; %proportion saturated vapor
odorDur = 5; %in sec
isi = 10; %in sec
nBlocks = 40; %number of odor blocks
%%%%%%%%%%%%%%%%%%%% edit here %%%%%%%%%%%%%%%%%%%%%%%%%%


%Valve correspondence
airLeft = 5;
odorAleft = 6; %MCH
odorBleft = 7; %OCT
odorCleft = 8;

airRight = 1;
odorAright = 2; %MCH
odorBright = 3; %OCT
odorCright = 4;

%Odor matrix(left/right concentration; left/right valves)
for qq = 1:nBlocks
    stim(qq).odor = [conc conc; ...
        eval(odors{1}) eval(odors{2})];
end

%Build stimulus epochs
if nBlocks > 1
    lastTime = 60-isi;
    for i=1:nBlocks
        startTime = lastTime+isi;
        stim(i).times = [startTime:startTime+odorDur];
        lastTime = max(stim(i).times);
    end
    
else
    startTime = 60; %wait 1 min before odor onset
    stim.times = startTime:(startTime+odorDur);
    lastTime = max(stim.times);
end

duration = lastTime + 60; %add 1 minute clean air to end

stimTimes = zeros(1,duration+1);

for qqq=1:nBlocks
    stimTimes(stim(qqq).times) = qqq;
end

%Start flushing with air
valves = [airLeft airRight];
conc = [0.2 0.2];
odorPeriod = 0;
airPeriod = presentAir(NIobject, aliComm, valves, conc);

%Set up video input
vid = videoinput('dcam',1,'Y8_640x480');

set(vid.source,'Brightness',700,'Gain',100);
set(vid,'ReturnedColorSpace','gray');

start(vid)
pause(2)

preFrame = peekdata(vid,1);
imshow(preFrame)
title(['Select ROI, then double click'])
h = imrect;
ROI = round(wait(h));
vid.ROIPosition = ROI;
stop(vid)

clf

start(vid)
pause(2)

preFrame = peekdata(vid,1);
imshow(preFrame)
title(['CLICK on each fly'])
hold on

hlfwd = 10;

for q = 1:nFlies
h = impoint;
flypos(q,:) = round(h.getPosition);

clf
imshow(preFrame)
title(['CLICK on each fly'])
hold on

%Detection of fly silhouette
clip = preFrame(flypos(q,2)-hlfwd:flypos(q,2)+hlfwd,flypos(q,1)-hlfwd:flypos(q,1)+hlfwd);
indTemp(:,:,q) = im2bw(clip,graythresh(clip));
%Now separate fly objs from wall objs and find the object containing the user-selected point

plot(flypos(:,1),flypos(:,2),'.g') %temp plotting soln
end

stop(vid)

triggerconfig(vid,'manual');
start(vid)
pause(2)


%Calculate background
backgroundFrames=100;
data=zeros(ROI(4),ROI(3),backgroundFrames);
for i=1:backgroundFrames
    data(:,:,i)=uint8(peekdata(vid,1));
    imagesc(data(:,:,i)-mean(data,3))
    title(['Acquiring background (' sprintf('%d',i) '/' sprintf('%d',backgroundFrames) ')'])
    pause(.3)
end

flyTracks.bg = uint8(mean(data,3));
clear data

data=peekdata(vid,1);

h=image(data); colormap(gray)


i=0;
tic

tailCount = 0;
colors=hsv(nFlies+1);
propFields = {'Area' 'MajorAxisLength' 'Orientation' 'Centroid'}; %'Extrema'

while toc < duration
    
    %Set stimuli
    if stimTimes(ceil(toc))
        block = stimTimes(ceil(toc));
        valves = stim(block).odor(2,:);
        conc = stim(block).odor(1,:);
        epoch = ['Stim ' sprintf('%d', block)];
        
        if ~odorPeriod
            airPeriod = 0;
            odorPeriod = presentOdor(NIobject, aliComm, valves, conc);
        end
        
    else valves = [airLeft airRight];
        conc = [0.1 0.1];
        epoch = 'Air';
        
        if ~airPeriod
            odorPeriod = 0;
            airPeriod = presentAir(NIobject, aliComm, valves, conc);
        end
    end
    
    % Detect moving flies
    i=i+1;
    data=peekdata(vid,1);
    flyTracks.bg = 0.999*flyTracks.bg+0.001*data;
    flyTracks.times(i) = toc;
    delta = flyTracks.bg-data;
    mask = zeros(size(delta));
    mask(delta >= 20) = 1;
    mask = logical(mask);
    
    set(h,'CData',data)
    
    props = regionprops(mask, propFields);
    area = [props.Area];
    
    % Force detection of nFlies
    if size(props,1) > nFlies
        [~, idx]=sort(area,'descend');
        junkIdx=idx(nFlies+1:length(idx)); % The boundaries to discard
        k=1;
        
        center=cell(1,nFlies);
        head=cell(1,nFlies);
        majAx = cell(1,nFlies);
        
        for ii=1:size(props,1)
            if ii ~= junkIdx
                center{k}=props(ii).Centroid;
                ang(k) = props(ii).Orientation;
                kinematics = findHead(props(ii),delta);
                head{k} = kinematics.head;
                majAx{k} = [kinematics.lx; kinematics.ly];
                
                k=k+1;
            end
        end
        
        clear area idx boundaries
        flyCenter=center;
        
    else
        center=cell(1,size(props,1));
        head=cell(1,nFlies);
        majAx = cell(1,nFlies);
        kinematics = findHead(props,delta);
        
        for ii=1:size(props,1)
            center{ii}=props(ii).Centroid;
            ang(ii) = props(ii).Orientation;
            head{ii} = kinematics.head(ii,:);
            majAx{ii} = [kinematics.lx(ii,:); kinematics.ly(ii,:)];
        end
        
        clear area idx boundaries
        flyCenter=center;
    end
    
    clear bound %%%%%%%%%%%% Is this a relic? %%%%%%%%%%
    
    %Format for output
    if i <= runningLength
        for k=1:length(flyCenter)
            position = flyCenter{k};
            %hold all
            %plot(position(1),position(2),'o');
            flyPositions(i,1,k) = position(1);
            flyPositions(i,2,k) = position(2);
        end
        flyTracks.positions(i,:,:)=single(flyPositions(i,:,:));
        
    else
        flyPositions(1,:,:)=[];
        for k=1:length(flyCenter)
            position = flyCenter{k};
            flyPositions(runningLength,1,k) = position(1);
            flyPositions(runningLength,2,k) = position(2);
            %plot function used to be here
        end
        flyTracks.positions(i,:,:)=single(flyPositions(runningLength,:,:));
    end
    
    for ctr=1:nFlies
        flyTracks.head(i,:,ctr) = single(head{ctr});
        flyTracks.orientationX(i,:,ctr) = single(majAx{ctr}(1,:));
        flyTracks.orientationY(i,:,ctr) = single(majAx{ctr}(2,:));
        flyTracks.angle(i,ctr) = ang(ctr);
    end
    
    %update image at dispRate
    if mod(i,dispRate) == 0
        timeLeft=round(100*toc/duration);
        title(['Tracking Flies -' epoch ' (' sprintf('%d',timeLeft) '% done)'])
        tailCount = tailCount+1;
        
        for k=1:length(flyCenter)
            hold all
            if tailCount > 1
                set(p(k), 'XData', flyPositions(:,1,k), 'YData', flyPositions(:,2,k),...
                    'LineWidth',2,'Color',colors(k,:));
                
                set(ori(k), 'XData', majAx{k}(1,:), 'YData', majAx{k}(2,:),...
                    'LineWidth',2,'Color','g');
                
                set(hd(k), 'XData', head{k}(1), 'YData', head{k}(2),...
                    'Marker','*', 'Color','r');
                
            else
                p(k) = plot(flyPositions(:,1,k),flyPositions(:,2,k),...
                    'LineWidth',2,'color',colors(k,:));
                
                ori(k) = plot(majAx{k}(1,:),majAx{k}(2,:), ...
                    'LineWidth',2,'color','g');
                
                hd(k) = plot(head{k}(1),head{k}(2),'*r');
                
            end
            
        end
        
        drawnow
        
    end
end

%%% On finish %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Update this to auto-save and exit gracefully on crash
flyTracks.duration = duration;

for i=1:length(stim)
    flyTracks.stim{1,i} = ['Stim ' sprintf('%d',i)];
    flyTracks.stim{2,i} = stim(i).times;
    flyTracks.stim{3,i} = stim(i).odor;
end

stop(vid)

%%% Local Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function looping = presentAir(NI, aliComm, valves, conc)
        
        totalFlow = 1.6; %total flow rate through MFCs (mL/min)
        putvalue(NI.Line(2),0)
        putvalue(NI.Line(3),0)
        putvalue(NI.Line(4),0)
        putvalue(NI.Line(6),0)
        putvalue(NI.Line(7),0)
        putvalue(NI.Line(8),0)
        putvalue(NI.Line(valves(1)),1)
        putvalue(NI.Line(valves(2)),1)
        
        flowA = calcFlow(totalFlow-(totalFlow*conc(1)),5);
        flowB = calcFlow(totalFlow-(totalFlow*conc(2)),5);
        flowC = calcFlow(totalFlow*conc(1),1);
        flowD = calcFlow(totalFlow*conc(2),1);
        
        fprintf(aliComm, sprintf('%s%0.0f','A',flowA));
        fprintf(aliComm, sprintf('%s%0.0f','B',flowB));
        fprintf(aliComm, sprintf('%s%0.0f','C',flowC));
        fprintf(aliComm, sprintf('%s%0.0f','D',flowD));
        
        looping = 1;
    end

    function looping = presentOdor(NI, aliComm, valves, conc)
        
        totalFlow = 1.6; %total flow rate through MFCs (L/min)
        putvalue(NI.Line(1),0)
        putvalue(NI.Line(5),0)
        putvalue(NI.Line(valves(1)),1)
        putvalue(NI.Line(valves(2)),1)
        
        flowA = calcFlow(totalFlow-(totalFlow*conc(1)),5);
        flowB = calcFlow(totalFlow-(totalFlow*conc(2)),5);
        flowC = calcFlow(totalFlow*conc(1),1);
        flowD = calcFlow(totalFlow*conc(2),1);
        
        fprintf(aliComm, sprintf('%s%0.0f','A',flowA));
        fprintf(aliComm, sprintf('%s%0.0f','B',flowB));
        fprintf(aliComm, sprintf('%s%0.0f','C',flowC));
        fprintf(aliComm, sprintf('%s%0.0f','D',flowD));
        
        looping = 1;
    end

    function kinOut = findHead(props,delta)
        for q = 1:length(props)
            inp = props(q);
            
            % recover the major axis
            r = inp.MajorAxisLength/2;
            x = r* cos(inp.Orientation*(pi/180));
            y = r* sin(inp.Orientation*(pi/180));
            
            lx = [inp.Centroid(1)+x inp.Centroid(1)-x];
            ly = [inp.Centroid(2)-y inp.Centroid(2)+y];
            
            lr = (delta > 15 & delta < 40);
            c = improfile(lr, lx, ly);
            
            r = round(r/2);
            endcts = [sum(abs(c(1:r))) sum(abs(c(length(c)-r:end)))];
            headpos = [lx(endcts == min(endcts)) ly(endcts == min(endcts))];
            
            if length(headpos) > 2
                headpos = NaN(1,2); %not enough evidence to find head of this fly
            end
            
            kinOut.head(q,:) = headpos;
            kinOut.lx(q,:) = lx;
            kinOut.ly(q,:) = ly;
            
        end
    end
end
