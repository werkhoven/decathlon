k = 1; % Fly number

% Velocity min/max to scale colormap
l = [min(flyTracks.velocity(:,k)) max(flyTracks.velocity(:,k))];

c = colormap(jet(64));

colmap = linspace(l(1), l(2), 64);

hold on
for i = 1:length(flyTracks.velocity(:,k))
    try
        col = find(diff(flyTracks.velocity(i,k) > colmap));
        plot(i,flyTracks.headLocal(i,2,k), '.', 'Color', c(col,:))
    end
end

line([0 size(flyTracks.orientation,1)], [max(flyTracks.corridorPos) max(flyTracks.corridorPos)], 'Color' ,'k', 'LineStyle', '--')
line([0 size(flyTracks.orientation,1)], [min(flyTracks.corridorPos) min(flyTracks.corridorPos)], 'Color' ,'k', 'LineStyle', '--')