function stimProps=optoDispBlackWhiteStim(stimProps,stimOFF)

    % Adjust source rects by stimulus angle
    tmpSrc=zeros(size(stimProps.srcRect));
    tmpSrc([2 4],:)=stimProps.srcRect([2 4],:);
    tmpSrc([1 3],stimProps.angle==0)=stimProps.srcRect([1 3],stimProps.angle==0)+0.34*stimProps.stimOffset;
    tmpSrc([1 3],stimProps.angle==180)=stimProps.srcRect([1 3],stimProps.angle==180)-0.34*stimProps.stimOffset;
    tmpSrc([1 3],stimProps.angle==66)=stimProps.srcRect([1 3],stimProps.angle==66)+0.00*stimProps.stimOffset;
    tmpSrc([1 3],stimProps.angle==242)=stimProps.srcRect([1 3],stimProps.angle==242)-0.00*stimProps.stimOffset;
    tmpSrc([1 3],stimProps.angle==115)=stimProps.srcRect([1 3],stimProps.angle==115)-0.35*stimProps.stimOffset;
    tmpSrc([1 3],stimProps.angle==295)=stimProps.srcRect([1 3],stimProps.angle==295)+0.35*stimProps.stimOffset;

    % Update the brightness of each ROIs stimulus
    stimProps.color(2,:)=stimProps.color(2,:)+0.01;
    stimProps.color(2,stimProps.color(2,:)>1)=1;
    stimProps.color(2,stimOFF)=0;
    
    %% Batch Draw all of the texures to screen

    % Batch Draw all of the texures to screen
    Screen('DrawTextures', stimProps.window, stimProps.Rtex, tmpSrc, stimProps.dsRects, stimProps.angle,...
        [], [], stimProps.color,[], kPsychUseTextureMatrixForRotation);

    % Flip to the screen
    Screen('Flip', stimProps.window);
    
end