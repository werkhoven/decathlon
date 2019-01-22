function state = flipFinalValve(state)

if nargin < 1
    state = 1;                     % flip valves to OPEN state by default
end

global NI valveState

valveState([4,17]) = state;

outputSingleScan(NI,valveState);

% putvalue(NI.Line(4),state)
% putvalue(NI.Line(17),state)