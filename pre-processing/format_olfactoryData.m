function format_olfactoryData(varargin)

%% parse input vars
label=[];
label.ID=[];
for i = 1:length(varargin)
    
    arg = varargin{i};
    if ischar(arg)
        switch arg
            case 'Strain'
                i = i+1;
                label.Strain = varargin{i};
            case 'Treatment'
                i = i+1;
                label.Treatment = varargin{i};
            case 'Sex'
                i = i+1;
                label.Sex = varargin{i};
            case 'Day'
                i = i+1;
                label.Day = varargin{i};
        end
    end
    
end

%% Get parent directory of all olfactory files

fDir = autoDir;
fPaths = recursiveSearch(fDir,'keyword','processed');
fDir=cell(size(fPaths));
fName=cell(size(fPaths));
for j=1:length(fPaths)
    [tmp_dir,tmp_name,~]=fileparts(fPaths{j});
    fDir(j) = {[tmp_dir '\']};
    fName(j) = {tmp_name};
end


%% process files sequentially

hwb = waitbar(0,'loading data');

for j = 1:length(fPaths)
    
    load(fPaths{j});                    % read in flyTracks struct
    expmt = ExperimentData;
    expmt.meta.name = 'Olfaction';
    expmt.meta.num_traces = flyTracks.nFlies;
    N = flyTracks.nFlies;
    
    % update waitbar
    hwb = waitbar(j/length(fPaths),hwb,['processing file ' num2str(j) ' of ' num2str(length(fPaths))]);
    
    % format file label
    fLabel = [fName{j} '_' expmt.meta.name];
    f = fieldnames(label);
    ID = flyTracks.ID(~isnan(flyTracks.ID));
    for i = 1:length(f)
        expmt.meta.(f{i}) = label.(f{i});
    end
    
    expmt.meta.labels_table =  table(repmat({label.Strain},N,1),repmat({label.Sex},N,1),...
        repmat({label.Treatment},N,1),repmat(label.Day,N,1),ID',...
        'VariableNames',{'Strain';'Sex';'Treatment';'Day';'ID'});
    
    
    % convert format to ymaze turn format
    fturns = flyTracks.turns;
    turns.n = NaN(expmt.meta.num_traces,1); 
    for i = 1:expmt.meta.num_traces
        turns.n(i) = length(fturns(i).all);
    end
    
    % record right turn probability, turn sequence, and turn timing
    turns.rBias = NaN(expmt.meta.num_traces,1);
    turns.sequence = NaN(max(turns.n),expmt.meta.num_traces);
    turns.t = NaN(max(turns.n),expmt.meta.num_traces);    
    
    for i = 1:expmt.meta.num_traces
        r = fturns(i).right;
        t = fturns(i).all;
        turns.rBias(i) = length(r)/length(t);
        turns.sequence(1:length(t),i) = ismember(t,r);
        turns.t(1:length(t),i) = t;
    end
    
    % Calculate clumpiness and switchiness
    turns.switchiness = NaN(expmt.meta.num_traces,1);
    turns.clumpiness = NaN(expmt.meta.num_traces,1);
    for i = 1:expmt.meta.num_traces
        idx = ~isnan(turns.sequence(:,i));
        s = turns.sequence(idx,i);
        r = turns.rBias(i);
        n = turns.n(i);
        t = turns.t(idx,i);
        iti = (t(2:end) - t(1:end-1));
        turns.switchiness(i) = sum((s(1:end-1)+s(2:end))==1)/(2*r*(1-r)*n);
        turns.clumpiness(i) = std(iti) / mean(iti);
    end
    
    % record turning metrics
    expmt.data.Turns = RawDataField;
    f = fieldnames(turns);
    addprops(expmt.data.Turns, f);
    for i=1:numel(f)
        expmt.data.Turns.(f{i}) = turns.(f{i});
    end
    
    % record occupancy
    expmt.meta.occupancy = flyTracks.occupancy;
    expmt.meta.velocity = flyTracks.velocity;
    
    % create new folder if necessary and save file
    expmt.meta.path.dir = [fDir{j} fLabel ,'\'];
    if ~exist(expmt.meta.path.dir,'dir')
        [mkst,~] = mkdir(expmt.meta.path.dir);
    end
    
    expmt.meta.path.full = [expmt.meta.path.dir fLabel '.mat'];
    expmt.meta.path.name = fLabel;
    save(expmt.meta.path.full,'expmt');
    
    
end

delete(hwb);