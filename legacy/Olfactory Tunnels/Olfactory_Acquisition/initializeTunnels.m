function [NI AC vid] = initializeTunnels

% Seed randomizer to be different across sessions
RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));

% Make session variables global
global NI AC

% Initialize hardware interfaces
NI = connectToUSB6501;
AC = connectAlicat;
presentAir([0.2 0.2], 1.5, 1);

% pause(5)
% presentAir([0.2 0.2], 0, 1);

initializeCamera;

global vid