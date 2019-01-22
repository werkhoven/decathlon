    %Update the yCoordinate
    counter = counter + 1;
    yPos = rem(counter,20) - 10;
    yPos = yPos:20:778;
    
    
    % Make our rectangle coordinates
    allRects = nan(4, length(yPos));
    for i = 1:length(yPos)
        allRects(:, i) = CenterRectOnPointd(baseRect, xCenter, yPos(i));
    end
    
    for i = 1:length(yPos)
        
        if allRects(2,i) < 0
            allRects(2,i) = 0;
        else if allRects(4,i) > 768
            allRects(4,i) = 768;
            end
        end
    end
    
        color_checker = rem(counter,40);
    if (0 <= color_checker) && (color_checker <= 19)
        current_colors = red_first_colors(:,1:length(allRects));
        color = 'red'
    else if (20 <= color_checker) && (color_checker <= 40)
        current_colors = magenta_first_colors(:,1:length(allRects));
        color = 'magenta'
    %else if (color_checker == 0)
       % current_colors = magenta_first_colors(:,1:length(allRects));
        %color = 'magenta'
    % end
    end
    end
    
    allRects
    counter
    color
    yPos