function NI=connectToUSB6501
% Connect to NI USB-6501
%
% function NI=connectToUSB6501
%
%
% Purpose
% Initiate a connection to the USB-6501 box. Configure all DIOs as output
% since we won't be recording anything from the tunnels using DIO. 
%
% Outputs
% NI - handle to the created object. Briefly:
%       NI.Line(1) is Port0, Line0
%       NI.Line(8) is Port0, Line7
%       ...
%       NI.Line(24) is Port2, Line7
%
%
% Rob Cambell - March 2010


hw=daqhwinfo('nidaq');

NI=[];
for ii=1:size(hw.ObjectConstructorName,1)
    if strmatch(hw.BoardNames{ii},'USB-6501')
        eval(sprintf('NI=%s;',hw.ObjectConstructorName{ii,3}))
    end
end

if isempty(NI)
    error('Cannot connect to USB-6501')
else
    for port=0:2
        addline(NI,[0:7],port,'out');
    end
end