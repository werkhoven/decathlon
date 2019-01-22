function odorantConditioning(CSplus)

% Coordinates delivery of odorants and shocks to flies. Delivery protocol
% is 5x spaced forward pairing: 
% 1 min CSplus/shock, 30 sec air, 1 min CS-, repeated 5x with 15 min ITI

dbstop if error;

global NI AC valveState

%% Establish general parameters

if nargin < 1
    CSplus = 'OCT';         % default conditioned odorant is octanol
end

conc = 0.12;                % Odorant concentration

charge_time = 5;            % Amount of time (sec)
                            % given for odor to charge
                            % before flipping final
                            % valve; also used to delay
                            % onset of shock post odor onset

pre_time = 45;              % wait time before first odor block (sec)
post_time = 30;              % wait time after last odor block
                                                

pin = 11;                   % pin from NI controller used for shock apparatus;
                            % 19 = p2.2; 11  = 1.2

% Shock parameters
shock_len = 1.25;           % duration of shock (sec)
shock_rate = 0.2;           % rate of shock reps (Hz)
trial_len = 60;             % length of shock epoch (sec)
CS_spacing = 30;            % time between CS+ and CS- presentation (sec)
iti = 15;                   % inter-trial interval (min)
num_reps = 5;               % number of times the shock protocol is repeated



%% Construct stimulus parameters

% Shock parameters
num_shocks = trial_len*shock_rate;          % number of shocks delivered in a given epoch
shock_delay = 1/shock_rate - shock_len;     % delay between individual shocks
iti = iti*60;                               % convert to seconds

valveState(pin) = 1;                             % make sure pin initialized to 1 (off)
outputSingleScan(NI, valveState);


% Odorant parameters
odors = {'MCH' 'OCT'};

CSminus = odors(~strcmpi(odors,CSplus));
c = [conc conc];
tf = [1.5 1.537];

if strcmpi('OCT',CSplus)                    % Set valves for CSplus
    valves_plus = [3 18];                   % (same odorant from both sides)
    valves_minus = [21 7];
elseif strcmpi('MCH',CSplus)
    valves_plus = [21 7];
    valves_minus = [3 18];
end



%% Run protocol

% Start flushing tunnels with air
odorPeriod = presentAir([conc conc]);

tic;

while toc < pre_time - charge_time    % leave time for initial valve flips
    i = 0;
end

% PRESENT PROTOCOL

for i = 1:num_reps
        
    % CSPLUS
        
    presentOdor(valves_plus, c, tf);      % Initial charge
    pause(charge_time);
    
    flipFinalValve(1);              % Flip but leave time for odor flow
    pause(charge_time);             % before initiating shocks

    % Present shocks
    for j = 1:num_shocks

        % Turn pin on
        tic;
        valveState(pin) = 0;
        outputSingleScan(NI, valveState)
        while toc < shock_len
            valveState(pin) = 1;
        end

        % Turn pin off
        tic;
        outputSingleScan(NI, valveState)
        while toc < shock_delay
            valveState(pin) = 0;
        end

    end

    % Present air between CS+/CS-
    flipFinalValve(0);
    presentAir([conc conc], 0);
    pause(CS_spacing);
    
    % CS MINUS PRESENTATION
    presentOdor(valves_minus, c, tf);      % Initial charge
    pause(charge_time);
    
    flipFinalValve(1);
    pause(charge_time);
    
    tic;
    pause(trial_len);
    
    % Present air during inter-trial interval
    flipFinalValve(0);
    presentAir([conc conc], 0);
    
    tic;
    while toc < post_time
        k = 0;
    end
    
    if i < 5        % Only pause for the iti if it's not the last rep
        
        while toc < iti - charge_time
            k = 0;
        end
        
    end
    
end


flipFinalValve(0);
presentAir([conc conc], 0);





