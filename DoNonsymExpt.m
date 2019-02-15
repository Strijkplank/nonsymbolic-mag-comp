function DoNonsymExpt()

SKIP_SYNC = 0
ALLOW_QUIT = true;
thisDateString = datestr(now(),'DDMMYYhhmmss');

try
    
    %General questions to ask before hand
       fprintf('First some demographic questions.\n\n\n');
    
    subjdata.code = input('Wat is uw proefpersoon-nummer?');
    
    subjdata.age = input('Wat is uw leeftijd?');
    
    subjdata.gender = input('Wat is uw geslacht? Gelieve M voor Mannelijk, of V voor Vrouwelijk in te geven. ','s');
    
    subjdata.code = 'Leuven'
    
    subjdata.grade = 'Adult'
    
    subjdata.runtime = datestr(now,0);
    
    TASK_TYPE = 'full'; % the other option is 'partial'
    
    CURRENT_FOLDER = cd;
    commandwindow;
    HideCursor
   
    
    
    
    try
        addpath([CURRENT_FOLDER filesep 'functions' filesep 'my-ptb-funcs'])
        addpath([CURRENT_FOLDER filesep 'functions'])
    catch ME
        error('Make sure you''re in the corret folder')
    end
    
    % --          EXPERIMENT DETAILS               -- %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % task type and trial number
    
    TASK_TYPE = 'full'; % the other option is 'partial' # should be 100 full and 100 partial
    N_TRIALS = 200;
    PRAC_TRIALS = 40;
    CURRENT_FOLDER = cd;
    N_BLOCKS = 5;
    
    BLOCK_BREAKS = (1:N_TRIALS/N_BLOCKS:N_TRIALS) - 1;
    BLOCK_BREAKS = BLOCK_BREAKS(BLOCK_BREAKS > 0);
    % Trial timing
    
    FIXATION_DURATION = 1;
    ISI = .5;
    
    % instructions etc
    
    MAIN_INSTRUCTIONS = 'In deze taak zult u verschillende afbeeldingen zien'' In deze afbeeldingen zult u twee verschillende puntenwolken zien'' Het is de bedoeling dat u aangeeft in welke van de twee er MEER punten zijn.'' Indien er meer punten zijn in het linkse puntenwolk, dien je op de f toets te drukken.''Indien er meer punten zijn in het rechtse puntenwolk, dien je op de j toets te drukken''Probeer zo snel en accuraat mogelijk te antwoorden';

    PRAC_INSTRUCTIONS = 'Practice Trials';
    EXPT_INSTRUCTIONS = 'Experimental Trials';
    
    % response keys
    LEFT_RESP = 'f';
    RIGHT_RESP = 'j';
    SPACE_RESP = 'SPACE';
    QUIT_RESP = 'q';
    
    responseKeyList = zeros(256,1);
    responseKeyList(KbName(LEFT_RESP)) = 1;
    responseKeyList(KbName(RIGHT_RESP)) = 1;
    if ALLOW_QUIT == true
        responseKeyList(KbName(QUIT_RESP)) = 1;
    end
    
    spaceKeyList = zeros(1,256);
    spaceKeyList(KbName(SPACE_RESP)) = 1;
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% -- Load the params -- %%
    
    load([CURRENT_FOLDER '/functions/params.mat'])
    
    
    
    if length(GetKeyboardIndices) == 1
        DEVICE = GetKeyboardIndices;
    else
        DEVICE = load('keyboard.ini','-ASCII');
    end
    
    SCALE_FACTOR = params.scaleFactor;
    
    %% -- Load the image files -- %%
    
    
    imageDir = [CURRENT_FOLDER filesep 'functions' filesep 'images' filesep TASK_TYPE '400N'];
    imageFiles = arrayfun(@(n) [imageDir filesep num2str(n) '.bmp'],1:N_TRIALS,'UniformOutput',false);
    
    switch TASK_TYPE
        case 'full'
            imageInfo = load([CURRENT_FOLDER filesep 'functions' filesep 'FullConditions.mat'],'-ASCII');
            imageInfo = imageInfo(1:200,:);
            
            
        case 'partial'
            imageInfo = load([CURRENT_FOLDER filesep 'functions' filesep 'PartialConditions.mat'],'-ASCII');
            imageInfo = imageInfo(1:200,:);
    end
    
    % Preload the shuffling %
    
    % This is ridiculous ineffecient. I should fix it.
    trialTypes = unique(arrayfun(@(x,y) [num2str(x) '_' num2str(y)],imageInfo(:,3), imageInfo(:,11),'UniformOutput',false));
    trialTypes = [trialTypes; trialTypes];
    trialTokens = arrayfun(@(x,y) [num2str(x) '_' num2str(y)],imageInfo(:,3), imageInfo(:,11),'UniformOutput',false);
    trialNumbers = 1: N_TRIALS;
    shuffled = [];
    while length(trialTokens) > 0
        
        for type = 1 : length(trialTypes)
            
            thisType = trialTypes(type);
            tokenValues = find(ismember(trialTokens,thisType));
            tokenValues = tokenValues(randperm(length(tokenValues),length(tokenValues)));
            thisValue = tokenValues(1);
            shuffled = [shuffled; trialNumbers(thisValue)];
            trialTokens(thisValue) = [];
            trialNumbers(thisValue) = [];
        end
    end
    % -- %
    trialStruct = {};
    
    TABLE_DESC_FILE = 'table_desc.txt';
    
    tableDesc = readtable([CURRENT_FOLDER filesep 'functions' filesep TABLE_DESC_FILE]);
    tableDesc.Properties.VariableNames([1:3]) = {'col','desc','label'};
    
    
    for i = 1 : N_TRIALS
        origImg = imread(imageFiles{i});
        
        [p, n, e] = fileparts(imageFiles{i});
        % -- Resize the images -- %
        newImg = imresize(origImg, params.scaleFactor);
        
        
        % -- Put them in the trialStruct -- %
        
        trialStruct(i).TASK_TYPE = TASK_TYPE;
        
        trialStruct(i).origImg = origImg;
        trialStruct(i).stimulus = newImg;
        
        trialStruct(i).fileName = [n e];
        trialStruct(i).fullPath = p;
        
        
        for t = 1 : height(tableDesc)
            trialStruct(i).(tableDesc.label{t}) = imageInfo(i,tableDesc.col(t));
        end
        
    end
    
    
    
    % -- Randomise and build trial structure -- %
    
    
    
    trialStruct = struct2table(trialStruct);
    trialStruct = trialStruct(shuffled,:);
    trialStruct.trialNumber = [1:N_TRIALS]'; % the the trial number
    
    % -- Now add the descriptions -- %
    
    for t = 1 : height(tableDesc)
        trialStruct.Properties.VariableDescriptions{tableDesc.label{t}} = tableDesc.desc{t};
    end
    
    trialStruct.Properties.VariableDescriptions{'TASK_TYPE'} = 'For the full condition, congruent means: larger number with larger sensory cues for the partial condition, congruent means: larger number with larger convex hull but smaller diameter, smaller surface, smaller contour length and less dense';
    trialStruct.Properties.VariableDescriptions{'fileName'} = 'filename of the image';
    trialStruct.Properties.VariableDescriptions{'fullPath'} = 'full path where the image was read from';
    
    trialStruct.Properties.VariableDescriptions{'origImg'} = 'matrix of the original image';
    trialStruct.Properties.VariableDescriptions{'stimulus'} = 'matrix of the resized image';
    
    trialStruct.trialType = repmat('exp',height(trialStruct),1);
    
    trialStruct.Properties.VariableDescriptions{'trialType'} = 'prac trial or experimental trial';
    
    
    % -- -- %
    
    
    % -- Now add the 40 practise trials
    
    pracStruct = MakePrac(TASK_TYPE,TABLE_DESC_FILE,PRAC_TRIALS,CURRENT_FOLDER,params.scaleFactor);
    
    % Now concatenate them
    
    
    %% -- Main Experiment -- %%
    
    % -- PTB Prelim -- %
    
    % Check the keyboard
    
    %WaitSecs(.5);
    %clc
    %disp('Checking keyboard.....PRESS A KEY TO CONTINUE')
    %[~, keyCode, ~] = KbWait(DEVICE,[],GetSecs() + 5);
    
    %if any(keyCode) == false
    %    warning('Either the keyboard isn''t working or you didn''t press a key!');
    %    warning('I''ll run the keyboard setup again')
    %    DoKeyboardSetup
    %end
    
    % Entering participant information
    
    thisDateString = datestr(now(),'DDMMYYhhmmss');
    
    
    
    %% -- Initialise PTB -- %%
    
    [d,ME] = IntializeDisplay(SKIP_SYNC);
    
    % -- Give the instructions -- %
    
    
    
    fontSize = 30  ;
    textWrap = 50      ; % replace with a function that gets the optimal wrapping based on a font size
    vSpacing = 1.5  ;
    
    Screen('TextSize',d.window,fontSize);
    
    DrawFormattedText(d.window,  MAIN_INSTRUCTIONS, 'center', 'center', d.white, textWrap,[],[],vSpacing);
    Screen('Flip', d.window);
    
    PressToGo(DEVICE,spaceKeyList)
    
    
    %% -- Main Experiment LOOP -- %%
    
    
    
    
    
    %% --- PRAC TRIALS
    
    % - PRAC INSTRUCTIONS
    DrawFormattedText(d.window,  PRAC_INSTRUCTIONS, 'center', 'center', d.white, textWrap,[],[],vSpacing);
    Screen('Flip', d.window);
    spaceKeyList = zeros(1,256);
    spaceKeyList(KbName('SPACE')) = 1;
    PressToGo(DEVICE,spaceKeyList)
    
    KbQueueCreate(DEVICE,responseKeyList)
    
    pracStruct.key = repmat({0},height(pracStruct),1);
    pracStruct.trial = zeros(height(pracStruct),1);
    pracStruct.RT = zeros(height(pracStruct),1);
    
    pracStruct.Properties.VariableDescriptions{'key'} = 'the response made by the participant';
    pracStruct.Properties.VariableDescriptions{'trial'} = 'trial number. only really useful during testing';
    pracStruct.Properties.VariableDescriptions{'RT'} = 'the response time in seconds';
    
    for t = 1 : PRAC_TRIALS
        
        [thisRT, thisKey] =  DoTrial(params,d,FIXATION_DURATION,...
            DEVICE,QUIT_RESP,ISI,pracStruct,t,responseKeyList,...
            ALLOW_QUIT,LEFT_RESP,RIGHT_RESP);
        
        pracStruct.trial(t) =  t;
        pracStruct.key{t} = thisKey;
        pracStruct.RT(t) = thisRT;
    end
    
    KbQueueRelease(DEVICE);
    KbQueueStop(DEVICE);
    
    %% --- EXPT TRIALS
    
    % - EXPT INSTRUCTIONS
    
    DrawFormattedText(d.window,  EXPT_INSTRUCTIONS, 'center', 'center', d.white, textWrap,[],[],vSpacing);
    Screen('Flip', d.window);
    spaceKeyList = zeros(1,256);
    spaceKeyList(KbName('SPACE')) = 1;
    PressToGo(DEVICE,spaceKeyList)
    
    KbQueueCreate(DEVICE,responseKeyList)
    
    
    trialStruct.key = repmat({0},height(trialStruct),1);
    trialStruct.trial = zeros(height(trialStruct),1);
    trialStruct.RT = zeros(height(trialStruct),1);
    
    trialStruct.Properties.VariableDescriptions{'key'} = 'the response made by the participant';
    trialStruct.Properties.VariableDescriptions{'trial'} = 'trial number. only really useful during testing';
    trialStruct.Properties.VariableDescriptions{'RT'} = 'the response time in seconds';
    
    
    missedTrials = 0;
    
    for t = 1: N_TRIALS
        
        [thisRT, thisKey] =  DoTrial(params,d,FIXATION_DURATION,...
            DEVICE,QUIT_RESP,ISI,trialStruct,t,responseKeyList,...
            ALLOW_QUIT,LEFT_RESP,RIGHT_RESP);
        
        
        if strcmp(thisKey,'nr')
            missedTrials = missedTrials + 1;
        else 
            missedTrials = 0;
        end
        
        if missedTrials > 5
           error('Too many mised trials')
        end
        
        trialStruct.trial(t) =  t;
        trialStruct.key{t} = thisKey;
        trialStruct.RT(t) = thisRT;
        
        if any(t == BLOCK_BREAKS) == 1
            % Reached the end of a block
            KbQueueRelease(DEVICE);
            KbQueueStop(DEVICE);
            DrawFormattedText(d.window,  ['END OF BLOCK' num2str(find(t == BLOCK_BREAKS))], 'center', 'center', d.white, textWrap,[],[],vSpacing);
            Screen('Flip', d.window);
            spaceKeyList = zeros(1,256);
            spaceKeyList(KbName('SPACE')) = 1;
            PressToGo(DEVICE,spaceKeyList)
            KbQueueCreate(DEVICE,responseKeyList)
            
        end
        
    end
    
    DrawFormattedText(d.window,  'THE END', 'center', 'center', d.white, textWrap,[],[],vSpacing);
    Screen('Flip', d.window);
    WaitSecs(2);
    sca;
    
    %% -- save everything out! -- %
    SaveWS
    SubjectData.rawInfo = ws;
    ws = rmfield(ws,'trialStruct');
    ws = rmfield(ws,'pracStruct');
    SubjectData.trialStruct = trialStruct;
    SubjectData.pracStruct = pracStruct;
    SubjectData.subjInfo = subjdata;
    
    if exist('data','dir')==0
        mkdir('data')
    end
    
    save(['data/',subjdata.code,'_' thisDateString '_data.mat'],'SubjectData','-v7.3');
    
catch ME
    sca
    ShowCursor;
    ListenChar;
    disp(ME.stack)
    SaveWS
    errorData.subjInfo = subjdata;
    errorData.rawInfo = ws;
    
    
    if exist('error','dir')==0
        mkdir('error')
    end
    save(['error/',subjdata.code,'_' thisDateString '_error.mat'],'errorData','-v7.3');
    
end

ShowCursor;
ListenChar;

