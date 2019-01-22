function out=flyY120(data,roi,varargin)

%out=flyY120(data,roi)
%This script is for analyzing data in the 120 fly Y mazes.  It analyzes
%flies 1 through 64 the same as before. [edit-2011.07.06 ben] and uses new
%refPoints for mazes 65-120.

dispTicks=0;
if ~isempty(varargin)
    if varargin{1}==1
        dispTicks=1;
    end
end

timeZero=data(1,2);

refPointsX=[roi/2 roi 0];
refPointsY=[0 3*roi/4 3*roi/4];

UDrefPointsX=[roi roi/2 0];
UDrefPointsY=[roi/4 roi roi/4];

numFlies=(size(data,2)-2)/2;

out={};
out.all=[];
out.sub=[];
out.hundred=[];


%RIGHTSIDE UP FLIES

%    |
%    |
%    |
%    |
%   / \
%  /   \
% /     \

if numFlies<65
    
    for i=1:numFlies
        if dispTicks==1; disp(i); end;
        datax=data(:,2*i+1);
        datay=data(:,2*i+2);
        
        
        onPath=0;
        
        turnSeq=[];
        timeSeq=[];
        phase1Seq=[];
        phase2Seq=[];
        
        for j=2:length(datax)
            if isnan(datax(j))==0 && isnan(datax(j-1))==1
                onPath=1;
                xStart=datax(j);
                yStart=datay(j);
                
            else
                if onPath==1
                    if isnan(datax(j))==1 && isnan(datax(j-1))==0
                        onPath=0;
                        xEnd=datax(j-1);
                        yEnd=datay(j-1);
                        
                        startRefDists=sqrt((refPointsX-xStart).^2+(refPointsY-yStart).^2);
                        endRefDists=  sqrt((refPointsX-xEnd  ).^2+(refPointsY-yEnd  ).^2);
                        
                        startPos=find(startRefDists==min(startRefDists));
                        endPos=find(endRefDists==min(endRefDists));
                        
                        a=[startPos endPos];
                        
                        if length(a)==2
                            if isequal(a,[1 2]) || isequal(a,[2 3]) || isequal(a,[3 1])
                                turnSeq=[turnSeq;1];
                                                        timeSeq=[timeSeq;data(j,2)-timeZero];
                            end
                            if isequal(a,[2 1]) || isequal(a,[3 2]) || isequal(a,[1 3])
                                turnSeq=[turnSeq;0];
                                                        timeSeq=[timeSeq;data(j,2)-timeZero];
                            end
                        end
                        

                        
                    end
                end
            end
        end
        
        % All data
        %The above script flips left and right turns, probably as a consequence
        %of converting from matrix to Cartesian coordinates.  To correct for
        %this, below I've switched "mean(turnSeq" to "1-mean(turnSeq). SMB
        %4/5/12
        if ~isempty(turnSeq)
            temp={turnSeq timeSeq length(turnSeq) (1-mean(turnSeq)) phase1Seq mean(phase1Seq) phase2Seq mean(phase2Seq)};
            out.all=[out.all; temp];
        else
            temp={NaN NaN NaN NaN NaN NaN NaN NaN};
            out.all=[out.all; temp];
        end
        
        
        % Subset of data w/ min number of turns
        %The above script flips left and right turns, probably as a consequence
        %of converting from matrix to Cartesian coordinates.  To correct for
        %this, below I've switched "mean(turnSeq" to "1-mean(turnSeq). SMB
        %4/5/12
        if length(turnSeq)>=50
            temp={turnSeq timeSeq length(turnSeq) (1-mean(turnSeq)) phase1Seq mean(phase1Seq) phase2Seq mean(phase2Seq)};
            out.sub=[out.sub; temp];
        end
    end
