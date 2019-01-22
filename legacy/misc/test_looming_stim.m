scrProp=initialize_projector([1 1 1]);

%% hdhjsdaa
imaqreset
pause(0.5);
% Camera mode set to 8-bit with 664x524 resolution
imaqreset
c=imaqhwinfo;

% Select appropriate adaptor for connected camera
for i=1:length(c.InstalledAdaptors)
    camInfo=imaqhwinfo(c.InstalledAdaptors{i});
    if ~isempty(camInfo.DeviceIDs)
        adaptor=i;
    end
end
camInfo=imaqhwinfo(c.InstalledAdaptors{adaptor});
camInfo.Exposure = 2.4;
camInfo.Gain = 1;
camInfo.Shutter = 16.61;

% Set the device to default format and populate pop-up menu
if ~isempty(camInfo.DeviceInfo.SupportedFormats);
default_format=camInfo.DeviceInfo.DefaultFormat;

    for i=1:length(camInfo.DeviceInfo.SupportedFormats)
        if strcmp(default_format,camInfo.DeviceInfo.SupportedFormats{i})
            camInfo.ActiveMode=camInfo.DeviceInfo.SupportedFormats(i);
        end
    end
    
end

vid = initializeCamera(camInfo);
start(vid);
pause(0.1);
ref=peekdata(vid,1);
ref=ref(:,:,2);

%%
x=100:100:800;
y=100:100:600;
x=repmat(x,length(y),1);
x=x(:);
y=repmat(y,1,length(100:100:800))';

black=[0 0 0];
ct=0;

%{
while ~KbCheck
    
    r=mod(ct,40);
    ct=ct+2;
    
    scrProp=drawCircle(x,y,r,black,scrProp);
end
%}
ROI_size=50;
dstBaseRect=[0 0 5 ROI_size];
Screen('BlendFunction', scrProp.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
r=1;
inc=2;
d1=10;
d2=50;
offset=0;

while ~KbCheck
tic
    im=peekdata(vid,1);
    diffim=ref-im(:,:,2);
    props=regionprops(diffim>5,'Centroid','Area');
    pause(0.02);
    
    % Initialize circle
    circImage=ones(ROI_size*2);
    circCenter=size(circImage)/2;
    circBounds=[circCenter(2)-r circCenter(1)-r circCenter(2)+r-1 circCenter(1)+r-1];
    circMask=~(Circle(r));
    circImage(circBounds(2):circBounds(4),circBounds(1):circBounds(3))=circMask;

    circTex = Screen('MakeTexture', scrProp.window, circImage);
    dst_rect=[x-d1 y-d2 x+d1 y+d2];
    dst_rect=dst_rect+r;
    dst_rect=dst_rect+rand();
    srcRect=[0 0 size(circImage,2) size(circImage,1)];
    srcRect=repmat(srcRect+r,size(dst_rect,1),1);
    srcRect=srcRect+rand();

    Screen('DrawTextures', scrProp.window, circTex, srcRect', dst_rect', [],...
        [], [], [],[], []);
    
    if r==size(circImage,2)/2-1
        inc=-2;
    elseif r<=1
        inc=2;
    end
    r=r+inc;
    
    % Flip to the screen
    Screen('Flip', scrProp.window);
toc
end