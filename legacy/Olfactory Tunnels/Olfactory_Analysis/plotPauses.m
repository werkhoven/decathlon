function plotPauses(flyTracks,flyIdx)

pauses = find(flyTracks.pauses(:,flyIdx));

plot(flyTracks.relTimes, flyTracks.headLocal(:,2,flyIdx)-2); hold on
plot(flyTracks.relTimes(pauses), flyTracks.headLocal(pauses,2,flyIdx)-2, '.r')
line([0 380], [88 88], 'Color' ,'k', 'LineStyle', '--')
line([0 380], [112 112], 'Color' ,'k', 'LineStyle', '--')
xlim([180 360])