else
    
    
    %RIGHTSIDE UP FLIES
    
    %    |
    %    |
    %    |
    %    |
    %   / \
    %  /   \
    % /     \
    
    
    for i=1:64
        if dispTicks==1; disp(i); end;
        datax=data(:,2*i+1);
        datay=data(:,2*i+2);
        
        
        onPath=0;
        
        turnSeq=[];
        timeSeq=[];
        phase1Seq=[];
        phase2Seq=[];
        
        for j=2:length(datax)
            if isnan(datax(j))==0 && isnan(datax(j-1))==1
                onPath=1;
                xStart=datax(j);
                yStart=datay(j);
                
            else
                if onPath==1
                    if isnan(datax(j))==1 && isnan(datax(j-1))==0
                        onPath=0;
                        xEnd=datax(j-1);
                        yEnd=datay(j-1);
                        
                        startRefDists=sqrt((refPointsX-xStart).^2+(refPointsY-yStart).^2);
                        endRefDists=  sqrt((refPointsX-xEnd  ).^2+(refPointsY-yEnd  ).^2);
                        
                        startPos=find(startRefDists==min(startRefDists));
                        endPos=find(endRefDists==min(endRefDists));
                        
                        a=[startPos endPos];
                        
                        if length(a)==2
                            if isequal(a,[1 2]) || isequal(a,[2 3]) || isequal(a,[3 1])
                                turnSeq=[turnSeq;1];
                                                        timeSeq=[timeSeq;data(j,2)-timeZero];
                            end
                            if isequal(a,[2 1]) || isequal(a,[3 2]) || isequal(a,[1 3])
                                turnSeq=[turnSeq;0];
                                                        timeSeq=[timeSeq;data(j,2)-timeZero];
                            end
                        end
                        
                    end
                end
            end
        end
        
        % All data
        %The above script flips left and right turns, probably as a consequence
        %of converting from matrix to Cartesian coordinates.  To correct for
        %this, below I've switched "mean(turnSeq" to "1-mean(turnSeq). SMB
        %4/5/12
        if ~isempty(turnSeq)
            temp={turnSeq timeSeq length(turnSeq) (1-mean(turnSeq)) phase1Seq mean(phase1Seq) phase2Seq mean(phase2Seq)};
            out.all=[out.all; temp];
        else
            temp={NaN NaN NaN NaN NaN NaN NaN NaN};
            out.all=[out.all; temp];
        end
        
        
        % Subset of data w/ min number of turns
        %The above script flips left and right turns, probably as a consequence
        %of converting from matrix to Cartesian coordinates.  To correct for
        %this, below I've switched "mean(turnSeq" to "1-mean(turnSeq). SMB
        %4/5/12
        if length(turnSeq)>=50
            temp={turnSeq timeSeq length(turnSeq) (1-mean(turnSeq)) phase1Seq mean(phase1Seq) phase2Seq mean(phase2Seq)};
            out.sub=[out.sub; temp];
        end
        
    end
    
    
    
    %UPSIDE DOWN FLIES
    
    %     \     /
    %      \   /
    %       \ /
    %        |
    %        |
    %        |
    %        |
    
    for i=65:numFlies
        if dispTicks==1; disp(i); end;
        datax=data(:,2*i+1);
        datay=data(:,2*i+2);
        
        
        onPath=0;
        
        turnSeq=[];
        timeSeq=[];
        phase1Seq=[];
        phase2Seq=[];
        
        for j=2:length(datax)
            if isnan(datax(j))==0 && isnan(datax(j-1))==1
                onPath=1;
                xStart=datax(j);
                yStart=datay(j);
                
            else
                if onPath==1
                    if isnan(datax(j))==1 && isnan(datax(j-1))==0
                        onPath=0;
                        xEnd=datax(j-1);
                        yEnd=datay(j-1);
                        
                        startRefDists=sqrt((UDrefPointsX-xStart).^2+(UDrefPointsY-yStart).^2);
                        endRefDists=  sqrt((UDrefPointsX-xEnd  ).^2+(UDrefPointsY-yEnd  ).^2);
                        
                        startPos=find(startRefDists==min(startRefDists));
                        endPos=find(endRefDists==min(endRefDists));
                        
                        a=[startPos endPos];
                        
                        if length(a)==2
                            if isequal(a,[1 2]) || isequal(a,[2 3]) || isequal(a,[3 1])
                                turnSeq=[turnSeq;1];
                                                        timeSeq=[timeSeq;data(j,2)-timeZero];
                            end
                            if isequal(a,[2 1]) || isequal(a,[3 2]) || isequal(a,[1 3])
                                turnSeq=[turnSeq;0];
                                                        timeSeq=[timeSeq;data(j,2)-timeZero];
                            end
                        end
                        
                    end
                end
            end
        end
        
        % All data
        %The above script flips left and right turns, probably as a consequence
        %of converting from matrix to Cartesian coordinates.  To correct for
        %this, below I've switched "mean(turnSeq" to "1-mean(turnSeq). SMB
        %4/5/12
        if ~isempty(turnSeq)
            temp={turnSeq timeSeq length(turnSeq) (1-mean(turnSeq)) phase1Seq mean(phase1Seq) phase2Seq mean(phase2Seq)};
            out.all=[out.all; temp];
        else
            temp={NaN NaN NaN NaN NaN NaN NaN NaN};
            out.all=[out.all; temp];
        end
        
        
        % Subset of data w/ min number of turns
        %The above script flips left and right turns, probably as a consequence
        %of converting from matrix to Cartesian coordinates.  To correct for
        %this, below I've switched "mean(turnSeq" to "1-mean(turnSeq). SMB
        %4/5/12
        if length(turnSeq)>=50
            temp={turnSeq timeSeq length(turnSeq) (1-mean(turnSeq)) phase1Seq mean(phase1Seq) phase2Seq mean(phase2Seq)};
            out.sub=[out.sub; temp];
        end
        
    end
end


