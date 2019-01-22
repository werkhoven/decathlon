function flow=calcFlow(setPoint,MFCcapacity)
% function flow=calcFlow(setPoint)
%
% Convert a desired flow rate into the correct units for the MFC. See p. 22
% of operating manual. 
% (desired set point * 64000)/Full scale range
%
% Function not much use now but could be useful in the future if we have
% different MFC types. 
%
% Rob Campbell - 21st March 2008 - CSHL  


 flow = (setPoint * 64000)/MFCcapacity; 