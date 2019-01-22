%% Re-analyze handedness

% before starting, be sure to put all the files you want to re-analyze 
% within the same nested directory (meaning that don't need to be in
% the same folder, but that you need to be able to select a higher
% directory that will contain all the files to be analyzed in a sub
% directory

dfields = {'Centroid';'Time';'Texture';'StimAngle'};           % fields to be decimated
dfac = 10;                                                     % factor by which to decimate data
args={'Dir';'getdir';'Decimate';dfields;'DecFac';dfac;...
    'Keyword';'Slow Phototaxis';'Raw'};

% run the analysis scripts
analyze_multiFile(args{:});