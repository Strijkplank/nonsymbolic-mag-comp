function [thisRT, thisKey] =  DoTrial(params,d,FIXATION_DURATION,DEVICE,QUIT_RESP,ISI,allTrialsStruct,t,responseKeyList,ALLOW_QUIT,LEFT_RESP,RIGHT_RESP)

    
    
    % - DRAW A FIXATION CROSS
    fixationSize = round(5 * params.scaleFactor);
    
    Screen('DrawLine', d.window,[0 255 0],d.xCenter, d.yCenter-fixationSize,d.xCenter,d.yCenter+fixationSize,2);
    Screen('DrawLine', d.window,[0 255 0],d.xCenter-fixationSize,d.yCenter, d.xCenter+fixationSize, d.yCenter,2);
    Screen('Flip', d.window);
    WaitSecs(FIXATION_DURATION);
    
    % - load the texture
    thisTexture = Screen('MakeTexture',d.window,allTrialsStruct.stimulus{t});
    Screen('DrawTextures',d.window,thisTexture)
    
    % - put the fixation cross back
    Screen('DrawLine', d.window,[0 255 0],d.xCenter, d.yCenter-fixationSize,d.xCenter,d.yCenter+fixationSize,2);
    Screen('DrawLine', d.window,[0 255 0],d.xCenter-fixationSize,d.yCenter, d.xCenter+fixationSize, d.yCenter,2);
  
    
    
    KbQueueFlush([]); % flush the queue
    KbQueueStart([]); % start the queue
    
    Screen('Flip', d.window); % flip the stimulus
    
    stimOnset = GetSecs; % Measure time after flip
    
    pressed = 0;
    
    while pressed == 0
        [ pressed, firstPress] = KbQueueCheck([]); %  check if any key was pressed.
    end
    
    validResponses = firstPress(responseKeyList == 1);
    if ALLOW_QUIT == true
        CheckQuit(firstPress,QUIT_RESP)
    end
    
    
    thisRT =  (validResponses(validResponses > 0)) - stimOnset;
    
    switch KbName(find(firstPress > 0))
        case LEFT_RESP
            thisKey = 'left';
        case RIGHT_RESP
            thisKey = 'right';
        otherwise 
            thisKey = 'nr';
    end
    
    Screen('FillRect', d.window, d.black);
    Screen('Flip', d.window);
    WaitSecs(ISI);
end
