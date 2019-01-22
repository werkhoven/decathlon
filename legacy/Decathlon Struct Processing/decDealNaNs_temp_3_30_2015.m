function out=decDealNaNs(data)

for i = 1:length(data)

    tempstruct = data(i).photo;
    fields = fieldnames(tempstruct);
    
        nanData(i).photo.p_lightprob = NaN;
        nanData(i).photo.p_numTrials = NaN;
        nanData(i).photo.p_choicepermin = NaN;
        nanData(i).photo.p_habituation = NaN;
        nanData(i).photo.p_clumpiness = NaN;
        %nanData(i).photo.maze = NaN;
        %nanData(i).photo.direction = NaN;
        
    %NOTE: Special condition used to edit the matrix after already made
    if strcmp(fields(2),'p_numTrials')~=1
        data(i).photo=nanData(i).photo;
    end

    tempstruct = data(i).ymaze;
    fields = fieldnames(tempstruct);
    
        %nanData(i).ymaze.numTurns = NaN;
        nanData(i).ymaze.y_TurnBias = NaN;
        nanData(i).ymaze.y_TurnsPermin = NaN;
        nanData(i).ymaze.y_switchiness = NaN;
        nanData(i).ymaze.y_clumpiness = NaN;
        %nanData(i).ymaze.TurnSequence = NaN;
        %nanData(i).ymaze.tStamps = NaN;
        %nanData(i).ymaze.ROIcoords = NaN;
        %nanData(i).ymaze.date = NaN;
        %nanData(i).ymaze.time = NaN;
    
        %NOTE: Special condition used to edit the matrix after already made
    if strcmp(fields(1),'numTurns')==1
        data(i).ymaze=nanData(i).ymaze;
    end
    
        nanData(i).circles.mu = NaN;
        nanData(i).circles.c_speed = NaN;
        nanData(i).circles.c_edgeposition = NaN;
        nanData(i).circles.c_habituation = NaN;
        %nanData(i).circles.numTrials = NaN;
    
    if isnan(data(i).circles.mu) > 0
        data(i).circles=nanData(i).circles;
    end

        tempstruct = data(i).olfaction;
        fields = fieldnames(tempstruct);

        nanData(i).olfaction.o_odorbias = NaN;
        nanData(i).olfaction.o_avg_velocity = NaN;
        nanData(i).olfaction.o_occupancy = NaN;
        nanData(i).olfaction.o_pauseRate = NaN;
        nanData(i).olfaction.o_Rturnbias = NaN;
        
    if strcmp(fields(1),'odorbias')==1
        data(i).olfaction=nanData(i).olfaction;
    end

        nanData(i).gravity.g_graviprob = NaN;
        nanData(i).gravity.g_choicepermin = NaN;
        nanData(i).gravity.g_numTrials = NaN;
        nanData(i).gravity.g_habituation = NaN;
        nanData(i).gravity.g_clumpiness = NaN;
        %nanData(i).gravity.maze = NaN;

        tempstruct = data(i).gravity;
        fields = fieldnames(tempstruct);
        
        %NOTE: Special condition used to edit the matrix after already made
    if strcmp(fields(1),'graviprob')==1
        data(i).gravity=nanData(i).gravity;
    end
    
    
        nanData(i).photo2.p_lightprob = NaN;
        nanData(i).photo2.p_numTrials = NaN;
        nanData(i).photo2.p_choicepermin = NaN;
        nanData(i).photo2.p_habituation = NaN;
        nanData(i).photo2.p_clumpiness = NaN;
        %nanData(i).photo.maze = NaN;
        %nanData(i).photo.direction = NaN;
        
    %NOTE: Special condition used to edit the matrix after already made
    if isempty(data(i).photo2)==1
        data(i).photo2=nanData(i).photo2;
    end
    
end

out=data;