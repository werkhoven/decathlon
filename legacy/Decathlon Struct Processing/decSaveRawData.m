for i = 1:length(flyData)
    
    % Phototaxis
    photoData(i).ID=flyData(i).ID;
    photoData(i).p_lightprob=flyData(i).photo.lightprob;
    photoData(i).p_choicepermin=flyData(i).photo.choicepermin;
    photoData(i).p_habituation=flyData(i).photo.habituation;
    photoData(i).p_clumpiness=flyData(i).photo.clumpiness;
    photoData(i).p_maze=flyData(i).photo.maze;
    photoData(i).p_direction=flyData(i).photo.direction; 
    
    circData(i).ID=flyData(i).ID;
    circData(i).c_mu=flyData(i).circles.mu;
    circData(i).c_angleavg=flyData(i).circles.angleavg;
    circData(i).c_numTrials=flyData(i).circles.numTrials;
    circData(i).c_speed=flyData(i).circles.speed;
    circData(i).c_habituation=flyData(i).circles.habituation;
    circData(i).c_edgeposition=flyData(i).circles.edgeposition;
    circData(i).c_angleSD=flyData(i).circles.angleSD;
    circData(i).c_angleSEM=flyData(i).circles.angleSEM;
    
    olfData(i).ID=flyData(i).ID;
    olfData(i).o_odorbias = flyData(i).olfaction.odorbias;
    olfData(i).o_avg_velocity=flyData(i).olfaction.avg_velocity ;
    olfData(i).o_occupancy =flyData(i).olfaction.occupancy;
    olfData(i).o_pauseRate =flyData(i).olfaction.pauseRate;
    olfData(i).o_Rturnbias =flyData(i).olfaction.Rturnbias;
        
    yData(i).ID=flyData(i).ID;
    yData(i).y_numTurns = flyData(i).ymaze.numTurns;
    yData(i).y_TurnBias =flyData(i).ymaze.TurnBias;
    yData(i).y_TurnsPermin =flyData(i).ymaze.TurnsPermin;
    yData(i).y_switchiness =flyData(i).ymaze.switchiness;
    yData(i).y_clumpiness =flyData(i).ymaze.clumpiness;
    yData(i).y_TurnSequence =flyData(i).ymaze.TurnSequence;
    yData(i).y_tStamps =flyData(i).ymaze.tStamps;
    yData(i).y_ROIcoords =flyData(i).ymaze.ROIcoords;
    yData(i).y_date =flyData(i).ymaze.date;
    yData(i).y_time =flyData(i).ymaze.time;
    
    gravData(i).ID=flyData(i).ID;
    gravData(i).g_graviprob=flyData(i).gravity.graviprob;
    gravData(i).g_choicepermin=flyData(i).gravity.choicepermin;
    gravData(i).g_habituation=flyData(i).gravity.habituation;
    gravData(i).g_clumpiness=flyData(i).gravity.clumpiness;
    gravData(i).g_numTrials=flyData(i).gravity.numTrials;
    gravData(i).g_maze=flyData(i).gravity.maze;
end