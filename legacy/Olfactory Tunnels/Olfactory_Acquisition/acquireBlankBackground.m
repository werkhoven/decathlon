function acquireBlankBackground

global vid;

if isempty(vid)
    initializeCamera(0)
end

if isrunning(vid)
    stop(vid)
end

vid.ROIPosition = [0 0 640 480];

start(vid)
pause(1)

nFrames = 100; % n frames over which to average

for i =1:nFrames
    blankBg(:,:,i) = uint8(peekdata(vid,1));
end

blankBg = uint8(mean(blankBg,3));
    
save('C:\Users\khonegger\Documents\MATLAB\TunnelData\blankBg.mat', 'blankBg')
