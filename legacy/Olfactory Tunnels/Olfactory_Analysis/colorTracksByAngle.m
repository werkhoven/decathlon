k =14; % Fly number

% Velocity min/max to scale colormap
l = [min(flyTracks.orientation(:,k)) max(flyTracks.orientation(:,k))];

c = colormap(jet(64));

colmap = linspace(l(1), l(2), 64);

hold on
for i = 1:length(flyTracks.orientation(:,k))
    try
        col = find(diff(flyTracks.orientation(i,k) > colmap));
        plot(flyTracks.relTimes(i), flyTracks.centroidLocal(i,2,k), '.', 'Color', c(col,:))
    end
end