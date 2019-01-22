function balanceSides(odor, side, conc)

if strmatch(odor, 'MCH') & strmatch(side, 'A')
    valve = [21 20];
elseif strmatch(odor, 'MCH') & strmatch(side, 'B')
    valve = [7 1];
elseif strmatch(odor, 'OCT') & strmatch(side, 'A')
    valve = [3 20];
elseif strmatch(odor, 'OCT') & strmatch(side, 'B')
    valve = [18 1];
elseif strmatch(odor, 'Air')
    valve = [1 20];
else
    error('bad inputs')
end

c = [0 0];
c(strmatch(side, {'A' 'B'})) = conc;

tf = [1.5 1.537];
tf(strmatch(side, {'B' 'A'})) = 0;

presentOdor(valve, c, tf);
pause(5);

for i = 1:10
    flipFinalValve(1);
    pause(2);
    flipFinalValve(0);
    pause(2);
end

flipFinalValve(0);
presentAir([0.1 0.1], 0);