function posMatrix = generatePositionMatrix(startX, endX, startY, endY, gapX, gapY, numPlots)

% This function generates four element vectors for positioning axes using
% the above paprameters (all positioning parameters should be given normalized)
%
% Start and end designations are for all the plots together
%
% if the gap is 0 plots would be overlapping; if the gap is negative plots
% would tile the other dimension (e.g. negative gapY means horizontal placing)
% if both gaps are positive the function generates an NXM cell array with
% N = numplots(1) and M=numplots(2)


if gapX >=0 && gapY < 0
    posMatrix = zeros(numPlots, 4);
    widthX = (endX - startX - (numPlots-1)*gapX)/numPlots;
    if widthX <= 0
        error('Gap is too big for the X dimension')
    end
    posMatrix(1, :) = [startX, startY, widthX, endY-startY];
    
    for ii=2:numPlots
        posMatrix(ii, :) = [posMatrix(ii-1, 1)+widthX+gapX, startY, widthX, endY-startY];
    end
    
    
elseif gapX < 0 && gapY >= 0
    posMatrix = zeros(numPlots, 4);
    heightY = (endY - startY - (numPlots-1)*gapY)/numPlots;
    if heightY <= 0
        error('Gap is too big for the Y dimension')
    end
    posMatrix(1, :) = [startX, startY, endX-startX, heightY];
    
    for ii=2:numPlots
        posMatrix(ii, :) = [startX, posMatrix(ii-1, 2)+heightY+gapY, endX-startX, heightY];
    end
    
elseif gapX >= 0 && gapY >= 0
    if size(numPlots) == [1,2]
        posMatrix = cell(numPlots(1), numPlots(2));
        
        widthX = (endX - startX - (numPlots(1)-1)*gapX)/numPlots(1);
        heightY = (endY - startY - (numPlots(2)-1)*gapY)/numPlots(2);
        if heightY <= 0
        error('Gap is too big for the Y dimension')
        end
        if widthX <= 0
        error('Gap is too big for the X dimension')
        end
        
        posMatrix{1, 1} = [startX, startY, widthX, heightY];
        
        for ii=2:numPlots(1)
            posMatrix{ii, 1} = [posMatrix{ii-1, 1}(1)+widthX+gapX, ...
                                startY, widthX, heightY];
        end
        
        for jj=2:numPlots(2)
            posMatrix{1, jj} = [startX, ...
                                posMatrix{1,jj-1}(2)+heightY+gapY, ...
                                widthX, heightY];
        end
        
        for ii=2:numPlots(1)
            for jj=2:numPlots(2)
                posMatrix{ii,jj} = [posMatrix{ii-1, jj-1}(1)+widthX+gapX, ...
                                    posMatrix{ii-1, jj-1}(2)+heightY+gapY, ...
                                    widthX, heightY];
            end
        end
                
        
    else
        error('When both gaps are positive, numPlots should be a 1X2 vector')
    end
    
else
    error('Both gaps cannot be negative')
end
    


end

