function [data,fn] = getDataFields_abshand(expmt,trackProps)

    switch expmt.Name
        
        case 'Arena Circling'
            
            data.circling = expmt.handedness.mu;
            data.abs_circling = abs(expmt.handedness.mu);
            data.speed = expmt.Speed.avg;
            data.filter = expmt.Speed.active;

        case 'Y-maze'     
            
            idx = expmt.labels{1,4}:expmt.labels{1,5};
            expmt.nTracks = length(idx);
            
            data.circling = expmt.handedness.mu(idx);
            data.abs_circling = abs(expmt.handedness.mu(idx));
            data.right_bias = expmt.Turns.rBias(idx);
            data.abs_right_bias = abs(0.5-expmt.Turns.rBias(idx));
            data.hand_clumpiness = expmt.Turns.clumpiness(idx);
            data.hand_switchiness = expmt.Turns.switchiness(idx);
            data.speed = expmt.Speed.avg(idx);
            data.filter = expmt.Turns.active(idx);

        case 'LED Y-maze'

            idx = expmt.labels{1,4}:expmt.labels{1,5};
            expmt.nTracks = length(idx);

            data.circling = expmt.handedness.mu(idx);
            data.abs_circling = abs(expmt.handedness.mu(idx));
            data.right_bias = expmt.Turns.rBias(idx);
            data.abs_right_bias = abs(0.5-expmt.Turns.rBias(idx));
            data.light_bias = expmt.LightChoice.pBias(idx);
            data.hand_clumpiness = expmt.Turns.clumpiness(idx);
            data.hand_switchiness = expmt.Turns.switchiness(idx);
            data.light_switchiness = expmt.LightChoice.switchiness(idx);
            data.speed = expmt.Speed.avg(idx);
            data.filter = expmt.Turns.active(idx);

        case 'Slow Phototaxis'

            data.circling = expmt.handedness.mu;
            data.abs_circling = abs(expmt.handedness.mu);
            data.occupancy = expmt.Light.avg_occ;
            data.speed = expmt.Speed.avg;
            data.filter = expmt.Speed.active;

        case 'Optomotor'

            data.circling = expmt.handedness.mu;
            data.abs_circling = abs(expmt.handedness.mu);
            data.optomotor_index = abs(expmt.Optomotor.index);
            data.speed = expmt.Speed.avg;
            data.filter = expmt.Speed.active;

        case 'Circadian'

            data.circling = expmt.handedness.mu;
            data.abs_circling = abs(expmt.handedness.mu);
            data.speed = nanmean(expmt.Speed.data);
            data.filter = data.speed > 0.1;
            
        case 'Olfaction'
            
            data.occupancy = expmt.occupancy;
            data.orientation = nanmean(diff(expmt.orientation));
            data.preodor_occupancy = expmt.preOdorOccupancy;
            data.right_bias = expmt.Turns.rBias;
            data.abs_right_bias = abs(0.5-expmt.Turns.rBias);
            data.hand_clumpiness = expmt.Turns.clumpiness;
            data.hand_switchiness = expmt.Turns.switchiness;
            data.speed = nanmean(expmt.velocity);
            data.filter = data.speed > 1;

        otherwise
            errordlg('Experiment name not recognized, no analysis performed');
            
    end
    
    % standardize dimensions
    fn = fieldnames(data);
    for i = 1:length(fn)
        tmp = data.(fn{i});
        if find(size(tmp)==expmt.nTracks,1)==2
            data.(fn{i}) = data.(fn{i})';
        end
    end
    
    fn(strmatch('filter',fn))=[];
        
    
end