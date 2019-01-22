function [data,f] = getDataFields(expmt)

    switch expmt.Name
        
        case 'Arena Circling'
            
            f = {'circling';'speed'}; 
            data.circling = expmt.handedness.mu;
            data.speed = expmt.Speed.avg;
            
            if ~isfield(expmt.Speed,'active')
                expmt.Speed.active = expmt.Speed.avg > 0.1;
            end
            
            data.filter = expmt.Speed.active;
            
            if isfield(expmt,'Gravitaxis');
                f = [f;{'yBias';'xBias';'index';'prob'}];
                data.yBias = expmt.Gravitaxis.yBias;
                data.xBias = expmt.Gravitaxis.xBias;
                data.index = expmt.Gravitaxis.index;
                data.prob = expmt.Gravitaxis.prob;
            end

        case 'Y-maze'     
            
            idx = 1:expmt.nTracks;
            
            f = {'right_bias';'hand_clumpiness';'hand_switchiness';'speed'}; 
            data.circling_mu = expmt.handedness.mu(idx);
            data.right_bias = expmt.Turns.rBias(idx);
            data.hand_clumpiness = expmt.Turns.clumpiness(idx);
            data.hand_switchiness = expmt.Turns.switchiness(idx);
            data.speed = expmt.Speed.avg(idx);
            data.filter = expmt.Turns.n(idx) > 25;

        case 'LED Y-maze'

            idx = expmt.labels{1,4}:expmt.labels{1,5};
            
            f = {'right_bias';'light_bias';'hand_clumpiness';'hand_switchiness';'light_switchiness';'speed'}; 
            data.right_bias = expmt.Turns.rBias(idx);
            data.light_bias = expmt.LightChoice.pBias(idx);
            data.hand_clumpiness = expmt.Turns.clumpiness(idx);
            data.hand_switchiness = expmt.Turns.switchiness(idx);
            data.light_switchiness = expmt.LightChoice.switchiness(idx);
            data.speed = expmt.Speed.avg(idx);
            data.filter = expmt.Turns.n(idx) > 25;

        case 'Slow Phototaxis'

            f = {'circling';'speed';'occupancy'}; 
            data.circling = expmt.handedness.mu;
            data.occupancy = expmt.Light.avg_occ;
            data.speed = expmt.Speed.avg;
            data.filter = expmt.Speed.active;

        case 'Optomotor'

            f = {'circling';'speed';'optomotor_index'}; 
            data.circling = expmt.handedness.mu;
            data.optomotor_index = -expmt.Optomotor.index;
            if isfield(expmt.Speed,'avg')
                data.speed = expmt.Speed.avg;
                data.filter = expmt.Speed.active;
            else
                data.speed = nanmean(expmt.Speed.data);
                data.filter = data.speed > 0.01;
            end
            

        case 'Circadian'

            
            f = {'circling';'speed'}; 
            data.circling = expmt.handedness.mu;
            data.speed = nanmean(expmt.Speed.data);
            data.filter = data.speed > 0.1;

            if isfield(expmt,'Gravity');
                %{
                f = [f;{'index';'circling_corrected';'circling_floor';'circling_ceiling'}];

                data.index = expmt.Gravity.index;
                data.circling_corrected = expmt.Gravity.mu;
                data.circling_ceiling = expmt.handedness_ceiling.mu;
                data.circling_floor = expmt.handedness_floor.mu;
                %}
                
                f = [f;{'gravitactic_index'}];

                data.gravitactic_index = expmt.Gravity.index;
                data.circling = expmt.Gravity.mu;

            end

        case 'Olfaction'
            
            f = {'occupancy';'right_bias';'hand_clumpiness';'hand_switchiness';'speed'};
            data.occupancy = expmt.occupancy;
            data.right_bias = expmt.Turns.rBias;
            data.hand_clumpiness = expmt.Turns.clumpiness;
            data.hand_switchiness = expmt.Turns.switchiness;
            data.speed = nanmean(expmt.velocity);
            data.filter = data.speed > 1;
            
        case 'Temporal Phototaxis'
            
            f = {'circling';'speed';'occupancy';'iti'}; 
            data.circling = expmt.handedness.mu;
            data.speed = expmt.Speed.avg;
            data.occupancy = expmt.LightStatus.occ;
            data.iti = expmt.LightStatus.iti;
            
            if ~isfield(expmt.Speed,'active')
                expmt.Speed.active = expmt.Speed.avg > 0.01;
            end
            
            data.filter = expmt.Speed.active;

        otherwise
            errordlg('Experiment name not recognized, no analysis performed');
            
    end
    %{
    if isfield(expmt.ROI,'cam_dist')
        f = [f;'cam_dist'];
        data.cam_dist = expmt.ROI.cam_dist(1:expmt.nTracks);
    end
    %}
    
    % standardize dimensions
    fn = fieldnames(data);
    for i = 1:length(fn)
        tmp = data.(fn{i});
        if find(size(tmp)==expmt.nTracks,1)==2
            data.(fn{i}) = data.(fn{i})';
        end
    end      
        
    
end