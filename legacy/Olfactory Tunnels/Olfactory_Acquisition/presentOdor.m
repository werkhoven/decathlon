function odorState = presentOdor(valves, conc, totalFlow)

if nargin < 3
    totalFlow = [1.5 1.5]; %total flow rate through MFCs (L/min)
end

global NI AC valveState

% Set valve states
valveState = zeros(1,24);   % close empty valves
valveState(valves(1)) = 1;  % open odor valves
valveState(valves(2)) = 1;

outputSingleScan(NI,valveState);

% Fudge factors to compensate for MFC offset and tubing leakes
aOffset = 0; %0.004;
bOffset = 0; %0.029;
cOffset = 0; %0.011;
dOffset = 0; %0.004;

% Calculate flow rates, send to MFCs
flowA = calcFlow(totalFlow(1)-(totalFlow(1)*conc(1)) + aOffset*(totalFlow(1)>0),5);
flowB = calcFlow(totalFlow(2)-(totalFlow(2)*conc(2)) + bOffset*(totalFlow(2)>0),5);
flowD = calcFlow(totalFlow(1)*conc(1) + cOffset*(totalFlow(1)>0),1);
flowC = calcFlow(totalFlow(2)*conc(2) + dOffset*(totalFlow(2)>0),1);

fprintf(AC, sprintf('%s%0.0f','A',flowA));
fprintf(AC, sprintf('%s%0.0f','B',flowB));
fprintf(AC, sprintf('%s%0.0f','C',flowC));
fprintf(AC, sprintf('%s%0.0f','D',flowD));

odorState = 1;
end