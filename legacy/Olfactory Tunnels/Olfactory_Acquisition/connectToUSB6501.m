function NI=connectToUSB6501
% Connect to NI USB-6501 using new Session-based data acquisition interface
%
% function NI=connectToUSB6501
%
%
% Purpose
% Initiate a connection to the USB-6501 box. Configure all 24 DIOs as
% output since we won't be recording anything from the tunnels using DIO. 
%
% Outputs
% NI - handle to the created session-based data acquisition object. 
%
% Example
% Set only valves 1 and 20 to high:
%       targetValves = zeros(1,24);
%       targetValves([1 20]) = 1;
%       outputSingleScan(NI,targetValves);
%
% Kyle Honegger - June 2014


NI = daq.createSession('ni');

addDigitalChannel(NI,'Dev1','port0/line0:7','OutputOnly');
addDigitalChannel(NI,'Dev1','port1/line0:7','OutputOnly');
addDigitalChannel(NI,'Dev1','port2/line0:7','OutputOnly');

targetValves = zeros(1,24);
targetValves([1 20]) = 1;

outputSingleScan(NI,targetValves); % Close all valves but air

