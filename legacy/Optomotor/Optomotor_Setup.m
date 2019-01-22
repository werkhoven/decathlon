function varargout = Optomotor_Setup(varargin)
% OPTOMOTOR_SETUP MATLAB code for Optomotor_Setup.fig
%      OPTOMOTOR_SETUP, by itself, creates a new OPTOMOTOR_SETUP or raises the existing
%      singleton*.
%
%      H = OPTOMOTOR_SETUP returns the handle to a new OPTOMOTOR_SETUP or the handle to
%      the existing singleton*.
%
%      OPTOMOTOR_SETUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPTOMOTOR_SETUP.M with the given input arguments.
%
%      OPTOMOTOR_SETUP('Property','Value',...) creates a new OPTOMOTOR_SETUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Optomotor_Setup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Optomotor_Setup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Optomotor_Setup

% Last Modified by GUIDE v2.5 07-Jan-2015 15:51:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Optomotor_Setup_OpeningFcn, ...
                   'gui_OutputFcn',  @Optomotor_Setup_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Optomotor_Setup is made visible.
function Optomotor_Setup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Optomotor_Setup (see VARARGIN)

% Choose default command line output for Optomotor_Setup
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Optomotor_Setup wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Optomotor_Setup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(~, ~, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 


global vid VidStatus refimage refstatus ROI_bounds ROI_coords ROI_widths ROI_heights;                % Declare camera object, video status, and reference image


if refstatus ~= 1;

    %axes(handles.axes1);
    vid = videoinput('pointgrey', 1, 'F7_BayerRG16_664x524_Mode1');
    src = getselectedsource(vid);
    src.Exposure = 2.4;

    triggerconfig(vid,'manual');

    % Create the image object in which you want to display 
    % the video preview data. Make the size of the image
    % object match the dimensions of the video frames.

    vidRes = vid.VideoResolution;
    nBands = vid.NumberOfBands;
    hImage = image( zeros(vidRes(2), vidRes(1), nBands) );

    start(vid)
    VidStatus = 1
end

if refstatus == 1;
    
    tunnel_images = zeros(max(ROI_heights),max(ROI_widths),length(ROI_bounds));
    set(gcf,'Position',[1921 1 3200 720]);

    while VidStatus == 1;
        
        pause(0.02);                                                        % Pause adjusts frame rate

        imagedata = peekdata(vid,1);                                        % Take one frame
        imagedata = refimage(:,:,1)-imagedata(:,:,1);
        imagedata = im2bw(imagedata(:,:,1),0.25);                            % Threshold the image
        %imshow(imagedata(:,:,1))                                           % Show only the red channel
        
       for i = 1:length(ROI_bounds)
           
       tunnel_images(1:(ROI_heights(i)+1),1:(ROI_widths(i)+1),i) = imagedata(ROI_coords(i,2):ROI_coords(i,4),ROI_coords(i,1):ROI_coords(i,3));
       
       end
       
       fly_centroids = trackflies(tunnel_images,ROI_coords);
       %centroid_marked = step(markerInserter, imagedata, fly_centroids);
       imshow(imagedata)
       
       hold on
       plot(fly_centroids(:,1),fly_centroids(:,2),'o','Color','r')
       
       
       for i = 1:length(ROI_bounds)
        rectangle('Position',ROI_bounds(i,:),'EdgeColor','r')
       end
       
       hold off

    end
  
else
    while VidStatus == 1;

        pause(0.04);                            % Pause adjusts frame rate

        imagedata = peekdata(vid,1);        % Take one frame
        imshow(imagedata(:,:,1))            % Show only the red channel

    end
end





% --- Executes on button press in stop_video.
function stop_video_Callback(hObject, eventdata, handles)

global vid VidStatus refstatus;

VidStatus = 0;
refstatus = 0;

stop(vid);  % Stops the video


% --- Executes on button press in take_reference.
function take_reference_Callback(hObject, eventdata, handles)
% hObject    handle to take_reference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global vid refimage refstatus ROI_bounds ROI_coords ROI_widths ROI_heights;           % Pull in camera object and declare reference image

refstatus = 1                                                               % Note that reference has been taken
refimage_stack = zeros(524,664,10);

for i = 1:10
    
    refimage = peekdata(vid,1);
    refimage_stack(:,:,i) = refimage(:,:,1);
    pause(0.2);
    
    i
    
end

isa(refimage,'uint16');

    refimage_stack = refimage_stack * 0.1;
    
    for i = 1:size(refimage_stack,1)
        
        for j = 1:size(refimage_stack,2)
        
        refimage(i,j,1) = sum(refimage_stack(i,j,:));
        
        end
    end
    
    refimage(100:120,100:120,1)
    
    imshow(refimage(:,:,1))

                                      % Isolate red channel

[ROI_bounds,ROI_coords,ROI_widths,ROI_heights] = detect_ROIs(refimage);




