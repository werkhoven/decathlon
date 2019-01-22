function [active,activityParameter]=thresholdActivity(flyTracks)

experiment=flyTracks.exp;

switch experiment
    case 'Y-maze'
        active=flyTracks.numTurns>40;
        activityParameter='numTurns';
    case 'LED Y-maze'
        active=flyTracks.numTurns>25;
        activityParameter='numTurns';
    case 'Arena Circling'
        active=nanmean(flyTracks.speed)>0.1;
        activityParameter='speed';
    case 'Circadian'
        active=nanmean(flyTracks.speed)>0.1;
        activityParameter='speed';
    case 'Optomotor'
        active=flyTracks.nTrials>25;
        activityParameter='nTrials';
    case 'Slow Phototaxis'
        active=flyTracks.light_total_time>0.4;
        activityParameter='light_total_time';
end