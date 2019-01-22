function out=decathlonDealNaNs(flyData)

for i = 1:length(flyData)

    if isempty(flyData(i).photo) > 0

        flyData(i).photo.lightprob = NaN;
        flyData(i).photo.choicepermin = NaN;
        flyData(i).photo.habituation = NaN;
        flyData(i).photo.clumpiness = NaN;
        flyData(i).photo.maze = NaN;
        flyData(i).photo.direction = NaN;
    end

        nanData(i).ymaze.numTurns = NaN;
        nanData(i).ymaze.TurnBias = NaN;
        nanData(i).ymaze.TurnsPermin = NaN;
        nanData(i).ymaze.switchiness = NaN;
        nanData(i).ymaze.clumpiness = NaN;
        nanData(i).ymaze.TurnSequence = NaN;
        nanData(i).ymaze.tStamps = NaN;
        nanData(i).ymaze.ROIcoords = NaN;
        nanData(i).ymaze.date = NaN;
        nanData(i).ymaze.time = NaN;
    
    if isnan(flyData(i).ymaze) > 0
        flyData(i).ymaze=nanData(i).ymaze;
    end
    
        nanData(i).circles.mu = NaN;
        nanData(i).circles.angleavg = NaN;
        nanData(i).circles.numTrials = NaN;
        nanData(i).circles.angleSD = NaN;
        nanData(i).circles.angleSEM = NaN;
        nanData(i).circles.speed = NaN;
        nanData(i).circles.edgeposition = NaN;
        nanData(i).circles.habituation = NaN;
    
    if isnan(flyData(i).circles.mu) > 0
        flyData(i).circles=nanData(i).circles;
    end

    if isempty(flyData(i).olfaction) > 0

        flyData(i).olfaction.odorbias = NaN;
        flyData(i).olfaction.avg_velocity = NaN;
        flyData(i).olfaction.occupancy = NaN;
        flyData(i).olfaction.pauseRate = NaN;
        flyData(i).olfaction.Rturnbias = NaN;
    end

     if isempty(flyData(i).gravity) > 0

        flyData(i).gravity.graviprob = NaN;
        flyData(i).gravity.choicepermin = NaN;
        flyData(i).gravity.habituation = NaN;
        flyData(i).gravity.clumpiness = NaN;
        flyData(i).gravity.numTrials = NaN;
        flyData(i).gravity.maze = NaN;
    end

end

out=flyData;