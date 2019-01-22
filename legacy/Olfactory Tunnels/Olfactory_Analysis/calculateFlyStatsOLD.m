function varargout = calculateFlyStats(fname, refOdor)
%CALCULATEFLYSTATS Initial analysis of fly tunnel behavioral data.
%   FLYTRACKS = CALCULATEFLYSTATS(FLYTRACKS) performs data pre-processing,
%   calculates several useful metrics for individual flies (including
%   velocity, distance traveled, and odor choice probability) and returns a
%   data structure with new information appended.
%
%   INPUT:
%          fname - a path to the structure created by flyTracker2013.m
%
%   OUTPUT:
%          flyTracks(optional) - an updated version of the input structure
%          with new information appended. This structure can be supplied to
%          MbockPlot20XX.m and other plotting functions. 
% 
%          If no output variable is requested, the function will save a copy of the
%          input structure to a file with name 'fname-processed.mat
%
%   DEPENDENCIES:
%          FINDHEAD.m
%          FLYVELOCITY.m
%          CALCULATECHOICESTATS.m
%          CALCULATEOCCUPANCYSTATS.m
%
%
%   March 17, 2014
%   Kyle Honegger, Harvard & CSHL



% Load data
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
load(fname, 'flyTracks');                   % load flyTracks data structure

if ~exist('flyTracks','var')             % check for correct data structure
    error('input file does not contain a valid flyTracks structure')
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %



% Check for reference odor input
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
if nargin < 2
    refOdor = flyTracks.stim{4,1}(1); % calculate scores in reference to Odor A of the first presentation
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %



% Smooth data (improves quality of velocity estimate)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
winSz = 4;                % 125ms - assuming an average frame rate of 32fps

% Identify flies with missing data
hasNaNs = logical(sum(isnan(squeeze(flyTracks.orientation))));

for i = find(~hasNaNs)            % skip flies that have any missing data
    flyTracks.centroid(:,1,i) = smooth(flyTracks.centroid(:,1,i),winSz);
    flyTracks.centroid(:,2,i) = smooth(flyTracks.centroid(:,2,i),winSz);
    %flyTracks.orientation(:,i) = smooth(flyTracks.orientation(:,i),winSz);
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %



% Calculate timestamps relative to experiment start
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
for i = 1:length(flyTracks.times)
    flyTracks.relTimes(i) = etime(datevec(flyTracks.times(i)), ...
        datevec(flyTracks.times(1)));
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %



% Reorder shuffled tunnel positions to original Day 1 positions
% !!!! FIX: Flies missing on Day 2 are not treated as such  !!!!!!
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
% if isfield(flyTracks,'day1Idx')
%     flyTracks.centroid(:,:,flyTracks.day1Idx) = flyTracks.centroid;
%     flyTracks.orientation(:,flyTracks.day1Idx) = flyTracks.orientation;
%     flyTracks.majorAxisLength(:,flyTracks.day1Idx) = flyTracks.majorAxisLength;
%     flyTracks.tunnels(:,flyTracks.day1Idx) = flyTracks.tunnels;
%     flyTracks.tunnelActive(flyTracks.day1Idx) = flyTracks.tunnelActive;
% end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %



% Calculate average frame rate (in fps)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
nFrames = size(flyTracks.centroid,1);
flyTracks.rate = nFrames/flyTracks.duration;
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %



% Total distance traveled for each fly
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
for k = 1:flyTracks.nFlies
    flyTracks.dist(k) = sum(abs(diff(flyTracks.centroid(:,2,k))) ...
        * flyTracks.pxRes);
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %



% Find head (major axis endpt closest to instantaneous direction vector)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
flyTracks.headPosition = findHead(flyTracks);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %



% Reference coordinates relative to tunnels
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
activeTunnels = find(flyTracks.tunnelActive);

for i = 1:length(activeTunnels)
    tun = flyTracks.tunnels(:,activeTunnels(i));
    
    flyTracks.centroidLocal(:,:,i) = [(flyTracks.centroid(:,1,i) - tun(1)), ...
        (flyTracks.centroid(:,2,i) - tun(2))];
    flyTracks.headLocal(:,:,i) = [(flyTracks.headPosition(:,1,i) - tun(1)), ...
        (flyTracks.headPosition(:,2,i) - tun(2))];
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %



% Re-map orientation to the interval [0 180] degrees
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
for k = 1:flyTracks.nFlies
    a = flyTracks.orientation(:,k);
    flyTracks.orientation(a < 0,k) = 180 + a(a<0);
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %



% Instantaneous centroid velocity
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
flyTracks.velocity = flyVelocity(flyTracks,0);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %



% Find turns, pauses, and slow-downs
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
for k = 1:flyTracks.nFlies
    flyTracks.turns(k).left = find(diff(flyTracks.orientation(:,k)) ...
        < -120);
    
    flyTracks.turns(k).right = find(diff(flyTracks.orientation(:,k)) ...
        > 120);
    
    flyTracks.turns(k).all = find(abs(diff(flyTracks.orientation(:,k)))...
        > 120);
    
    flyTracks.pauses(:,k) = flyTracks.velocity(:,k) < 5; % mm/sec
    
    flyTracks.slow(:,k) = flyTracks.velocity(:,k) < 6; % mm/sec
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %



% Calculate choice statistics (corridor entry/exit, side/odor chosen)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
flyTracks = calculateChoiceStats(flyTracks, refOdor);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %



% Calculate occupancy times for each odor
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
flyTracks = calculateOccupancyStats(flyTracks, refOdor);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %



% Return output structure, if requested, or save new structure
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
if nargout == 1
    varargout{1} = flyTracks;
else
    
    if strcmp('.mat', fname(end-3:end))
        fname(end-3:end) = [];
    end
    
    save([fname '-processed.mat'], 'flyTracks')
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %


