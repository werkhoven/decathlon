function meta = assignMetaData(expmt)


plate_map = cell(192*2,1);
plate_map(1:96) = {'A'};
plate_map(97:192) = {'B'};
plate_map(193:288) = {'C'};
plate_map(289:384) = {'D'};
meta.Day = repmat(expmt.Day,expmt.nTracks,1);

switch expmt.Name
    case 'Olfaction'
        meta.Plate = plate_map(expmt.ID);
        
    otherwise
        % calculate time of day from date
        date = expmt.date;
        date(date=='_')=[];
        b = find(date=='-');
        tod = str2double(date(b(3)+1:b(4)-1))*3600 +...
            str2double(date(b(4)+1:b(5)-1))*60 + str2double(date(b(5)+1:end));

        % assign time of day and plate meta data
        meta.TimeofDay = repmat(tod,expmt.nTracks,1);
        meta.Plate = plate_map(expmt.labels_table.ID);

        switch expmt.Name
            case 'Circadian'
                meta.Box = arrayfun(@(x) ['circ-' num2str(x)],...
                    expmt.labels_table.Box,'UniformOutput',false);

            otherwise
                meta.Box = arrayfun(@(x) ['proj-' num2str(x)],...
                    expmt.labels_table.Box,'UniformOutput',false);
                meta.Tray = num2cell(num2str(expmt.labels_table.Tray),2);
        end
end
        
        