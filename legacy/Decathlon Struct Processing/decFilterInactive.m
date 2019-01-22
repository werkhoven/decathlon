function out=decFilterInactive(flyData);

numFlies = length(flyData);

fields=fieldnames(flyData);

for i=1:length(fields)
    fieldNum(i)=sum(double(char(fields(i,:))));
end

%% Set activity thresholds

% Minimum trials
photo=sum(double('photo'));
p_check=sum(fieldNum==photo)>0;
if p_check>0
photoThresh = 10;
photoStruct = [flyData.photo];
end

photo2=sum(double('photo2'));
p2_check=sum(fieldNum==photo2)>0;
if p2_check>0
photo2Struct = [flyData.photo2];
end

% Minimum trials
gravity=sum(double('gravity'));
g_check=sum(fieldNum==gravity)>0;
if g_check>0
gravThresh = 1.65;
gravStruct = [flyData.gravity];
end

% Turns per min
ymaze=sum(double('ymaze'));
y_check=sum(fieldNum==ymaze)>0;
if y_check>0
ymazeThresh = 1.2;
yStruct = [flyData.ymaze];
end

ymaze2=sum(double('ymaze2'));
y2_check=sum(fieldNum==ymaze2)>0;
if y2_check>0
y2Struct = [flyData.ymaze2];
end

% Minimum avg. speed
olfaction=sum(double('olfaction'));
o_check=sum(fieldNum==olfaction);
if o_check>0
olfStruct = [flyData.olfaction];
meanSpeeds = [olfStruct.o_avg_velocity];
mean=nanmean(meanSpeeds);
sigma=nanstd(meanSpeeds);
olfactionThresh = mean - sigma;
end

% Minimum avg. speed (current set as anything 2 standard deviations from the mean)
circles=sum(double('circles'));
c_check=sum(fieldNum==circles);
if c_check>0
arenaStruct = [flyData.circles];
meanSpeeds = [arenaStruct.c_speed];
mean = nanmean(meanSpeeds);
sigma = nanstd(meanSpeeds);
arenaThresh = mean - sigma;
end

circles2=sum(double('circles2'));
c2_check=sum(fieldNum==circles2);
if c2_check>0
arena2Struct = [flyData.circles2];
meanSpeeds = [arena2Struct.c2_speed];
mean = nanmean(meanSpeeds);
sigma = nanstd(meanSpeeds);
arena2Thresh = mean - sigma;
end

%% Find indices of subthreshold flies and replace with NaNs

numInactive=[];

if p_check>0
photoInactive = find([photoStruct.p_numTrials]<photoThresh);
for i = 1:length(photoInactive)
    fields = fieldnames(photoStruct);
    for j=1:length(fields)
        flyData(photoInactive(i)).photo.(cell2mat(fields(j)))=NaN;
        
    end
end
numInactive=[numInactive length(photoInactive)];
end
    
if p2_check>0
photo2Inactive = find([photo2Struct.p_numTrials]<photoThresh);
for i = 1:length(photo2Inactive)
    fields = fieldnames(photo2Struct);
    for j=1:length(fields)
        flyData(photo2Inactive(i)).photo2.(cell2mat(fields(j)))=NaN;
        
    end
end
numInactive=[numInactive length(photo2Inactive)];
end

if g_check>0
gravInactive = find([gravStruct.g_numTrials]<gravThresh);
for i = 1:length(gravInactive)
    fields = fieldnames(gravStruct);
    for j=1:length(fields)
        flyData(gravInactive(i)).gravity.(cell2mat(fields(j)))=NaN;
        
    end
end
numInactive=[numInactive length(gravInactive)];
end

if y_check>0
yInactive = find([yStruct.y_TurnsPermin]<ymazeThresh);
for i = 1:length(yInactive)
    fields = fieldnames(yStruct);
    for j=1:length(fields)
        flyData(yInactive(i)).ymaze.(cell2mat(fields(j)))=NaN;
        
    end
end
numInactive=[numInactive length(yInactive)];
end

if y2_check>0
y2Inactive = find([y2Struct.y2_TurnsPermin]<ymazeThresh);
for i = 1:length(y2Inactive)
    fields = fieldnames(y2Struct);
    for j=1:length(fields)
        flyData(y2Inactive(i)).ymaze2.(cell2mat(fields(j)))=NaN;
        
    end
end
numInactive=[numInactive length(y2Inactive)];
end

if o_check>0
olfInactive = find([olfStruct.o_avg_velocity]<olfactionThresh);
for i = 1:length(olfInactive)
    fields = fieldnames(olfStruct);
    for j=1:length(fields)
        flyData(olfInactive(i)).olfaction.(cell2mat(fields(j)))=NaN;
        
    end
end
numInactive=[numInactive length(olfInactive)];
end

if c_check>0
arenaInactive = find([arenaStruct.c_speed]<arenaThresh);
for i = 1:length(arenaInactive)
    fields = fieldnames(arenaStruct);
    for j=1:length(fields)
        flyData(arenaInactive(i)).circles.(cell2mat(fields(j)))=NaN;
        
    end
end
numInactive=[numInactive length(arenaInactive)];
end

if c2_check>0
arena2Inactive = find([arena2Struct.c2_speed]<arena2Thresh);
for i = 1:length(arena2Inactive)
    fields = fieldnames(arena2Struct);
    for j=1:length(fields)
        flyData(arena2Inactive(i)).circles2.(cell2mat(fields(j)))=NaN;
    end
end
numInactive=[numInactive length(arena2Inactive)];
end

out.data = flyData;
out.numInactive = numInactive;

end



