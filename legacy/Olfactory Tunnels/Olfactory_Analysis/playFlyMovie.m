function playFlyMovie(flyTracks, startTime)

if nargin < 2, startTime = 0; end

for k = 1:flyTracks.nFlies
    for i = 1:size(flyTracks.centroid,1)
        
        r = flyTracks.majorAxisLength(i,k)/2;
        
        x = r* cos(flyTracks.orientation(i,k)*(pi/180));
        y = r* sin(flyTracks.orientation(i,k)*(pi/180));
        
        % x-values of endpts
        lx(i,:,k) = [flyTracks.centroid(i,1,k)+x flyTracks.centroid(i,1,k)-x];
        
        % y-values of endpts
        ly(i,:,k) = [flyTracks.centroid(i,2,k)-y flyTracks.centroid(i,2,k)+y];
        
    end
end

t = find(flyTracks.relTimes > startTime,1);


for i = t:length(flyTracks.centroid)
    imshow(flyTracks.bg)
    hold on
    
    for k = 1:flyTracks.nFlies
        
        if any(i == flyTracks.turns(k).right)
            plot(lx(i,:,k), ly(i,:,k), '-r')
            plot(flyTracks.headPosition(i,1,k), flyTracks.headPosition(i,2,k), '.r')
        elseif any(i == flyTracks.turns(k).left)
            plot(lx(i,:,k), ly(i,:,k), '-b')
            plot(flyTracks.headPosition(i,1,k), flyTracks.headPosition(i,2,k), '.b')
        else
            plot(lx(i,:,k), ly(i,:,k), '-g')
            plot(flyTracks.headPosition(i,1,k), flyTracks.headPosition(i,2,k), '.k')
        end
    end
    title(sprintf('%f', flyTracks.relTimes(i)))
    pause(0.001)
    clf
end