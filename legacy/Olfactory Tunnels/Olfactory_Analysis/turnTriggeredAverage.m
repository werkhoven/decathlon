function flyTracks = turnTriggeredAverage(flyTracks)

winsz = 100; % size of window
param = 'orientation';

for k = 1:flyTracks.nFlies
        
    tturn = flyTracks.turns(k).all; % get the times of each turn
    
    ct = 0;
    clear tta
    
    for i =1:length(tturn)
        try
            % Line below must be altered for param other than orientation
            tmp = eval(['flyTracks.' param '(tturn(i)-winsz:tturn(i),k)']);
            ct = ct + 1;
            tta(ct,:) = tmp;
        end
    end
    
    flyTracks.tta(k).all = tta;
    
    
    
	tturn = flyTracks.turns(k).left; % get the times of each turn
    
    ct = 0;
    clear tta
    
    for i =1:length(tturn)
        try
            % Line below must be altered for param other than orientation
            tmp = eval(['flyTracks.' param '(tturn(i)-winsz:tturn(i),k)']);
            ct = ct + 1;
            tta(ct,:) = tmp;
        end
    end
    
    flyTracks.tta(k).left = tta;
    
    
    
	tturn = flyTracks.turns(k).right; % get the times of each turn
    
    ct = 0;
    clear tta
    
    for i =1:length(tturn)
        try
            % Line below must be altered for param other than orientation
            tmp = eval(['flyTracks.' param '(tturn(i)-winsz:tturn(i),k)']);
            ct = ct + 1;
            tta(ct,:) = tmp;
        end
    end
    
    flyTracks.tta(k).right = tta;
    flyTracks.handedness(k) = length(flyTracks.turns(k).left)/...
        length(flyTracks.turns(k).all);
    
end

% fly = 1;
% hold on
% dt = linspace(-(winsz/flyTracks.rate),0,winsz+1);
% plot(dt,mean(flyTracks.tta(fly).left))
% plot(dt,mean(flyTracks.tta(fly).right),'r')
% xlim([min(dt) 0])

