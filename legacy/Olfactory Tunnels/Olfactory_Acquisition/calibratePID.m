function calibratePID

%Run this first:
% NIn=connectToUSB6009;

set(NIn,'SampleRate', 100);
set(NIn,'SamplesPerTrigger', 1000); % 10 sec of data

start(NIn) % Record zero concentration
out = getdata(NIn);

% Next present 5ppm
start(NIn)
out(:,2) = getdata(NIn);

% Next present 50ppm
start(NIn)
out(:,3) = getdata(NIn);

% Next present 100ppm
start(NIn)
out(:,4) = getdata(NIn);


save '131212Isobut.mat' out

% Smooth traces
for i = 1:4
    out(:,i) = smooth(out(:,i), 30);
end

% Find peaks
v = max(out);

c = [0 5 50 100]; % Conc in ppm

p = polyfit(v, c, 2); % Fit a second-order polynomial

save 'C:\Documents and Settings\fly\My Documents\MATLAB\TunnelData\calibrationFit.mat' p v c out

f = polyval(p, min(v):0.001:max(v));

plot(v,c,'o-k','linewidth', 2, 'markercolor', 'k')
hold on
plot(min(v):0.001:max(v),f, 'r')
ylabel('Concentration (ppm)')
xlabel('PID output (V)')
