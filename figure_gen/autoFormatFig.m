function varargout = autoFormatFig(varargin)

% standardizes a figure to Ben approved specifications

%% parse inputs

fh = gcf;
recolor = true;
preset = [];

for i = 1:length(varargin)
    
    arg = varargin{i};
    
    if ishghandle(arg)
        switch arg.Type
            case 'figure', fh = arg;
            case 'axes', ah = arg;    
        end
    end
    
    if ischar(arg)
        switch arg
            case 'Preset'
                i = i+1;
                preset = varargin{i};
            case 'Panel'
                i=i+1;
                panel = varargin{i};
            case 'LegendLocation'
                i=i+1;
                legloc = varargin{i};
            case 'LegendBuffer'
                i=i+1;
                legbuf= varargin{i};
            case 'Recolor'
                i=i+1;
                recolor = varargin{i};
        end
    end
    
end

if ~exist('ah','var')
    ah = findobj(fh,'-depth',1,'Type','Axes');
end


%% format axis size and properties

fh.Units = 'inches';
ah.Units = 'inches';
if ~isempty(preset)
    switch preset
        case 'medium'
            ah.Position(3:4) = [3 2];
    end
else

    ah.Position(3:4) = [1.8 1.2];   
end

ah.FontSize = 6;
ah.FontName = 'Arial';
ah.TickLength = [0 0];
ah.Box = 'on';

%% format tick labels as custom text objects
m=0.02;
ah.XLim = [ah.XLim(1)-diff(ah.XLim)*m ah.XLim(2)+diff(ah.XLim)*m];
ah.YLim = [ah.YLim(1)-diff(ah.YLim)*m*2 ah.YLim(2)+diff(ah.YLim)*m*2];

xL = ah.XAxis.Label;
xL.FontUnits = 'points';
xL.FontSize = 8;
xL.Units = 'inches';
xL.VerticalAlignment = 'top';
xL.HorizontalAlignment = 'center';
xL.Position(2) = -0.2;
yL = ah.YAxis.Label;
yL.FontUnits = 'points';
yL.FontSize = 8;
yL.Units = 'inches';
yL.VerticalAlignment = 'bottom';
yL.Position(1) = -0.2;

%% define color table

hexstr = {...
    '#65BADA','#87D0E2',...
    '#068E8C','#75B3A7',...
    '#00A757','#82BA4F',...
    '#E5BA52','#F3EA1F',...
    '#D86F27','#E89E23',...
    '#C82E6B','#D4668F',...
    '#991B37','#C30021',...
    '#364285','#5D5296'};
coltable = hex2rgb(hexstr);
ah.ColorOrder = coltable(1:2:end,:);


%% format lines

lineObjs = findobj(ah,'-depth',6,'Type','line');
if numel(lineObjs)
    if recolor
        if numel(lineObjs)>1
            for i=1:length(lineObjs)
                lineObjs(i).Color = ah.ColorOrder(i,:);
            end
        else
            lineObjs.Color = [0,0,0];
        end
    end
    set(lineObjs,'Linewidth',0.75);
    if iscell(lineObjs)
        xExtent = [min(cellfun(@min,get(lineObjs,'XData'))) max(cellfun(@max,get(lineObjs,'XData')))];
        ah.XLim = xExtent;
    end
    uistack(lineObjs,'bottom');
end

%% format scatter plots

sch = findobj(ah,'-depth',2,'Type','Scatter');
if ishghandle(sch)
    
    sch.LineWidth = 0.75;
    sch.SizeData = 12;
    
end

%% format legend

lh = findobj(fh,'-depth',1,'Type','legend');
if ~isempty(lh)
    
    labstr = lh.String;
    for i = 1:length(labstr)
        tmp = labstr{i};
        tmp(tmp=='_')=' ';
        labstr(i) = {tmp};
    end

    if exist('legloc','var')
        switch legloc
            case 'inside', anchor = [3 3];
            case 'outside', anchor = [3 1];
        end

    else
        if length(labstr)<4
            anchor = [3 3];
        else
            anchor = [3 1];
        end
    end

    if ~exist('legbuf','var')
        legbuf = [0.05 00];
    end


    [lh,objh] = legendflex(ah,labstr,'anchor',anchor,'buffer',legbuf,...
        'bufferunit','inches','box','off','xscale',0.25,'FontSize',7);
    
end


%% create panel label

if exist('panel','var')
    ph = text(yL.Position(1),ah.Position(4)+0.05,panel,'FontSize',12,'Units','inches',...
        'VerticalAlignment','baseline','HorizontalAlignment','right');
end


ah.Parent.Units = ah.Units;
ah.Parent.Position(3:4) = ah.Position(3:4) .* 1.5;









