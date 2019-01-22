function [r, c] = batchTemporalAnalysis

% To do:
% 1.  Plot time dilation
% 2.  Plot r values as a function of tunnel distance
% 3.  Calculate p of being on the same tunnel side

r = [];
c = [];

group = {'A' 'B' 'C' 'D' 'E' 'F'};

% cd('/Users/honegger/Documents/Work/Behavior/Tunnels/Harvard/Data/OdorPreference/130830')
% 
% for i = 1:length(group)
%     ft1 = load(['2U_3dayOldFemales_25C_day1_' group{i} '.mat']);
%     ft2 = load(['2U_3dayOldFemales_25C_day2_' group{i} '.mat']);
%     [tmpr, tmpc] = temporalAnalysisAcrossDays(ft1.flyTracks, ft2.flyTracks);
%     r = [r tmpr];
%     c = [c tmpc];
% end
% 
% cd('/Users/honegger/Documents/Work/Behavior/Tunnels/Harvard/Data/OdorPreference/130909')
% 
% for i = 1:length(group)
%     ft1 = load(['2U_3dayOldFemales_25C_day1_' group{i} '.mat']);
%     ft2 = load(['2U_3dayOldFemales_25C_day2_' group{i} '.mat']);
%     [tmpr, tmpc] = temporalAnalysisAcrossDays(ft1.flyTracks, ft2.flyTracks);
%     r = [r tmpr];
%     c = [c tmpc];
% end
% 
% cd('/Users/honegger/Documents/Work/Behavior/Tunnels/Harvard/Data/OdorPreference/130921')
% 
% for i = 1:length(group)
%     ft1 = load(['2U_3dayOldFemales_25C_day1_' group{i} '.mat']);
%     ft2 = load(['2U_3dayOldFemales_25C_day2_' group{i} '.mat']);
%     [tmpr, tmpc] = temporalAnalysisAcrossDays(ft1.flyTracks, ft2.flyTracks);
%     r = [r tmpr];
%     c = [c tmpc];
% end


cd('/Users/honegger/Documents/Work/Behavior/Tunnels/Harvard/Data/Sensitivity/130731')

for i = 1:length(group)
    ft1 = load(['2U_2dayOldFemales_25C_day1_' group{i} '.mat']);
    ft2 = load(['2U_2dayOldFemales_25C_day2_' group{i} '.mat']);
    [tmpr, tmpc] = temporalAnalysisAcrossDays(ft1.flyTracks, ft2.flyTracks);
    r = [r tmpr];
    c = [c tmpc];
end

cd('/Users/honegger/Documents/Work/Behavior/Tunnels/Harvard/Data/Sensitivity/130806')

for i = 1:length(group)
    ft1 = load(['2U_3dayOldFemales_25C_day1_' group{i} '.mat']);
    ft2 = load(['2U_3dayOldFemales_25C_day2_' group{i} '.mat']);
    [tmpr, tmpc] = temporalAnalysisAcrossDays(ft1.flyTracks, ft2.flyTracks);
    r = [r tmpr];
    c = [c tmpc];
end

cd('/Users/honegger/Documents/Work/Behavior/Tunnels/Harvard/Data/Sensitivity/130814')

for i = 1:length(group)
    ft1 = load(['2U_5dayOldFemales_25C_day1_' group{i} '.mat']);
    ft2 = load(['2U_5dayOldFemales_25C_day2_' group{i} '.mat']);
    [tmpr, tmpc] = temporalAnalysisAcrossDays(ft1.flyTracks, ft2.flyTracks);
    r = [r tmpr];
    c = [c tmpc];
end

cd('/Users/honegger/Documents/Work/Behavior/Tunnels/Harvard/Data/Sensitivity/130822')

for i = 1:length(group)
    ft1 = load(['2U_1dayOldFemales_25C_day1_' group{i} '.mat']);
    ft2 = load(['2U_1dayOldFemales_25C_day2_' group{i} '.mat']);
    [tmpr, tmpc] = temporalAnalysisAcrossDays(ft1.flyTracks, ft2.flyTracks);
    r = [r tmpr];
    c = [c tmpc];
end

cd('/Users/honegger/Documents/Work/Behavior/Tunnels/Harvard/Data/Sensitivity/130824')

for i = 1:length(group)
    ft1 = load(['2U_5dayOldFemales_25C_day1_' group{i} '.mat']);
    ft2 = load(['2U_5dayOldFemales_25C_day2_' group{i} '.mat']);
    [tmpr, tmpc] = temporalAnalysisAcrossDays(ft1.flyTracks, ft2.flyTracks);
    r = [r tmpr];
    c = [c tmpc];
end

multiHist([r; c]')