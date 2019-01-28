function [data,f] = getDataFields(expmt)

    reset(expmt);
    switch expmt.meta.name
        
        case 'Basic Tracking'
            
            f = {'circling';'speed'}; 
            data.circling = expmt.meta.handedness.mu;
            data.speed = nanmean(expmt.data.speed.raw());
            data.filter = nanmean(expmt.data.speed.raw()) > 0.1;

        case 'Y-Maze'     
            
            idx = 1:numel(expmt.meta.labels_table.ID);
            expmt.meta.num_traces = numel(expmt.meta.labels_table.ID);
            
            f = {'circling_mu';'right_bias';'hand_clumpiness';...
                'hand_switchiness';'speed';'nTrials'};
            data.circling_mu = expmt.meta.handedness.mu(idx);
            data.right_bias = expmt.data.Turns.rBias(idx);
            data.hand_clumpiness = expmt.data.Turns.clumpiness(idx);
            data.hand_switchiness = expmt.data.Turns.switchiness(idx);
            data.speed = nanmean(expmt.data.speed.raw(:,idx));
            data.nTrials = expmt.data.Turns.n(idx);
            data.filter = expmt.data.Turns.n(idx) > 25;

        case 'LED Y-maze'

            idx = 1:numel(expmt.meta.labels_table.ID);
            expmt.meta.num_traces = numel(expmt.meta.labels_table.ID);
            
            f = {'circling_mu';'right_bias';'light_bias';...
                'hand_clumpiness';'hand_switchiness';'speed';'nTrials'}; 
            data.circling_mu = expmt.meta.handedness.mu(idx);
            data.right_bias = expmt.data.Turns.rBias(idx);
            data.light_bias = expmt.data.LightChoice.pBias(idx);
            data.hand_clumpiness = expmt.data.Turns.clumpiness(idx);
            data.hand_switchiness = expmt.data.Turns.switchiness(idx);
            data.light_switchiness = expmt.data.LightChoice.switchiness(idx);
            data.speed = nanmean(expmt.data.speed.raw(:,idx));
            data.nTrials = expmt.data.Turns.n(idx);
            data.filter = expmt.data.Turns.n(idx) > 25;

        case 'Slow Phototaxis'

            f = {'circling';'speed';'occupancy';'nTrials'}; 
            data.circling = expmt.meta.handedness.mu;
            data.occupancy = expmt.meta.Light.avg_occ;
            data.speed = nanmean(expmt.data.speed.raw());
            data.nTrials = cellfun(@(t) sum(t>0), expmt.meta.Light.tInc);
            data.filter = nanmean(expmt.data.speed.raw()) > 0.1;

        case 'Optomotor'

            f = {'circling';'speed';'optomotor_index';'nTrials'}; 
            data.circling = expmt.meta.handedness.mu;
            data.optomotor_index = -expmt.meta.Optomotor.index;
            data.speed = nanmean(expmt.data.speed.raw());
            data.nTrials = sum(diff(expmt.data.StimStatus.raw())==1);
            data.filter = nanmean(expmt.data.speed.raw()) > 0.1;
            
        case 'Circadian'
            
            f = {'circling';'speed';'gravitactic_index'}; 
            data.circling = expmt.meta.handedness.mu;
            data.gravitactic_index = expmt.data.area.gravity_index;
            data.speed = nanmean(expmt.data.speed.raw());
            data.filter = nanmean(expmt.data.speed.raw()) > 0.1;

        case 'Olfaction'
            
            f = {'occupancy';'right_bias';'hand_clumpiness';...
                'hand_switchiness';'speed';'nTrials'};
            data.occupancy = expmt.meta.occupancy;
            data.right_bias = expmt.data.Turns.rBias;
            data.hand_clumpiness = expmt.data.Turns.clumpiness;
            data.hand_switchiness = expmt.data.Turns.switchiness;
            data.speed = nanmean(expmt.meta.velocity);
            data.nTrials = expmt.data.Turns.n;
            data.filter = data.speed > 1;
            
        case 'Temporal Phototaxis'
            
            f = {'circling';'speed';'occupancy';'iti';'nTrials'}; 
            data.circling = expmt.meta.handedness.mu;
            data.speed = nanmean(expmt.data.speed.raw());
            data.occupancy = expmt.data.LightStatus.occ;
            data.iti = expmt.data.LightStatus.iti;       
            data.nTrials = expmt.data.LightStatus.n;
            data.filter = nanmean(expmt.data.speed.raw()) > 0.1;

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
        if find(size(tmp)==expmt.meta.num_traces,1)==2
            data.(fn{i}) = data.(fn{i})';
        end
    end      
        
    
end