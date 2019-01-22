function plotChoiceProbByChoiceNumber

%--------------------- Choice prob by Choice Number ------------------%
figure;

byChoice = NaN(size(flyTracks.inCorridor(k).refOdorChosen,2), max(structfun(@length, flyTracks.inCorridor.refOdorChosen)));

for i = 1:size(byChoice,1)
    byChoice(i,1:length(flyTracks.inCorridor(i).refOdorChosen)) = flyTracks.inCorridor(i).refOdorChosen;
end

plot(nanmean(byChoice), '.-')
ylim([0 1])
%---------------------------------------------------------------------%