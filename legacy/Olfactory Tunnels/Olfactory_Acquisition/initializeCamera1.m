function initializeCamera(previewOn)

if nargin == 0
    previewOn = 1;
end

global vid;

%vid = videoinput('dcam',1,'Y8_640x480');
%set(vid.source,'Brightness',700,'Gain',0);

vid = videoinput('pointgrey', 1, 'Mono8_640x480');
triggerconfig(vid,'manual');
set(vid,'ReturnedColorSpace','gray');
start(vid);
pause(2)

if previewOn
    preview(vid);
end