function odorState = presentAir(conc, totalFlow, checkFlow)

if nargin < 3
    checkFlow = 0;
end

if nargin < 2
    totalFlow = 1.5; %total flow rate through MFCs (L/min)
end

global NI AC valveState

% Set valve states
valveState = zeros(1,24);

if totalFlow ~= 0
    valveState([1 20]) = 1;
end

outputSingleScan(NI,valveState); % Will automatically switch final valves
                                 % (lines 4 and 17) to CLOSED state

% Calculate flow rates, send to MFCs
if totalFlow == 0
    fprintf(AC, sprintf('%s%0.0f','A',0));
    fprintf(AC, sprintf('%s%0.0f','B',0));
    fprintf(AC, sprintf('%s%0.0f','C',0));
    fprintf(AC, sprintf('%s%0.0f','D',0));
else
    flowB = calcFlow(totalFlow-(totalFlow*conc(1)),5);
    flowA = calcFlow(totalFlow-(totalFlow*conc(2)),5);
    flowD = calcFlow(totalFlow*conc(2),1);
    flowC = calcFlow(totalFlow*conc(1),1);
    
    fprintf(AC, sprintf('%s%0.0f','A',flowA));
    fprintf(AC, sprintf('%s%0.0f','B',flowB));
    fprintf(AC, sprintf('%s%0.0f','C',flowC));
    fprintf(AC, sprintf('%s%0.0f','D',flowD));
end

% Check for MFC comm errors
if checkFlow
    unit = {'A', 'B', 'C', 'D'};
    flows = [totalFlow-(totalFlow*conc(1));
        totalFlow-(totalFlow*conc(2));
        totalFlow*conc(1);
        totalFlow*conc(2)];
    
    for i = 1:4
        
        OUT = [];
        
        
        % Discard first read - for some reason it's usually crap
        fprintf(AC,unit{i})
        pause(0.05)
        
        while AC.BytesAvailable > 0
            fscanf(AC);
        end
        % ---------------------------------------------------------
        
        fprintf(AC,unit{i})
        pause(0.05)
        
        try
            OUT = readMFC(AC);
            
            if isempty(OUT)
                warning(['Communication error with MFC unit ''' unit{i} ''''])
            elseif uint8(OUT.setPoint) ~= uint8(flows(i))
                warning(['Communication error with MFC unit ''' unit{i} ''''])
            end
            
        catch
            warning(['Communication error with MFC unit ''' unit{i} ''''])
        end
    end
end

odorState = 0;