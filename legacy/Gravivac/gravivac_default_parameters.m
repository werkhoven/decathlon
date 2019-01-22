%% default parameters for running gravivac analysis

d=[1,2,3];                              % testing days
p={'histogram';'bootstrap'};            % plots to make
choice_thresh = 10;

analyze_gravivac('Day',d,'Plots',p,'Thresh',choice_thresh);


%% correlation analysis

[corrMat,p_values,activityLevel,data] = decInterExpCorr_multiFile('Gravity','Subfield','bias');