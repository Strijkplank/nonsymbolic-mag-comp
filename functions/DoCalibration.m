function DoCalibration()
try
    clc
    commandwindow; % give focus to the command window
    
    % CalcNewImageScaleFactor
    
    ORIGINAL_PX_WIDTH = 1175;
    ORIGINAL_PX_HEIGHT = 575;
    
    
    ORIGINAL_MM_WIDTH = 334;
    ORIGINAL_MM_HEIGHT = 163;
    
    NEW_MM_WIDTH = 10;
    NEW_MM_HEIGHT = 10;
    
    DEV_MODE = 1;
    
    %% -- Main function -- %%
    
    % -- check whether a calibration file already exists -- %
    if exist([cd filesep 'functions/params.mat'],'file') == 2
        
        warning('This system already appears to be calibrated')
        
        while 1
            resp = input('Are you sure you want to continue? (Y/N): ','s');
            
            switch upper(resp(1))
                case 'N'
                    error('Calibrate:quitEarly','Aborted!')
                    
                case 'Y'
                    warning('overwriting the parameters file...')
                    break
                    
                otherwise
                    disp('Not a valid response!')
            end
        end
    end
    

    % -- take care of some PTB stuff -- %
    KbName('UnifyKeyNames')
    
    Screen('Preference', 'SkipSyncTests', DEV_MODE);
    
    % -- Set the keys -- %
    ESCAPE_KEY = KbName('ESCAPE');
    UP_KEY = KbName('UpArrow');
    DOWN_KEY = KbName('DownArrow');
    LEFT_KEY = KbName('LeftArrow');
    RIGHT_KEY = KbName('RightArrow');
    
    % -- use some PTB default settings -- %
    PsychDefaultSetup(2);
    
    screens = Screen('Screens');
    
    screenNumber = min(screens);
    
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    
    % Open an on screen window
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
    
    HideCursor();
    ListenChar(-1);
    
    % give the instructions
    Screen('TextSize',window,24);
    
    DrawFormattedText(window,[...
        'Use the arrow keys to resize the box so that it measures ' ...
        num2str(NEW_MM_HEIGHT / 10) ' cm x ' num2str(NEW_MM_WIDTH / 10) ' cm' '\n\n' ....
        'Press ESC once complete.' '\n\n' ...
        'Note that you will have two attempts to ensure accuracy.' '\n\n' ...
        'Press any key to continue'], ...
        'center','center',[1 1 1], 80);
    
    Screen('Flip',window);
    KbWait();
    
    
    % -- now do the actual calibration -- %
    
    % draw the box
    
    [xCenter, yCenter] = RectCenter(windowRect);
    rectWidth = 100;
    rectHeight = 100;
    baseRect = [0 0 rectWidth rectHeight];
    rect = CenterRectOnPointd(baseRect, xCenter, yCenter);
    Screen('FillRect', window, [1 1 1], rect);
    Screen('Flip', window);
    
    % resize the box
    
    attempts = 0;
    
    sizeparams = {};
    
    KbQueueCreate();
    KbQueueStart();
    
    while attempts < 2
        
        while  1
            
            [pressed, firstPress] = KbQueueCheck();
            
            firstPress(firstPress==0)=NaN; %little trick to get rid of 0s
            [endtime, keyCode]=min(firstPress); % gets the RT of the first key-press and its ID
            
            switch keyCode
                case ESCAPE_KEY
                    attempts = attempts + 1;
                    sizeparams(attempts).rectWidth = rectWidth;
                    sizeparams(attempts).rectHeight = rectHeight;
                    rectWidth = 100;
                    rectHeight = 100;
                    break
                case UP_KEY
                    rectHeight = rectHeight + 1;
                case DOWN_KEY
                    rectHeight = rectHeight - 1;
                case LEFT_KEY
                    rectWidth = rectWidth - 1;
                case RIGHT_KEY
                    rectWidth = rectWidth + 1;
            end
            
            
            baseRect = [0 0 rectWidth rectHeight];
            rect = CenterRectOnPointd(baseRect, xCenter, yCenter);
            Screen('FillRect', window, [1 1 1], rect);
            Screen('Flip', window);
            
            
        end
        
    end
    
    
    
    
    
    
    
    sca;
    ShowCursor;
    ListenChar(0);
    
    % -- now do the calculations -- %
    clc
    clc
    disp(' ');disp(' ');disp(' ');disp(' ');disp(' ');
    disp('Now doing the calculations...');
    
    widths = horzcat(sizeparams(:).rectWidth);
    heights = horzcat(sizeparams(:).rectHeight);
    meanWidth = mean(widths);
    meanHeight = mean(heights);
    
    disp(['The box height was ' num2str(meanWidth) ' pixels (range: ' num2str(min(widths)) '-' num2str(max(widths)) ')'])
    disp(['The box height was ' num2str(meanHeight) ' pixels (range: ' num2str(min(heights)) '-' num2str(max(heights)) ')'])
    
    while 1
        resp = input('Do you want to accept these values (Y/N): ','s');
        
        switch upper(resp(1))
            case 'N'
                error('Calibrate:redo','Aborted!')
                
            case 'Y'
                disp('Writing the parameters file...')
                break
                
            otherwise
                disp('Not a valid response!')
        end
    end
    
catch ERROR_MSG
    sca;
    disp(ERROR_MSG.message)
    ShowCursor();
    ListenChar(0);
    
end


ORIGINAL_DOTSIZE_WIDTH = ORIGINAL_MM_WIDTH / ORIGINAL_PX_WIDTH;
ORIGINAL_DOTSIZE_HEIGHT = ORIGINAL_MM_HEIGHT / ORIGINAL_PX_HEIGHT;

new_Dotsize_Width = NEW_MM_WIDTH / meanWidth;
new_Dotsize_Height = NEW_MM_HEIGHT / meanHeight;

new_Px_Width = round(ORIGINAL_MM_WIDTH / new_Dotsize_Width);
new_Px_Height = round(ORIGINAL_MM_HEIGHT / new_Dotsize_Height);

widthScaleFactor = new_Px_Width / ORIGINAL_PX_WIDTH;
heightScaleFactor = new_Px_Height / ORIGINAL_PX_HEIGHT;

scaleFactor = mean([widthScaleFactor heightScaleFactor]);

% -- now save out the params -- %
params.scaleFactor = scaleFactor;
params.ToUse = device;

SaveWS;
params.rawInfo = ws;


save([cd '/functions/params.mat'], 'params')