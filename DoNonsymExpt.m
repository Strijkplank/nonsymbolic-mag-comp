function DoNonsymExpt()

% SHORT VERSIONs

SKIP_SYNC = 0
ALLOW_QUIT = true;
thisDateString = datestr(now(),'DDMMYYhhmmss');

try
    
    %General questions to ask before hand
       fprintf('First some demographic questions.\n\n\n');
    
    subjdata.code = input('What is the participant number? ','s');
    
    subjdata.age = input('What is the participant age? ','s');
    
    subjdata.gender = input('What is the participant gender? ','s');
    
    
    subjdata.grade = input('What is the participant grade? ','s'); % grade
    
        
    subjdata.school = input('What is the participant code? ','s');% school
    
    subjdata.runtime = datestr(now,0);
    
    TASK_TYPE = 'full'; % the other option is 'partial' # should be 100 full and 100 partial

     CURRENT_FOLDER = cd;

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
    
    
    N_TRIALS = 160;
    PRAC_TRIALS = 20;

    N_BLOCKS = 4;
    
    BLOCK_BREAKS = (1:N_TRIALS/N_BLOCKS:N_TRIALS) - 1;
    BLOCK_BREAKS = BLOCK_BREAKS(BLOCK_BREAKS > 0);
    % Trial timing
    
    FIXATION_DURATION = 1;
    ISI = .5;
    
    % instructions etc
    
    MAIN_INSTRUCTIONS = 'Il tuo compito e'' di indicare in quale parte dello schermo appaiono piu'' pallini: se l''insieme piu'' numeroso e'' a sinistra premi il tasto (Z), se invece e'' a destra, premi il tasto (M). Cerca di rispondere il piu'' velocemente e accuratamente possibile.';
    PRAC_INSTRUCTIONS = 'Practice Trials';
    EXPT_INSTRUCTIONS = 'Experimental Trials';
    
    % response keys
    LEFT_RESP = 'z';
    RIGHT_RESP = 'm';
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
    %imageFiles = arrayfun(@(n) [imageDir filesep num2str(n) '.bmp'],1:N_TRIALS,'UniformOutput',false);
    
    % Preload the shuffling %
    
    imageInfoF = load([CURRENT_FOLDER filesep 'functions' filesep 'FullConditions.mat'],'-ASCII');
    imageInfoF = imageInfoF(1:200,:);        
    trialTokens = arrayfun(@(x,y,z) [num2str(x) '_' num2str(y) '_' num2str(z)], imageInfoF(:,3),imageInfoF(:,11),imageInfoF(:,18),'UniformOutput',false);
    trialTypes = unique(trialTokens);
    fullBlocks = cellfun(@(x) Shuffle(find(ismember(trialTokens,x))),trialTypes,'UniformOutput',false);
    
    
    
        
    imageInfoP = load([CURRENT_FOLDER filesep 'functions' filesep 'PartialConditions.mat'],'-ASCII');
    imageInfoP = imageInfoP(1:200,:);        
    trialTokens = arrayfun(@(x,y,z) [num2str(x) '_' num2str(y) '_' num2str(z)], imageInfoP(:,3),imageInfoP(:,11),imageInfoP(:,18),'UniformOutput',false);
    trialTypes = unique(trialTokens);
    partialBlocks = cellfun(@(x) Shuffle(find(ismember(trialTokens,x))),trialTypes,'UniformOutput',false);
    
    
    
    fb1 =  cell2mat(horzcat(arrayfun(@(i) fullBlocks{i}(1),1:length(fullBlocks),'UniformOutput',false)'));
    fb2 =  cell2mat(horzcat(arrayfun(@(i) fullBlocks{i}(2),1:length(fullBlocks),'UniformOutput',false)'));
    pb1 = cell2mat(horzcat(arrayfun(@(i) partialBlocks{i}(1),1:length(fullBlocks),'UniformOutput',false)'));
    pb2 = cell2mat(horzcat(arrayfun(@(i) partialBlocks{i}(2),1:length(fullBlocks),'UniformOutput',false)'));
    
   
    blockCodes = Shuffle({'fb1','fb2','pb1','pb2'});
    
    
    AllTrials = [];
    % -- %
   for bb = 1 : N_BLOCKS 
    trialStruct = {};
    
    TABLE_DESC_FILE = 'table_desc.txt';
    
    tableDesc = readtable([CURRENT_FOLDER filesep 'functions' filesep TABLE_DESC_FILE]);
    tableDesc.Properties.VariableNames([1:3]) = {'col','desc','label'};
    
    
    thisBlock = eval(blockCodes{bb});
    
    switch blockCodes{bb}
        case 'fb1'
            imageInfo = imageInfoF;
            TASK_TYPE = 'full';
        case 'fb2'
            imageInfo = imageInfoF;
            TASK_TYPE = 'full'
        case 'pb1'
            imageInfo = imageInfoP;
            TASK_TYPE = 'partial'
        case 'pb2'
            imageInfo = imageInfoP;
            TASK_TYPE = 'partial'
    end
    
    for ii = 1:length(thisBlock)
        i = thisBlock(ii);
        %origImg = imread(imageFiles{i});
        origImg =[];
        %[p, n, e] = fileparts(imageFiles{i});
        % -- Resize the images -- %
        %newImg = imresize(origImg, params.scaleFactor);
        newImg = [];
        
        % -- Put them in the trialStruct -- %
        
        trialStruct(ii).TASK_TYPE = TASK_TYPE;
        
        trialStruct(ii).origImg = origImg;
        trialStruct(ii).stimulus = newImg;
        
        trialStruct(ii).fileName = [];%[n e];
        trialStruct(ii).fullPath = [];%p;
        
        
        for t = 1 : height(tableDesc)
            trialStruct(ii).(tableDesc.label{t}) = imageInfo(i,tableDesc.col(t));
        end
        
    end
    
    
    
    % -- Randomise and build trial structure -- %
    
    trialStruct = struct2table(trialStruct);
    AllTrials = vertcat(AllTrials,trialStruct);
    
    end
    
    AllTrials.fullPath = cellfun(@(x,y) [CURRENT_FOLDER filesep 'functions' filesep 'images' filesep x '400N' filesep y '.bmp'],...
        AllTrials.TASK_TYPE,arrayfun(@(x) num2str(x),AllTrials.imageNumber,'UniformOutput',false),...
        'UniformOutput',false);
    
    AllTrials.fileName = AllTrials.fullPath;
    
    for i = 1 : height(AllTrials)
        origImg = imread(AllTrials.fullPath{i});
        newImg =  imresize(origImg, params.scaleFactor);
        AllTrials.origImg{i} =  origImg;
        AllTrials.stimulus{i} = newImg;
    end

    trialStruct = AllTrials;
    
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
    
    
    trialTokens  = arrayfun(@(x,y,z,q) strcat(num2str(x,'%.1f'), '_', num2str(y), '_', num2str(z), '_', q), trialStruct.ratio, trialStruct.congruency, trialStruct.correctResp, trialStruct.TASK_TYPE,'UniformOutput',false);
    trialTokens = cellfun(@(x) x,trialTokens);
    trialTypes = unique(trialTokens);
    
    orders = arrayfun(@(x) find(ismember(trialTokens,trialTypes{x}))',1:length(trialTypes),'UniformOutput',false)';
    orders = cell2mat(orders);
    
    for i = 1 : N_BLOCKS
        orders(:,i) = Shuffle(orders(:,i));
    end
    
    orders = reshape(orders,N_TRIALS,1);
    
    trialStruct = trialStruct(orders,:);
    
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
    
    KbQueueCreate([],responseKeyList)
    
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
    
    KbQueueRelease([]);
    KbQueueStop([]);
    
    %% --- EXPT TRIALS
    
    % - EXPT INSTRUCTIONS
    
    DrawFormattedText(d.window,  EXPT_INSTRUCTIONS, 'center', 'center', d.white, textWrap,[],[],vSpacing);
    Screen('Flip', d.window);
    spaceKeyList = zeros(1,256);
    spaceKeyList(KbName('SPACE')) = 1;
    PressToGo(DEVICE,spaceKeyList)
    
    KbQueueCreate([],responseKeyList)
    
    
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
            KbQueueRelease([]);
            KbQueueStop([]);
            DrawFormattedText(d.window,  ['END OF BLOCK' num2str(find(t == BLOCK_BREAKS))], 'center', 'center', d.white, textWrap,[],[],vSpacing);
            Screen('Flip', d.window);
            spaceKeyList = zeros(1,256);
            spaceKeyList(KbName('SPACE')) = 1;
            PressToGo(DEVICE,spaceKeyList)
            KbQueueCreate([],responseKeyList)
            
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
   % ListenChar;
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

