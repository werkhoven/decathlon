function out = naturalOdorPIDtest(NIn)

%Run these first:
% NIn=connectToUSB6009;
% [NI AC] = initializeTunnels;

global NI AC

chargeTime = 120;
odorDur = 180;
Fs = 100;
TrDur = 190;
conc = 0.2;

set(NIn,'SampleRate', Fs);
set(NIn,'SamplesPerTrigger', Fs*TrDur);

pause(1)
presentAir([conc conc], 0);
pause(2)

presentOdor([20 21], [conc conc]); % change to [20 21] for Mango
pause(chargeTime-1)

start(NIn)
pause(1)

flipFinalValve(1);
pause(odorDur)

flipFinalValve(0);
presentAir([conc conc], 0);

pause(1+TrDur-odorDur)

out = getdata(NIn);
plot(out)
    