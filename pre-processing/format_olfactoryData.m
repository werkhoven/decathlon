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


fPaths = getHiddenMatDir(fDir,'keyword','processed');
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
    expmt = flyTracks;
    expmt.Name = 'Olfaction';
    clearvars flyTracks
    expmt.nTracks = expmt.nFlies;
    expmt = rmfield(expmt,'nFlies');
    
    % update waitbar
    hwb = waitbar(j/length(fPaths),hwb,['processing file ' num2str(j) ' of ' num2str(length(fPaths))]);
    
    
    % format file label
    idx = find(fName{j}=='_',2);
    expmt.date = fName{j}(1:idx(2)-1);
    expmt.fLabel = [expmt.date '_' expmt.Name];
    f = fieldnames(label);
    expmt.ID = expmt.ID(~isnan(expmt.ID));
    for i = 1:length(f)
        switch f{i}
            case 'Strain'
                expmt.(f{i}) = label.(f{i});
                expmt.expmt.Turns.activeLabel = [expmt.fLabel '_' label.(f{i})];
            case 'Sex'
                expmt.(f{i}) = label.(f{i});
                expmt.fLabel = [expmt.fLabel '_' label.(f{i})];
            case 'Treatment'
                expmt.(f{i}) = label.(f{i});
                expmt.fLabel = [expmt.fLabel '_' label.(f{i})];
            case 'Day'
                expmt.(f{i}) = label.(f{i});
                expmt.fLabel = [expmt.fLabel '_Day' num2str(label.(f{i}))];
            case 'ID'
                ids = expmt.ID;
                expmt.fLabel = [expmt.fLabel '_' num2str(ids(1)) '-' num2str(ids(end))];
        end
    end
    
    
    % convert format to ymaze turn format
    expmt.Turns.n = NaN(expmt.nTracks,1); 
    for i = 1:expmt.nTracks
        expmt.Turns.n(i) = length(expmt.turns(i).all);
    end
    
    % record right turn probability, turn sequence, and turn timing
    expmt.Turns.rBias = NaN(expmt.nTracks,1);
    expmt.Turns.sequence = NaN(max(expmt.Turns.n),expmt.nTracks);
    expmt.Turns.t = NaN(max(expmt.Turns.n),expmt.nTracks);    
    
    for i = 1:expmt.nTracks
        
        r = expmt.turns(i).right;
        t = expmt.turns(i).all;
        expmt.Turns.rBias(i) = length(r)/length(t);
        expmt.Turns.sequence(1:length(t),i) = ismember(t,r);
        expmt.Turns.t(1:length(t),i) = t;
    
    end
    
    % Calculate clumpiness and switchiness
    expmt.Turns.switchiness = NaN(expmt.nTracks,1);
    expmt.Turns.clumpiness = NaN(expmt.nTracks,1);
    for i = 1:expmt.nTracks

        idx = ~isnan(expmt.Turns.sequence(:,i));
        s = expmt.Turns.sequence(idx,i);
        r = expmt.Turns.rBias(i);
        n = expmt.Turns.n(i);
        t = expmt.Turns.t(idx,i);
        iti = (t(2:end) - t(1:end-1));

        expmt.Turns.switchiness(i) = sum((s(1:end-1)+s(2:end))==1)/(2*r*(1-r)*n);
        expmt.Turns.clumpiness(i) = std(iti) / mean(iti);

    end
    
    expmt = rmfield(expmt,'turns');
    
    % create new folder if necessary and save file
    expmt.fDir = [fDir{j} expmt.fLabel ,'\'];
    if ~exist(expmt.fDir,'dir')
        [mkst,~] = mkdir(expmt.fDir);
    end
    
    expmt.fPath = [expmt.fDir expmt.fLabel '.mat'];
    save(expmt.fPath,'expmt');
    
    
end

delete(hwb);